class Server < ActiveRecord::Base
  unloadable
  
  has_and_belongs_to_many :issues
  has_and_belongs_to_many :interfaces
  has_and_belongs_to_many :instances, :include => :appli
  belongs_to :datacenter
  belongs_to :operating_system
  belongs_to :hypervisor, :class_name => "Server"
  has_many :virtual_machines, :class_name => "Server", :foreign_key => "hypervisor_id", :order => "name"
  
  acts_as_ipaddress :attributes => :ipaddress
  
  attr_accessible :name, :fqdn, :description, :status, :interfaces_attributes, 
                  :datacenter_id, :hypervisor_id, :operating_system_id
  accepts_nested_attributes_for :interfaces,
                                :reject_if => lambda { |a| a["ipaddress"].blank? },
                                :allow_destroy => true
  
  STATUS_ACTIVE = 1
  STATUS_LOCKED = 2
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false,
                          :scope => [:status],
                          :unless => Proc.new { |server| !server.active? }
  validates_uniqueness_of :fqdn, :case_sensitive => false,
                          :scope => [:status],
                          :unless => Proc.new { |server| !server.active? },
                          :allow_nil => true, :allow_blank => true
  validates_format_of :name, :with => /\A[a-zA-Z0-9_-]*\Z/
  
  scope :active, where(:status => STATUS_ACTIVE).order('name asc')
  scope :for_datacenter, lambda {|datacenter_id| where(:datacenter_id => datacenter_id)}
  scope :hypervisors, includes(:operating_system).where('operating_systems.hypervisor' => true).order('servers.name asc')
  
  def active?
    self.status == STATUS_ACTIVE
  end
  
  def fullname
    self.fqdn.blank? ? self.name : self.fqdn
  end
  
  def virtual?
    !!hypervisor_id
  end
  
  def hypervisor?
    virtual_machines.any?
  end
  
  def storage_file
    @storage_file ||= self.datacenter.storage_files.detect do |file|
      File.basename(file) == self.name
    end
  end
  
  def storage_device?
    storage_file
  end  
  
  def storage_device
    @device ||= Storage::Bay.new(name, :profile => storage_file) if storage_device?
  end
  
  def has_crontab?
    File.exists?(crontab_file)
  end
  
  def crontab_file
    File.join(datacenter.crondir,name)
  end
  
  def has_apache?
    File.directory?(apache_dir)
  end
  
  def apache_dir
    File.join(datacenter.apachedir,name)
  end
  
  def apache_files
    @apache_files ||= Dir.glob("#{self.apache_dir}/**/*.conf").map do |f|
      f.chomp.gsub(self.apache_dir,"").gsub(%r(^/),"")
    end.sort_by do |f|
      f.split("/")
    end
  end
  
  def virtual_hosts
    return @virtualhosts if defined?(@virtualhosts)
    @virtualhosts = []
    apache_files.each do |file|
      content = File.readlines("#{self.apache_dir}/#{file}")
      content = content.force_encoding('UTF-8') if content.respond_to?(:force_encoding)
      content.delete_if{|line| line.strip.start_with?('#')}
      content.join.scan(%r{<VirtualHost[^>]*>.*?</VirtualHost>}mi).each do |section|
        vhost = Apache::VirtualHost.new(section, :server => self, :file => file)
        @virtualhosts << vhost unless vhost.servername.blank?
      end
    end
    @virtualhosts
  end
end
