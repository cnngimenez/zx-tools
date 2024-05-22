# Copyright 2024 Christian Gimenez
#
# cpm.rb
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

module CPM
  class Directory
    def initialize
      @entries = []
    end

    attr_accessor :entries

    def add(entry)
      @entries.push entry
    end

    def to_bin
      @entries.map(&:to_bin).join
    end

    private

    # Create a list of 32 byte-string elements from data.
    def split_data(data)
      lst = []
      i = 0
      while i < data.size
        lst.push data[i, 32]
        i += 32
      end
      lst
    end

    class << self
      def from_bin(data)
        dir = Directory.new

        split_data(data).map do |entry_data|
          dir.add Entry.from_bin(entry_data)
        end

        dir
      end
    end
  end

  class Entry
    def initialize(filename, extension = '', last_bytes = 0, pointers = [])
      @status = 0
      @filename = filename
      @extension = extension
      @last_bytes = last_bytes
      @pointers = pointers

      # File properties
      @read_only = false
      @system_file = false
      @archived = false
    end

    # Bytes used in the last extent.
    #
    # The total bytes is calculated as: last_bytes * 126
    attr_accessor :last_bytes

    attr_accessor :status, :filename, :extension, :pointers,
                  :read_only, :system_file, :archived

    def ext_to_bin
      ext = @extension.ljust(3).bytes
      ext[0] = ext[0] | 0b1000_0000 if @read_only
      ext[1] = ext[1] | 0b1000_0000 if @system_file
      ext[2] = ext[2] | 0b1000_0000 if @archived
      ext.pack('CCC')
    end

    # Assign filename and file properties from the given string.
    #
    # The file properties for filename is ignored. Therefore, the highest
    # bit is removed for each byte in this version.
    #
    # @todo Implement the filename properties (the high bit).
    #
    # Also, remove trailing right spaces.
    #
    # @param filename [String] The filename, but the highest bit in each byte
    #                          has the file property.
    def filename_with_props=(filename)
      @filename = filename.bytes.map do |c|
        b = c & 0b0111_1111
        b.chr
      end
      @filename = @filename.join.rstrip
    end

    def extension_with_props=(ext)
      ext2 = ext.bytes
      @extension = ext2.map do |c|
        b = c & 0b0111_1111
        b.chr
      end

      @read_only = !(ext2[0] & 0b1000_0000).nonzero?.nil?
      @system_file = !(ext2[1] & 0b1000_0000).nonzero?.nil?
      @archived = !(ext2[2] & 0b1000_0000).nonzero?.nil?

      @extension = @extension.join.rstrip
    end

    def to_bin
      lstp = @pointers.fill 0, @pointers.length, (16 - @pointers.length)
      lst = [@status, @filename.ljust(8), ext_to_bin, 0, 0, 0, @last_bytes].concat(lstp)
      lst.pack('CA8A3CCCCCCCCCCCCCCCCCCCC')
    end

    def to_s
      "#<CPM::Entry #{@filename}.#{@extension}>"
    end

    class << self
      def from_bin(data)
        status, filename, extension, last_bytes = data[0x0, 0x10].unpack 'CA8A3xxxC'
        pointers = data[0x10, 0x10].unpack 'CCCCCCCCCCCCCCCC'
        i = pointers.rindex(&:nonzero?)
        pointers = pointers[0, i + 1]

        e = Entry.new '', '', last_bytes, pointers
        e.filename_with_props = filename
        e.extension_with_props = extension
        e.status = status
        e
      end
    end
  end
end
