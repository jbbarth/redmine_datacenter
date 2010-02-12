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
    
    #migrate old data
    #NB: works only if you just have one project with datacenter module
    #enabled. As nobody uses this plugin for the moment, no pb with that :)
    project = Project.all.detect{|p|p.module_enabled?(:datacenter)}
    if project
      Datacenter.create(:name => "Default datacenter", :project_id => project.id)
      Server.update_all("datacenter_id = 1")
      Appli.update_all("datacenter_id = 1")
    end
  end
  
  def self.down
    remove_column :servers, :datacenter_id
    remove_column :applis, :datacenter_id
    drop_table :datacenters
    drop_table :datacenters_projects
  end
end
