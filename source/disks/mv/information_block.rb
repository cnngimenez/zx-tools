# Copyright 2022 Christian Gimenez
#
# information_block.rb
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

module Disks
  module MV2
    # DiskInformationBlock class
    class DiskInformationBlock
      # This is the default descriptor according to CPCWiki.
      DEFAULT_DESCRIPTOR = "MV - CPCEMU Disk-File\r\nDisk-Info\r\n"

      # Create a disk information block with default values.
      def initialize
        @descriptor = DEFAULT_DESCRIPTOR
        @creator_name = "\x00" * 14
        @track_count = 40
        @side_count = 1
        @track_size = 4864
      end

      attr_accessor :descriptor, :creator_name, :track_count, :side_count, :track_size

      def to_bin
        [@descriptor, @creator_name,
         @track_count, @side_count,
         @track_size].pack 'A34A14CCS<x204'
      end

      class << self
        # Parse a binary string into a DiskInformationBlock instance.
        #
        # Interpret the binary data into a disk information block fields.
        #
        # @param str [String] A binary String.
        #
        # @return DiskInformationBlock instance.
        def from_bin(str)
          dib = DiskInformationBlock.new
          dib.descriptor, dib.creator_name, dib.track_count,
          dib.side_count, dib.track_size = str.unpack 'A34A14CCS<x204'
          dib
        end
      end
    end

    class TrackInformationBlock
      DEFAULT_DESCRIPTOR = "Track-Info\r\n\0"

      def initialize
        @descriptor = DEFAULT_DESCRIPTOR
        @number = 1
        @side = 1
        @sector_size = 512
        @gap_3_length = 78
        @filler_byte = "\xE5"
        @sib_list = SectorInformationBlock.create_empty_list 9
      end

      attr_accessor :descriptor, :number, :side, :sector_size,
                    :gap_3_length, :filler_byte, :sib_list

      def sector_count
        @sib_list.length
      end

      # Return the binary of the sector information block list.
      def sib_bin
        binlst = @sib_list.map(&:to_bin)
        binlst.join
      end

      def to_bin
        [@descriptor,
         @number - 1, @side - 1,
         @sector_size / 256,
         sector_count,
         @gap_3_length, @filler_byte,
         sib_bin].pack 'A13x3CCx2CCCA1a*'
      end

      class << self
        # Parse a binary string into a DiskInformationBlock instance.
        #
        # Interpret the binary data into a disk information block fields.
        #
        # @param str [String] A binary String.
        #
        # @return DiskInformationBlock instance.
        def from_bin(str)
          tib = TrackInformationBlock.new

          # sector_count is not parsed!
          tib.descriptor, number, side,
          sector_size,
          tib.gap_3_length, tib.filler_byte, sib_bin = str.unpack 'A13x3CCx2CxCA1a*'

          tib.number = number + 1
          tib.side = side + 1
          tib.sector_size = sector_size * 256

          tib.sib_list = SectorInformationBlock.from_lst_bin sib_bin

          tib
        end
      end
    end

    class SectorInformationBlock
      def initialize
        @track = 1
        @side = 1
        @sector_id = 1
        @sector_size = 512
        @fdc = [0, 0]
      end

      attr_accessor :track, :side, :sector_id, :sector_size, :fdc

      def to_bin
        [@track - 1, @side - 1, @sector_id, @sector_size / 256,
         @fdc[0], @fdc[1]].pack 'CCCCCCx2'
      end

      class << self
        # Create an empty list
        def create_empty_list(amount)
          lst = []
          amount.times do |index|
            sib = SectorInformationBlock.new
            sib.sector_id = index + 1
            lst.push sib
          end

          lst
        end

        def from_bin(str)
          sib = SectorInformationBlock.new

          track, side, sib.sector_id, size, fdc0, fdc1 = str.unpack 'CCCCCCx2'
          sib.track = track + 1
          sib.side = side + 1
          sib.sector_size = size * 256
          sib.fdc = [fdc0, fdc1]

          sib
        end

        def from_lst_bin(str)
          lst = []
          (str.length / 8).times do |index|
            istart = index * 8
            iend = istart + 8
            lst.push SectorInformationBlock.from_bin str[istart..iend]
          end
          lst
        end
      end
    end
  end
end
