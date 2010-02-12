require File.dirname(__FILE__) + '/../test_helper'
require 'datacenters_controller'

# Re-raise errors caught by the controller.
class DatacentersController; def rescue_action(e) raise e end; end

class DatacentersControllerTest < ActionController::TestCase
  fixtures :datacenters, :issues, :users

  def setup
    #@controller = DatacentersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
    Setting["plugin_datacenter_plugin"]["domain"] = ".example.com"
  end
  
  def test_non_admin_user_should_be_dropped_out_on_admin_actions
    @request.session[:user_id] = 2
    get :show, :project_id => 1
    assert_response :success
    get :edit, :project_id => 1
    assert_response 403
  end

  def test_index
    get :show, :project_id => 1
    assert_template 'show'
  end

  def test_index_with_project_routing
    assert_routing({:method => :get, :path => '/projects/23/datacenter'},
                   :controller => 'datacenters', :action => 'show', :project_id => '23')
  end

  
  def test_new
    get :new, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_invalid
    Datacenter.any_instance.stubs(:valid?).returns(false)
    post :create, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_valid
    Datacenter.any_instance.stubs(:valid?).returns(true)
    post :create, :datacenter => {:name => "mydatacenter", :project_id => 1}, :project_id => 1
    assert_redirected_to '/projects/ecookbook/datacenter'
    datacenter = Datacenter.find_by_name("mydatacenter")
    assert_not_nil datacenter
    assert_equal 1, datacenter.project_id
  end
  
  def test_edit
    get :edit, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_invalid
    Datacenter.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Datacenter.first.id, :datacenter => {}, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_valid
    Datacenter.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Datacenter.first.id, :datacenter => {}, :project_id => 1
    assert_redirected_to '/projects/ecookbook/datacenter'
  end
  
  def test_destroy
    datacenter = Datacenter.find(1)
    assert_equal datacenter.project_id, 1
    delete :destroy, :project_id => 1
    assert_redirected_to '/projects/ecookbook/datacenter'
    datacenter.reload
    assert Datacenter.exists?(1)
    assert_equal Datacenter::STATUS_LOCKED, datacenter.status
  end
end
