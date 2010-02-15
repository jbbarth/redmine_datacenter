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
end
