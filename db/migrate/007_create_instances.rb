class CreateInstances < ActiveRecord::Migration
  def self.up
    create_table :instances do |t|
      t.string :name
      t.integer :appli_id
      t.timestamps
    end
    create_table :instances_servers, :id => false do |t|
      t.column :instance_id, :integer, :null => false
      t.column :server_id, :integer, :null => false
    end
    add_index :instances_servers, [:instance_id, :server_id], :unique => true, :name => :instances_servers_ids
  end
  
  def self.down
    drop_table :instances
    drop_table :instances_servers
  end
end
