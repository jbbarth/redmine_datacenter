class MoveDomainToDatacenter < ActiveRecord::Migration
  def self.up
    add_column :datacenters, :domain, :string
    previous_domain = begin Setting["plugin_datacenter_plugin"]["domain"]; rescue; ""; end
    Datacenter.all.each do |dc|
      dc.domain = "#{previous_domain}"
      dc.save!
    end
  end

  def self.down
    remove_column :datacenters, :domain
  end
end
