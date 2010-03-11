require File.dirname(__FILE__) + '/../test_helper'

class InterfaceTest < ActiveSupport::TestCase
  fixtures :interfaces

  def test_new_valid
    int = Interface.new(:ipaddress => "192.168.0.1")
    assert int.valid?
    assert_equal "192.168.0.1", int.ipaddress
    assert_equal 3232235521, int.read_attribute(:ipaddress) #IPAddr.new("192.168.0.1").to_i
  end

  def test_invalid
    assert !Interface.new(:ipaddress => "192.168.0.1a").valid?
    assert !Interface.new(:ipaddress => "blah").valid?
    assert !Interface.new(:ipaddress => "").valid?
    assert !Interface.new(:name => "blah").valid?
  end
end
