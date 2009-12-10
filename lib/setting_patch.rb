require_dependency 'setting'

class Setting
  def self.datacenter_multiselect?
    plugin_datacenter_plugin["multiple_select"].to_i == 1
  end
end
