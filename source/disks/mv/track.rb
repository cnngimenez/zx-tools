# Copyright 2024 Christian Gimenez
#
# track.rb
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

require_relative 'information_block'
require_relative 'sector'

module Disks
  module MV2
    # Track representation
    #
    # A track is composed by the TrackInformationBlock (TIB) and its sectors.
    class Track
      def initialize(number = 1, side = 1)
        @tib = TrackInformationBlock.new
        @tib.number = number
        @tib.side = side
        @sectors = []
      end

      attr_accessor :tib, :sectors

      def number
        @tib.number
      end

      def side
        @tib.side
      end

      def data
        @sectors.map(&:data).join
      end

      # Return the real data of sectors.
      #
      # This means, return all sectors data that would be stored on the
      # disk, without filler bytes.
      #
      # @see Disks::MV2::Sector#real_data
      def real_data
        @sectors.map(&:real_data).join
      end

      def add_sector(sector, sib = nil)
        @sectors.push sector
        @tib.add_sib sib unless sib.nil?
      end

      def new_empty_sector(size, filler_byte)
        sector = Sector.new
        sector.sector_size = size
        sector.filler_byte = filler_byte

        add_sector sector
      end

      def to_bin
        @tib.fill_sibs @sectors.length
        data = @tib.to_bin
        @sectors.each do |sector|
          sector.filler_byte = @tib.filler_byte
          sector.sector_size = @tib.sector_size
          data.concat sector.to_bin
        end
        data + "\0" * (0x100 - data.length)
      end

      class << self
        # Create a Track from binary data.
        #
        # @return Track instance.
        def from_bin(data)
          tib = TrackInformationBlock.from_bin data

          # TIB length = 0x100. Sector data starts after TIB last byte.
          sectors = Sector.from_bin_with_sib tib.sib_list, data[0x100..-1], tib.filler_byte

          track = Track.new
          track.tib = tib
          track.sectors = sectors
          track
        end

        def lst_from_bin(data, track_size, track_count)
          tracks = []
          iend = -1
          track_count.times do
            istart = iend + 1
            iend = istart + track_size - 1
            trackdata = data[istart..iend]
            tracks.push Track.from_bin trackdata unless trackdata.nil?
          end

          tracks
        end
      end
    end
  end
end
