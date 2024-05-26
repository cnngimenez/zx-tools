# Copyright 2024 Christian Gimenez
#
# test_information_block.rb
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
require 'zxtools'

class TestSectorInformationBlock2 < Minitest::Test
  def setup
    @dibbin2 = "MV - CPCEMU Disk-File\r\nDisk-Info\r\n" +
               "WHO\0\0\0\0\0\0\0\0\0\0\0" +
               "\x29\x02\x01\x13" +
               "\0" * 204
    @sibbin1 = "\x00\x00\x01\x00\x00\x00\0\0"
    @sibbin2 = "\x01\x02\x05\x00\x01\x02\0\0"
    @siblstbin = "\x01\x01\x01\x00\x01\x02\0\0" +
                 "\x01\x01\x02\x00\x01\x02\0\0" +
                 "\x01\x01\x03\x00\x01\x02\0\0"
    @tibbin1 = "Track-Info\r\n\0" +
               "\0\0\0" +
               "\x01\x02\0\0\x03\x03\x4E\xF5" +
               @siblstbin
    @dibbin = File.binread 'tests/data/empty.dsk', 0x100, 0x0
    @empty7 = File.binread 'tests/data/empty.dsk', 0x100, 0x700
    @dib = ZXTools::MV2::DiskInformationBlock.new
    @tib = ZXTools::MV2::TrackInformationBlock.new
    @sib = ZXTools::MV2::SectorInformationBlock.new
  end

  def test_dib_to_bin
    assert_equal @dibbin.bytes, @dib.to_bin.bytes
  end

  def test_dib_from_bin
    dib = ZXTools::MV2::DiskInformationBlock.from_bin @dibbin2
    assert_equal 'WHO', dib.creator_name
    assert_equal 41, dib.track_count, 41
    assert_equal 2, dib.side_count
    assert_equal 4865, dib.track_size
  end

  def test_sib_to_bin
    sib = ZXTools::MV2::SectorInformationBlock.new
    assert_equal @sibbin1.bytes, sib.to_bin.bytes
  end

  def test_sib_from_bin
    sib = ZXTools::MV2::SectorInformationBlock.from_bin @sibbin2
    assert_equal 2, sib.track
    assert_equal 3, sib.side
    assert_equal 5, sib.sector_id
    assert_equal 0, sib.sector_size
    assert_equal [1, 2], sib.fdc
  end

  def test_sib_from_lst_bin
    lst = ZXTools::MV2::SectorInformationBlock.from_lst_bin @siblstbin
    assert_equal 3, lst.length

    assert_equal 2, lst[0].track
    assert_equal 2, lst[0].side
    assert_equal 1, lst[0].sector_id
    assert_equal 0, lst[0].sector_size
    assert_equal [1, 2], lst[0].fdc

    assert_equal 2, lst[1].track
    assert_equal 2, lst[1].side
    assert_equal 2, lst[1].sector_id
    assert_equal 0, lst[1].sector_size
    assert_equal [1, 2], lst[1].fdc

    assert_equal 2, lst[2].track
    assert_equal 2, lst[2].side
    assert_equal 3, lst[2].sector_id
    assert_equal 0, lst[2].sector_size
    assert_equal [1, 2], lst[2].fdc
  end

  def test_tib_empty_from_bin
    tib = ZXTools::MV2::TrackInformationBlock.from_bin @empty7

    assert_equal "Track-Info\r\n", tib.descriptor
    assert_equal 6, tib.number
    assert_equal 1, tib.side
    assert_equal 0, tib.sector_size
    assert_equal 78, tib.gap_3_length
    assert_equal [0xe5], tib.filler_byte.bytes
    assert_equal 1, tib.sector_count
    assert_equal 1, tib.sib_list.length
  end
  
  def test_tib_to_bin
    tib = ZXTools::MV2::TrackInformationBlock.new
    tib.number = 2
    tib.side = 3
    tib.sector_size = 3 * 256
    tib.gap_3_length = 78
    tib.filler_byte = "\xf5"
    tib.sib_list = ZXTools::MV2::SectorInformationBlock.from_lst_bin @siblstbin

    assert_equal @tibbin1.bytes, tib.to_bin.bytes
  end
  
  def test_tib_from_bin
    tib = ZXTools::MV2::TrackInformationBlock.from_bin @tibbin1
    
    assert_equal "Track-Info\r\n", tib.descriptor
    assert_equal 2, tib.number
    assert_equal 3, tib.side
    assert_equal 3 * 256, tib.sector_size
    assert_equal 78, tib.gap_3_length
    assert_equal [0xf5], tib.filler_byte.bytes
    assert_equal 3, tib.sib_list.length
  end
end
