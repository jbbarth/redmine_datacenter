require File.dirname(__FILE__) + '/../test_helper'

class InstanceTest < ActiveSupport::TestCase
  fixtures :instances, :applis
  def test_should_be_valid
    assert Instance.new(:name => "myinstance").valid?
  end

  def test_fullname
    assert_equal Instance.find(1).fullname, "first_application(first-app-prod)"
  end
end
