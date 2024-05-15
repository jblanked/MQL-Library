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
//| Class-container for zip-directory                                |
//+------------------------------------------------------------------+
class CZipDirectory : public CZipContent
{
public:
                  CZipDirectory(string name);
                  CZipDirectory(CSourceZip& zip);
   virtual bool   UnpackOnDisk(string folder, int file_common);
};
//+------------------------------------------------------------------+
//| Create for set                                                   |
//+------------------------------------------------------------------+
CZipDirectory::CZipDirectory(string name) : CZipContent(ZIP_TYPE_DIRECTORY, name)
{
   CreateDateTime(TimeCurrent());
}

CZipDirectory::CZipDirectory(CSourceZip& zip_source) : CZipContent(zip_source)
{
}
//+------------------------------------------------------------------+
//| Unpack folder on Disk                                            |
//+------------------------------------------------------------------+
bool CZipDirectory::UnpackOnDisk(string folder,int file_common)
{
   if(folder != "" && !FolderCreate(folder))
      return false;
   string name = StringSubstr(Name(), 0, StringLen(Name())-1);
   if(!FolderCreate(folder + "\\" + Name(), file_common))
      return false;
   return true;
}