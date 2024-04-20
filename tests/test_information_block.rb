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
require 'information_block'

class TestSectorInformationBlock2 < Minitest::Test
  def setup
    @dib = Disks::MV2::DiskInformationBlock.new
    @tib = Disks::MV2::TrackInformationBlock.new
    @sib = Disks::MV2::SectorInformationBlock.new
  end

  def test_dib_defaults
    dibbin = "MV - CPCEMU Disk-File\r\nDisk-Info\r\n" +
             "\0\0\0\0\0\0\0\0\0\0\0\0\0\0" +
             "\x28\x01\x00\x13" +
             "\0" * 204
    assert_equal 256, dibbin.length 
    assert_equal dibbin, @dib.to_bin
  end
  
end
