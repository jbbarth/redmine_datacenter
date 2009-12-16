class AddApplisToIssueForm < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => "applis/issue_form"
  render_on :view_issues_show_details_bottom, :partial => "applis/issue_show"
end
