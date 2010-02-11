require File.dirname(__FILE__) + '/../test_helper'

class DatacenterTest < ActiveSupport::TestCase
  #fixtures :datacenters
  def test_should_be_valid
    assert Datacenter.new(:name => "My Datacenter").valid?
  end
end
