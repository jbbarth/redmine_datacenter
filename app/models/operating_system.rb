class OperatingSystem < ActiveRecord::Base
  has_many :servers

  acts_as_nested_set

  validates_presence_of :name
  validates_uniqueness_of :name
end
