# Copyright 2021 Christian Gimenez
#
# blocks.rb
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

module Blocks
  # BlockManager
  class BlockManager
    def initialize(disk, blocksize=2048)
      @disk = disk
      @blocksize = blocksize
    end

    def block_pos(num)
      # why 2217?!
      offset = (num - 1) * @blocksize + 2217
      tracknum = offset / @disk.dib.track_size
      track_offset = offset - (tracknum * @disk.dib.track_size)
      { offset: offset,
        track_offset: track_offset,
        track: tracknum }
    end

  end
end
