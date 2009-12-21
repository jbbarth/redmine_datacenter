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
  end
  
  def test_new
    get :new, :appli_id => 1
    assert_template 'new'
  end
  
  def test_create_invalid
    Instance.any_instance.stubs(:valid?).returns(false)
    post :create, :appli_id => 1
    assert_template 'new'
  end
  
  def test_create_valid
    Instance.any_instance.stubs(:valid?).returns(true)
    post :create, :appli_id => 1
    assert_redirected_to appli_url(Appli.first)
  end
  
  def test_edit
    get :edit, :id => Instance.first, :appli_id => 1
    assert_template 'edit'
  end
  
  def test_update_invalid
    Instance.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Instance.first, :appli_id => 1
    assert_template 'edit'
  end
  
  def test_update_valid
    Instance.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Instance.first, :appli_id => 1
    assert_redirected_to appli_url(Appli.first)
  end
  
  def test_destroy
    instance = Instance.first
    delete :destroy, :id => instance, :appli_id => 1
    assert_redirected_to appli_url(Appli.first)
    assert !Instance.exists?(instance.id)
  end
end
