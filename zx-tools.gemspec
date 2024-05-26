# Copyright 2024 Christian Gimenez
#
# zx-tools.gemspec
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

Gem::Specification.new do |s|
  s.name        = 'zx-tools'
  s.version     = '0.1.0'
  s.summary     = 'Tools to manage emulated diskette images'
  s.description = 'Tools to read, write, extract, or add files from/to an emulated diskette.'
  s.authors     = ["Christian Gimenez"]
  s.email       = [nil],
  s.files       = Dir[
    'lib/**/*.rb',
    'docs/*.org',
    'docs/*.info',
    'bin/**',
    'tests/**'
  ] + [
    'LICENSE',
    'README.org',
    'Gemfile',
    'Rakefile',
    'zx-tools.gemspec'
  ]
  s.homepage    = 'https://github.com/cnngimenez/zx-tools'
  s.license     = 'GPL-3.0'
end
