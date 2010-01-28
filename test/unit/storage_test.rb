require File.dirname(__FILE__) + '/../test_helper'

class StorageTest < ActiveSupport::TestCase
  def test_bay_creation
    bay = Storage::Bay.new("DS4300")
    bay.load_profile_from_file("test/fixtures/storage/profile_ibm_ds4300.txt")
    assert bay.logical_drives.any?
    assert bay.arrays.any?
  end
end
