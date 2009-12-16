require File.dirname(__FILE__) + '/../test_helper'

class ServerTest < ActiveSupport::TestCase
  #fixtures :servers
  def test_should_be_valid
    assert Server.new(:name => "myserver").valid?
  end
end
