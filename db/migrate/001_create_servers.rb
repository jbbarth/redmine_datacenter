class CreateServers < ActiveRecord::Migration
  def self.up
    create_table :servers do |t|
      t.string :name, :null => false
      t.string :fqdn
      t.string :ipaddress
      t.text   :description
      t.timestamps
    end
  end

  def self.down
    drop_table :servers
  end
end
