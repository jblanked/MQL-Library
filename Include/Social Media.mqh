//+------------------------------------------------------------------+
//|                                                 Social Media.mqh |
//|                                     Copyright 2023-2025,JBlanked |
//|                                  https://www.github.com/jblanked |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023-2025,JBlanked"
#property link      "https://www.jblanked.com"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSocialMedia
{
private:
   bool GetPostData1(uchar &postData[], string &headers, string chat, string text, string fileName);
   void AddPostData1(uchar &data[], string &hash, string key = "", string value = "");
   void AddPostData1(uchar &data[], string &hash, string key, uchar &value[], string fileName = "");
   void ArrayCopy(uchar &dst[], string src);
   string Hash1();

public:
   bool SendDiscordMessage(string discord_webhook, string message);
   bool SendScreenshotToDiscord(string discord_webhook, string fileName, string symbol, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, int height = 800, int width = 600, string fileType = "image/png");
   bool telegramSendScreenhot(string fileName, string fileType, string inputChatId, string inputToken);
   bool SendTelegramMessage(string token, string chat, string text, string fileName = "");
};
//+------------------------------------------------------------------+
bool CSocialMedia::SendDiscordMessage(string discord_webhook, string message)
{
   ResetLastError();

   string strJsonText = "{\r\n  \"content\": \"" + message + "\"\r\n}";
   uchar jsonData[];
   StringToCharArray(strJsonText, jsonData, 0, StringLen(strJsonText), CP_UTF8);

   string serverHeaders;
   string requestHeaders = "Content-Type: application/json";
   char serverResult[];
   int res = WebRequest("POST", discord_webhook, requestHeaders, 10000, jsonData, serverResult, serverHeaders);

   if (res != 200 && res != 204)
   {
      const int errNumber = GetLastError();
      if(errNumber == 4014)
      {
         Print("Add https://discord.com/api to Tools -> Options -> Experts Advisors");
         return false;
      }
      Print("Error sending a file to the server #" + (string)res + ", LastError=" + (string)errNumber);
      return false;
   }
   return true;
}
// Call this function to send a screenshot to Discord
bool CSocialMedia::SendScreenshotToDiscord(string discord_webhook, string fileName, string symbol, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, int height = 800, int width = 600, string fileType = "image/png")
{
   ResetLastError();

   if(ChartSymbol() == symbol && ChartPeriod() == timeframe)
   {
      ChartScreenShot(0, fileName + " " + symbol + ".png", height, width);
   }
   else
   {
      ChartSetSymbolPeriod(0, symbol, timeframe);
      ChartScreenShot(0, fileName + " " + symbol + ".png", height, width);
   }

   int res;
   string header;
   char requestData[], responseData[];
   char file[];
   string str;
   string sep = "-------Jyecslin9mp8RdKV";

   if (fileName + " " + symbol + ".png" != NULL && fileName + " " + symbol + ".png" != "")
   {
      res = FileOpen(fileName + " " + symbol + ".png", FILE_READ | FILE_BIN);
      if (res < 0)
      {
         Print("Error opening the file \"" + fileName + " " + symbol + ".png" + "\"");
         return false;
      }

      if (FileReadArray(res, file) != FileSize(res))
      {
         FileClose(res);
         Print("Error reading the file \"" + fileName + " " + symbol + ".png" + "\"");
         return false;
      }
      FileClose(res);
   }

   if (ArraySize(file) != 0)
   {
      str = "--" + sep + "\r\nContent-Disposition: form-data; name=\"file\"; filename=\"" + fileName + " " + symbol + ".png" + "\"\r\n";
      str += "Content-Type: " + fileType + "\r\n\r\n";
      res = StringToCharArray(str, requestData);

      res += ::ArrayCopy(requestData, file, res - 1, 0);

      res += StringToCharArray("\r\n--" + sep + "--\r\n", requestData, res - 1);

      ArrayResize(requestData, ArraySize(requestData) - 1);

      header = "Content-Type: multipart/form-data; boundary=" + sep + "\r\n";

      ResetLastError();

      res = WebRequest("POST", discord_webhook, header, 0, requestData, responseData, str);

      if (res != 200 && res != 204)
      {
         const int errNumber = GetLastError();
         if(errNumber == 4014)
         {
            Print("Add https://discord.com/api to Tools -> Options -> Experts Advisors");
            return false;
         }
         Print("Error sending a file to the server #" + (string)res + ", LastError=" + (string)errNumber);
         return false;
      }

      return true;
   }

   return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSocialMedia::telegramSendScreenhot(string fileName, string fileType, string inputChatId, string inputToken)
{
   int    res;
   string header;
   char   requestData[], responseData[];
   char   file[];
   string str;
   string sep = "-------Jyecslin9mp8RdKV";

   if(fileName != NULL && fileName != "")
   {
      res = FileOpen(fileName, FILE_READ | FILE_BIN);
      if(res < 0)
      {
         Print("Error opening the file \"" + fileName + "\"");
         return false;
      }

      if(FileReadArray(res, file) != FileSize(res))
      {
         FileClose(res);
         Print("Error reading the file \"" + fileName + "\"");
         return false;
      }
      FileClose(res);
   }

   if(ArraySize(file) != 0)
   {

      str = "--" + sep + "\r\nContent-Disposition: form-data; name=\"chat_id\"\r\n\r\n" + inputChatId + "\r\n";
      str += "--" + sep + "\r\n";
      str += "Content-Disposition: form-data; name=\"photo\"; filename=\"" + fileName + "\"\r\n";
      str += "Content-Type: " + fileType + "\r\n\r\n";
      res = StringToCharArray(str, requestData);

      res += ::ArrayCopy(requestData, file, res - 1, 0);

      res += StringToCharArray("\r\n--" + sep + "--\r\n", requestData, res - 1);

      ArrayResize(requestData, ArraySize(requestData) - 1);

      header = "Content-Type: multipart/form-data; boundary=" + sep + "\r\n";

      ResetLastError();

      string base_url = "https://api.telegram.org";
      string url = base_url + "/bot" + inputToken + "/sendPhoto";

      res = WebRequest("POST", url, header, 0, requestData, responseData, str);

      if (res != 200 && res != 204)
      {
         const int errNumber = GetLastError();
         if(errNumber == 4014)
         {
            Print("Add https://api.telegram.org to Tools -> Options -> Experts Advisors");
            return false;
         }
         Print("Error sending a file to the server #" + (string)res + ", LastError=" + (string)errNumber);
         return false;
      }
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSocialMedia::SendTelegramMessage(string token, string chat, string text,
                                       string fileName = "")
{

   const    int            UrlDefinedError1  = 4066; // Because MT4 and MT5 are different
   string headers    = "";
   string requestUrl = "";
   uchar   postData[];
   char   resultData[];
   string resultHeaders;
   int    timeout = 5000; // 1 second, may be too short for a slow connection

   ResetLastError();

   if(fileName == "")
   {
      requestUrl =
         StringFormat("%s/bot%s/sendmessage?chat_id=%s&text=%s", "https://api.telegram.org", token, chat, text);
   }
   else
   {
      requestUrl = StringFormat("%s/bot%s/sendPhoto", "https://api.telegram.org", token);
      if(!GetPostData1(postData, headers, chat, text, fileName))
      {
         return (false);
      }
   }

   ResetLastError();
   int response =
      WebRequest("POST", requestUrl, headers, timeout, postData, resultData, resultHeaders);

   switch(response)
   {
   case -1:
   {
      int errorCode = GetLastError();
      Print("Error in WebRequest. Error code  =", errorCode);
      if(errorCode == UrlDefinedError1)
      {
         //--- url may not be listed
         PrintFormat("Add the address '%s' in the list of allowed URLs", "https://api.telegram.org");
      }
      break;
   }
   case 200:
   case 204:
      //--- Success
      Print("The message has been successfully sent");
      break;
   default:
   {
      string result = CharArrayToString(resultData);
      PrintFormat("Unexpected Response '%i', '%s'", response, result);
      break;
   }
   }


   if (response != 200 && response != 204)
   {
      const int errNumber = GetLastError();
      if(errNumber == 4014)
      {
         Print("Add https://api.telegram.org to Tools -> Options -> Experts Advisors");
         return false;
      }
      Print("Error sending a file to the server #" + (string)response + ", LastError=" + (string)errNumber);
      return false;
   }
   return true;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSocialMedia::GetPostData1(uchar &postData[], string &headers, string chat, string text, string fileName)
{

   ResetLastError();

   if(!FileIsExist(fileName))
   {
      PrintFormat("File '%s' does not exist", fileName);
      return (false);
   }

   int flags = FILE_READ | FILE_BIN;
   int file  = FileOpen(fileName, flags);
   if(file == INVALID_HANDLE)
   {
      int err = GetLastError();
      PrintFormat("Could not open file '%s', error=%i", fileName, err);
      return (false);
   }

   int   fileSize = (int)FileSize(file);
   uchar photo[];
   ArrayResize(photo, fileSize);
   FileReadArray(file, photo, 0, fileSize);
   FileClose(file);

   string hash = "";
   AddPostData1(postData, hash, "chat_id", chat);
   if(StringLen(text) > 0)
   {
      AddPostData1(postData, hash, "caption", text);
   }
   AddPostData1(postData, hash, "photo", photo, fileName);
   ArrayCopy(postData, "--" + hash + "--\r\n");

   headers = "Content-Type: multipart/form-data; boundary=" + hash + "\r\n";

   return (true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSocialMedia::AddPostData1(uchar &data[], string &hash, string key = "", string value = "")
{

   uchar valueArr[];
   StringToCharArray(value, valueArr, 0, StringLen(value));

   AddPostData1(data, hash, key, valueArr);
   return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSocialMedia::AddPostData1(uchar &data[], string &hash, string key, uchar &value[], string fileName = "")
{

   if(hash == "")
   {
      hash = Hash1();
   }

   ArrayCopy(data, "\r\n");
   ArrayCopy(data, "--" + hash + "\r\n");
   if(fileName == "")
   {
      ArrayCopy(data, "Content-Disposition: form-data; name=\"" + key + "\"\r\n");
   }
   else
   {
      ArrayCopy(data, "Content-Disposition: form-data; name=\"" + key + "\"; filename=\"" +
                fileName + "\"\r\n");
   }
   ArrayCopy(data, "\r\n");
   ::ArrayCopy(data, value, ArraySize(data));
   ArrayCopy(data, "\r\n");

   return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSocialMedia::ArrayCopy(uchar &dst[], string src)
{

   uchar srcArray[];
   StringToCharArray(src, srcArray, 0, StringLen(src));
   ::ArrayCopy(dst, srcArray, ArraySize(dst), 0, ArraySize(srcArray));
   return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CSocialMedia::Hash1()
{
   uchar  tmp[];
   string seed = IntegerToString(TimeCurrent());
   int    len  = StringToCharArray(seed, tmp, 0, StringLen(seed));
   string hash = "";
   for(int i = 0; i < len; i++)
      hash += StringFormat("%02X", tmp[i]);
   hash = StringSubstr(hash, 0, 16);

   return (hash);
}
//+------------------------------------------------------------------+
