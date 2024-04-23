# Copyright 2024 Christian Gimenez
#
# test_track.rb
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

# frozen_string_literal: true

require 'minitest/autorun'
require 'disks'

# Test TrackInformationBlock class.
class TestTrackInformationBlock < Minitest::Test
  def setup
    @disk = Disks::MV::MVDisk.from_file 'tests/data/test.dsk'
    @dib = @disk.dib
    @tib0 = @disk.track(1).tib
    @tib1 = @disk.track(2).tib
  end

  def test_descriptor
    assert_equal "Track-Info\r\n\0", @tib0.descriptor
    assert_equal "Track-Info\r\n\0", @tib1.descriptor
  end

  def test_number
    assert_equal 1, @tib0.number
    assert_equal 2, @tib1.number
  end

  def test_side
    assert_equal 1, @tib0.side
    assert_equal 1, @tib1.side
  end

  def test_sector_size
    assert_equal 2 * 256, @tib0.sector_size
    assert_equal 2 * 256, @tib1.sector_size
  end

  def test_sector_count
    assert_equal 9, @tib0.sector_count
    assert_equal 9, @tib1.sector_count
  end

  def test_gap_3_length
    assert_equal 0x4e, @tib0.gap_3_length
    assert_equal 0x4e, @tib1.gap_3_length
  end

  def test_filler_byte
    assert_equal [0xe5], @tib0.filler_byte.bytes
    assert_equal [0xe5], @tib1.filler_byte.bytes
  end
end
