# Copyright 2024 Christian Gimenez
#
# plus3dos.rb
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

module ZXTools
  module Plus3DOS
    class Header
      def initialize
        @soft_eof = 0x1a
        @issue = 1
        @version = 0
        @length = 0
        @basic_header = '\0' * 8
        @checksum = 0x00
      end

      attr_accessor :soft_eof, :issue, :version, :length, :basic_header, :checksum

      def make_checksum
        sum = to_bin[0..-2].bytes.sum
        sum % 256
      end
      
      def make_checksum!
        @checksum = make_checksum
      end

      # Is the checksum correct?
      def check_checksum?        
        @checksum == make_checksum
      end
      
      def to_bin
        lst = ["PLUS3DOS", @soft_eof,
               @issue, @version,
               @length, @basic_header,
               @checksum] 
        lst.pack 'A8CCCL<a8x104C'
      end
    end
  end
end
