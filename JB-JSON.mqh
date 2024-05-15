//+------------------------------------------------------------------+
//|                                                      JB-JSON.mqh |
//|                                          Copyright 2024, JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, JBlanked"
#property link      "https://www.jblanked.com/"
#include <jason_with_search.mqh>

class JSON
  {
private:
   uchar             Bytes[];
   char              file_content[];
   int               filehandle;

public:
   // Class constructor
                     JSON::JSON(void)
     {
      filehandle = INVALID_HANDLE; // Initialize filehandle to INVALID_HANDLE in the constructor
      filename = "";
      json = new CJAVal();
      ArrayResize(Bytes,0);
      ArrayResize(file_content,0);
     }

   JSON::           ~JSON(void) // deconstructor
     {
      filehandle = INVALID_HANDLE; // Initialize filehandle to INVALID_HANDLE in the constructor
      filename = "";
      delete json;
      ArrayResize(Bytes,0);
      ArrayResize(file_content,0);
     }


   CJAVal            *json;
   string            filename;
   void              FileDelete() {if(FileIsExist(filename, FILE_COMMON))FileDelete(filename, FILE_COMMON);};
   void              FileWrite(bool deleteFile=false)
     {
      if(deleteFile)
         FileDelete();
      filehandle = FileOpen(filename, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
      ArrayResize(file_content, StringToCharArray(json.Serialize(), file_content, 0, WHOLE_ARRAY) - 1);
      FileWriteArray(filehandle, file_content);
      FileClose(filehandle);
     }

   void              FileRead()
     {
      if(FileIsExist(filename, FILE_COMMON))
        {
         filehandle = FileOpen(filename, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
         FileReadArray(filehandle,file_content);
         json.Deserialize(CharArrayToString(file_content), CP_UTF8);
         FileClose(filehandle);
        }

     }
  };
//+------------------------------------------------------------------+
