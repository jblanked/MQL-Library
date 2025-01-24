//+------------------------------------------------------------------+
//|                                                          Zip.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Dictionary.mqh>
#include "ZipDefines.mqh"
#include "ZipHeader.mqh"
#include "ZipDirectory.mqh"
#include "ZipFile.mqh"
//+------------------------------------------------------------------+
//| Object char array container for private working                  |
//+------------------------------------------------------------------+
class CCharArray : public CObject
{
private:
      uchar m_array[];
public:
   CCharArray(uchar& array[])
   {
      ArrayCopy(m_array, array);
   }
   void GetArray(uchar& array[])
   {
      ArrayCopy(array, m_array);
   }
};
//+------------------------------------------------------------------+
//| Object uint container for private working                        |
//+------------------------------------------------------------------+
class CIntValue : public CObject
{
public:   
        CIntValue(void){;}
        CIntValue(uint value){offset = value;}
   uint offset;
};

//+------------------------------------------------------------------+
//| Class for working with zip-archives                              |
//+------------------------------------------------------------------+
class CZip
{
private:
   enum           ENUM_ZIP_PART        // Part of zip archive
   {
                  ZIP_PART_HEADER,     // Header part
                  ZIP_PART_DIRECTORY   // Directory part
   };
   int            m_size;
   CArrayObj      m_archive;
   CDictionary    m_names;             // Contain names of all files
   CDictionary    m_ofsets;            // Contain offset of local file directory
   bool           CreateFolder(string name);
   void           ZipElementsToArray(uchar& zip_elements[], ENUM_ZIP_PART part);
   bool           LoadZipFile(string full_path, int file_common, uchar& zip_array[]);
   bool           TakeECDR(uchar& zip_array[], ZipEndRecord& record);
   int            LoadHeader(uchar& zip_array[], int offset, CSourceZip& zip);
   int            LoadDirectory(uchar& zip_array[], int offset, CSourceZip& zip);
   bool           AddZipContent(CZipContent* zip);
   void           AddFolders(string full_path);
   int            FindZipFileSize(uchar& zip_array[], int offset);
public:
                  CZip(void);
   void           ToCharArray(uchar& zip_arch[]);
   bool           CreateFromCharArray(uchar& zip_arch[]);
   bool           SaveZipToFile(string zip_name, int file_common);
   bool           LoadZipFromFile(string full_path, int file_common);
   bool           LoadZipFromUrl(string url);
   bool           UnpackZipArchive(string folder, int file_common);
   int            Size();
   int            TotalElements(void);
   bool           AddFile(CZipFile* file);
   bool           DeleteFile(int index);
   CZipContent*   ElementAt(int index)const;
   CZipContent*   ElementByName(string element_name);
   void           Clear();
};

