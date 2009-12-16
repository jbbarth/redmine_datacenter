class IssueViewAdditions < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => "datacenter/issue_form"
  #WORKS TOO :
  #def view_issues_form_details_bottom(context)
  #  template = context[:controller].instance_variable_get("@template")
  #  template.render :partial => "datacenter/issue_form", :locals => {:context => context}
  #end
  
  render_on :view_issues_show_details_bottom, :partial => "datacenter/issue_show"
end
