class CreateDatacenters < ActiveRecord::Migration
  def self.up
    create_table :datacenters do |t|
      t.string :name
      t.text :description
      t.integer :project_id
      t.integer :status, :default => 1
    end
    
    add_column :servers, :datacenter_id, :integer
    add_column :applis, :datacenter_id, :integer

    Datacenter.create(:name => "Default datacenter")
    Server.update_all("datacenter_id = 1")
    Appli.update_all("datacenter_id = 1")
  end
  
  def self.down
    remove_column :servers, :datacenter_id
    remove_column :applis, :datacenter_id
    drop_table :datacenters
    drop_table :datacenters_projects
  end
end
