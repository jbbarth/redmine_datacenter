# Redmine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.dirname(__FILE__) + '/../test_helper'
require 'issues_controller'

# Re-raise errors caught by the controller.
class IssuesController; def rescue_action(e) raise e end; end

class IssuesControllerDatacenterTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :servers,
           :applis
  
  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1
    p = Project.find(1)
    p.enabled_module_names = p.enabled_modules.map(&:name) << "datacenter"
  end
  
  def test_add_and_remove_servers_from_an_issue
    issue = Issue.find(1)
    put :update, :id => 1, :issue => {:subject => 'Custom field change',
                                     :priority_id => '6',
                                     :category_id => '1',
                                     :server_ids => ["1", "2"]}
    assert_redirected_to :action => 'show', :id => '1'
    issue.reload
    assert_equal [1,2], issue.server_ids
    #let's repost without server_ids :
    #the fix in lib/issues_controller_patch should be applied
    #and remove servers from this issue
    put :update, :id => 1, :issue => {:subject => 'Custom field change',
                                     :priority_id => '6',
                                     :category_id => '1'}
    assert_redirected_to :action => 'show', :id => '1'
    issue.reload
    assert_equal [], issue.server_ids
  end

  def test_new_issue_form_contains_active_but_not_locked_servers
    get :new, :project_id => 1, :tracker_id => 1
    assert_response :success
    assert_template 'new'
    assert_tag :option,
               :attributes => { :value => "2" },
               :content => "server-mail"
    assert_no_tag :option,
                  :attributes => { :value => "3" },
                  :content => "server-locked"
    assert_no_tag :option,
                  :attributes => { :value => "5" },
                  :content => "stranger" #server not in this datacenter
  end

  def test_edit_issue_form_contains_right_servers
    issue = Issue.find(1)
    issue.server_ids = [1,2,3] #1,2 are active, 3 is locked
    get :edit, :id => 1
    assert_tag :option,
               :attributes => { :value => "1", :selected => "selected" },
               :content => "server-web"
    assert_tag :option,
               :attributes => { :value => "3", :selected => "selected" },
               :content => "server-locked"
    assert_no_tag :option,
                  :attributes => { :value => "4" },
                  :content => "server2-locked"
    assert_no_tag :option,
                  :attributes => { :value => "5" },
                  :content => "stranger" #server not in this datacenter
  end

  def test_custom_filters_are_present
    get :index, :project_id => 1
    assert_tag :tag => 'select', :attributes => {:id => 'add_filter_select'},
               :child => {:tag => 'option', :attributes => {:value => 'server_id'} }
    assert_tag :tag => 'tr', :attributes => {:id => 'tr_server_id', :style => 'display:none;'}
    assert_tag :tag => 'select', :attributes => {:id => 'add_filter_select'},
               :child => {:tag => 'option', :attributes => {:value => 'appli_id'} }
    assert_tag :tag => 'tr', :attributes => {:id => 'tr_appli_id', :style => 'display:none;'}
  end

  def test_custom_filters_are_kept_when_used
    #Parameters: {
    # "group_by"=>"",
    # "set_filter"=>"1",
    # "project_id"=>"test",
    # "action"=>"index",
    # "authenticity_token"=>"4DKnXQtSSgyTR+AjccMghCmRWGrp8oeabfR6RnCRHuw=",
    # "fields"=>["status_id", "server_id"],
    # "operators"=>{"start_date"=>"<t+", "estimated_hours"=>"=", "created_on"=>">t-", "priority_id"=>"=", "server_id"=>"=", "done_ratio"=>"=", "updated_on"=>">t-", "subject"=>"~", "assigned_to_id"=>"=", "tracker_id"=>"=", "due_date"=>"<t+", "author_id"=>"=", "status_id"=>"o", "cf_1"=>"="},
    # "values"=>{"start_date"=>[""], "estimated_hours"=>[""], "created_on"=>[""], "priority_id"=>["3"], "server_id"=>["1"], "done_ratio"=>[""], "updated_on"=>[""], "subject"=>[""], "assigned_to_id"=>["1"], "tracker_id"=>["1"], "due_date"=>[""], "author_id"=>["1"], "status_id"=>["1"], "cf_1"=>["Un"]},
    # "controller"=>"issues",
    # "_"=>"",
    # "query"=>{"column_names"=>["tracker", "status", "priority", "subject", "assigned_to", "updated_on"]}
    # }
    #SERVERS
    post :index, :project_id => "1", :set_filter => "1",
          :fields => ["status_id", "server_id"],
          :operators => {"status_id" => "o", "server_id" => "="},
          :values => {"status_id" => ["1"], "server_id"=>["1"]}
    assert_response :success
    assert_tag :tr, :attributes => {:id => 'tr_server_id'}
    assert_no_tag :tr, :attributes => {:id => 'tr_server_id', :style => 'display:none;'}
    #APPLIS
    post :index, :project_id => "1", :set_filter => "1",
          :fields => ["status_id", "appli_id"],
          :operators => {"status_id" => "o", "appli_id" => "="},
          :values => {"status_id" => ["1"], "appli_id"=>["1"]}
    assert_response :success
    assert_tag :tr, :attributes => {:id => 'tr_appli_id'}
    assert_no_tag :tr, :attributes => {:id => 'tr_appli_id', :style => 'display:none;'}
  end
  
  def test_add_and_remove_applis_from_an_issue
    issue = Issue.find(1)
    put :update, :id => 1, :issue => {:subject => 'Custom field change',
                                     :priority_id => '6',
                                     :category_id => '1',
                                     :appli_instance_ids => ["Appli:1", "Appli:2", "Instance:1"]}
    assert_redirected_to :action => 'show', :id => '1'
    issue.reload
    assert_equal [1,2], issue.appli_ids
    assert_equal [1], issue.instance_ids
    assert_equal ["Appli:1", "Appli:2", "Instance:1"], issue.appli_instance_ids
    put :update, :id => 1, :issue => {:subject => 'Custom field change',
                                     :priority_id => '6',
                                     :category_id => '1'}
    issue.reload
    assert_equal [], issue.appli_ids
    assert_equal [], issue.instance_ids
    assert_equal [], issue.appli_instance_ids
  end
  
  def test_servers_and_applis_are_added_to_journal
    issue = Issue.find(4)
    issue.journals.clear
    ActionMailer::Base.deliveries.clear

    #first we make sure no instance or appli is linked..
    assert_equal [], issue.appli_instance_ids
    
    #ok, let's add appli/instances
    put :update, :id => issue.id, 
         :issue => {:appli_instance_ids => ["Appli:1", "Appli:2", "Instance:1"]}
    assert_redirected_to :action => 'show', :id => issue.id
    
    issue.reload
    j = issue.journals.find(:first, :order => 'id DESC')
    details = j.details.reject{|d| d.property == "cf"} #we don't want to have custom field details..
    assert j.notes.blank?
    assert_equal 1, details.size
    assert_equal [], YAML.load(details.first.old_value)
    assert_equal ["Appli:1", "Appli:2", "Instance:1"], YAML.load(details.first.value)
    
    put :update, :id => issue.id, :issue => {}
    assert_redirected_to :action => 'show', :id => issue.id
    issue.reload
    j = issue.journals.find(:first, :order => 'id DESC')
    details = j.details.reject{|d| d.property == "cf"} #we don't want to have custom field details..
    assert_equal 1, details.size
    assert_equal [], YAML.load(details.first.value)
    assert_equal ["Appli:1", "Appli:2", "Instance:1"], YAML.load(details.first.old_value)

    #let's test applis are formated correctly in a journal detail
    get :show, :id => issue.id
    assert_select "div#history div.journal",
                  /Applications set to first_application, first_application\(first-app-prod\), second_app/
  end
end
