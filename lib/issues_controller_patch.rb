require_dependency 'issues_controller'

class IssuesController
  helper :servers
  helper :applis
  before_filter :fix_missing_ids, :only => [:edit, :update]
  
  def fix_missing_ids
    #see railscasts #17 ; actually redmine only uses "edit" method with "post" requests
    #but I don't want this to be broken in future redmine updates, so trying to guess
    #the future :)
    if request.post? || request.put?
      params[:issue][:server_ids] ||= []
      params[:issue][:appli_ids] ||= []
    end
  end
end
