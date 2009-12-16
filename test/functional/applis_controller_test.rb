require File.dirname(__FILE__) + '/../test_helper'
require 'applis_controller'

# Re-raise errors caught by the controller.
class ApplisController; def rescue_action(e) raise e end; end

class ApplisControllerTest < ActionController::TestCase
  fixtures :applis, :servers, :issues, :users
  
  def setup
    @controller = ApplisController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1 # admin
  end
  
  def test_non_admin_user_should_be_dropped_out
    @request.session[:user_id] = 2
    get :index
    assert_response 403
  end
  
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Appli.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Appli.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Appli.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to appli_url(assigns(:appli))
  end
  
  def test_edit
    get :edit, :id => Appli.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Appli.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Appli.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Appli.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Appli.first
    assert_redirected_to appli_url(assigns(:appli))
  end
  
  def test_destroy
    appli = Appli.first
    delete :destroy, :id => appli
    assert_redirected_to applis_url
    assert !Appli.exists?(appli.id)
  end
end