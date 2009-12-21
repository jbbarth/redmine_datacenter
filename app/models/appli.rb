class Appli < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :issues
  has_many :instances

  attr_accessible :name, :description

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
end
