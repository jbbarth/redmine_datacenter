class CreateOperatingSystems < ActiveRecord::Migration
  def self.up
    create_table :operating_systems do |t|
      t.string :name
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.boolean :hypervisor
      t.timestamps
    end
    #default values
    {"Windows" => %w(XP 2003Server),
     "Linux" => %w(Debian Redhat Ubuntu)}.each do |k,v|
      os = OperatingSystem.create(:name => k)
      os.save!
      v.each do |oss|
        OperatingSystem.create(:name => oss, :parent_id => os.id)
      end
    end
    #server<->os
    add_column :servers, :operating_system_id, :integer
  end

  def self.down
    drop_table :operating_systems
    remove_column :servers, :operating_system_id
  end
end
