class IssuesControllerAdditions < Redmine::Hook::ViewListener
  def controller_issues_edit_before_save(context)
    #{:params => params, :issue => @issue, :time_entry => @time_entry, :journal => journal}
    app_before = context[:controller].instance_variable_get("@appli_instance_ids_before_change").sort
    if app_before
      app_after = context[:issue].appli_instance_ids.sort
      if app_after != app_before
        context[:journal].details << JournalDetail.new(:property => 'attr',
                                                       :prop_key => 'appli_instance_ids',
                                                       :old_value => app_before,
                                                       :value => app_after)
        context[:journal].save!
      end
    end
  end
end
