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

    class << self
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

    def file_size(block_size)
      blocks = @pointers.count(&:nonzero?)
      (blocks - 1) * block_size + @last_bytes * 0x100
    end

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
      ext2 = ext.rjust(3).bytes
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
        i = -1 if i.nil?
        pointers = pointers[0, i + 1]

        e = Entry.new '', '', last_bytes, pointers
        e.filename_with_props = filename
        e.extension_with_props = extension
        e.status = status
        e
      end
    end
  end

  class Block
    DEFAULT_FILLER_BYTE = 0xe5
    DEFAULT_SIZE = 0x400
    
    def initialize(number, data, filler_byte = DEFAULT_FILLER_BYTE,
                   max_size = DEFAULT_SIZE)
      @number = number
      @data = data
      @filler_byte = filler_byte
      @size = max_size
      trim_data!
    end

    attr_accessor :number, :data, :filler_byte

    # The size of the block.
    #
    # This is the size with filler bytes.
    attr_accessor :size

    # Remove filler bytes at the end of data.
    def trim_data!
      last = @data.bytes.rindex do |b|
        b != @filler_byte
      end
      return if last.nil?

      @data = @data[0, last + 1]
    end

    class << self
      def from_bin(data, max_size=0x400, filler_byte = 0xe5)
        count = data.length / max_size
        return [] unless count.positive?

        lst = []
        ending = -1
        count.times do |i|
          beg = ending + 1
          ending = beg + max_size - 1
          lst.push Block.new i, data[beg..ending], filler_byte, max_size
        end

        lst
      end
    end
  end
end
