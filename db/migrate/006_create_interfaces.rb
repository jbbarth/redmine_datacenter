class CreateInterfaces < ActiveRecord::Migration
  def self.up
    create_table :interfaces do |t|
      t.column :name, :string
      t.column :ipaddress, :string
      t.column :note, :text
    end
    create_table :interfaces_servers, :id => false do |t|
      t.column :interface_id, :integer, :null => false
      t.column :server_id, :integer, :null => false
    end
    add_index :interfaces_servers, [:interface_id, :server_id], :unique => true, :name => :interfaces_servers_ids
    Server.all.each do |server|
      server.interfaces << Interface.create(:ipaddress => server.ipaddress)
      server.save
    end
    remove_column :servers, :ipaddress
  end

  def self.down
    add_column :servers, :ipaddress, :string
    Server.all.each do |server|
      server.ipaddress = server.interfaces.first.ipaddress if server.interfaces.any?
      server.save
    end
    drop_table :interfaces
    drop_table :interfaces_servers
  end
end
