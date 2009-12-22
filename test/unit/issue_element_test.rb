require File.dirname(__FILE__) + '/../test_helper'

class IssueElementTest < ActiveSupport::TestCase
  fixtures :issue_elements
  
  #see: http://www.inter-sections.net/2007/09/25/polymorphic-has_many-through-join-model/
  
  def setup
  end

  test "should have correct fixtures set up" do
    assert true
  end
end
