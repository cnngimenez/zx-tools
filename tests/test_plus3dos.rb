# Copyright 2024 Christian Gimenez
#
# test_plus3dos.rb
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

class TestPlus3DOS < Minitest::Test
  def test_to_bin
    data = File.binread 'tests/data/test.dsk', 0x80, 0x1d00
    header = ZXTools::Plus3DOS::Header.new
    header.length = 0x8c
    header.basic_header = "\0\x0c\0\0\x80\x0c\0\0"
    header.make_checksum!

    assert_equal data.bytes, header.to_bin.bytes
  end
end
