require File.dirname(__FILE__) + '/../test_helper'
require 'servers_controller'

# Re-raise errors caught by the controller.
class ServersController; def rescue_action(e) raise e end; end

class ServersControllerTest < ActionController::TestCase
  fixtures :servers, :issues, :users

  def setup
    @controller = ServersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
    Setting["plugin_datacenter_plugin"]["domain"] = ".example.com"
  end
  
  def test_non_admin_user_should_be_dropped_out_on_admin_actions
    @request.session[:user_id] = 2
    get :index
    assert_response :success
    get :edit, :id => Server.first
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
    Server.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Server.any_instance.stubs(:valid?).returns(true)
    post :create, :server => {:name => "myserver"}
    assert_redirected_to server_url(assigns(:server))
    server = Server.find_by_name("myserver")
    assert_not_nil server
    assert_equal "myserver.example.com", server.fqdn
  end
  
  def test_edit
    get :edit, :id => Server.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Server.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Server.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Server.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Server.first
    assert_redirected_to server_url(assigns(:server))
  end
  
  def test_destroy
    server = Server.first
    delete :destroy, :id => server
    assert_redirected_to servers_url
    assert !Server.exists?(server.id)
  end
end
