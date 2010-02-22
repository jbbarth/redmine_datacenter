require File.dirname(__FILE__) + '/../test_helper'

class InterfaceTest < ActiveSupport::TestCase
  fixtures :interfaces

  def test_new_valid
    assert Interface.new(:ipaddress => "192.168.0.1").valid?
  end

  def test_invalid
    assert !Interface.new(:ipaddress => "192.168.0.1a").valid?
    assert !Interface.new(:ipaddress => "blah").valid?
    assert !Interface.new(:ipaddress => "").valid?
    assert !Interface.new(:name => "blah").valid?
  end
end
