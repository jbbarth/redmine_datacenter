class IssuesHelperAdditions < Redmine::Hook::ViewListener
  def helper_issues_show_detail_after_setting(context)
    #{:detail => detail, :label => label, :value => value, :old_value => old_value}
    d = context[:detail]
    if d.prop_key == 'appli_instance_ids'
      #TODO: DRY it (see ApplisHelper)
      #TODO: optimize it: caching between multiple journals and between these two..
      
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
            if value.match(/^(Appli|Instance):(\d+)$/)
              Kernel.const_get($~[1]).find($~[2]).fullname
            else
              value
            end
          end.sort.join(", "))
        end
      end
    end
  end
end
