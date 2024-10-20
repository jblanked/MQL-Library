//+------------------------------------------------------------------+
//|                                                      JB-File.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#property strict
#ifndef JB_FILE_H
#define JB_FILE_H 1010101
//+------------------------------------------------------------------+
// Read from .txt or .ini file in \Terminal\Common\Files\
string readTextFile(string fileNameWithExtension)
  {
   string _stringFile_;
   if(::FileIsExist(fileNameWithExtension, FILE_COMMON))
     {
      int _fileHandle_ = ::FileOpen(fileNameWithExtension, FILE_READ | FILE_COMMON | FILE_TXT | FILE_ANSI);
      if(_fileHandle_ == INVALID_HANDLE)
        {
         ::Print("Invalid file handle");
         return "";
        }

      while(!::FileIsEnding(_fileHandle_))
        {
         _stringFile_ += (::FileReadString(_fileHandle_) + "\r\n");
        }
     }
   return _stringFile_;
  }
//+------------------------------------------------------------------+
// Read from .bin or any binary file in \Terminal\Common\Files\
string readBinaryFile(string fileNameWithExtension)
  {
   string _stringFile_;
   char _fileContent_[];
   if(::FileIsExist(fileNameWithExtension, FILE_COMMON))
     {
      int _fileHandle_ = ::FileOpen(fileNameWithExtension, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
      ::FileReadArray(_fileHandle_, _fileContent_);
      _stringFile_ = ::CharArrayToString(_fileContent_);
      ::FileClose(_fileHandle_);
     }
   return _stringFile_;
  }
//+------------------------------------------------------------------+
// Write to bytes file in \Terminal\Common\Files\
bool writeTextToFile(string fileNameWithExtension, string textToWrite)
  {
   char _fileContent_[];
   int _fileHandle_ = ::FileOpen(fileNameWithExtension, FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
   ::ArrayResize(_fileContent_, ::StringToCharArray(textToWrite, _fileContent_, 0, WHOLE_ARRAY) - 1);
   ::FileWriteArray(_fileHandle_, _fileContent_);
   ::FileClose(_fileHandle_);
   return true;
  }
//+------------------------------------------------------------------+
// Write to bytes file in \Terminal\Common\Files\
bool writeBytesToFile(string fileNameWithExtension, char &bytesToWrite[])
  {
   int _fileHandle_ = ::FileOpen(fileNameWithExtension, FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
   ::FileWriteArray(_fileHandle_, bytesToWrite);
   ::FileClose(_fileHandle_);
   return true;
  }
//+------------------------------------------------------------------+
#endif // JB_FILE_H
