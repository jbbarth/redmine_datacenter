class Instance < ActiveRecord::Base
  unloadable

  belongs_to :appli
  has_and_belongs_to_many :servers
  has_many :issue_elements, :as => :element,
           :dependent => :destroy
  has_many :issues,
           :through => :issue_elements

  attr_accessible :name, :appli_id, :server_ids, :status

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:appli_id]

  STATUS_ACTIVE = 1
  STATUS_LOCKED = 2
  
  named_scope :active, :conditions => { :status => STATUS_ACTIVE }
  
  def active?
    self.status == STATUS_ACTIVE
  end

  def fullname
    "#{appli.name}(#{name})"
  end
end
