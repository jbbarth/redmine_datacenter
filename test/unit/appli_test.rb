require File.dirname(__FILE__) + '/../test_helper'

class AppliTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Appli.new(:name => "myappli").valid?
  end
end
