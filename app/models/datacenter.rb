class Datacenter < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_many :applis
  has_many :servers
  has_many :networks

  attr_accessible :name, :description, :status, :project_id, :domain, :options

  serialize :options
  
  STATUS_ACTIVE = 1
  STATUS_LOCKED = 2
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  default_scope :order => 'name asc'
  named_scope :active, :conditions => { :status => STATUS_ACTIVE }
  
  def active?
    self.status == STATUS_ACTIVE
  end
  
  def instances_number
    self.applis.map do |appli|
      appli.instances.select{|i| i.active? }.length if appli.active?
    end.compact.inject(0) do |memo,n|
      memo + n
    end
  end

  def applis_number
    self.applis.select do |appli|
      appli.active?
    end.length
  end

  def servers_number
    self.servers.select do |server|
      server.active?
    end.length
  end

  def options
    read_attribute(:options) || Hash.new(nil)
  end

  def method_missing(symbol,*args)
    if symbol.to_s =~ /(.*enabled)\?$/
      options[$1].to_i == 1
    else
      super
    end
  end
end
