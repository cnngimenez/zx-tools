# Copyright 2024 Christian Gimenez
#
# test_disk.rb
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'minitest/autorun'
require 'zxtools'

class TestDisk2 < Minitest::Test

  # def setup    
  # end

  def test_empty_from_bin
    empty = File.binread 'tests/data/empty.dsk'
    # track1data = File.binread 'tests/data/empty.dsk', 0x180 - 0x200 , 0x200
    
    disk = ZXTools::MV2::Disk.from_bin empty
    # Test the DIB
    assert_equal 0x28, disk.dib.track_count
    assert_equal 0x01, disk.dib.side_count
    assert_equal 0x180, disk.dib.track_size
    # Test data
    # Should not test data because disk data is invalid (not formatted).
    # assert_equal track1data.bytes, disk.tracks[1].data.bytes
  end

  def test_formatted_from_bin
    formatted = File.binread 'tests/data/formatted-edited.dsk'
    track1data = File.binread 'tests/data/formatted-edited.dsk', (512 * 9), 0x200
    
    disk = ZXTools::MV2::Disk.from_bin formatted
    # Test the DIB
    assert_equal 0x28, disk.dib.track_count
    assert_equal 0x01, disk.dib.side_count
    assert_equal 0x1300, disk.dib.track_size
    # Test track 1
    assert_equal 512, disk.tracks[0].tib.sector_size
    assert_equal 9, disk.tracks[0].tib.sector_count
    assert_equal 9, disk.tracks[0].sectors.length
    assert_equal [0x01], disk.tracks[0].data[0].bytes
    assert_equal [49], disk.tracks[0].data[0x1ff].bytes
    assert_equal [57], disk.tracks[0].data[-1].bytes
    # Test data
    assert_equal (512 * 9), disk.tracks[0].data.length
    assert_equal track1data.length, disk.tracks[0].data.length
    assert_equal track1data.bytes, disk.tracks[0].data.bytes
  end
  
  # def test_empty_to_bin
  #   disk = ZXTools::MV2::Disk.new
  #   # File.binwrite '/tmp/empty-test.dsk', disk.to_bin
  #   assert_equal @empty.bytes, disk.to_bin.bytes
  # end
end
