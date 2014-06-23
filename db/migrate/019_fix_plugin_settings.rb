class FixPluginSettings < ActiveRecord::Migration
  def self.up
    default = Setting.available_settings["plugin_redmine_datacenter"]["default"]
    setting = Setting.find_or_default('plugin_redmine_datacenter')
    if Setting["plugin_redmine_datacenter"].blank?
      Setting["plugin_redmine_datacenter"] = default
    end
  end

  def self.down
  end
end
