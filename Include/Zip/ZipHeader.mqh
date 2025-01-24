//+------------------------------------------------------------------+
//|                                                    ZipHeader.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"

#include "ZipDefines.mqh"

//+------------------------------------------------------------------+
//| Local file header based on specification 6.3.4:                  |
//| https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT,     |
//| 4.3.7                                                            |
//+------------------------------------------------------------------+
struct ZipLocalHeaderBase
{
   uint   header;                 // Zip local header, always equal 0x04034b50
   ushort version;                // Minumun version for extracting
   ushort bit_flag;               // Bit flag
   ushort comp_method;            // Compressed method (0 - uncompressed, 8 - deflate)
   ushort last_mod_time;          // File modification time
   ushort last_mod_date;          // File modification date
   uint   crc_32;                 // CRC-32 hash
   uint   comp_size;              // Compressed size
   uint   uncomp_size;            // Uncompressed size
   ushort filename_length;        // Length of the file name
   ushort extrafield_length;      // Length field with additional data
};

struct ZipLocalHeader : public ZipLocalHeaderBase
{
   bool   LoadFromCharArray(uchar& array[]);
   int    ToCharArray(uchar &array[]);
   ZipLocalHeader()/*: header(ZIP_LOCAL_HEADER),
                     version(10),
                     bit_flag(2),
                     comp_method(DEFLATE),
                     last_mod_time(0),
                     last_mod_date(0),
                     crc_32(0),
                     comp_size(0),
                     uncomp_size(0),
                     filename_length(0),
                     extrafield_length(0)
                     {;} */
  {
    this.header = ZIP_LOCAL_HEADER;
    this.version = 10;
    this.bit_flag = 2;
    this.comp_method = DEFLATE;
    this.last_mod_time = 0;
    this.last_mod_date = 0;
    this.crc_32 = 0;
    this.comp_size = 0;
    this.uncomp_size = 0;
    this.filename_length = 0;
    this.extrafield_length = 0;
  }
};
struct ZipLocalHeaderOpen : public ZipLocalHeaderBase
{
};
//+------------------------------------------------------------------+
//| Кастинг zip заголовка                                            |
//+------------------------------------------------------------------+
union UnionZipHeader
{
   ZipLocalHeaderOpen zip_header;
   uchar zip_header_array[sizeof(ZipLocalHeader)];
};
//+------------------------------------------------------------------+
//| Private struct for convert LocalHeader to uchar array             |
//+------------------------------------------------------------------+
struct ZipLocalHeaderArray
{
   uchar array[sizeof(ZipLocalHeader)];              // Size of ZipLocalHeader
};
//+------------------------------------------------------------------+
//| Convert ZipHeader struct to uchar array.                         |
//| RETURN:                                                          |
//|   Numbers of copied elements.                                    |
//+------------------------------------------------------------------+
int ZipLocalHeader::ToCharArray(uchar &array[])
{
   UnionZipHeader un_header;
   un_header.zip_header = this;
   return ArrayCopy(array, un_header.zip_header_array);
}
//+------------------------------------------------------------------+
//| Init local header structure from charr array                     |
//+------------------------------------------------------------------+
bool ZipLocalHeader::LoadFromCharArray(uchar &array[])
{
   if(ArraySize(array) != sizeof(ZipLocalHeader))
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   UnionZipHeader un_zip;
   ArrayCopy(un_zip.zip_header_array, array, 0, 0, WHOLE_ARRAY);
   this = un_zip.zip_header;
   if(header != ZIP_LOCAL_HEADER)
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   return true;
}

struct ZipCentralDirectoryBase
{
   uint   header;                 // Central directory header, always equal 0x02014B50
   ushort made_ver;               // Version made by
   ushort version;                // Minumun version for extracting
   ushort bit_flag;               // Bit flag
   ushort comp_method;            // Compressed method (0 - uncompressed, 8 - deflate)
   ushort last_mod_time;          // File modification time
   ushort last_mod_date;          // File modification date
   uint   crc_32;                 // CRC32 hash
   uint   comp_size;              // Compressed size
   uint   uncomp_size;            // Uncompressed size
   ushort filename_length;        // Length of the file name
   ushort extrafield_length;      // Length field with additional data
   ushort file_comment_length;    // length of comment file
   ushort disk_number_start;      // Disk number start
   ushort internal_file_attr;     // Internal file aatributes
   uint   external_file_attr;     // External file aatributes
   uint   offset_header;          // Relative offset of local header
};

//+------------------------------------------------------------------+
//| Central directory structure                                      |
//+------------------------------------------------------------------+
struct ZipCentralDirectory : public ZipCentralDirectoryBase
{
   bool   LoadFromCharArray(uchar &array[]);
   int    ToCharArray(uchar &array[]);
   ZipCentralDirectory()/* : header(ZIP_CENTRAL_HEADER),
                           made_ver(20),
                           version(10),
                           bit_flag(2),
                           comp_method(DEFLATE),
                           last_mod_time(0),
                           last_mod_date(0),
                           crc_32(0),
                           comp_size(0),
                           uncomp_size(0),
                           filename_length(0),
                           extrafield_length(0),
                           file_comment_length(0),
                           disk_number_start(0),
                           internal_file_attr(0),
                           external_file_attr(0)
                           {;} */
  {
    this.header = ZIP_CENTRAL_HEADER;
    this.made_ver = 20;
    this.version = 10;
    this.bit_flag = 2;
    this.comp_method = DEFLATE;
    this.last_mod_time = 0;
    this.last_mod_date = 0;
    this.crc_32 = 0;
    this.comp_size = 0;
    this.uncomp_size = 0;
    this.filename_length = 0;
    this.extrafield_length = 0;
    this.file_comment_length = 0;
    this.disk_number_start = 0;
    this.internal_file_attr = 0;
    this.external_file_attr = 0;
  }

};
struct ZipCentralDirectoryOpen : public ZipCentralDirectoryBase
{
};

