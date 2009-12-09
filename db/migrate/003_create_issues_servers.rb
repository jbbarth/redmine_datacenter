class CreateIssuesServers < ActiveRecord::Migration
  def self.up
    create_table :issues_servers, :id => false do |t|
      t.column :issue_id, :integer, :null => false
      t.column :server_id, :integer, :null => false
    end
    add_index :issues_servers, [:issue_id, :server_id], :unique => true, :name => :issues_servers_ids
  end

  def self.down
    drop_table :issues_servers
  end
end
