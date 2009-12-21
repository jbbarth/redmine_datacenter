require File.dirname(__FILE__) + '/../test_helper'

class InstanceTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Instance.new(:name => "myinstance").valid?
  end
end
