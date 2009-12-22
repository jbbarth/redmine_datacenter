module ApplisHelper
  def links_to_applis(applis_and_instances)
    applis_and_instances.sort_by(&:fullname).map do |element|
      appli_id = element.is_a?(Appli) ? element.id : element.appli_id
      link_to(element.fullname, appli_path(appli_id))
    end.join(", ")
  end

  def select_applis_or_instances(issue,applis)
    #<select id="issue_appli_ids" name="issue[appli_ids][]"><option value=""></option> 
    #<option value="4">I-noemie</option> 
    #<option value="1" selected="selected">Noemie</option></select>
    #
    #select_tag "access", "<option>Read</option><option>Write</option>", :multiple => true, :class => 'form_input'
    #=> <select class="form_input" id="access" multiple="multiple" name="access[]"><option>Read</option>
    #   <option>Write</option></select>
    #
    available_options = ["",""]
    applis.sort_by(&:name).each do |appli|
      available_options << [ appli.name, "Appli:#{appli.id}" ]
      appli.instances.sort_by(&:name).each do |instance|
        available_options << [ "&nbsp;  -- #{instance.fullname}", "Instance:#{instance.id}" ]
      end
    end
    
    #options_for_select() is not really good since it escape_html() our html :-(
    #patch at the end of this file
    values = options_for_select_without_escape(available_options, :selected => issue.appli_instance_ids)
    
    #alternative:
    values = available_options.map do |option|
      selected = issue.appli_instance_ids.include?(option.last) ? ' selected="selected"' : ''
      %Q(<option value="#{option.last}"#{selected}>#{option.first}</option>)
    end.join("\n")

    options = { :multiple => (issue.appli_instance_ids.length > 1 ? true : false),
                :name => 'issue[appli_instance_ids][]' }
    select_tag "issue_appli_instance_ids", values, options
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
