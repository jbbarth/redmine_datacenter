require 'ipaddr'

class Interface < ActiveRecord::Base
  has_and_belongs_to_many :servers
  
  acts_as_ipaddress :attributes => :ipaddress

  def validate
    errors.add(:ipaddress, :invalid_ipaddress) unless IPAddr.valid?(ipaddress)
  end 
end
