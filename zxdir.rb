# Copyright 2021 Christian Gimenez
#
# zxdir.rb
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

# The ZX Directory and DirectoryEntry
#
# Implemented according the CPCWiki.
module Zxdir
  # The ZX Media Directory.
  #
  # This class can interpret a portion of data used by the ZX Spectrum to list
  # files inside a media (i.e. a disk). It usually resides at the begining of
  # the disks.
  class Directory
    def initialize(data)
      @data = data
    end

    attr_reader :data

    # Get a directory entry.
    #
    # @param num [Integer] The directory entry number. Starts from 1.
    # @return [DirectoryEntry]
    def entry(num)
      dbegin = (num - 1) * 32 + 169
      dend = dbegin + 32
      DirectoryEntry.new @data[dbegin..dend]
    end

    def entry_count
      (@data.length - 169) / 32
    end

    def entries
      (1..entry_count).to_a.map do |num|
        entry num
      end
    end

    def inspect
      '#<Directory>'
    end

    class << self
      def from_disk(disk)
        t = disk.track 2
        Directory.new t.sector_data1 1
      end
    end
  end

  # A DirectoryEntry instance used by the Directory.
  class DirectoryEntry
    def initialize(data)
      @data = data
    end

    attr_reader :data

    def status
      @data[0].unpack1 'C'
    end

    def filename
      bytes = @data[1..8].bytes.map do |b|
        b & 0b0111_1111
      end
      bytes.pack 'C*'
    end

    def extension
      bytes = @data[9..11].bytes.map do |b|
        b & 0b0111_1111
      end
      bytes.pack 'C*'
    end

    def attributes
      @data[1..11].bytes.map do |b|
        (b & 0b1000_0000) != 0
      end
    end

    # Hashed version of the file attribute with the meaning of the relevant bits.
    #
    # Get the relevant bits and create a hash with their meaning.
    #
    # @param type [Symbol] :p2dos, :zsdos or :backgrounder2. Default is :zsdos
    # @return [Hash] The attritues where the key are the meanings and values are
    #   true/false if the attribute is setted/unsetted.
    def attributes_hash(type = :zsdos)
      b = attributes
      hash = DirectoryEntry.common_attributes b

      case type
      when :backgrounder2
        hash.merge DirectoryEntry.backgrounder_attributes(b)
      when :zsdos
        hash.merge DirectoryEntry.zsdos_attributes(b)
      when :p2dos
        hash.merge DirectoryEntry.p2dos_attributes(b)
      end
    end

    def extent_number
      x = @data[14] + @data[12]
      x.unpack 'C'
    end

    def data_length
      [@data[13].unpack1('C'), @data[15].unpack1('C')]
    end

    def block_pointers
      @data[16..31].bytes
    end

    def inspect
      "#<DirectoryEntry file=\"#{filename}.#{extension}\">"
    end

    class << self
      def common_attributes(bytes)
        { read_only: bytes[8],
          system_file: bytes[9],
          archived: bytes[10] }
      end

      def backgrounder_attributes(bytes)
        { requires_wheel: bytes[0],
          foreground_only_cmd: bytes[1],
          background_only_cmd: bytes[2] }
      end

      def zsdos_attributes(bytes)
        { public: bytes[1],
          datestamp: bytes[2],
          wheel_protect: bytes[7] }
      end

      def p2dos_attributes(bytes)
        { public: bytes[1] }
      end
    end
  end
end
