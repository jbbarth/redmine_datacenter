require File.dirname(__FILE__) + '/../test_helper'

class DatacenterTest < ActiveSupport::TestCase
  fixtures :datacenters, :applis, :instances, :servers, :projects

  def setup
    @datacenter = Datacenter.find(2)
  end

  def test_should_be_valid
    assert Datacenter.new(:name => "My Datacenter").valid?
  end

  def test_applis_number
    assert_equal 2, @datacenter.applis_number
  end

  def test_servers_number
    assert_equal 2, @datacenter.applis_number
  end

  def test_instances_number
    assert_equal 2, @datacenter.applis_number
  end

  def test_retrieve_fake_option
    assert_nil @datacenter.options[:undefined_key]
  end

  def test_fetch_activity
    activity = @datacenter.fetch_activity(:user => User.find(1),
                                          :types => %w(issues wiki_edits changesets),
                                          :limit => 3)
    assert_equal [3,2,1], activity[:issues].map(&:id)
    assert_equal Journal, activity[:issues].first.class
    assert_equal 3, activity[:wiki_edits].length
    assert_equal 3, activity[:changesets].length
  end
end
