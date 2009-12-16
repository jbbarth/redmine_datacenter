class Appli < ActiveRecord::Base
  has_and_belongs_to_many :issues

  attr_accessible :name, :description

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
end
