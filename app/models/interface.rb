require 'ipaddr'

class Interface < ActiveRecord::Base
  has_and_belongs_to_many :servers
  
  def validate
    begin
      IPAddr.new(ipaddress.to_s)
    rescue
      errors.add(:ipaddress, :invalid_ipaddress)
    end
  end 
end
