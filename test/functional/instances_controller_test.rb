require File.dirname(__FILE__) + '/../test_helper'
require 'instances_controller'

# Re-raise errors caught by the controller.
class InstancesController; def rescue_action(e) raise e end; end

class InstancesControllerTest < ActionController::TestCase
  fixtures :applis, :instances, :servers, :issues, :users
  
  def setup
    @controller = InstancesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
    #adds correct modules / permissions for the plugin
    #TODO: DRY it !
    Role.find(1).add_permission! :view_datacenter, :manage_datacenter
    p = Project.find(1)
    p.enabled_module_names = p.enabled_modules.map(&:name) << "datacenter"
  end
  
  def test_new
    get :new, :appli_id => 1, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_invalid
    Instance.any_instance.stubs(:valid?).returns(false)
    post :create, :appli_id => 1, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_valid
    Instance.any_instance.stubs(:valid?).returns(true)
    post :create, :appli_id => 1, :project_id => 1
    assert_redirected_to "/projects/ecookbook/applis/1"
  end
  
  def test_edit
    get :edit, :id => Instance.first, :appli_id => 1, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_invalid
    Instance.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Instance.first, :appli_id => 1, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_valid
    Instance.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Instance.first, :appli_id => 1, :project_id => 1
    assert_redirected_to "/projects/ecookbook/applis/1"
  end
  
  def test_destroy
    instance = Instance.first
    delete :destroy, :id => instance, :appli_id => 1, :project_id => 1
    assert_redirected_to "/projects/ecookbook/applis/1"
    instance.reload
    assert Instance.exists?(instance.id)
    assert_equal Instance::STATUS_LOCKED, instance.status
  end

  def test_select_servers
    #we should do "xhr :get", but it's not easy to parse Element.update's content..
    get :select_servers, :project_id => 1, :ids => "Appli:1,Instance:1,Instance:9999,Dummy"
    assert_tag :select, :attributes => {:id => 'issue_server_ids'}, :children => {:count => 4}
    assert_tag :option, :attributes => {:value => "1", :selected => "selected"}
    assert_tag :option, :attributes => {:value => "2", :selected => nil}
  end
end
