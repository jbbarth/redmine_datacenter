require_dependency 'issues_controller'

class IssuesController
  helper :servers
  helper :applis
  before_filter :fix_missing_ids, :only => [:edit, :update]
  before_filter :remember_datacenter_elements, :only => [:edit, :update]
  
  def fix_missing_ids
    #see railscasts #17 ; actually redmine only uses "edit" method with "post" requests
    #but I don't want this to be broken in future redmine updates, so trying to guess
    #the future :)
    if params[:issue] && (request.post? || request.put?)
      params[:issue][:server_ids] ||= []
      params[:issue][:appli_instance_ids] ||= []
    end
  end

  def remember_datacenter_elements
    @datacenter_elements_before_change = {
      :appli_instance_ids => @issue.appli_instance_ids,
      :server_ids => @issue.server_ids
    }
  end
end
