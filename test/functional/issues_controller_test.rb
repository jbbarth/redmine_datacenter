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
           :servers
  
  def setup
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1
  end
  
  def test_add_and_remove_servers_from_an_issue
    issue = Issue.find(1)
    post :edit, :id => 1, :issue => {:subject => 'Custom field change',
                                     :priority_id => '6',
                                     :category_id => '1',
                                     :server_ids => ["1", "2"]}
    assert_redirected_to :action => 'show', :id => '1'
    issue.reload
    assert_equal [1,2], issue.server_ids
    #let's repost without server_ids :
    #the fix in lib/issues_controller_patch should be applied
    #and remove servers from this issue
    post :edit, :id => 1, :issue => {:subject => 'Custom field change',
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
    assert_tag :input,
                  :attributes => {
                    :id => 'issue_server_ids_',
                    :type => 'checkbox',
                    :value => '2'
                  }
    assert_no_tag :input,
                  :attributes => {
                    :id => 'issue_server_ids_',
                    :type => 'checkbox',
                    :value => '3'
                  }
  end
end
