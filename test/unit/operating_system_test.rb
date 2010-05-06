require File.dirname(__FILE__) + '/../test_helper'

class OperatingSystemTest < ActiveSupport::TestCase
  fixtures :operating_systems

  def test_create
    assert !OperatingSystem.new.valid?
    assert OperatingSystem.new(:name => "OpenSolaris").valid?
  end
end
