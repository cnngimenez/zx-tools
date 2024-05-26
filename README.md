
# Table of Contents

1.  [What is it?](#org59fe191)
2.  [What can I do with this?](#org671c9bf)
3.  [What is the objective?](#org0a2d05e)
4.  [Programs](#org58cc456)
5.  [How to use in development?](#orgbcd9670)
    1.  [API Documentation](#org8b3eb78)
    2.  [Install gem](#orgc8dcbb2)
    3.  [Run tests](#org458330e)
6.  [License](#org44686b0)


<a id="org59fe191"></a>

# What is it?

These are tools to read and modify ZX Spectrum diskette images.


<a id="org671c9bf"></a>

# What can I do with this?

It provides the following features:

-   [X] Extract files from a diskette image.
-   [X] List files inside the diskette.
-   [X] Show disk, tracks, and sectors information.
-   [X] Show blocks data.
-   [ ] Add files to a diskette images.
-   Provide a Ruby API to read and modify diskette images pragmatically.
-   A complete documentation about the diskette image format.


<a id="org0a2d05e"></a>

# What is the objective?

Programming inside a ZX Spectrum emulator is fun. But, sometimes, you want to use you usual editor, to see get the file, study it, mess with the binary code, etc.

[The atari800 emulator](https://github.com/atari800/atari800/) has a particular feature for this: it is possible to assign a specific directory from the host computer as the unit H1, H2, etc. Thus, a file saved on H1 through the emulator, will appear on a directory on the host machine.

[The Fuse emulator](http://fuse-emulator.sourceforge.net/fuse.php) does not have this possibility, but it can use cassettes and diskettes image files. Also, the emulator does not provide any means to read or extract the file from the images through programs on the host machine.

So, the objective can be explained as this: Read/edit file in host &harr; zxtools &harr; Fuse emulator.
The idea is to make it possible to read and edit files using nowadays tools, and at the same time, that it can be processed by the Fuse emulator too. In order to do this, the zxtools is needed as intermediary.


<a id="org58cc456"></a>

# Programs

All programs are in the bin directory. This is a Ruby Gem file, so it is supposed to be installed in your home directory with `gem install` utility.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">bin/listdir</td>
<td class="org-left">Print all diskette files</td>
</tr>


<tr>
<td class="org-left">bin/zxblock</td>
<td class="org-left">Print binary data from a specific block</td>
</tr>


<tr>
<td class="org-left">bin/zxdisk</td>
<td class="org-left">Show diskette image information</td>
</tr>


<tr>
<td class="org-left">bin/zxdiskdata</td>
<td class="org-left">Print binary data of the whole diskette image</td>
</tr>


<tr>
<td class="org-left">bin/zxtracks</td>
<td class="org-left">Show all tracks header information</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">(sector sizes, sector count, track number, etc.)</td>
</tr>
</tbody>
</table>


<a id="orgbcd9670"></a>

# How to use in development?


<a id="org8b3eb78"></a>

## API Documentation

As any other Ruby code, `rdoc` can be used to generate the documentation inside a specific directory in the source code. Just change dir inside the zx-tools cloned repository and run rdoc.

    rdoc -o api-docs
    firefox api-docs/index.html


<a id="orgc8dcbb2"></a>

## Install gem

See [&ldquo;Make your own gem&rdquo; guide at rubygems.org](https://guides.rubygems.org/make-your-own-gem/) for information about how to create the gem. In summary, the gem must be built first, then it can be installed. The following commands should work:

    gem build zx-tools.gempsec
    gem install ./zx-tools-*.gem


<a id="org458330e"></a>

## Run tests

    rake test


<a id="org44686b0"></a>

# License

This work is under the GNU General Public License version 3 (GPLv3) except where specified.

The source code of the program CLOCK.BAS inside the disk file tests/data/manual.dsk, is the Clock program which source code where obtained from The Sinclair ZX Spectrum +3 manual, copyright Amstrad Plc. The manual was found at:

<https://worldofspectrum.net/ZXSpectrum128+3Manual/index.html>

The Basic source code of Clock can be found at Chapter 8 Part 33, under the following URL:

<https://worldofspectrum.net/ZXSpectrum128+3Manual/chapter8pt33.html>

Both URL were available and visited on April 20, 2024.

