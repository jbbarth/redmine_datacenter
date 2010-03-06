require File.dirname(__FILE__) + '/../test_helper'

class IpaddrTest < ActiveSupport::TestCase
  def test_to_range
    #we have a dirty patch for ruby < 1.8.7, let's test we can 
    #access to range.first and range.last
    range = IPAddr.new("192.168.0.0/255.255.255.0").to_range
    assert_equal "192.168.0.0", range.first.to_s
    assert_equal "192.168.0.255", range.last.to_s
  end

  def test_new_from_int
    assert IPAddr.respond_to?(:new_from_int)
    assert_raise ArgumentError do 
      IPAddr.new_from_int
    end
    assert_equal IPAddr.new_from_int("50"), IPAddr.new_from_int(50)
    assert_equal "192.168.0.1", IPAddr.new_from_int(IPAddr.new("192.168.0.1").to_i)
    assert_nil IPAddr.new_from_int(nil)
  end
end
