require File.dirname(__FILE__) + '/../test_helper'
require 'datacenters_controller'

# Re-raise errors caught by the controller.
class DatacentersController; def rescue_action(e) raise e end; end

class DatacentersControllerTest < ActionController::TestCase
  fixtures :datacenters, :issues, :users

  def setup
    @controller = DatacentersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
    Setting["plugin_datacenter_plugin"]["domain"] = ".example.com"
  end
  
  def test_non_admin_user_should_be_dropped_out_on_admin_actions
    @request.session[:user_id] = 2
    get :index
    assert_response :success
    get :edit, :id => Datacenter.first
    assert_response 403
  end

  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Datacenter.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Datacenter.any_instance.stubs(:valid?).returns(true)
    post :create, :datacenter => {:name => "mydatacenter"}
    assert_redirected_to datacenter_url(assigns(:datacenter))
    datacenter = Datacenter.find_by_name("myserver")
    assert_not_nil datacenter
    assert_equal "mydatacenter.example.com", datacenter.fqdn
  end
  
  def test_edit
    get :edit, :id => datacenter.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Datacenter.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Datacenter.first.id, :datacenter => {}
    assert_template 'edit'
  end
  
  def test_update_valid
    Datacenter.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Datacenter.first.id, :datacenter => {}
    assert_redirected_to datacenter_url(assigns(:datacenter))
  end
  
  def test_destroy
    datacenter = Datacenter.first
    delete :destroy, :id => datacenter
    assert_redirected_to datacenters_url
    datacenter.reload
    assert Datacenter.exists?(datacenter.id)
    assert_equal Datacenter::STATUS_LOCKED, datacenter.status
  end
end
