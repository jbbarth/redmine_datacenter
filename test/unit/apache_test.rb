require File.dirname(__FILE__) + '/../test_helper'

class ApacheTest < ActiveSupport::TestCase
  fixtures :servers
  
  def setup
    @files = Dir.glob("test/fixtures/apache/*/*.conf")
    @server = Server.find(1)
    def @server.apache_dir; "."; end
    @server.instance_variable_set "@apache_files", @files
  end
  
  def test_virtualhosts
    vhost = @server.virtual_hosts.first
    assert_equal "bleh.example.net", vhost.servername
    assert_equal ["bleh.example.com"], vhost.serveraliases
    assert_equal 3, vhost.proxypasses.length
    assert_equal @server, vhost.server
    assert_equal "test/fixtures/apache/sites-enabled/virtual_host_ok.conf", vhost.file
  end
end
