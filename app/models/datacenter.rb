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

  #nagios integration
  def nagios_file
    File.join(Rails.root,"vendor","plugins","redmine_datacenter","data",
              project.identifier,"nagios","status.dat")
  end
  
  #storage integration
  #currently supports only IBM DS4000 devices
  def storage_dir
    @storage_dir ||= File.join(Rails.root,"vendor","plugins","redmine_datacenter","data",
                               project.identifier,"storage")
  end

  def storage_files
    Dir.glob(File.join(storage_dir,"*"))
  end

  def storage_file(server_name)
    File.join(storage_dir,"#{server_name}.profile")
  end

  #third party tools integration
  def tool_enabled?(tool)
    options["#{tool}_enabled"].to_i == 1
  end

  def fetch_activity(options)
    activity = {}
    fetcher  = Redmine::Activity::Fetcher.new(options[:user], :project => project)
    options[:types].each do |type|
      fetcher.scope=([type])
      activity[type.to_sym] = fetcher.events(nil, nil, :limit => options[:limit])
      if type == "changesets"
        #patch so that revisions are just displayed with
        #their short identifier in the next section
        activity[:changesets].each do |c|
          def c.event_title
            "#{l(:label_revision)} #{revision.first(8)} #{": "+short_comments unless short_comments.blank?}"
          end
        end
      end
    end
    activity
  end
end
