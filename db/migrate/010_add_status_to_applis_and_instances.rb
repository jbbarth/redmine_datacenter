class AddStatusToApplisAndInstances < ActiveRecord::Migration
  def self.up
    add_column :applis, :status, :integer, :default => 1, :null => false
    Appli.update_all("status = 1")
    add_column :instances, :status, :integer, :default => 1, :null => false
    Instance.update_all("status = 1")
  end

  def self.down
    remove_column :applis, :status
    remove_column :instances, :status
  end
end
