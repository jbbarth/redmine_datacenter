require File.dirname(__FILE__) + '/../test_helper'

class DatacenterTest < ActiveSupport::TestCase
  fixtures :datacenters, :applis, :instances, :servers, :projects

  def test_should_be_valid
    assert Datacenter.new(:name => "My Datacenter").valid?
  end

  def test_applis_number
    assert_equal 2, Datacenter.find(1).applis_number
  end

  def test_servers_number
    assert_equal 2, Datacenter.find(1).applis_number
  end

  def test_instances_number
    assert_equal 2, Datacenter.find(1).applis_number
  end
end
