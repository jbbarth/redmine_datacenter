module ApplisHelper
  include InstancesHelper

  def links_to_applis(project,applis_and_instances, no_html = false)
    applis_and_instances.sort_by(&:fullname).map do |element|
      appli_id = element.is_a?(Appli) ? element.id : element.appli_id
      (no_html ? element.fullname : link_to(element.fullname, appli_path(project,appli_id)))
    end.join(", ")
  end

  def links_to_instances(project,appli)
    appli.instances.map do |instance|
      link_to instance.name, edit_appli_instance_path(project,appli,instance)
    end.join(", ")
  end

  def select_applis_or_instances(issue,applis)
    available_options = [["",""]]
    applis.sort_by(&:name).each do |appli|
      available_options << [ appli.name, "Appli:#{appli.id}" ]
      appli.instances.sort_by(&:name).each do |instance|
        if instance.active? || issue.has_instance?(instance)
          available_options << [ "&nbsp;  -- #{instance.fullname}", "Instance:#{instance.id}" ]
        end
      end
    end
    
    # options_for_select() is not really good since it escape_html() our html :-(
    # patch at the end of this file
    values = options_for_select_without_escape(available_options, :selected => issue.appli_instance_ids)
    
    options = { :multiple => (issue.appli_instance_ids.length > 1 ? true : false),
                :name => 'issue[appli_instance_ids][]' }

    select_tag "issue_appli_instance_ids", values, options
  end

  def change_link_appli_status(appli)
    parameters = {:id => appli, :action => :update}
    if appli.active?
      link_to l(:button_lock),
              url_for(:overwrite_params => parameters.merge(:appli => {:status => Appli::STATUS_LOCKED})),
              :method => :put,
              :class => 'icon icon-lock'
    else
      link_to l(:button_unlock),
              url_for(:overwrite_params => parameters.merge(:instance => {:status => Appli::STATUS_ACTIVE})),
              :method => :put,
              :class => 'icon icon-unlock'
    end
  end
  
  def applis_status_options_for_select(selected)
    appli_count_by_status = Appli.count(:group => 'status').to_hash
    options = [[l(:label_all), '']]
    [[:status_active,Appli::STATUS_ACTIVE],[:status_locked,Appli::STATUS_LOCKED]].each do |a|
      options << ["#{l(a[0])} (#{appli_count_by_status[a[1]].to_i})", a[1]]
    end
    options_for_select(options, selected)
  end
end

module ActionView
  module Helpers
    module FormOptionsHelper
      def options_for_select_without_escape(container, selected = nil)
        container = container.to_a if Hash === container
        selected, disabled = extract_selected_and_disabled(selected)
        
        options_for_select = container.inject([]) do |options, element|
          text, value = option_text_and_value(element)
          selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
          disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
          options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{disabled_attribute}>#{text.to_s}</option>)
        end
        
        options_for_select.join("\n")
      end
    end
  end
end