CZip::CZip(void) : m_size(0)
{
   m_names.FreeMode(false);
}
//+------------------------------------------------------------------+
//| Clear archive (in memory only).                                  |
//+------------------------------------------------------------------+
void CZip::Clear(void)
{
   m_archive.Clear();
   m_size = 0;
   m_names.Clear();
   m_ofsets.Clear();
}
//+------------------------------------------------------------------+
//| Return size archive in bytes.                                    |
//+------------------------------------------------------------------+
int CZip::Size(void)
{
   if(m_size > 0)return m_size + sizeof(ZipEndRecord);
   long size = 0;
   for(int i = 0; i < m_archive.Total(); i++)
   {
      CZipContent* zipContent = m_archive.At(i);
      size += sizeof(ZipLocalHeader)+zipContent.FileNameLength()*2+sizeof(ZipCentralDirectory)+zipContent.CompressedSize();
   }
   m_size = (int)size;
   return m_size + sizeof(ZipEndRecord);
}
//+------------------------------------------------------------------+
//| Return sum length all files.                                     |
//+------------------------------------------------------------------+
void CZip::ZipElementsToArray(uchar &zip_elements[], ENUM_ZIP_PART part)
{
   CArrayObj elements;
   int totalSize = 0;
   int total_length = 0;
   for(int i = 0; i < m_archive.Total(); i++)
   {
      uchar zip_element[];
      CZipContent* zipContent = m_archive.At(i);
      string name = zipContent.Name();
      if(part == ZIP_PART_HEADER)
      {
         zipContent.ToCharArrayHeader(zip_element);
         m_ofsets.AddObject(name, new CIntValue(totalSize));
      }
      else if(part == ZIP_PART_DIRECTORY)
      {
         CIntValue* value = m_ofsets.GetObjectByKey(name);
         zipContent.ToCharArrayDirectory(zip_element, value.offset);
      }
      if(part == ZIP_PART_HEADER && zipContent.ZipType() == ZIP_TYPE_FILE)
      {
         uchar pack[];
         CZipFile* file = zipContent;
         file.GetPackFile(pack);
         ArrayCopy(zip_element, pack, ArraySize(zip_element));
      }
      totalSize += ArraySize(zip_element);
      elements.Add(new CCharArray(zip_element));
   }
   ArrayResize(zip_elements, totalSize);
   int offset = 0;
   for(int i = 0; i < elements.Total(); i++)
   {
      CCharArray* objArray = elements.At(i);
      uchar array[];
      objArray.GetArray(array);
      ArrayCopy(zip_elements, array, offset);
      offset += ArraySize(array);
   }
   int dbg = 4;
}
//+------------------------------------------------------------------+
//| Generate zip archive as uchar array.                             |
//+------------------------------------------------------------------+
void CZip::ToCharArray(uchar &zip_arch[])
{
   uchar elements[], directories[], ecdr_array[];
   ZipElementsToArray(elements, ZIP_PART_HEADER);
   ZipElementsToArray(directories, ZIP_PART_DIRECTORY);
   ZipEndRecord ecdr;
   ecdr.total_entries_disk = (ushort)m_archive.Total();
   ecdr.total_entries = (ushort)m_archive.Total();
   ecdr.size_central_dir = ArraySize(directories);
   ecdr.start_cd_offset = ArraySize(elements);
   ecdr.ToCharArray(ecdr_array);
   int totalSize = ArraySize(elements)+ ArraySize(directories) + ArraySize(ecdr_array);
   ArrayResize(zip_arch, totalSize);
   ArrayCopy(zip_arch, elements, 0);
   ArrayCopy(zip_arch, directories, ArraySize(elements));
   ArrayCopy(zip_arch, ecdr_array, ArraySize(elements) + ArraySize(directories));
}

