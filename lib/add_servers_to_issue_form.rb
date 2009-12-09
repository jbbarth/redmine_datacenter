class AddServersToIssueForm < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => "servers/issue_form"
  #WORKS TOO :
  #def view_issues_form_details_bottom(context)
  #  template = context[:controller].instance_variable_get("@template")
  #  template.render :partial => "servers/issue_form", :locals => {:context => context}
  #end
  
  render_on :view_issues_show_details_bottom, :partial => "servers/issue_show"
end
