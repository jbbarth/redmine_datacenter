require File.dirname(__FILE__) + '/../test_helper'

class OperatingSystemTest < ActiveSupport::TestCase
  fixtures :operating_systems

  def test_create
    assert !OperatingSystem.new.valid?
    assert OperatingSystem.new(:name => "OpenSolaris").valid?
  end

  def test_hypervisor_scope
    assert_equal 2, OperatingSystem.hypervisors.length
  end
end
