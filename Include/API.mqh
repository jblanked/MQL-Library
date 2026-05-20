//+------------------------------------------------------------------+
//|                                                          API.mqh |
//|                                     Copyright 2023-2025,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023-2025,JBlanked"
#property link      "https://www.jblanked.com/"

#ifdef __MQL5__
#define USER_AGENT "MetaTrader 5 Terminal (Wininet)"
#else
#define USER_AGENT "MetaTrader 4 Terminal (Wininet)"
#endif

#import "Wininet.dll"
int InternetOpenW(string name, int config, string, string, int);
int InternetOpenUrlW(int, string, string, int, int, int);
bool InternetReadFile(int, uchar &sBuffer[], int, int &OneInt);
bool InternetCloseHandle(int);
bool HttpAddRequestHeadersW(int, string, int, int);
int HttpOpenRequestW(int, string, string, string, string, string, int, int);
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, uchar &lpOptional[], int dwOptionalLength);
bool InternetWriteFile(int, uchar &[], int, int &);
bool InternetQueryDataAvailable(int, int &);
bool InternetSetOptionW(int, int, int &, int);
int InternetConnectW(int, string, int, string, string, int, int, int);
int InternetReadFile(int, string, int, int& OneInt[]);

#define INTERNET_OPTION_SECURITY_FLAGS 31
#define SECURITY_FLAG_IGNORE_REVOCATION 32
#define INTERNET_OPTION_IGNORE_OFFLINE 37
#define INTERNET_OPEN_TYPE_DIRECT 1
#define INTERNET_FLAG_RELOAD 0x80000000
#define INTERNET_FLAG_NO_CACHE_WRITE 0x04000000
#define INTERNET_FLAG_PRAGMA_NOCACHE 0x00000100
#define INTERNET_FLAG_NO_UI 0x00000200
#define INTERNET_FLAG_RAW_DATA 0x40000000
#define INTERNET_FLAG_KEEP_CONNECTION 0x00400000
#define INTERNET_FLAG_SECURE 0x00800000
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID 0x00001000
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID 0x00002000
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP 0x00008000
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS 0x00004000
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS_ 0x00010000
#define INTERNET_FLAG_OFFLINE 0x01000000
#define INTERNET_FLAG_SECURE_SCHANNEL 0x00004000
#define INTERNET_FLAG_TRANSFER_ASCII 0x00000001
#define INTERNET_FLAG_TRANSFER_BINARY 0x00000002
#define INTERNET_ERROR_BASE 12000
#define INTERNET_ERROR_LAST (INTERNET_ERROR_BASE + 2000)
#define INTERNET_OPTION_CONNECT_TIMEOUT 2
#define INTERNET_OPTION_RECEIVE_TIMEOUT 6
#define INTERNET_OPTION_SEND_TIMEOUT 5

#define HTTP_QUERY_FLAG_NUMBER 0x20000000
#define HTTP_QUERY_STATUS_CODE 19
#define HTTP_QUERY_FLAG_NUMBER64 0x2000000000000000
#define HTTP_QUERY_RAW_HEADERS 21
#define HTTP_STATUS_DENIED 401
#define HTTP_STATUS_PROXY_AUTH_REQ 407

#define OPEN_TYPE_PRECONFIG           0  // use confuguration by default
#define FLAG_KEEP_CONNECTION 0x00400000  // keep connection
#define FLAG_PRAGMA_NOCACHE  0x00000100  // no cache
#define FLAG_RELOAD          0x80000000  // reload page when request
#define SERVICE_HTTP                  3  // Http service
#define HTTP_QUERY_CONTENT_LENGTH     5
#define INTERNET_DEFAULT_FTP_PORT       21          // default for FTP servers
#define INTERNET_DEFAULT_GOPHER_PORT    70          //    "     "  gopher "
#define INTERNET_DEFAULT_HTTP_PORT      80          //    "     "  HTTP   "
#define INTERNET_DEFAULT_HTTPS_PORT     443         //    "     "  HTTPS  "
#define INTERNET_DEFAULT_SOCKS_PORT     1080

#define INTERNET_FLAG_EXISTING_CONNECT  0x20000000  // do not create new connection object
#import

