class Datacenter < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_many :applis
  has_many :servers

  attr_accessible :name, :description, :status, :project_id
  
  STATUS_ACTIVE = 1
  STATUS_LOCKED = 2
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  default_scope :order => 'name asc'
  named_scope :active, :conditions => { :status => STATUS_ACTIVE }
  
  def active?
    self.status == STATUS_ACTIVE
  end
end
