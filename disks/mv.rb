# coding: utf-8
# Copyright 2021 Christian Gimenez
#
# mv.rb
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
  module MV
    # MV Disk class.
    #
    class MVDisk
      # Create a new MV Disk instance
      #
      # @param data [String]
      def initialize(data)
        @dib = DiskInformationBlock.new data[0x00..0xff]
        @data = data[0x100..data.length]
      end

      attr_reader :dib, :data

      class << self
        def from_file(path)
          File.open path, 'rb' do |file|
            MVDisk.new file.read
          end
        end
      end

      def to_s
        'MVDisk'
      end

      def track(num)
        trange = @dib.track_range num
        Track.new @data[trange.begin..trange.end - 0x100]
      end
    end

    # Disk Information Block class.
    class DiskInformationBlock
      def initialize(data)
        @data = data
      end

      attr_reader :data

      def descriptor
        @data[0x00..0x21]
      end

      def creator_name
        @data[0x22..0x2f]
      end

      def track_count
        @data[0x30].unpack1 'C'
      end

      def side_count
        @data[0x31].unpack1 'C'
      end

      def track_size
        @data[0x32..0x33].unpack1 'S<'
      end

      # Disk Information Block: Not used bytes.
      def not_used
        @data[0x34..0xff]
      end

      # @return The track begining and ending position.
      def track_range(num, offset = 0)
        offset + track_size * (num - 1)..offset + track_size * num
      end
    end

    # Track class
    class Track
      def initialize(data)
        tib_end = TrackInformationBlock.tib_end data
        @tib = TrackInformationBlock.new data[0x00..tib_end]
        @data = data[tib_end..data.length]
      end

      attr_reader :tib, :data

      def inspect
        "#<Track number=#{@tib.number} side=#{@tib.side}>"
      end
    end

    # Track Information Block
    class TrackInformationBlock
      def initialize(data)
        @data = data
      end

      attr_reader :data

      def descriptor
        @data[0x00..0x0c]
      end

      # Track number
      def number
        @data[0x10].unpack1('C') + 1
      end

      def side
        @data[0x11].unpack1('C') + 1
      end

      def sector_size
        @data[0x14].unpack1 'C'
      end

      def sector_count
        @data[0x15].unpack1 'C'
      end

      def gap_3_length
        @data[0x16].unpack1 'C'
      end

      def filler_byte
        @data[0x17]
      end

      # Sector information list
      #
      # @return [String]
      def sil_data
        @data[0x18..0x18 + sector_count * 0x07]
      end

      # @return [Array] An array of SectorInformationBlock
      def sil
        data = sil_data
        lst = []
        init = 0x00
        ending = 0x07
        sector_count.times do
          lst.append SectorInformationBlock.new data[init..ending]
          init = ending + 1
          ending = init + 0x07
        end
        lst
      end

      # @param num [Integer] Sector number (first sector is 1, not 0).
      # @return [SectorInformationBlock]
      def sib(num)
        init = 0x18 + (num - 1) * 0x07
        ending = 0x18 + num * 0x07
        SectorInformationBlock.new @data[init..ending]
      end

      class << self
        # Where is the Track Information Block ending address?
        #
        # The Track Information Block depends on the sector count, which is specified
        # at the 0x15 byte. Retrieve this information from the data and calculate the
        # ending address of the information block.
        #
        # @param data [String] The data used for initializing the
        #   TrackInformationBlock instance. The 0x00 address is the starting address
        #   for the information block.
        # @return [Integer] The address where the Track Information Block ends.
        def tib_end(data)
          sector_count = data[0x15].unpack1 'C'
          # Track information is up to 0x18. Sector Information List is from 0x18.
          0x18 + sector_count * 0x07
        end
      end
    end

    # Sector
    class Sector
      # Initialize the Sector instance.
      #
      # The sector information block is on the TrackInformationBlock, not above the
      # sector data.
      #
      # @param sib [SectorInformationBlock]
      # @param data [String]
      def initialize(sib, data)
        @sib = sib
        @data = data[0x00..@sib.size]
      end
    end

    # Sector Information Block
    class SectorInformationBlock
      STATUS_REG_1 = {
        0Xb7 => 'End of cylinder',
        0xb5 => 'Data error',
        0xb2 => 'No data',
        0xb0 => 'Missing address mark'
      }.freeze
      STATUS_REG_2 = {
        0Xb5 => 'Control mark or data error in data field',
        0xb0 => 'Missing address mark in data field'
      }.freeze

      # @param data [String]
      def initialize(data)
        @data = data
      end

      # Track number where the sector is.
      def track
        @data[0x00]
      end

      # Side of the disk where the sector is.
      def side
        @data[0x01]
      end

      # Sector ID
      def sector_id
        @data[0x02]
      end

      # Sector size
      def size
        @data[0x03]
      end

      # FDC status register 1 and 2.
      def fdc_status
        @data[0x04..0x05]
      end

      # Not used data in the sector block.
      def not_used
        @data[0x06..0x07]
      end
    end
  end
end
