require File.dirname(__FILE__) + '/../test_helper'

class ApachesControllerTest < ActionController::TestCase
  def setup
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
  
  def test_show
    get :show, :project_id => 1, :id => 1
    assert_template 'show'
  end
end
