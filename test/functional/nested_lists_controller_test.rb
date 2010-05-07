require File.dirname(__FILE__) + '/../test_helper'

class NestedListsControllerTest < ActionController::TestCase
  fixtures :operating_systems

  def setup
    @request.session[:user_id] = 1 # admin
    OperatingSystem.rebuild! #populates lft/rgt columns
  end
  
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new, :type => "OperatingSystem"
    assert_template 'new'
  end
  
  def test_create_invalid
    OperatingSystem.any_instance.stubs(:valid?).returns(false)
    post :create, :type => "OperatingSystem"
    assert_template 'new'
  end
  
  def test_create_without_parent
    post :create, :type => "OperatingSystem", :element=>{:name => "GNU/Hurd"}
    assert_redirected_to nested_lists_url
    os = OperatingSystem.find_by_name("GNU/Hurd")
    assert_not_nil os
    assert_nil os.parent_id
  end
  
  def test_create_with_parent
    linux=OperatingSystem.find_by_name("Linux")
    post :create, :type => "OperatingSystem", :element=>{:name => "Gentoo", :parent_id => linux.id}
    assert_redirected_to nested_lists_url
    os = OperatingSystem.find_by_name("Gentoo")
    assert_not_nil os
    assert_equal linux.id, os.parent_id
  end

  def test_edit
    get :edit, :type => "OperatingSystem", :id=>1
    assert_template 'edit'
  end
  
  def test_update_invalid
    OperatingSystem.any_instance.stubs(:valid?).returns(false)
    post :update, :type => "OperatingSystem", :id => 1, :element=>{}
    assert_template 'edit'
  end
  
  def test_update
    put :update, :type => "Operatingsystem", :id => 1, :element => {}
    assert_redirected_to nested_lists_url
  end
  
  def test_destroy
    delete :destroy, :type => "OperatingSystem", :id => 1
    assert_redirected_to nested_lists_url
    assert !OperatingSystem.exists?(1)
  end
end
