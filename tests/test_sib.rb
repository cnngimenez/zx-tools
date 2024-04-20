# Copyright 2024 Christian Gimenez
#
# test_sib.rb
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

class TestSectorInformationBlock < Minitest::Test
  def setup
    @disk = Disks::MV::MVDisk.from_file 'tests/data/test.dsk'
    @dib = @disk.dib
    @sib0 = @disk.track(1).tib.sib(1)
    @sib1 = @disk.track(2).tib.sib(2)
  end

  def test_track
    assert_equal 1, @sib0.track
    assert_equal 2, @sib1.track
  end

  def test_side
    assert_equal 1, @sib0.side
    assert_equal 1, @sib1.side
  end

  def test_sector_id
    assert_equal 1, @sib0.sector_id
    assert_equal 2, @sib1.sector_id
  end

  def test_size
    assert_equal 512, @sib0.size
    assert_equal 512, @sib1.size
  end

  def test_fdc_status
    assert_equal [0, 0], @sib0.fdc_status.bytes
    assert_equal [0, 0], @sib1.fdc_status.bytes
  end
  
end