union UnionZipZentralDirectory
{
   ZipCentralDirectoryOpen zip_dir;
   uchar zip_array[sizeof(ZipCentralDirectoryOpen)];
};
//+------------------------------------------------------------------+
//| Private struct for convert central directory to uchar array      |
//+------------------------------------------------------------------+
struct ZipCentralDirectoryArray
{
   uchar array[sizeof(ZipCentralDirectory)];              // Size of ZipCentralDirectory
};
//+------------------------------------------------------------------+
//| Init local header structure from charr array                     |
//+------------------------------------------------------------------+
bool ZipCentralDirectory::LoadFromCharArray(uchar &array[])
{
   if(ArraySize(array) != sizeof(ZipCentralDirectory))
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   UnionZipZentralDirectory un_zip_dir;
   ArrayCopy(un_zip_dir.zip_array, array);
   this = un_zip_dir.zip_dir;
   /*ZipCentralDirectoryArray zarray;
   ArrayCopy(zarray.array, array);
   this = (ZipCentralDirectory)zarray;*/
   if(header != ZIP_CENTRAL_HEADER)
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
//| Convert ZipHeader struct to uchar array.                         |
//| RETURN:                                                          |
//|   Numbers of copied elements.                                    |
//+------------------------------------------------------------------+
int ZipCentralDirectory::ToCharArray(uchar &array[])
{
   UnionZipZentralDirectory un_zip_dir;
   un_zip_dir.zip_dir = this;
   return ArrayCopy(array, un_zip_dir.zip_array);
   //ZipCentralDirectoryArray zarray = (ZipCentralDirectoryArray)this;
   //return ArrayCopy(array, zarray.array);
}

//+------------------------------------------------------------------+
//| End of central directory record structure                        |
//+------------------------------------------------------------------+
struct ZipEndRecordBase
{
   uint   header;                // Header of end central directory record, always equal 0x06054b50
   ushort disk_number;           // Number of this disk
   ushort disk_number_cd;        // Number of the disk with the start of the central directory
   ushort total_entries_disk;    // Total number of entries in the central directory on this disk
   ushort total_entries;         // Total number of entries in the central directory
   uint   size_central_dir;      // Size of central directory
   uint   start_cd_offset;       // Starting disk number
   ushort file_comment_length;   // File comment length
};

struct ZipEndRecord : public ZipEndRecordBase
{
   string FileComment(void);
   bool   LoadFromCharArray(uchar& array[]);
   int    ToCharArray(uchar &array[]);
   ZipEndRecord(void)/* : header(ZIP_END_HEADER),
                        disk_number(0),
                        disk_number_cd(0),
                        total_entries_disk(0),
                        total_entries(0),
                        size_central_dir(0),
                        start_cd_offset(0),
                        file_comment_length(0)
   {;} */
   {
     this.header = ZIP_END_HEADER;
     this.disk_number = 0;
     this.disk_number_cd = 0;
     this.total_entries_disk = 0;
     this.total_entries = 0;
     this.size_central_dir = 0;
     this.start_cd_offset = 0;
     this.file_comment_length = 0;
   }
};

struct ZipEndRecordOpen : public ZipEndRecordBase
{
};
union UnionZipEndRecord
{
   ZipEndRecordOpen zip_record;
   uchar zip_array[sizeof(ZipEndRecordOpen)];
};
//+------------------------------------------------------------------+
//| Private struct for convert end record structure to uchar array   |
//+------------------------------------------------------------------+
struct ZipEndRecordArray
{
   uchar array[sizeof(ZipEndRecord)];              // Size of zip end record
};
//+------------------------------------------------------------------+
//| Convert ZipHeader struct to uchar array.                         |
//| RETURN:                                                          |
//|   Numbers of copied elements.                                    |
//+------------------------------------------------------------------+
int ZipEndRecord::ToCharArray(uchar &array[])
{
   UnionZipEndRecord un_zip_rec;
   un_zip_rec.zip_record = this;
   return ArrayCopy(array, un_zip_rec.zip_array);
   //ZipEndRecordArray zarray = (ZipEndRecordArray)this;
   //return ArrayCopy(array, zarray.array);
}
//+------------------------------------------------------------------+
//| Load End Record structure from uchar array.                      |
//+------------------------------------------------------------------+
bool ZipEndRecord::LoadFromCharArray(uchar& array[])
{
   if(ArraySize(array) != sizeof(ZipEndRecord))
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   UnionZipEndRecord zip_end_rec;
   ArrayCopy(zip_end_rec.zip_array, array);
   this = zip_end_rec.zip_record;
   /*ZipEndRecordArray zer;
   ArrayCopy(zer.array, array);
   this = (ZipEndRecord)zer;*/
   if(header != ZIP_END_HEADER)
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   return true;
}