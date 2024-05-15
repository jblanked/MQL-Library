//+------------------------------------------------------------------+
//|                                                   ZipDefines.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"

//+------------------------------------------------------------------+
//| Zip errors.                                                      |
//+------------------------------------------------------------------+
enum ENUM_ZIP_ERROR
{
   ZIP_ERROR_EMPTY_SOURCE,       // Empty source file array
   ZIP_ERROR_BAD_PACK_ZIP,       // Bad pack zip array 
   ZIP_ERROR_BAD_FORMAT_ZIP,     // Bad zip format file
   ZIP_ERROR_NAME_ALREADY_EXITS, // File name already exits
   ZIP_ERROR_BAD_URL             // Bad url adress. Link is not zip archive or permissions of EA are not enough.
};

#define DEFLATE 8
#define ZIP_LOCAL_HEADER      0x04034B50
#define ZIP_CENTRAL_HEADER    0x02014B50
#define ZIP_END_HEADER        0x06054B50
