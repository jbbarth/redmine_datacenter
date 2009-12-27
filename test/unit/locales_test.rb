require File.dirname(__FILE__) + '/../test_helper'

class AppliTest < ActiveSupport::TestCase
  def test_locales_should_have_the_same_keys
    locale_keys = {}
    Dir.glob("config/locales/*.yml").each do |locale|
      locale_keys[locale] = File.open(locale).readlines.map(&:strip).delete_if do |line|
        line.match(/^#/) || line.match(/^$/)
      end.map do |line|
        line.split(":").first
      end.sort
    end
    #now let's delete keys present everywhere
    every_keys = locale_keys.values.flatten.uniq
    missing_keys = {}
    every_keys.each do |key|
      locale_keys.each_pair do |file,file_keys|
        unless file_keys.include?(key)
          missing_keys[file] ||= []
          missing_keys[file] << key
        end
      end
    end
    assert_equal({},missing_keys)
  end
end
