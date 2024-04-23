# Copyright 2022 Christian Gimenez
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
require 'disks'

class TestDiskInformationBlock < Minitest::Test
  def setup
    @disk = Disks::MV::MVDisk.from_file 'tests/data/test.dsk'
    @dib = @disk.dib
  end
  
  def test_descriptor    
    assert_equal "MV - CPCEMU Disk-File\r\nDisk-Info\r\n", @dib.descriptor
  end

  def test_creator_name
    assert_equal "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", @dib.creator_name
  end

  def test_track_count
    assert_equal 40, @dib.track_count
  end

  def test_side_count
    assert_equal 1, @dib.side_count    
  end

  def test_track_size
    assert_equal 4864, @dib.track_size
  end

  def test_track_range
    assert_equal 0 .. 4864, @dib.track_range(1)
    assert_equal 4864 .. 9728, @dib.track_range(2)
  end
end
