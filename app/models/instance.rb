class Instance < ActiveRecord::Base
  unloadable

  belongs_to :appli
  has_and_belongs_to_many :servers

  attr_accessible :name, :appli_id, :server_ids

  validates_presence_of :name

  def fullname
    "#{appli.name}(#{name})"
  end
end
