class RenamePlugin < ActiveRecord::Migration
  def self.up
    setting = Setting.find_or_default('plugin_redmine_datacenter')
    value = YAML.load(Setting.find_by_name('plugin_datacenter_plugin').read_attribute(:value)) rescue nil
    setting.update_attribute(:value, value) if value
  end

  def self.down
  end
end
