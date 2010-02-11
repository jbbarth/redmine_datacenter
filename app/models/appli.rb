class Appli < ActiveRecord::Base
  unloadable

  has_many :instances, :dependent => :destroy
  has_many :issue_elements, :as => :element,
           :dependent => :destroy
  has_many :issues,
           :through => :issue_elements
  belongs_to :datacenter

  attr_accessible :name, :description, :status

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  STATUS_ACTIVE = 1
  STATUS_LOCKED = 2

  named_scope :active, :conditions => { :status => STATUS_ACTIVE }
  
  def active?
    self.status == STATUS_ACTIVE
  end

  def fullname
    self.name
  end
  
  def short_description(max=50)
    short = "#{self.description}".split("\n").first.to_s
    (short.length > max ? short[0..(max-5)] + "<i>[...]</i>" : short)
  end
end
