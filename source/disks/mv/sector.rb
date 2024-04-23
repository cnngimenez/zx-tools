# Copyright 2024 Christian Gimenez
#
# sector.rb
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

module Disks
  module MV2
    class Sector
      DEFAULT_FILLER_BYTE = "\xe5"
      
      def initialize
        @sector_size = 0
        @filler_byte = DEFAULT_FILLER_BYTE
        @data = ""
      end

      attr_accessor :sector_size, :filler_byte, :data

      def to_bin
        data = @data.clone

        if data.length < @sector_size
          data.concat(@filler_byte * (@sector_size - data.length))
        else
          data[0..@sector_size - 1]
        end
      end

      class << self
        # Create Sector instances from several SIB and data.
        #
        # A SectorInformationBlock (SIB) has the data size field. Calculate the start and end of
        # the data of each sector and create the Sector instances from a list of SIB.
        #
        # @param sib_list [Array[SectorInformationBlock]] Information about the sector data to extract.
        # @param data [String] Binary String.
        # @param filler_byte [String] A String with one char to fill the sector if incomplete.
        #
        # @return Array[Sector]
        def from_bin_with_sib(sib_list, data, filler_byte = DEFAULT_FILLER_BYTE)
          sectors = []
          iend = -1
          sib_list.each do |sib|
            istart = iend + 1
            iend = istart + sib.sector_size - 1
            sectors.push Sector.from_bin(data[istart..iend], filler_byte)
          end
          sectors
        end
        
        # Create a Sector instance from binary data.
        #
        # @param data [String] The binary string data.
        # @para filler_byte [String] A string with one character. This is the filler to mark empty bytes.
        def from_bin(data, filler_byte = DEFAULT_FILLER_BYTE)
          s = Sector.new
          s.data = data
          s.filler_byte = filler_byte
          s
        end
      end
    end
  end
end
