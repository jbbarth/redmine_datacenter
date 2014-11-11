require 'uri'

class Apache::VirtualHost
  attr_accessor :server, :file, :content,
                :servername, :serveraliases, :proxypasses
   
  include Redmine::I18n
  
  def initialize(section, options = {})
    @@resolver ||= Redmine::Resolver.new
    @content = section
    section = section.force_encoding('UTF-8') if section.respond_to?(:force_encoding)
    parse_servername!
    parse_serveraliases!
    parse_proxypasses!
    @server = options[:server] if options[:server]
    @file = options[:file] if options[:file]
  end
  
  private
  
  def parse_servername!
    @servername ||= @content.scan(/ServerName\s+(\S+)/).first.try(:first)
  end
  
  def parse_serveraliases!
    return @serveraliases if @serveraliases
    @serveraliases = []
    @content.split("\n").grep(/ServerAlias/).each do |line|
      serveralias = line.scan(/ServerAlias\s+(\S+)/).first.try(:first)
      @serveraliases << serveralias unless serveralias.blank?
    end
    @serveraliases
  end
  
  def parse_proxypasses!
    return @proxypasses if @proxypasses
    @proxypasses = []
    @content.split("\n").grep(/ProxyPass\s/).each do |line|
      proxypass = {}
      proxypass[:line] = line
      realserver = line.scan(/ProxyPass\s+\S+\s+(\S+)/i).first.try(:first)
      if realserver == "!"
        proxypass[:dns] = []
      else
        realserver.gsub!("_", "--UNDERSCORE--")
        realserver = URI.parse(realserver).host
        realserver.gsub!("--UNDERSCORE--", "_")
        begin
          chain = @@resolver.deeplook(realserver)
          chain.shift
          proxypass[:dns] = chain
        rescue
          proxypass[:dns] = [l(:label_no_dns_record_for, :value => realserver)]
        end
      end
      @proxypasses << proxypass
    end
    @proxypasses
  end
end
