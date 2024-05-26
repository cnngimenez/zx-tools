
# Table of Contents

1.  [Disk image](#orgdd1d484)
    1.  [Implementation Conventions](#orgd528a19)
    2.  [Disk Information Block (DIB)](#orgb93542f)
    3.  [Track information block (TIB)](#org9833cc7)
    4.  [Sector Information Block (SIB)](#orgb9b6070)
2.  [Directory](#org62d7122)
    1.  [St - Status value](#orge1af1e9)
    2.  [F0-F7 and E0-E2 - Filename](#orge9924a5)
    3.  [Xl and Xh - Extent number](#org0d47f84)
    4.  [Rc - Bytes used](#org4afe386)
    5.  [Al - Pointers](#org8b80545)
    6.  [File size calculation](#orgc05be87)
3.  [Blocks](#org3e3f87d)
4.  [Bibliography](#org08acbc7)


<a id="orgdd1d484"></a>

# Disk image

The dsk format is a hardware representation. A disk is divided in sides, which in turn it has tracks and each track has sectors.

-   sides
    -   tracks
        -   sectors

On the file image, each track and each sector has a header or an "information block". It describes their representation. For instance, the track/sector size, the current track and side number, etc. The track information block is at the begining of each track, but the sector information block is inside the information block (not at the begining of the sector).


<a id="orgd528a19"></a>

## Implementation Conventions

A disk block or structure is represented as a class. It has a `@data` attribute which contains the complete binary information. The data type used to store binary information is a String (not an Array instance). The `#unpack` method that String class possess is useful to convert bytes into integer, real, or other Ruby values. Also, several methods are implemented for each field the structure has, that access directly to the `@data` attribute at the specific offset simply by using indexing techniques.

For instance, the information block is implemented as `Disks::MV::DiskInformationBlock` class. Its `@data` contains all the 256 bytes of information block. A method `#creator_name` is implemented to access to `@data` from byte number 22<sub>16</sub> to number 2f<sub>16</sub>. The creator name is a string, and thus no data type conversion is required. However, `#track_size` and `#track_count` methods are implemented to convert its bytes into a Ruby integer value.

The **number conventions** are the following:

-   Track number starts with 1. In binary data starts with 0;
-   Side number starts with 1. In binary data starts with 0;
-   Sector id number starts with 1. In binary data starts with 1.


<a id="orgb93542f"></a>

## Disk Information Block (DIB)

The Information Block is the first structure found on a disk file. To identify it from other files, the MV String first 8 bytes can be used, which is "MV - CPC". The complete MV String is: `"MV - CPCEMU Disk-File\r\nDisk-Info\r\n"` (without ending zero char).

The block structure is described at Table [1](#org446f5ad). Its size is 256 (100<sub>16</sub>) bytes, which it starts at byte 0, and ends at byte 100<sub>16</sub>

The **size of track** filed is expressed with little-endian representation. Thus, low byte is followed by the high byte. Its usual value is 4864 bytes (`"\x00\x13"` as a Ruby string).

<table id="org446f5ad" border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 1:</span> Information block structure. <a href="https://cpctech.cpcwiki.de/docs/dsk.html">Obtained from CPCWiki</a>.</caption>

<colgroup>
<col  class="org-right" />

<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">offset</th>
<th scope="col" class="org-left">description</th>
<th scope="col" class="org-right">bytes</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-right">00-21</td>
<td class="org-left">MV String</td>
<td class="org-right">34</td>
</tr>


<tr>
<td class="org-right">22-2f</td>
<td class="org-left">name of creator</td>
<td class="org-right">14</td>
</tr>


<tr>
<td class="org-right">30</td>
<td class="org-left">number of tracks</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">31</td>
<td class="org-left">number of sides</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">32-33</td>
<td class="org-left">size of track</td>
<td class="org-right">2</td>
</tr>


<tr>
<td class="org-right">34-ff</td>
<td class="org-left">not used</td>
<td class="org-right">204</td>
</tr>
</tbody>
</table>

The disk information block is represented by the class `Disks::MV::DiskInformationBlock`. 


<a id="org9833cc7"></a>

## Track information block (TIB)

The **Track String** is "Track-Info\r\n\\0". Comparing to the MV String of a Disk Information Block, in this case a zero character must be added to the end, to complete the field length of 13 bytes. 

The **sector size** field size is 1 byte. Therefore, it is a number between 0 to 255, which it cannot specify the complete size in bytes of the sector. This byte value must be multiplied by 256 according to CPCWiki (see [CPCWiki article](https://www.cpcwiki.eu/index.php?title=Format:DSK_disk_image_file_format&mobileaction=toggle_view_desktop)). The usual value is 2 (512 bytes or 200<sub>16</sub> bytes).

The **number of sectors** is represented as `sector_count` identifier in the implementation. Its usual value is 9. This means, the usual track size is $512 \times{} 9 = 4608$ bytes (1200<sub>16</sub> Bytes).

Also, the **GAP3 length** can be found as `gap_3_length` in the implementation. The common value is 78.

The **filler byte** is an example of the byte used to fill the track when there is no information in it. In other words, it indicates that that byte is empty. The track structure has the size indicated by the DIB structure. Thus, all the bytes are completely reserved in the file, whether it is with information or with a filler byte.

The **sector information list** has one Sector Information Block structure per number of sectors. A **Sector Information Block** (SIB) is an 8 byte register that describes the sector. It has the sector size which can be used to calculate the sector position relative to the current track.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 2:</span> Track information block structure. <a href="https://cpctech.cpcwiki.de/docs/dsk.html">Obtained from CPCWiki</a>.</caption>

<colgroup>
<col  class="org-right" />

<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">offset</th>
<th scope="col" class="org-left">description</th>
<th scope="col" class="org-right">bytes</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-right">00-0c</td>
<td class="org-left">Track String</td>
<td class="org-right">13</td>
</tr>


<tr>
<td class="org-right">0d-0f</td>
<td class="org-left">unused</td>
<td class="org-right">3</td>
</tr>


<tr>
<td class="org-right">10</td>
<td class="org-left">track number</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">11</td>
<td class="org-left">side number</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">12-13</td>
<td class="org-left">unused</td>
<td class="org-right">2</td>
</tr>


<tr>
<td class="org-right">14</td>
<td class="org-left">sector size</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">15</td>
<td class="org-left">number of sectors</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">16</td>
<td class="org-left">GAP3 length</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">17</td>
<td class="org-left">filler byte</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">18-xx</td>
<td class="org-left">Sector information list</td>
<td class="org-right">xx</td>
</tr>
</tbody>
</table>

The track information block is represented by the class `Disks::MV:TrackInformationBlock`. The track itself is another class: `Disks::MV::Track`.


<a id="orgb9b6070"></a>

## Sector Information Block (SIB)

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 3:</span> Sector information block structure. <a href="https://cpctech.cpcwiki.de/docs/dsk.html">Obtained from CPCWiki</a>.</caption>

<colgroup>
<col  class="org-right" />

<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">offset</th>
<th scope="col" class="org-left">description</th>
<th scope="col" class="org-right">bytes</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-right">00</td>
<td class="org-left">track</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">01</td>
<td class="org-left">side</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">02</td>
<td class="org-left">sector ID</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">03</td>
<td class="org-left">sector size</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">04</td>
<td class="org-left">FDC status register 1</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">05</td>
<td class="org-left">FDC status register 2</td>
<td class="org-right">1</td>
</tr>


<tr>
<td class="org-right">06-07</td>
<td class="org-left">not used</td>
<td class="org-right">2</td>
</tr>
</tbody>
</table>

The **sector size** is calculated as in the TIB. 

The sector information block is represented by the class `Disks::MV:SectorInformationBlock`. The sector itself is another class: `Disks::MV::Sector`.


<a id="org62d7122"></a>

# Directory

The directory is a list of files positioned at the begining of the disk (at track 2 usually). Each directory entry has 32 bytes with the following meaning:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 4:</span> </caption>

<colgroup>
<col  class="org-left" />
</colgroup>

<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Bytes</th>
<th scope="col" class="org-left">0</th>
<th scope="col" class="org-left">1</th>
<th scope="col" class="org-left">2</th>
<th scope="col" class="org-left">3</th>
<th scope="col" class="org-left">4</th>
<th scope="col" class="org-left">5</th>
<th scope="col" class="org-left">6</th>
<th scope="col" class="org-left">7</th>
<th scope="col" class="org-left">8</th>
<th scope="col" class="org-left">9</th>
<th scope="col" class="org-left">A</th>
<th scope="col" class="org-left">B</th>
<th scope="col" class="org-left">C</th>
<th scope="col" class="org-left">D</th>
<th scope="col" class="org-left">E</th>
<th scope="col" class="org-left">F</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">St</td>
<td class="org-left">F0</td>
<td class="org-left">F1</td>
<td class="org-left">F2</td>
<td class="org-left">F3</td>
<td class="org-left">F4</td>
<td class="org-left">F5</td>
<td class="org-left">F6</td>
<td class="org-left">F7</td>
<td class="org-left">E0</td>
<td class="org-left">E1</td>
<td class="org-left">E2</td>
<td class="org-left">Xl</td>
<td class="org-left">Bc</td>
<td class="org-left">Xh</td>
<td class="org-left">Rc</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
<td class="org-left">Al</td>
</tr>
</tbody>
</table>

-   **St:** The status value and file's user number.
-   **F0-F7:** The file name and file attributes at the highest bit of each byte.
-   **E0-E2:** The file extension and file attributes at the highest bit of each byte.
-   **Xl:** Extent number, lower byte.
-   **Bc:** Number of bytes used in last record.
-   **Xh:** Extent number, higher byte.
-   **Rc:** Number of 128 byte records of the last used logical extent.
-   **Al:** 16 bytes of Block pointers.

See the [Disk Structure article at CPCWiki](https://www.cpcwiki.eu/index.php/Disk_structure) for more information.


<a id="orge1af1e9"></a>

## St - Status value

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 5:</span> Value of the St byte.</caption>

<colgroup>
<col  class="org-right" />

<col  class="org-right" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-right">0</td>
<td class="org-right">15</td>
<td class="org-left">File: user number</td>
</tr>


<tr>
<td class="org-right">16</td>
<td class="org-right">31</td>
<td class="org-left">File: user number (P2DOS) or password extent</td>
</tr>


<tr>
<td class="org-right">32</td>
<td class="org-right">32</td>
<td class="org-left">Disk label</td>
</tr>


<tr>
<td class="org-right">33</td>
<td class="org-right">33</td>
<td class="org-left">Time stamp (P2DOS)</td>
</tr>


<tr>
<td class="org-right">229</td>
<td class="org-right">229</td>
<td class="org-left">Erased or unused (hex: 0xE5)</td>
</tr>
</tbody>
</table>


<a id="orge9924a5"></a>

## F0-F7 and E0-E2 - Filename

The highest bit of the filename characters are the attribute.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
<caption class="t-above"><span class="table-number">Table 6:</span> File name highest bit meanings.</caption>

<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Character</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">F0</td>
<td class="org-left">Wheel byte</td>
</tr>


<tr>
<td class="org-left">F1</td>
<td class="org-left">Public file (P2DOS, ZSDOS), foreground-only command</td>
</tr>


<tr>
<td class="org-left">F2</td>
<td class="org-left">Date stamp (ZSDOS), background-only command</td>
</tr>


<tr>
<td class="org-left">F7</td>
<td class="org-left">Wheel protect (ZSDOS)</td>
</tr>


<tr>
<td class="org-left">E0</td>
<td class="org-left">Read-only file</td>
</tr>


<tr>
<td class="org-left">E1</td>
<td class="org-left">System file</td>
</tr>


<tr>
<td class="org-left">E2</td>
<td class="org-left">Archived</td>
</tr>
</tbody>
</table>


<a id="org0d47f84"></a>

## Xl and Xh - Extent number

One file can use more than one directory entry.


<a id="org4afe386"></a>

## Rc - Bytes used

This is the bytes used by this extent.

The total bytes (T) used in the extent is calculated as $T = Rc \times{} 80_{16}$ ($T = Rc \times{}  126$).


<a id="org8b80545"></a>

## Al - Pointers

The pointers established which blocks stores the file. The offset address stored at the pointer value can be calculated as  $D + Al \times{} 400_{16}$, where $D$ is the directory address. The offset does not consider track and 

The directory is considered to start at block 0. It is the first byte, but considering the track and disk information block, it should be at address 0x1500 under usual circumstances (sector size of 512 and 9 sectors per track, 512 &times; 9 = 4608 bytes per track).


<a id="orgc05be87"></a>

## File size calculation

In overall, considering that $Pc$ is the pointers count, $Bz$ is the block size and $Rc$ is the value in the Rc field. The file size in bytes is calculated as follows.

$$(Pc - 1) \times{} Bz + Rc \times{} 128$$

&#9888;&#65039; The CAT command provides sizes in KB (or Kb).

&#9888;&#65039; The result is an approximated value.


<a id="org3e3f87d"></a>

# Blocks

The data (without headers) is divided by blocks. The block size can be 1024, 2048, 4096, 8192 or 16384, but the usual value is 2048.


<a id="org08acbc7"></a>

# Bibliography

-   "Disk image file format". CPCWiki document.
    
    <https://cpctech.cpcwiki.de/docs/dsk.html>
    
    Visited April 19, 2024.

-   "Format:DSK disk image file format". CPCWiki article.
    
    <https://www.cpcwiki.eu/index.php?title=Format:DSK_disk_image_file_format>
    
    Visited April 19, 2024.

-   "Disk Structure". CPCWiki.
    
    <https://www.cpcwiki.eu/index.php/Disk_structure>
    
    Visited April 19, 2024.

