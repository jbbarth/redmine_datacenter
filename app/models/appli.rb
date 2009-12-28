class Appli < ActiveRecord::Base
  unloadable

  has_many :instances, :dependent => :destroy
  has_many :issue_elements, :as => :element,
           :dependent => :destroy
  has_many :issues,
           :through => :issue_elements

  attr_accessible :name, :description

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  def fullname
    self.name
  end
  
  def short_description(max=50)
    short = "#{self.description}".split("\n").first.to_s
    (short.length > max ? short[0..(max-5)] + "<i>[...]</i>" : short)
  end
end
