require File.dirname(__FILE__) + '/../test_helper'

class ServersControllerTest < ActionController::TestCase
  fixtures :servers

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
    assert_redirected_to servers_url
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
    assert_redirected_to servers_url
  end
  
  def test_destroy
    server = Server.first
    delete :destroy, :id => server
    assert_redirected_to servers_url
    assert !Server.exists?(server.id)
  end
end
