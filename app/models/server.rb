class Server < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :issues
  has_and_belongs_to_many :interfaces
  has_and_belongs_to_many :instances, :include => :appli
  
  attr_accessible :name, :fqdn, :ipaddress, :description, :status,
                  :new_interface_attributes, :existing_interface_attributes
  
  STATUS_ACTIVE = 1
  STATUS_LOCKED = 2
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :fqdn, :case_sensitive => false
  validates_format_of :name, :with => /\A[a-zA-Z0-9_-]*\Z/
  validates_associated :interfaces

  after_update :save_interfaces
  
  named_scope :active, :conditions => { :status => STATUS_ACTIVE }
  
  def active?
    self.status == STATUS_ACTIVE
  end
  
  def ipaddress
    interfaces.first.ipaddress if interfaces.any?
  end

  def new_interface_attributes=(interface_attributes)
    interface_attributes.each do |attrs|
      interfaces.build(attrs) unless attrs['name'].blank? && attrs['ipaddress'].blank?
    end
  end
  
  def existing_interface_attributes=(interface_attributes)
    interfaces.reject(&:new_record?).each do |interface|
      attributes = interface_attributes[interface.id.to_s]
      if attributes
        interface.attributes = attributes
      else
        interfaces.delete(interface)
      end
    end
  end
  
  def save_interfaces
    interfaces.each do |interface|
      interface.save(false)
    end
  end
end
