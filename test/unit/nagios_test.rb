require File.dirname(__FILE__) + '/../test_helper'

class NagiosTest < ActiveSupport::TestCase
  def setup
    statusfile = File.dirname(__FILE__) + '/../fixtures/third_party/nagios/status.dat'
    @status = Nagios::Status.new(statusfile)
  end

  def test_status
    assert_equal 7, @status.sections.length
  end

  def test_service_problem
    section = @status.service_problems.first
    assert section.is_a?(Hash)
    assert_equal "server-web", section[:host_name]
    assert section[:current_state].is_a?(Fixnum)
    assert_not_equal section[:current_state], Nagios::Status::STATE_OK
    assert_equal "SWAP", section[:service_description]
    assert_equal "Swap Space: 50%used(990MB/1984MB) (>40%) : WARNING", section[:plugin_output]
  end
end
