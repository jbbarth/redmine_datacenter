require 'ipaddr'

class Network < ActiveRecord::Base
  unloadable

  belongs_to :datacenter

  attr_accessible :name, :address, :netmask, :color, :exceptions, :datacenter_id

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :address
  validates_presence_of :netmask
  
  named_scope :for_project, lambda {|datacenter_id| {:conditions => ["datacenter_id = ?", datacenter_id]}}
  
  def validate
    begin
      IPAddr.new("#{address}/#{netmask}")
    rescue
      errors.add(:address, :invalid_ipaddress)
    end
  end

  def iprange
    IPAddr.new("#{self.address}/#{self.netmask}")
  end
end
