require 'ipaddr'

class Network < ActiveRecord::Base
  unloadable

  belongs_to :datacenter

  attr_accessible :name, :address, :netmask, :color, :exceptions, :datacenter_id

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :address
  validates_presence_of :netmask
  validates_format_of :color, :with => /^#[0-9A-Z]{1,6}$/i, :allow_blank => true
  
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

  def include?(address)
    begin
      self.iprange.include?(address)
    rescue ArgumentError
      false
    end
  end

  def first
    IPAddr.new(iprange.to_range.first.to_i + 1, Socket::AF_INET).to_s
  end

  def last
    IPAddr.new(iprange.to_range.last.to_i - 1, Socket::AF_INET).to_s
  end

  def broadcast
    iprange.to_range.last.to_s
  end
end
