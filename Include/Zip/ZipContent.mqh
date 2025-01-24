//+------------------------------------------------------------------+
//|                                                   ZipContent.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include "ZipDefines.mqh"
#include "ZipHeader.mqh"

//+------------------------------------------------------------------+
//| Object container for private working                             |
//+------------------------------------------------------------------+
class CSourceZip
{
public:
   ZipLocalHeader       header;
   string               header_file_name;
   uchar                zip_array[];
   ZipCentralDirectory  directory;
   string               directory_file_name;
   bool                 IsFolder()
   {
      string ch = StringSubstr(header_file_name, StringLen(header_file_name)-1);
      return ch == "/";
   }
};

//+------------------------------------------------------------------+
//| Zip content types.                                               |
//+------------------------------------------------------------------+
enum ENUM_ZIP_TYPE
{
   ZIP_TYPE_DIRECTORY=1,
   ZIP_TYPE_FILE
};
//+------------------------------------------------------------------+
//| abstract base class for folders and files of zip archive.        |
//+------------------------------------------------------------------+
class CZipContent : public CObject
{
private:
              /*Private members*/
   ENUM_ZIP_TYPE        m_type;           // type of zip content: file or folder
   string               m_name;           // Name of zip folder or file
   int                  m_codepage;       // codepage for file name in HDD
                  
        /* Data and time convertors*/
   ushort               DosDate(datetime date);
   ushort               DosTime(datetime time);
   datetime             MqlDate(void);
   datetime             MqlTime(void);                      
protected:
   ZipCentralDirectory  m_directory;      // Central directory structure
   ZipLocalHeader       m_header;         // Local header structure
                        
                        CZipContent(ENUM_ZIP_TYPE type, string name);
                        CZipContent(CSourceZip& zip);
   void                 CompressedSize(uint size);
   void                 UncompressedSize(uint size);
public:
                        
            /*Service methods*/
   ENUM_ZIP_TYPE        ZipType(void);
   void                 Name(string name);
   string               Name(void);
   void                 CreateDateTime(datetime date_time);
   datetime             CreateDateTime(void);
   uint                 CompressedSize(void);
   uint                 UncompressedSize(void);
   virtual int          TotalSize(void);
   ushort               FileNameLength(void);
   virtual bool         UnpackOnDisk(string folder, int file_common);
   
