require File.dirname(__FILE__) + '/../test_helper'
require 'servers_controller'

# Re-raise errors caught by the controller.
class ServersController; def rescue_action(e) raise e end; end

class ServersControllerTest < ActionController::TestCase
  fixtures :servers, :issues, :users, :projects, :datacenters

  def setup
    @controller = ServersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
    Setting["plugin_datacenter_plugin"]["domain"] = ".example.com"
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
    Server.any_instance.stubs(:valid?).returns(false)
    post :create, :project_id => 1
    assert_template 'new'
  end
  
  def test_create_valid
    Server.any_instance.stubs(:valid?).returns(true)
    post :create, :server => {:name => "myserver", :datacenter_id => 1}, :project_id => 1
    assert_redirected_to "/projects/ecookbook/servers/#{assigns(:server).id}"
    server = Server.find_by_name("myserver")
    assert_not_nil server
    assert_equal "myserver.example.com", server.fqdn
  end
  
  def test_edit
    get :edit, :id => Server.first, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_invalid
    Server.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Server.first.id, :server => {}, :project_id => 1
    assert_template 'edit'
  end
  
  def test_update_valid
    Server.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Server.first.id, :server => {:datacenter_id => 1}, :project_id => 1
    datacenter = Datacenter.find(1)
    assert_redirected_to "/projects/ecookbook/servers/#{assigns(:server).id}"
  end
  
  def test_destroy
    server = Server.first
    delete :destroy, :id => server, :project_id => 1
    assert_redirected_to servers_url(server.datacenter.project)
    server.reload
    assert Server.exists?(server.id)
    assert_equal Server::STATUS_LOCKED, server.status
  end

  def test_create_valid_with_interfaces
    post :create,
         :project_id => 1,
         :server => {
           :name => "myserverwithinterfaces",
           :new_interface_attributes => [
             {:name => "eth0", :ipaddress => "192.168.0.99"},
             {:name => "eth1", :ipaddress => "192.168.1.99"}
           ]
         }
    assert_redirected_to "/projects/ecookbook/servers/#{assigns(:server).id}"
    server = Server.find_by_name("myserverwithinterfaces")
    assert_not_nil server
    assert_equal ["eth0","eth1"], server.interfaces.map(&:name)
    assert_equal ["192.168.0.99","192.168.1.99"], server.interfaces.map(&:ipaddress)
  end
  
  def test_create_with_invalid_interface
    post :create,
         :project_id => 1,
         :server => {
           :name => "myserverwithinterfaces",
           :new_interface_attributes => [
             {:name => "eth0", :ipaddress => "192.168.0.99"},
             {:name => "eth1", :ipaddress => "blablabla"}
           ]
         }
    assert_template 'new'
  end
  
  def test_update_interfaces
    server = Server.first
    interface_ids = server.interface_ids
    interfaces_hash = Hash[ server.interfaces.map do |interface|
      [ interface.id.to_s , {:name => interface.name, :ipaddress => interface.ipaddress} ]
    end ]
    put :update, :id => server.id,
        :server => {
          :name => server.name,
          :existing_interface_attributes => interfaces_hash
        }, :project_id => 1
    assert_redirected_to "/projects/ecookbook/servers/#{server.id}"
    server.reload
    assert_equal interface_ids, server.interface_ids
  end
  
  def test_update_interfaces_without_value
    server = Server.first
    assert_not_equal [], server.interface_ids
    put :update, :id => server.id, :server => {}, :project_id => 1
    assert_redirected_to "/projects/ecookbook/servers/#{server.id}"
    server.reload
    assert_equal [], server.interface_ids
  end
end
