class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.string :name
      t.integer :address, :limit => 8
      t.integer :netmask, :limit => 8
      t.string :color
      t.text :exceptions
      t.integer :datacenter_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :networks
  end
end
