# Copyright 2024 Christian Gimenez
#
# test_cpm.rb
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
require 'cpm'

include CPM

class TestCPM < Minitest::Test
  # def setup
  # end

  def test_entry_ext_to_bin
    e = Entry.new  ''
    e.read_only = true
    e.system_file = true
    e.archived = true

    assert_equal [160, 160, 160], e.ext_to_bin.bytes
  end
  
  def test_entry_to_bin
    dir = File.binread 'tests/data/manual.dsk', 0x20, 0x1500
    e = Entry.new 'CLOCK', 'BAS', 0x10, [0x02, 0x03]
    
    assert_equal dir.bytes, e.to_bin.bytes
  end
  
  def test_directory_to_bin
    dir = File.binread 'tests/data/manual.dsk', 0x20, 0x1500
    mydir = Directory.new
    e = Entry.new 'CLOCK', 'BAS', 0x10, [0x02, 0x03]
    mydir.add e
    
    assert_equal dir.bytes, mydir.to_bin.bytes
  end
end
