require File.dirname(__FILE__) + '/../test_helper'

class StorageTest < ActiveSupport::TestCase
  def setup
    @bays = {}
    Dir.glob("test/fixtures/storage/*").each do |f|
      name = File.basename(f)
      @bays[name] = Storage::Bay.new(name)
      @bays[name].load_profile_from_file(f)
    end
  end

  def test_bay_creation
    assert_equal [Storage::Bay], @bays.values.map(&:class).uniq
  end

  def test_arrays_parsing
    assert_equal 9, @bays["DS4300"].arrays.length
  end

  def test_logical_drives_parsing
    assert_equal 98, @bays["DS4300"].logical_drives.length
  end
end
