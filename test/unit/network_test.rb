require File.dirname(__FILE__) + '/../test_helper'

class NetworkTest < ActiveSupport::TestCase
  def test_should_be_valid
    [
      {:name => "My network", :address => "192.168.2.0", :netmask => "24"},
      {:name => "The return of my network", :address => "192.168.3.0", :netmask => "255.255.255.0"}
    ].each do |opts|
      assert Network.new(opts).valid?
    end
  end
  
  def test_should_not_be_valid
    [
      {:name => "", :address => "192.168.2.0", :netmask => "24"},
      {:name => "My network", :address => "192.168.2", :netmask => "24"},
      {:name => "My network", :address => "192.168.2.0", :netmask => "aa"},
      {:name => "My network", :address => "192.168.2.0"}
    ].each do |opts|
      puts Network.new(opts).errors.inspect if Network.new(opts).valid?
      assert !Network.new(opts).valid?
    end
  end

  def test_include
    network = Network.new(:name => "My network", :address => "192.168.2.0", :netmask => "24")
    assert network.include?("192.168.2.1")
    assert network.include?("192.168.2.0")
    assert !network.include?("192.168.3.1")
    assert !network.include?("aaa")
    assert !network.include?(nil)
  end

  def test_first_last_and_broadcast
    network = Network.new(:name => "My network", :address => "192.168.2.0", :netmask => "24")
    assert_equal "192.168.2.1", network.first
    assert_equal "192.168.2.254", network.last
    assert_equal "192.168.2.255", network.broadcast
  end

  def test_ipaddress_and_mask_storage
    network = Network.new(:name => "My network", :address => "192.168.2.0", :netmask => "24")
    assert_equal "192.168.2.0", network.address
    assert_equal 3232236032, network.read_attribute(:address) #IPAddr.new("192.168.2.0").to_i
    assert_equal "255.255.255.0", network.netmask
    assert_equal 4294967040, network.read_attribute(:netmask) #IPAddr.new("255.255.255.0").to_i
  end
end