// Import the ShellExecute function from the Windows API
#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

#include <jason_with_search.mqh>
#ifdef __MQL5__
#include <errordescription.mqh>
#endif
#include <websocket.mqh>
CWebsocket sock;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInternet
{
private:
   string            res_headers;
   int               r;
   int               bytesRead;
   string            headers;
   uchar             buffer[1024];
   int               hInternet;
   int               hUrl;

public:
   string            url;
   CJAVal            loader;
   string            result;
   string            key;

   void              openURL(void)
   {
      ShellExecuteW(0, "open", this.url, "", "", 1);
   }
   bool              GET(string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
   bool              GET(CJAVal &json_object, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/", bool showErrors = true);
   bool              GET(CJAVal &json_object, int timeout, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
   bool              WebSocketRead(CJAVal &json_object, bool close = true);
   bool              WebSocketSend(CJAVal &json_object, bool close = true);
   void              EventData(CJAVal &json_object, string API_KEY, string currency = NULL);
   bool              POST(int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
   bool              PUT(int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
   bool              DELETE(int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
   bool              DELETE(CJAVal &json_object, int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
   bool              POST(CJAVal &json_object, int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::WebSocketSend(CJAVal &json_object, bool close = true)
{

   if(sock.ClientState() == CONNECTED)
   {

      if(sock.SendString(json_object.Serialize()))
      {

         if(WebSocketRead(json_object))
         {
            return true;
         }
         else
         {
            Print("Failed to read returned JSON");
            return false;
         }

      }
      else
      {
         Print("Failed to send JSON");
         return false;
      }
   }

   else if(sock.ClientState() != CONNECTED)
   {

      if(sock.Connect(url))
      {
         if(sock.ClientState() == CONNECTED)
         {
            //Print("sending json: " + json_object.Serialize());
            if(sock.SendString(json_object.Serialize()))
            {

               if(WebSocketRead(json_object))
               {
                  return true;
               }
               else
               {
                  Print("Failed to read returned JSON");
                  return false;
               }

            }
            else
            {
               Print("Failed to send JSON");
               return false;
            }

         }
         else
         {

            Print("Websocket not connected...");
            Print(sock.LastErrorMessage(), " : ", sock.LastError());
            return false;
         }
      }
      else
      {
         Print("Websocket not connected...");
         Print(sock.LastErrorMessage(), " : ", sock.LastError());
         return false;
      }
   }
   else
   {
      Print("Websocket not connected...");
      Print(sock.LastErrorMessage(), " : ", sock.LastError());
      return false;
   }

   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::WebSocketRead(CJAVal &json_object, bool close = true)
{
   if(sock.ClientState() != CONNECTED)
   {
      if(!sock.Connect(url, 0, NULL, false))
      {
         Print("Websocket not connected...");
         Print(sock.LastErrorMessage(), " : ", sock.LastError());
         return false;
      }

      if(sock.ClientState() != CONNECTED)
      {
         Print("Websocket not connected...");
         Print(sock.LastErrorMessage(), " : ", sock.LastError());
         return false;
      }
   }

   string empty_result;
   if(!sock.ReadString(empty_result))
   {
      Print("Failed to read from websocket...");
      Print(sock.LastErrorMessage(), " : ", sock.LastError());
      return false;
   }

   json_object.Clear();
   json_object.Deserialize(empty_result);

   if(close)
   {
      sock.Close();

      while(sock.ClientState() != CLOSED)
      {
         Sleep(1000);
      }

      return sock.ClientState() == CLOSED;
   }

   return false;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInternet::EventData(CJAVal &json_object, string API_KEY, string currency = NULL)
{
   key = API_KEY;
   if(currency != NULL)
      url = "https://www.jblanked.com/news/api/mql5/list/" + currency + "/";
   else
      url = "https://www.jblanked.com/news/api/mql5/full-list/";

   GET(json_object);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::GET(string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
   bytesRead = 0;
   result = "";

// Initialize WinHTTP
   hInternet = InternetOpenW(USER_AGENT, 1, NULL, NULL, 0);
   if(!hInternet)
   {
      Print("Failed to open internet handle.");
      return false;
   }

// Set timeout options to 30 seconds (30000 milliseconds)
   int timeout = 30000;
   InternetSetOptionW(hInternet, INTERNET_OPTION_CONNECT_TIMEOUT, timeout, sizeof(timeout));
   InternetSetOptionW(hInternet, INTERNET_OPTION_RECEIVE_TIMEOUT, timeout, sizeof(timeout));
   InternetSetOptionW(hInternet, INTERNET_OPTION_SEND_TIMEOUT, timeout, sizeof(timeout));

// Open a URL
   hUrl = InternetOpenUrlW(hInternet, url, NULL, 0, 0, 0);
   if(!hUrl)
   {
      Print("Failed to open URL.");
      InternetCloseHandle(hInternet);
      return false;
   }

// Specify the headers
   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
             "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;

// if url is not mtAPI then send Request Headers
// added this in so the request isnt sent twice
   if(StringSubstr(url, 12, 5) != "mtapi")
   {

      if(!HttpSendRequestW(hUrl, headers, StringLen(headers), buffer, 0))
      {
         Print("Failed to send HTTP request.");
         InternetCloseHandle(hUrl);
         InternetCloseHandle(hInternet);
         return false;
      }
   }

// Read the response
   while(InternetReadFile(hUrl, buffer, ArraySize(buffer) - 1, bytesRead) && bytesRead > 0)
   {
      buffer[bytesRead] = 0; // Null-terminate the buffer
      result += CharArrayToString(buffer, 0, bytesRead, CP_UTF8); // Append the data to the result string
   }

// Close the URL handle
   InternetCloseHandle(hUrl);
// Close the WinHTTP handle
   InternetCloseHandle(hInternet);

   if(result != "")
   {
      if(!api.loader.Deserialize(result, CP_UTF8))
      {
         Print("[api.mqh CInternet::GET]: Failed to deserialize result:\n" + result);
         return false;
      }
      return true;
   }

   Print("No response from " + urlToShow);

   return false;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::GET(CJAVal &json_object, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/", bool showErrors = true)
{
   bytesRead = 0;
   result = "";


// Initialize WinHTTP
   hInternet = InternetOpenW(USER_AGENT, 1, NULL, NULL, 0);
   if(hInternet)
   {
      // Open a URL
      hUrl = InternetOpenUrlW(hInternet, this.url, NULL, 0, 0, 0);
      if(hUrl)
      {
         // Specify the headers
         headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
                   "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;


         // Send the request headers
         if(HttpSendRequestW(hUrl, headers, StringLen(headers), buffer, 0))
         {
            // Read the response
            while(InternetReadFile(hUrl, buffer, ArraySize(buffer) - 1, bytesRead) && bytesRead > 0)
            {
               buffer[bytesRead] = 0; // Null-terminate the buffer
               result += CharArrayToString(buffer, 0, bytesRead, CP_UTF8); // Append the data to the result string

            }
         }
         else
         {
            if(showErrors)
               Print("Failed to send headers");
         }
         InternetCloseHandle(hUrl); // Close the request handle


         InternetCloseHandle(hUrl); // Close the URL handle
      }
      else
      {
         if(showErrors)
            Print("Failed to open " + urlToShow);
      }

      InternetCloseHandle(hInternet); // Close the WinHTTP handle
   }
   else
   {
      if(showErrors)
         Print("Failed to initialize WinHTTP");
   }


   if(result != "")
   {
      //Print(result);
      if(!json_object.Deserialize(result, CP_UTF8))
      {
         if(showErrors)
         {
            Print("Failed to deserialize response.");
            Print(result);
         }
         return false;
      }
      else
         return true;

   }
   else
   {
      if(showErrors)
         Print("No response from " + urlToShow);
      return false;

   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::GET(CJAVal &json_object, int timeout, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
//--- serialize to string
   result = "";
   char data[];
//Print(loader.Serialize());
   ArrayResize(data, StringToCharArray(json_object.Serialize(), data, 0, WHOLE_ARRAY) - 1);

   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
             "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;

//--- send data
   char res_data[];
   res_headers = NULL;
   r = WebRequest("GET", this.url, headers, timeout, data, res_data, res_headers);

   if(r != -1)
   {
      result = CharArrayToString(res_data, 0, -1, CP_UTF8);

      if(StringLen(result) > 0)
      {
         json_object.Clear();
         json_object.Deserialize(result, CP_UTF8);
      }

      return true;
   }
   else
   {
      MessageBox("Add the address " + " ' " + urlToShow + " ' " + " to the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      return false;
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::POST(int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
//--- serialize to string
   result = "";
   char data[];
//Print(loader.Serialize());
   ArrayResize(data, StringToCharArray(loader.Serialize(), data, 0, WHOLE_ARRAY) - 1);

   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
             "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;

//--- send data
   char res_data[];
   res_headers = NULL;
   r = WebRequest("POST", this.url, headers, timeout, data, res_data, res_headers);

   if(r != -1)
   {
      result = CharArrayToString(res_data, 0, -1, CP_UTF8);

      if(StringLen(result) > 0)
      {
         loader.Clear();
         loader.Deserialize(result, CP_UTF8);
      }


      return true;
   }
   else
   {
      MessageBox("Add the address " + " ' " + urlToShow + " ' " + " to the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      return false;
   }

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::POST(CJAVal &json_object, int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
//--- serialize to string
   result = "";
   char data[];
//Print(loader.Serialize());
   ArrayResize(data, StringToCharArray(json_object.Serialize(), data, 0, WHOLE_ARRAY) - 1);

   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
             "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;

//--- send data
   char res_data[];
   res_headers = NULL;
   r = WebRequest("POST", this.url, headers, timeout, data, res_data, res_headers);

   if(r != -1)
   {
      result = CharArrayToString(res_data, 0, -1, CP_UTF8);

      if(StringLen(result) > 0)
      {
         json_object.Clear();
         json_object.Deserialize(result, CP_UTF8);
      }


      return true;
   }
   else
   {
      MessageBox("Add the address " + " ' " + urlToShow + " ' " + " to the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      return false;
   }

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::PUT(int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
//--- serialize to string
   char data[];
   ArrayResize(data, StringToCharArray(loader.Serialize(), data, 0, WHOLE_ARRAY) - 1);

   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
             "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;

//--- send data
   char res_data[];
   res_headers = NULL;
   r = WebRequest("PUT",  this.url, headers, timeout, data, res_data, res_headers);

   if(r == -1)
   {
      MessageBox("Add the address '" + urlToShow + "' to the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      return false;
   }
   else
   {
      return true;
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::DELETE(int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
//--- serialize to string
   char data[];
   ArrayResize(data, StringToCharArray(loader.Serialize(), data, 0, WHOLE_ARRAY) - 1);
   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
             "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;

//--- send data
   char res_data[];
   res_headers = NULL;
   r = WebRequest("DELETE",  this.url, headers, timeout, data, res_data, res_headers);
   if(r != -1)
   {
      result = CharArrayToString(res_data, 0, -1, CP_UTF8);

      if(StringLen(result) > 0)
      {
         this.loader.Clear();
         this.loader.Deserialize(result, CP_UTF8);
      }


      return true;
   }
   else
   {
      MessageBox("Add the address '" + urlToShow + "' to the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      return false;
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CInternet::DELETE(CJAVal &json_object, int timeout = 5000, string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
//--- serialize to string
   char data[];
   ArrayResize(data, StringToCharArray(json_object.Serialize(), data, 0, WHOLE_ARRAY) - 1);
   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers, 0, 22) == "Authorization: Api-Key" ?
             "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;

//--- send data
   char res_data[];
   res_headers = NULL;
   r = WebRequest("DELETE",  this.url, headers, timeout, data, res_data, res_headers);
   if(r != -1)
   {
      result = CharArrayToString(res_data, 0, -1, CP_UTF8);

      if(StringLen(result) > 0)
      {
         json_object.Clear();
         json_object.Deserialize(result, CP_UTF8);
      }


      return true;
   }
   else
   {
      MessageBox("Add the address '" + urlToShow + "' to the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      return false;
   }
}

CInternet api;
//+------------------------------------------------------------------+
