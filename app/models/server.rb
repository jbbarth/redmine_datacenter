class Server < ActiveRecord::Base
  attr_accessible :name, :fqdn, :ipaddress, :description
end
