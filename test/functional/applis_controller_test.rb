require File.dirname(__FILE__) + '/../test_helper'
require 'applis_controller'

# Re-raise errors caught by the controller.
class ApplisController; def rescue_action(e) raise e end; end

class ApplisControllerTest < ActionController::TestCase
  fixtures :applis, :servers, :issues, :users, :projects
  
  def setup
    @controller = ApplisController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 2 # not admin
    #adds correct modules / permissions for the plugin
    #TODO: DRY it !
    Role.find(1).add_permission! :view_datacenter, :manage_datacenter
    p = Project.find(1)
    p.enabled_module_names = p.enabled_modules.map(&:name) << "datacenter"
  end
  
  def test_module_enabled_and_user_has_permissions
    project = Project.find(1)
    assert project.module_enabled?(:datacenter)
    assert User.current.allowed_to?(:view_datacenter, project)
    assert User.current.allowed_to?(:manage_datacenter, project)
  end

  def test_index
    get :index, :project_id => 1
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => 2, :project_id => 1
    assert_template 'show'
    #Appli(2) has Instance(4)
    #Issue(2) linked to Appli(2)
    #Issue(3) linked to Instance(4)
    assert_tag :tr, :attributes => {:id => 'issue-2'}
    assert_tag :tr, :attributes => {:id => 'issue-3'}
  end

  def test_show_filter_does_not_interfer_if_incorrect
    params = {:id => 2, :project_id => 1, :filter => 'dummy'}
    get :show, params.merge(:filter => 'dummy')
    assert_tag :tr, :attributes => {:id => 'issue-2'}
    assert_tag :tr, :attributes => {:id => 'issue-3'}
    get :show, params.merge(:filter => 'Appli')
    assert_tag :tr, :attributes => {:id => 'issue-2'}
    assert_no_tag :tr, :attributes => {:id => 'issue-3'}
    get :show, params.merge(:filter => 'Instance:4')
    assert_no_tag :tr, :attributes => {:id => 'issue-2'}
    assert_tag :tr, :attributes => {:id => 'issue-3'}
  end

  def test_cannot_show_appli_from_other_project
    appli = Appli.find(3)
    assert_equal 2, appli.datacenter.project_id
    get :show, :id => 3, :project_id => 1
    assert_response 404
  end

  def test_show_includes_related_issues
    get :show, :id => Appli.find(2), :project_id => 1
    assert_tag :tr, :attributes => {:id => 'issue-2'} #Issue(2) linked to Appli(2)
    assert_tag :tr, :attributes => {:id => 'issue-3'} #Issue(3) linked to Instance(4) linked tp Appli(2)
  end
  
  def test_new
    get :new, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_invalid
    Appli.any_instance.stubs(:valid?).returns(false)
    post :create, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_valid
    Appli.any_instance.stubs(:valid?).returns(true)
    post :create, :project_id => 1
    assert_redirected_to "/projects/ecookbook/applis/#{assigns(:appli).id}"
  end
  
  def test_edit
    get :edit, :id => Appli.first, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_invalid
    Appli.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Appli.first, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_valid
    Appli.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Appli.first, :project_id => 1
    assert_redirected_to '/projects/ecookbook/applis/1'
  end
  
  def test_destroy
    appli = Appli.first
    delete :destroy, :id => appli, :project_id => 1
    assert_redirected_to '/projects/ecookbook/applis'
    appli.reload
    assert Appli.exists?(appli.id)
    assert_equal Appli::STATUS_LOCKED, appli.status
  end
end
