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

  def test_parsing
    p = @bays["DS4300"].parser
    assert (%w(infos arrays standard_logical_drives) - p.profile.keys).empty?
  end

  def test_arrays_parsing
    assert_equal 9, @bays["DS4300"].arrays.length
    #assert_equal 2, @bays["DS4100"].arrays.length
  end

  def test_arrays_values
    ary = @bays["DS4300"].arrays.detect{|a| a[:name] == "8"}
    assert_equal 39, ary.percent_used.to_i
    assert_equal 1997736391999, ary.size
    assert_equal 1213904860479, ary.free_space 
    assert_equal "5", ary[:raid]
    assert_equal "Serial ATA (SATA)", ary[:drive_type]
  end

  def test_logical_drives_parsing
    assert_equal 98, @bays["DS4300"].logical_drives.length
    #assert_equal 4, @bays["DS4100"].logical_drives.length
  end
end
