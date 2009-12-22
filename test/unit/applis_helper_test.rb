require File.dirname(__FILE__) + '/../test_helper'
require 'action_view/test_case'

class ApplisHelperTest < ActionView::TestCase
  fixtures :applis, :instances

  def test_links_to_applis
    ary = [Appli.find(1), Instance.find(1), Instance.find(2)]
    assert_equal %q(<a href="/datacenter/applis/1">first_application</a>, <a href="/datacenter/applis/1">first_application(first-app-prod)</a>, <a href="/datacenter/applis/1">first_application(first-app-test)</a>),
                 links_to_applis(ary)
  end
end
