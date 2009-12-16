class Appli < ActiveRecord::Base
  attr_accessible :name, :description

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
end
