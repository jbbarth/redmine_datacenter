class AddHypervisorToServer < ActiveRecord::Migration
  def self.up
    add_column :servers, :hypervisor_id, :integer
  end

  def self.down
    remove_column :servers, :hypervisor_id
  end
end
