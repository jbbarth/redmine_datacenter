class AddStatusToServers < ActiveRecord::Migration
  def self.up
    add_column :servers, :status, :integer, :default => 1, :null => false
    Server.update_all("status = 1")
  end

  def self.down
    remove_column :servers, :status
  end
end
