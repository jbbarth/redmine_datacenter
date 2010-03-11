require 'ipaddr'

class Network < ActiveRecord::Base
  unloadable

  belongs_to :datacenter

  attr_accessible :name, :address, :netmask, :color, :exceptions, :datacenter_id
  acts_as_ipaddress :attributes => [:address]

  def netmask
    attr = read_attribute(:netmask)
    attr = attr.to_i if attr == attr.to_i.to_s
    IPAddr.new(attr, Socket::AF_INET).to_s unless attr.blank?
  end
           
  def netmask=(value)
    if value == value.to_i.to_s && value.to_i <= 32 #netmask!
      value = IPAddr.new("255.255.255.255/"+value.to_s).to_s
    end
    write_attribute(:netmask, IPAddr.new(value).to_i) if IPAddr.valid?(value)
  end


  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :address
  validates_presence_of :netmask
  validates_format_of :color, :with => /^#[0-9A-Z]{1,6}$/i, :allow_blank => true
  
  named_scope :for_datacenter, lambda {|datacenter_id| {:conditions => ["datacenter_id = ?", datacenter_id]}}
  
  def validate
    errors.add(:address, :invalid_ipaddress) unless IPAddr.valid?(address)
    errors.add(:netmask, :invalid_ipaddress) unless IPAddr.valid?("#{address}/#{netmask}")
  end

  def iprange
    IPAddr.new("#{self.address}/#{self.netmask}")
  end

  def include?(addr)
    begin
      addr = IPAddr.new(addr) if RUBY_VERSION < '1.8.7'
      self.iprange.include?(addr)
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
