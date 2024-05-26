# Copyright 2024 Christian Gimenez
#
# disk.rb
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

require_relative 'information_block'
require_relative 'track'

module ZXTools
  module MV2
    class Disk
      def initialize
        @dib = DiskInformationBlock.new
        @tracks = []
        init_tracks
      end

      attr_accessor :dib, :tracks

      def data
        data = ""
        @tracks.each do |track|
          data.concat track.data
        end

        data
      end

      def to_bin
        data = @dib.to_bin
        @tracks.each do |track|
          data.concat track.to_bin
        end

        data
      end

      def inspect
        "#<Disks::MV2::Disk>"
      end      
      
      class << self
        def from_bin(data)
          dib = DiskInformationBlock.from_bin data[0..0xff]
          lst_tracks = Track.lst_from_bin data[0x100..-1], dib.track_size, dib.track_count

          disk = Disk.new
          disk.dib = dib
          disk.tracks = lst_tracks

          disk
        end
      end

      private
      def init_tracks
        @dib.track_count.times do |tracknum|
          track = Track.new tracknum + 1
          track.new_empty_sector @dib.track_size - track.tib.tib_size, 0xff
          @tracks.push track
        end
      end
    end
  end
end
