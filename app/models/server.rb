class Server < ActiveRecord::Base
  attr_accessible :name, :fqdn, :ipaddress, :description
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :fqdn, :case_sensitive => false
  validates_format_of :name, :with => /\A[a-zA-Z0-9_-]*\Z/
end
