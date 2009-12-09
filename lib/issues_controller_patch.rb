require_dependency 'issues_controller'

class IssuesController
  before_filter :fix_missing_server_ids, :only => [:edit, :update]
  
  def fix_missing_server_ids
    #see railscasts #17 ; actually redmine only uses "edit" method with "post" requests
    #but I don't want this to be broken in future redmine updates, so trying to guess
    #the future :)
    params[:issue][:server_ids] ||= [] if request.post? || request.put?
  end
end
