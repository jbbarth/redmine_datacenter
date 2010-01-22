class DatacenterIssueHook < Redmine::Hook::ViewListener
  
  # Add our own elements to issue show view (in show and form sections)
  #
  # NB: This works too, maybe for future use if we have many things to 
  # do before rendering :
  #
  #   def view_issues_form_details_bottom(context)
  #     template = context[:controller].instance_variable_get("@template")
  #     template.render :partial => "datacenter_plugin/issue_form", :locals => {:context => context}
  #   end
  #
  #   def view_issues_form_details_bottom(context)
  #     context[:controller].send(:render, :partial => "datacenter_plugin/issue_form", :locals => {:context => context})
  #   end
  render_on :view_issues_form_details_bottom, :partial => "datacenter_plugin/issue_form"
  render_on :view_issues_show_details_bottom, :partial => "datacenter_plugin/issue_show"
  
  # Add journal details for our elements related to the current issues
  #
  # Context:
  # * :params => Parameters of the request
  # * :issue => Current issue object
  # * :time_entry => Current time entry
  # * :journal => Current journal for this issue
  #
  def controller_issues_edit_after_save(context)
    dc_elements = context[:controller].instance_variable_get("@datacenter_elements_before_change")
    if dc_elements
      #appli_instance_ids
      app_before = dc_elements[:appli_instance_ids].sort
      app_after = context[:issue].appli_instance_ids.sort
      context[:journal].details << JournalDetail.new(:property => 'attr',
                                                     :prop_key => 'appli_instance_ids',
                                                     :old_value => app_before,
                                                     :value => app_after) unless app_before == app_after
      #server_ids
      serv_before = dc_elements[:server_ids]
      serv_after = context[:issue].server_ids
      context[:journal].details << JournalDetail.new(:property => 'attr',
                                                     :prop_key => 'server_ids',
                                                     :old_value => serv_before,
                                                     :value => serv_after) unless serv_before == serv_after
      #save changes
      context[:journal].save
    end
  end
  
  # Reformat journal details related to our Appli/Instance models
  #
  # Context: 
  # * :detail => Detail about de journal change
  # * :label  => Label for the current attribute
  # * :value  => New value for the current attribute
  # * :old_value => Old value for the current attribute
  #
  def helper_issues_show_detail_after_setting(context)
    #TODO: DRY it (see ApplisHelper)
    #TODO: optimize it: caching between multiple journals and between these two..
    d = context[:detail]
    if %w(appli_instance_ids server_ids).include?(d.prop_key)
      #Principle:
      # d.value = YAML.load(d.value.to_s)
      # d.value.map! do |a|
      #   type, id = a.split(":")
      #   Kernel.const_get(type).find(id).fullname
      # end.sort.join(", ")
      %w(value old_value).each do |key|
        d.send("#{key}=",YAML.load(d.send(key).to_s)) if d.send(key).is_a?(String) && d.send(key).match(/^---/)
        if d.send(key).respond_to?(:to_ary)
          d.send("#{key}=",d.send(key).map do |value|
            case d.prop_key
            when 'appli_instance_ids'
              if value.match(/^(Appli|Instance):(\d+)$/)
                begin
                  Kernel.const_get($~[1]).find($~[2]).fullname
                rescue
                 "unknown"
                end
              else
                value
              end
            when 'server_ids'
              begin
                Server.find(value).name
              rescue
                "unknown"
              end
            end
          end.compact.sort.join(", "))
        end
      end
    end
  end
end
