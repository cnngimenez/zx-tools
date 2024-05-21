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

    attr_accessor :status, :filename, :extension, :pointers

    attr_accessor :read_only, :system_file, :archived

    def ext_to_bin
      ext = @extension.ljust(3).bytes
      ext[0] = ext[0] | 0b1000_0000 if @read_only
      ext[1] = ext[1] | 0b1000_0000 if @system_file
      ext[2] = ext[2] | 0b1000_0000 if @archived
      ext.pack('CCC')
    end

    def to_bin
      lstp = @pointers.fill 0, @pointers.length, (16 - @pointers.length)
      lst = [@status, @filename.ljust(8), ext_to_bin, 0, 0, 0, @last_bytes].concat(lstp)
      lst.pack('CA8A3CCCCCCCCCCCCCCCCCCCC')
    end
  end

end
