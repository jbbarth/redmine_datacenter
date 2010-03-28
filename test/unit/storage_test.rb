require File.dirname(__FILE__) + '/../test_helper'

class StorageTest < ActiveSupport::TestCase
  include Storage::Utils

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
    assert_equal 2, @bays["DS4100"].arrays.length
  end

  def test_arrays_values
    #ds4300
    ary = @bays["DS4300"].arrays.detect{|a| a[:name] == "8"}
    assert_equal 10, ary[:logical_drives].length
    assert_equal 39, ary.percent_used.to_i
    assert_equal 1997736391999, ary.size
    assert_equal 1213904860479, ary.free_space 
    assert_equal "5", ary[:raid]
    assert_equal "Serial ATA (SATA)", ary[:drive_type]
    #ds4100
    ary = @bays["DS4100"].arrays.detect{|a| a[:name] == "1"}
    assert_equal 2, ary[:logical_drives].length
    assert_equal 100, ary.percent_used.to_i
    assert_equal 1247588141499, ary.size
    assert_equal 0, ary.free_space 
    assert_equal "5", ary[:raid]
    assert_equal "Serial ATA (SATA)", ary[:drive_type]
  end

  def test_logical_drives_parsing
    assert_equal 98, @bays["DS4300"].logical_drives.length
    assert_equal 4, @bays["DS4100"].logical_drives.length
  end

  def test_parse_size
    to_test = {
      "56,234 GB (14 Bytes)"        => 14,
      "10,000 KB (blah Bytes)"      => 10240000,
      "10 000 KB (blah Bytes)"      => 10240000,
      "10,000 KB (43 242 Bytes)"    => 43242,
      "577"                         => 577,
      "1 KB"                        => 1024,
      "1 MB"                        => 1024**2,
      "1 GB"                        => 1024**3,
      "1 TB"                        => 1024**4,
      "1 PB"                        => 1024**5,
      "37,39 GB"                    => 37.39*1024**3,
      "22,284 GB"                   => 22.284*1024**3,
      "235,079 GB"                  => 235.079*1024**3,
      "953,572 GB (1 023 890 138 112 Bytes)" => 1023890138112,
      "9,329 GB (10 016 522 240 Bytes)" => 10016522240,
      "11,293 GB (12 125 732 864 Bytes)" => 12125732864,
      "203.597 GB (218,610,794,496 Bytes)" => 218610794496,
      "5 GB (5,368,709,120 Bytes)" => 5368709120,
      "2.501 GB"                    => 2.501*1024**3,
      "112.641 GB"                  => 112.641*1024**3

    }
    to_test.each do |k,v|
      assert_equal v.round, parse_size(k), "Bad parsing for #{k}"
    end
  end
end