bool CZip::AddZipContent(CZipContent* zip)
{
   if(m_names.ContainsKey(zip.Name()))
   {
      SetUserError(ZIP_ERROR_NAME_ALREADY_EXITS);
      return false;
   }
   else   
      m_names.AddObject(zip.Name(), zip);
   m_size += (int)(sizeof(ZipLocalHeader)+zip.FileNameLength()*2+sizeof(ZipCentralDirectory)+zip.CompressedSize());
   return m_archive.Add(zip);
}
//+------------------------------------------------------------------+
//| Parse and add folders.                                           |
//+------------------------------------------------------------------+
void CZip::AddFolders(string full_path)
{
   string folders[];
   StringSplit(full_path, '\\', folders);
   for(int i = 0; i < ArraySize(folders)-1; i++)
   {
      string name = folders[i];
      CZipContent* content = new CZipDirectory(folders[i]);
      if(!AddZipContent(content))
         delete content;
   }
}
//+------------------------------------------------------------------+
//| Add zip file in current archive.                                 |
//+------------------------------------------------------------------+
bool CZip::AddFile(CZipFile *file)
{
   return AddZipContent(file);
}
//+------------------------------------------------------------------+
//| Return zip element by index.                                     |
//+------------------------------------------------------------------+
CZipContent* CZip::ElementAt(int index)const
{
   return m_archive.At(index);
}
//+------------------------------------------------------------------+
//| Return zip element by its name.                                  |
//+------------------------------------------------------------------+
CZipContent* CZip::ElementByName(string element_name)
{
   return m_names.GetObjectByKey(element_name);
}
int CZip::TotalElements(void)
{
   return m_archive.Total();
}
//+------------------------------------------------------------------+
//| Delete file from archive.                                        |
//+------------------------------------------------------------------+
bool CZip::DeleteFile(int index)
{
   CZipContent* content = m_archive.At(index);
   if(content.ZipType() != ZIP_TYPE_FILE)return false;
   return m_archive.Delete(index);
}
//+------------------------------------------------------------------+
//| Load zip archive from HDD file.                                  |
//+------------------------------------------------------------------+
bool CZip::LoadZipFile(string full_path,int file_common, uchar& zip_array[])
{
   int handle = FileOpen(full_path, FILE_READ|FILE_BIN|file_common);
   if(handle == INVALID_HANDLE)return false;
   FileReadArray(handle, zip_array);
   FileClose(handle);
   if(ArraySize(zip_array) < sizeof(ZipEndRecord))
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
//| Take out ECDR structure from zip uchar array.                    |
//+------------------------------------------------------------------+
bool CZip::TakeECDR(uchar &zip_array[],ZipEndRecord &ecdr)
{
   uchar ecdr_array[];
   int begin_offset = ArraySize(zip_array)-sizeof(ZipEndRecord);
   ArrayCopy(ecdr_array, zip_array, 0, begin_offset, WHOLE_ARRAY);
   if(!ecdr.LoadFromCharArray(ecdr_array))
   {
      SetUserError(ZIP_ERROR_BAD_FORMAT_ZIP);
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
//| Load Local Header with name file by offset array.                |
//| RETURN:                                                          |
//| Return adress after local header, name and zip content.          |
//| Return -1 if read failed.                                        |
//+------------------------------------------------------------------+
int CZip::LoadHeader(uchar &zip_array[],int offset, CSourceZip &zip_source)
{
   //Copy local header
   uchar header[];
   ArrayCopy(header, zip_array, 0, offset, sizeof(ZipLocalHeader));
   if(!zip_source.header.LoadFromCharArray(header))return -1;   
   offset += ArraySize(header);
   uchar name[];
   //Copy header file name
   ArrayCopy(name, zip_array, 0, offset, zip_source.header.filename_length);
   zip_source.header_file_name = CharArrayToString(name);
   offset += ArraySize(name);
   offset += zip_source.header.extrafield_length;
   //Copy zip array
   if(!zip_source.IsFolder() && zip_source.header.comp_size == 0)
      zip_source.header.comp_size = FindZipFileSize(zip_array, offset);
   ArrayCopy(zip_source.zip_array, zip_array, 0, offset, zip_source.header.comp_size);
   offset += ArraySize(zip_source.zip_array);
   return offset;
}
//+------------------------------------------------------------------+
//| Load Central Directory with name file by offset array.           |
//| RETURN:                                                          |
//| Return adress after CD and name.                                 |
//| Return -1 if read failed.                                        |
//+------------------------------------------------------------------+
int CZip::LoadDirectory(uchar &zip_array[],int offset,CSourceZip &zip_source)
{
   //Copy central directory
   uchar directory[];
   ArrayCopy(directory, zip_array, 0, offset, sizeof(ZipCentralDirectory));
   if(!zip_source.directory.LoadFromCharArray(directory))return -1;
   offset += ArraySize(directory);
   uchar name[];
   //Copy directory file name
   ArrayCopy(name, zip_array, 0, offset, zip_source.directory.filename_length);
   zip_source.directory_file_name = CharArrayToString(name);
   offset += ArraySize(name);
   return offset;
}
//+------------------------------------------------------------------+
//| Load zip archive from HDD file.                                  |
//+------------------------------------------------------------------+
bool CZip::LoadZipFromFile(string full_path,int file_common)
{
   uchar zip_array[];
   if(!LoadZipFile(full_path, file_common, zip_array))return false;
   return CreateFromCharArray(zip_array);
}
//+------------------------------------------------------------------+
//| Finds the size, in bytes content of a zip file. Used in cases    |
//| when the size of the compressed file is not specified            |
//| in the structure LocalHeader.                                    |
//| Return byte size of compressed zip file.                         |
//+------------------------------------------------------------------+
int CZip::FindZipFileSize(uchar &zip_array[],int offset)
{
   uint pattern =    0;
   int size =        0;
   uint header =     0x504b0304;
   uint cdheader =   0x504b0102;
   uint mask =       0xffff0000;
   int end_size = ArraySize(zip_array)-offset;
   //this is ring buffer based on byte left shift: x = x << 8
   for(; size < end_size; size++)
   {
      pattern = pattern << 8;
      uint nbyte = zip_array[offset+size];
      pattern = pattern | nbyte;
      //check upper 2 bytes
      if((pattern & mask)!=(0x504b << 16))
         continue;
      //if two upper byte equal 0x504b check all signatures
      if(pattern == header)
         break;
      if(pattern == cdheader)
         break;
   }
   //No signatures find. Bad format.
   if(size == end_size-1)
      return 0;
   //Return size - signature size.
   return size-sizeof(ZIP_LOCAL_HEADER)+1;
}
//+------------------------------------------------------------------+
//| Create zip archive from uchar array.                             |
//+------------------------------------------------------------------+
bool CZip::CreateFromCharArray(uchar &zip_array[])
{
   bool res = m_names.FreeMode();
   m_archive.Clear();
   m_size = 0;
   ZipEndRecord ecdr;
   if(!TakeECDR(zip_array, ecdr))
      return false;
   CSourceZip sources[];
   ArrayResize(sources, ecdr.total_entries);
   int offset = 0;
   int entries = ecdr.total_entries;
   for(int entry = 0; entry < ecdr.total_entries; entry++)
      offset = LoadHeader(zip_array, offset, sources[entry]);
   for(int entry = 0; entry < ecdr.total_entries; entry++)
      offset = LoadDirectory(zip_array, offset, sources[entry]);
   for(int entry = 0; entry < ecdr.total_entries; entry++)
   {
      bool is_folder = sources[entry].header.bit_flag == 3;
      CZipContent* content = NULL;
      if(is_folder)
         content = new CZipDirectory(sources[entry]);
      else
         content = new CZipFile(sources[entry]);
      m_archive.Add(content);
      if(!m_names.ContainsKey(content.Name()))
         m_names.AddObject(content.Name(), content);
      else
      {
         SetUserError(ZIP_ERROR_NAME_ALREADY_EXITS);
         delete content;
      }
   }
   return true;
}
//+------------------------------------------------------------------+
//| Unpack zip archive in folder 'folder'. If folder = "", unpack    |
//| without folder.                                                  |
//+------------------------------------------------------------------+
bool CZip::UnpackZipArchive(string folder,int file_common)
{
   for(int index = 0; index < m_archive.Total(); index++)
   {
      CZipContent* content = m_archive.At(index);
      content.UnpackOnDisk(folder, file_common);
   }
   return false;   
}
//+------------------------------------------------------------------+
//| Save zip archive in file zip_name                                |
//+------------------------------------------------------------------+
bool CZip::SaveZipToFile(string zip_name,int file_common)
{
   uchar zip_array[];
   ToCharArray(zip_array);
   int handle = FileOpen(zip_name, FILE_BIN|FILE_WRITE|file_common);
   if(handle == INVALID_HANDLE)return false;
   FileWriteArray(handle, zip_array);
   FileClose(handle);
   return true;
}
//+------------------------------------------------------------------+
//| Load zip archive from url                                        |
//+------------------------------------------------------------------+
bool CZip::LoadZipFromUrl(string url)
{
   string cookie, headers;
   int timeout = 5000;
   uchar data[], zip_array[];
   if(!WebRequest("GET", url, cookie, NULL, timeout, data, 0, zip_array, headers))
   {
      SetUserError(ZIP_ERROR_BAD_URL);
      return false;
   }
   return CreateFromCharArray(zip_array);
   return false;
}
//+------------------------------------------------------------------+
