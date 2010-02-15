require File.dirname(__FILE__) + '/../test_helper'
require 'networks_controller'

# Re-raise errors caught by the controller.
class NetworksController; def rescue_action(e) raise e end; end

class NetworksControllerTest < ActionController::TestCase
  fixtures :networks, :issues, :users, :projects, :datacenters

  def setup
    @controller = NetworksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
    #adds correct modules / permissions for the plugin
    #TODO: DRY it !
    Role.find(1).add_permission! :view_datacenter, :manage_datacenter
    p = Project.find(1)
    p.enabled_module_names = p.enabled_modules.map(&:name) << "datacenter"
  end
  
  def test_index
    get :index, :project_id => 1
    assert_template 'index'
  end
  
  def test_new
    get :new, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_invalid
    Network.any_instance.stubs(:valid?).returns(false)
    post :create, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_valid
    Network.any_instance.stubs(:valid?).returns(true)
    post :create, :network => {:name => "mynetwork", :datacenter_id => 1}, :project_id => 1
    assert_redirected_to "/projects/ecookbook/networks/#{assigns(:network).id}"
    network = Network.find_by_name("mynetwork")
    assert_not_nil network
  end
  
  def test_edit
    get :edit, :id => Network.first, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update
    Network.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Network.first.id, :network => {:datacenter_id => 1}, :project_id => 1
    datacenter = Datacenter.find(1)
    assert_redirected_to "/projects/ecookbook/networks/#{assigns(:network).id}"
  end
  
  def test_destroy
    network = Network.first
    delete :destroy, :id => network, :project_id => 1
    assert_redirected_to "/projects/ecookbook/networks"
    assert !Network.exists?(network.id)
  end
end
