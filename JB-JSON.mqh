//+------------------------------------------------------------------+
//|                                                      JB-JSON.mqh |
//|                                          Copyright 2024, JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, JBlanked"
#property link      "https://www.jblanked.com/"
#include <jason_with_search.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class JSON: public CJAVal
  {
private:
   uchar             Bytes[];
   char              file_content[];
   int               filehandle;
   string            tempName;
   int               tempHandle;
   datetime          fileDate;
   datetime          tempDate;

public:
   // Class constructor
                     JSON::JSON(void)
     {
      this.filehandle = INVALID_HANDLE; // Initialize filehandle to INVALID_HANDLE in the constructor
      this.filename = "";
      this.json = new CJAVal();
      ArrayResize(this.Bytes,0);
      ArrayResize(this.file_content,0);
     }

   JSON::           ~JSON(void) // deconstructor
     {
      //FileDelete();
      this.filehandle = INVALID_HANDLE; // Initialize filehandle to INVALID_HANDLE in the constructor
      this.filename = "";
      delete this.json;
      ArrayResize(this.Bytes,0);
      ArrayResize(this.file_content,0);
     }


   CJAVal            *json;
   string            filename;
   void              FileDelete() {if(FileIsExist(this.filename, FILE_COMMON))FileDelete(this.filename, FILE_COMMON);};
   void              FileWrite(bool deleteFile=false)
     {
      if(deleteFile)
         this.FileDelete();
      this.filehandle = FileOpen(this.filename, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
      ArrayResize(this.file_content, StringToCharArray(this.json.Serialize(), this.file_content, 0, WHOLE_ARRAY) - 1);
      FileWriteArray(this.filehandle, this.file_content);
      FileClose(this.filehandle);
     }

   void              FileRead()
     {
      if(FileIsExist(this.filename, FILE_COMMON))
        {
         this.filehandle = FileOpen(this.filename, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
         FileReadArray(this.filehandle,this.file_content);
         this.json.Deserialize(CharArrayToString(this.file_content), CP_UTF8);
         FileClose(this.filehandle);
        }

     }

   datetime           FileTime()
     {
      if(FileIsExist(this.filename, FILE_COMMON))
        {
         this.filehandle = FileOpen(this.filename, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
         this.fileDate = (datetime)FileGetInteger(this.filehandle,FILE_CREATE_DATE);
         FileClose(this.filehandle);
         return this.fileDate;
        }

      return 0;
     }

   datetime          TimeCurrent(void)
     {
      this.tempName = "cache" + "\\" + "json" + "\\" + "time.json";

      if(FileIsExist(this.tempName, FILE_COMMON))
        {
         FileDelete(this.tempName, FILE_COMMON);
        }

      this.tempHandle = FileOpen(this.tempName, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
      this.tempDate = (datetime)FileGetInteger(this.tempHandle,FILE_CREATE_DATE);
      FileClose(tempHandle);
      return this.tempDate;
     };

  };
//+------------------------------------------------------------------+
