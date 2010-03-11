require File.dirname(__FILE__) + '/../test_helper'

class ServerTest < ActiveSupport::TestCase
  #fixtures :servers
  def test_should_be_valid
    assert Server.new(:name => "myserver").valid?
  end

  def test_ipaddress
    assert_nil Server.new.ipaddress
    assert_nil Server.find(1).ipaddress
    #see ServersController#index
    joins = ["LEFT JOIN interfaces_servers ON interfaces_servers.server_id = servers.id",
             "LEFT JOIN interfaces ON interfaces_servers.interface_id = interfaces.id"]
    server = Server.first(:select => "servers.*, interfaces.ipaddress",
                          :joins => joins,
                          :conditions => ["servers.id = ?", 1])
    assert_equal "3232235521", server.attributes["ipaddress"]
    assert_equal "192.168.0.1", server.ipaddress
  end
end
