require 'uri'

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
  
  named_scope :active, :conditions => { :status => STATUS_ACTIVE }, :order => 'name asc'
  named_scope :for_datacenter, lambda {|datacenter_id| {:conditions => ["datacenter_id = ?", datacenter_id]}}
  named_scope :hypervisors, :include => :operating_system, 
                            :conditions => { 'operating_systems.hypervisor' => true },
                            :order => 'servers.name asc'
  
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
    resolver = Redmine::Resolver.new
    apache_files.each do |file|
      content = File.readlines("#{self.apache_dir}/#{file}")
      content.delete_if{|line| line.match(/^\s*#/)}
      content.join.scan(%r{<VirtualHost[^>]*>.*?</VirtualHost>}mi).each do |section|
        servername = section.scan(/ServerName\s+(\S+)/)
        serveraliases = []
        section.split("\n").grep(/ServerAlias/).each do |line|
          serveralias = line.scan(/ServerAlias\s+(\S+)/).to_s
          serveraliases << serveralias unless serveralias.blank?
        end
        proxypasses = []
        section.split("\n").grep(/ProxyPass\s/).each do |line|
          proxypass = {}
          proxypass[:line] = line
          realserver = line.scan(/ProxyPass\s+\S+\s+(\S+)/i).to_s
          if realserver == "!"
            proxypass[:dns] = []
          else
            realserver = URI.parse(realserver).host
            begin
              proxypass[:dns] = r.deeplook(realserver).drop(1)
            rescue
              proxypass[:dns] = [l(:label_no_dns_record_for,realserver)]
            end
          end
          proxypasses << proxypass
        end
        unless servername.blank?
          @virtualhosts << {:server => self,
                            :file => file,
                            :servername => servername,
                            :serveraliases => serveraliases,
                            :proxypasses => proxypasses,
                            :content => section }
        end
      end
    end
    @virtualhosts
  end
end