        /*Convertors to uchar array*/
   virtual void         ToCharArrayHeader(uchar& array[]);
   virtual void         ToCharArrayDirectory(uchar& array[], uint offset_file_header);
};
//+------------------------------------------------------------------+
//| Protected constructor.                                           |
//+------------------------------------------------------------------+
CZipContent::CZipContent(ENUM_ZIP_TYPE type, string name)
{
   m_type = type;
   m_codepage = CP_ACP;
   Name(name);
}
//+------------------------------------------------------------------+
//| Retutn type of zip content.                                      |
//+------------------------------------------------------------------+
ENUM_ZIP_TYPE CZipContent::ZipType(void)
{
   return m_type;
}
//+------------------------------------------------------------------+
//| Set name for zip content                                         |
//+------------------------------------------------------------------+
void CZipContent::Name(string full_name)
{
   if(full_name == "")return;
   m_name = full_name;
   if(ZipType() == ZIP_TYPE_DIRECTORY)
      m_name += "/";
   m_header.filename_length = FileNameLength();
   m_directory.filename_length = FileNameLength();
}
//+------------------------------------------------------------------+
//| Get name for zip content                                         |
//+------------------------------------------------------------------+
string CZipContent::Name(void)
{
   return m_name;
}
//+------------------------------------------------------------------+
//| Get file name Length                                             |
//+------------------------------------------------------------------+
ushort CZipContent::FileNameLength(void)
{
   if(ZipType() == ZIP_TYPE_FILE)
      return (ushort)StringLen(m_name);
   else
      return (ushort)StringLen(m_name)+1;
}
//+---------------------------------------------------------------------------------+
//| Get data in MS-DOS format. See specification on:                                |
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms724247(v=vs.85).aspx |
//+---------------------------------------------------------------------------------+
ushort CZipContent::DosDate(datetime date)
{
   ushort dos_date = 0;
   MqlDateTime time = {0};
   TimeToStruct(date, time);
   if(time.year > 1980)
   {
      dos_date = (ushort)(time.year-1980);
      dos_date = dos_date << 9;
   }
   ushort mon = (ushort)time.mon << 5;
   dos_date = dos_date | mon;
   dos_date = dos_date | (ushort)time.day;
   return dos_date;
}
//+---------------------------------------------------------------------------------+
//| Get Time in MS-DOS format. See specification on:                                |
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms724247(v=vs.85).aspx |
//+---------------------------------------------------------------------------------+
ushort CZipContent::DosTime(datetime time)
{
   ushort date = 0;
   MqlDateTime mql_time = {0};
   TimeToStruct(time, mql_time);
   date = (ushort)mql_time.hour << 11;
   ushort min = (ushort)mql_time.min << 5;
   date = date | min;
   date = date | (ushort)(mql_time.sec/2);
   return date;
}
//+---------------------------------------------------------------------------------+
//| Get data in MQL format. See specification on:                                   |
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms724247(v=vs.85).aspx |
//+---------------------------------------------------------------------------------+
datetime CZipContent::MqlDate(void)
{
   MqlDateTime time = {0};
   ushort date = m_directory.last_mod_date;
   time.day = date & 0x1F;
   time.mon = date & 0xE0;
   time.year = 1980+(date & 0xFE00);
   return StructToTime(time);
}
//+---------------------------------------------------------------------------------+
//| Get data in MQL format. See specification on:                                   |
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms724247(v=vs.85).aspx |
//+---------------------------------------------------------------------------------+
datetime CZipContent::MqlTime(void)
{
   MqlDateTime time = {0};
   ushort date = m_directory.last_mod_time;
   time.sec = (date & 0x1F)*2;
   time.min = date & 0x7E0;
   time.hour = date & 0xF800;
   return StructToTime(time);
}
//+------------------------------------------------------------------+
//| Set create time for zip content                                  |
//+------------------------------------------------------------------+
void CZipContent::CreateDateTime(datetime date_time)
{
   m_header.last_mod_date = DosDate(date_time);
   m_header.last_mod_time = DosTime(date_time);
   m_directory.last_mod_date = DosDate(date_time);
   m_directory.last_mod_time = DosTime(date_time);
}
//+------------------------------------------------------------------+
//| Get create time for zip content                                  |
//+------------------------------------------------------------------+
datetime CZipContent::CreateDateTime(void)
{
   datetime date = MqlDate();
   datetime time = MqlTime();
   return date+time;
}
//+------------------------------------------------------------------+
//| Get compressed size                                              |
//+------------------------------------------------------------------+
uint CZipContent::CompressedSize(void)
{
   return m_header.comp_size;
}
//+------------------------------------------------------------------+
//| Get uncompressed size                                            |
//+------------------------------------------------------------------+
uint CZipContent::UncompressedSize(void)
{
   return m_header.uncomp_size;
}
//+------------------------------------------------------------------+
//| Set compressed size                                              |
//+------------------------------------------------------------------+
void CZipContent::CompressedSize(uint size)
{
   m_header.comp_size = size;
   m_directory.comp_size = size;
}
//+------------------------------------------------------------------+
//| Set uncompressed size                                            |
//+------------------------------------------------------------------+
void CZipContent::UncompressedSize(uint size)
{
   m_header.uncomp_size = size;
   m_directory.uncomp_size = size;
}
//+------------------------------------------------------------------+
//| Get uchar array local header of zip directory                    |
//+------------------------------------------------------------------+
void CZipContent::ToCharArrayHeader(uchar &array[])
{
   //if(ZipType() == ZIP_TYPE_DIRECTORY)
   //   m_header.bit_flag = 2;
   uchar header[], name[];
   m_header.ToCharArray(header);
   StringToCharArray(m_name, name, 0, FileNameLength(), m_codepage);
   ArrayResize(array, ArraySize(header) + ArraySize(name));
   ArrayCopy(array, header);
   ArrayCopy(array, name, ArraySize(header), 0);
}
//+------------------------------------------------------------------+
//| Get uchar array central directory of folder                      |
//+------------------------------------------------------------------+
void CZipContent::ToCharArrayDirectory(uchar& array[], uint offset_file_header)
{
   uchar header[], name[];
   m_directory.offset_header = offset_file_header;
   m_directory.ToCharArray(header);
   StringToCharArray(m_name, name, 0, FileNameLength(), m_codepage);
   ArrayResize(array, ArraySize(header) + ArraySize(name));
   ArrayCopy(array, header);
   ArrayCopy(array, name, ArraySize(header), 0);
}
//+------------------------------------------------------------------+
//| Create zip content from zip sources.                             |
//+------------------------------------------------------------------+
CZipContent::CZipContent(CSourceZip &zip_source)
{
   m_directory = zip_source.directory;
   m_header = zip_source.header;
   m_name = zip_source.header_file_name;
   uint att = zip_source.directory.external_file_attr;
   if((att & 16) == 16)
      m_type = ZIP_TYPE_DIRECTORY;
   else
      m_type = ZIP_TYPE_FILE;
}
//+------------------------------------------------------------------+
//| Unpack current zip content and save it as file on disk.          |
//+------------------------------------------------------------------+
bool CZipContent::UnpackOnDisk(string folder, int file_common)
{
   return false;   
}