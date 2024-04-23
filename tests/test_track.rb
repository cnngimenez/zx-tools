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
require 'track'
require 'sector'
require 'information_block'

class TestTrack2 < Minitest::Test
  def setup
    # Complete first track with sector data (0x1400...0x2700).
    @data1 = File.binread 'tests/data/test.dsk', 0x1300, 0x1400    
    @empty7 = File.binread 'tests/data/empty.dsk', 0x100, 0x700
    # First sector of track 1. 
    @sector0 = File.binread 'tests/data/test.dsk', 512, 0x1500
    @sector5 = File.binread 'tests/data/test.dsk', 512, 0x1d00
  end

  def test_empty_from_bin
    track = Disks::MV2::Track.from_bin @empty7
    assert_equal 6, track.number
    assert_equal 1, track.side
    assert_equal 1, track.sectors.length    
  end
  
  def test_from_bin
    track = Disks::MV2::Track.from_bin @data1
    assert_equal 9, track.sectors.length
    assert_equal @sector0.bytes, track.sectors[0].to_bin.bytes
    assert_equal 512, track.sectors[0].to_bin.length
    assert_equal @sector5.bytes, track.sectors[4].to_bin.bytes
    assert_equal 512, track.sectors[4].to_bin.length
  end

  def test_to_bin
    track = Disks::MV2::Track.new 6, 1
    sib = Disks::MV2::SectorInformationBlock.new
    # SIB track and sector_id has no explanation in recently created dsk...
    # For some reason, new DSK files has one sector, with no size, track = 3,
    # and its ID is 0xfe.
    sib.sector_id, sib.track = 0xfe, 3     
    sector = Disks::MV2::Sector.new
    sector.sector_size = 0
    track.add_sector sector, sib

    assert_equal @empty7.bytes, track.to_bin.bytes
  end
end
