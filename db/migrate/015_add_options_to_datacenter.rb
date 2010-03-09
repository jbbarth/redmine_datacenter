class AddOptionsToDatacenter < ActiveRecord::Migration
  def self.up
    add_column :datacenters, :options, :text
  end

  def self.down
    remove_column :datacenters, :options
  end
end
