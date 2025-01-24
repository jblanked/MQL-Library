//+------------------------------------------------------------------+
//|                                                      ZipFile.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "ZipDefines.mqh"
#include "ZipContent.mqh"

//+------------------------------------------------------------------+
//| Class-container for zip-file                                     |
//+------------------------------------------------------------------+
class CZipFile : public CZipContent
{
private:
   uchar          m_file_puck[];             // array of pack file
protected:
                  CZipFile();
   uint           CRC32(uchar& array[]);
public:
                  CZipFile(CSourceZip& zip);
                  CZipFile(string path_file, int file_common);
                  CZipFile(string name, uchar& file_src[]);
   bool           AddFile(string full_path, int common);
   bool           AddFileArray(uchar& file_src[]);
   void           GetPackFile(uchar& file_array[]);
   void           GetUnpackFile(uchar& file_array[]);
   virtual bool   UnpackOnDisk(string folder, int file_common);
   
};
//+------------------------------------------------------------------+
//| Create zip-file from file array and name                         |
//+------------------------------------------------------------------+
CZipFile::CZipFile(string path_file,int file_common) : CZipContent(ZIP_TYPE_FILE, "")
{
   AddFile(path_file, file_common);
}
//+------------------------------------------------------------------+
//| Create zip-file from file array and name                         |
//+------------------------------------------------------------------+
CZipFile::CZipFile(string name, uchar &file_src[]) : CZipContent(ZIP_TYPE_FILE, name)
{
   AddFileArray(file_src);
}
//+------------------------------------------------------------------+
//| Create zip file from hdd file.                                   |
//+------------------------------------------------------------------+
bool CZipFile::AddFile(string full_path, int file_common)
{
   ResetLastError();
   int handle = FileOpen(full_path, FILE_READ|FILE_BIN|file_common);
   if(handle == INVALID_HANDLE)return false;
   uchar file[];
   uint count = FileReadArray(handle, file);
   if(count < 1)
   {
      SetUserError(ZIP_ERROR_EMPTY_SOURCE);
      FileClose(handle);
      return false;
   }
   FileClose(handle);
   bool res = AddFileArray(file);
   if(res)
      Name(full_path);
   return res;
}
//+------------------------------------------------------------------+
//| Add file array and zip it.                                       |
//+------------------------------------------------------------------+
bool CZipFile::AddFileArray(uchar &file_src[])
{
   ResetLastError();
   ArrayResize(m_file_puck, 0);
   CompressedSize(0);
   UncompressedSize(0);
   CreateDateTime(TimeCurrent());
   if(ArraySize(file_src) < 1)
   {
      SetUserError(ZIP_ERROR_EMPTY_SOURCE);
      return false;
   }
   uchar key[]={1,0,0,0};
   CryptEncode(CRYPT_ARCH_ZIP, file_src, key, m_file_puck);
   if(ArraySize(m_file_puck) < 1)
   {
      SetUserError(ZIP_ERROR_BAD_PACK_ZIP);
      return false;
   }
   UncompressedSize(ArraySize(file_src));
   CompressedSize(ArraySize(m_file_puck));
   uint crc32 = CRC32(file_src);
   m_header.crc_32 = crc32;
   m_directory.crc_32 = crc32;
   return true;
}
//+------------------------------------------------------------------+
//| Get pack file.                                                   |
//+------------------------------------------------------------------+
void CZipFile::GetPackFile(uchar &file_array[])
{
   ArrayCopy(file_array, m_file_puck);
}
//+------------------------------------------------------------------+
//| Get unpack file.                                                 |
//+------------------------------------------------------------------+
void CZipFile::GetUnpackFile(uchar &file_array[])
{
   uchar key[]={1,0,0,0};
   CryptDecode(CRYPT_ARCH_ZIP, m_file_puck, key, file_array);
}
//+------------------------------------------------------------------+
//| Create zip-file from zip sources data.                           |
//+------------------------------------------------------------------+
CZipFile::CZipFile(CSourceZip &zip_source) : CZipContent(zip_source)
{
   ArrayCopy(m_file_puck, zip_source.zip_array);
}
//+------------------------------------------------------------------+
//| Unpack folder on Disk                                            |
//+------------------------------------------------------------------+
bool CZipFile::UnpackOnDisk(string folder,int file_common)
{
   if(folder != "" && !FolderCreate(folder))
      return false;
   int handle = FileOpen(folder + "\\" + Name(), FILE_BIN|FILE_WRITE|file_common);
   if(handle == INVALID_HANDLE)
      return false;
   uchar src[];
   GetUnpackFile(src);
   FileWriteArray(handle, src);
   FileClose(handle);
   return true;
}
//+------------------------------------------------------------------+
//| Return CRC-32 sum on source data 'array'                         |
//+------------------------------------------------------------------+
uint CZipFile::CRC32(uchar &array[])
{
   uint crc_table[256];
   ArrayInitialize(crc_table, 0);
   uint crc = 0;
   for (int i = 0; i < 256; i++)
   {
      crc = i;
      for (int j = 0; j < 8; j++)
         crc = (crc & 1) > 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
      crc_table[i] = crc;
   }
   crc = 0xFFFFFFFF;
   int len = 0, size = ArraySize(array);
   while(len < size)
      crc = crc_table[(crc ^ array[len++]) & 0xFF] ^ (crc >> 8);
   return crc ^ 0xFFFFFFFF;
}
