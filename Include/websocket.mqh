//+------------------------------------------------------------------+
//|                                                    websocket.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include<winhttp.mqh>

#define WEBSOCKET_ERROR_FIRST              WINHTTP_ERROR_LAST+1000
#define WEBSOCKET_ERROR_NOT_INITIALIZED    WEBSOCKET_ERROR_FIRST+1
#define WEBSOCKET_ERROR_EMPTY_SEND_BUFFER  WEBSOCKET_ERROR_FIRST+2
#define WEBSOCKET_ERROR_NOT_CONNECTED      WEBSOCKET_ERROR_FIRST+3
//+------------------------------------------------------------------+
//| websocket state enumeration                                      |
//+------------------------------------------------------------------+

enum ENUM_WEBSOCKET_STATE
  {
   CLOSED = 0,
   CLOSING,
   CONNECTING,
   CONNECTED
  };


//+------------------------------------------------------------------+
//|Class CWebsocket                                                  |
//| Purpose: class for websocket client                              |
//+------------------------------------------------------------------+

class CWebsocket
  {
private:
   ENUM_WEBSOCKET_STATE clientState;            //websocket state
   HINTERNET            hSession;               //winhttp session handle
   HINTERNET            hConnection;            //winhttp connection handle
   HINTERNET            hWebSocket;             //winhttp websocket handle
   HINTERNET            hRequest;               //winhtttp request handle
   string               appname;                //optional application name sent as one of the headers in initial http request
   string               serveraddress;          //full server address
   string               serverName;             //server domain name
   INTERNET_PORT        serverPort;             //port number
   string               serverPath;             //server path 
   bool                 initialized;            //boolean flag that denotes the state of underlying winhttp infrastruture required for client
   BYTE                 rxbuffer[];             //internal buffer for reading from the socket
   bool                 isSecure;               //secure connection flag
   ulong                rxsize;                 //rxbuffer arraysize
   string               errormsg;               //internal buffer for error messages
   uint                 last_error;             //last winhttp/win32/class specific error
   // private methods
   bool              initialize(const string _serveraddress, const INTERNET_PORT _port, const string _appname,bool _secure);
   bool              createSessionConnection(void);
   bool              upgrade(void);
   void              reset(void);
   bool              clientsend(BYTE &txbuffer[],WINHTTP_WEB_SOCKET_BUFFER_TYPE buffertype);
   void              clientread(BYTE &rxbuffer[],ulong &bytes);
   void              setErrorDescription(uint error=0);

public:
                     CWebsocket(void):clientState(0),
                     hSession(NULL),
                     hConnection(NULL),
                     hWebSocket(NULL),
                     hRequest(NULL),
                     serveraddress(NULL),
                     serverName(NULL),
                     serverPort(0),
                     initialized(false),
                     isSecure(false),
                     rxsize(65539),
                     errormsg(NULL),
                     last_error(0)
     {
      ArrayResize(rxbuffer,(int)rxsize);
      ArrayFill(rxbuffer,0,rxsize,0);
      StringInit(errormsg,1000);
     }

                    ~CWebsocket(void)
     {
      Close();
      ArrayFree(rxbuffer);
     }
   //public methods
   
   bool              Connect(const string _serveraddress, const INTERNET_PORT _port=443, const string _appname=NULL,bool _secure=true);
   void              Close(void);
   bool              SendString(const string msg);
   bool              Send(BYTE &buffer[]);
   ulong             ReadString(string &response);
   ulong             Read(BYTE &buffer[]);
   void              Abort(void);
   void              ResetLastError(void) 
                      {
                        last_error=0;
                        StringFill(errormsg,0);
                        ::ResetLastError();
                      }  
   //public getter methods
   string            LastErrorMessage(void)          {  return(errormsg);    }
   uint              LastError(void)      {  return(last_error);  }        
   ENUM_WEBSOCKET_STATE ClientState(void) {  return(clientState); }
   string            DomainName(void)                {  return(serverName);  }
   INTERNET_PORT     Port(void)               {  return(serverPort);  }
   string            ServerPath(void)                {  return(serverPath);  }
   
               

  };


//+---------------------------------------------------------------------------------+
//| private method used to set the server parameters.                               |
//+---------------------------------------------------------------------------------+
bool CWebsocket::initialize(const string _serveraddress,const ushort _port,const string _appname,bool _secure)
  {
   if(initialized)
      return(true);

   if(_secure)
      isSecure=true;

   if(_port==0)
     {
      if(isSecure)
         serverPort=443;
      else
         serverPort=80;
     }
   else
     {
      serverPort=_port;
      isSecure=_secure;
      
      if(serverPort==443 && !isSecure)
        isSecure=true;
     }

   
         
   if(_appname!=NULL)
      appname=_appname;
   else
      appname="Mt5 app";

   serveraddress=_serveraddress;

   int dot=StringFind(serveraddress,".");

   int ss=(dot>0)?StringFind(serveraddress,"/",dot):-1;

   serverPath=(ss>0)?StringSubstr(serveraddress,ss+1):"/";

   int sss=StringFind(serveraddress,"://");

   if(sss<0)
      sss=-3;

   serverName=StringSubstr(serveraddress,sss+3,ss);

   initialized=createSessionConnection();

   return(initialized);
  }
 
typedef void(*WINHTTP_STATUS_CALLBACK)(HINTERNET,DWORD&,DWORD,BYTE &[],DWORD);

#import
// WINHTTP_STATUS_CALLBACK WinHttpSetStatusCallback(HINTERNET hInternet,WINHTTP_STATUS_CALLBACK lpfnInternetCallback,DWORD dwNotificationFlags,DWORD &dwReserved);
#import



//+------------------------------------------------------------------+
//|creates the session and connection handles for the client         |
//+------------------------------------------------------------------+
bool CWebsocket::createSessionConnection(void)
  {
   hSession=WinHttpOpen(appname,WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,NULL,NULL,0);

   if(hSession==NULL)
     {
      setErrorDescription();
      return(false);
     }
     //else
     //  {
     //    ulong callback=WinHttpSetStatusCallback(hSession,NULL,WINHTTP_CALLBACK_FLAG_ALL_NOTIFICATIONS,NULL);
     //    if(!callback)
     //    {
     //     setErrorDescription();
     //     reset();
     //     return(false);
     //    }
     //  }

   hConnection=WinHttpConnect(hSession,serverName,serverPort,0);

   if(hSession==NULL)
     {
      setErrorDescription();
      reset();
      return(false);
     }

   return(true);

  }

//+----------------------------------------------------------------------------+
//|the helper method releases all http resources (handles) no longer in use    |
//+----------------------------------------------------------------------------+
void CWebsocket::reset(void)
  {
   if(hWebSocket!=NULL)
     {
      WinHttpCloseHandle(hWebSocket);
      hWebSocket=NULL;
     }

   if(hRequest!=NULL)
     {
      WinHttpCloseHandle(hRequest);
      hRequest=NULL;
     }

   if(hConnection!=NULL)
     {
      WinHttpCloseHandle(hConnection);
      hConnection=NULL;
      initialized=false;
     }

   if(hSession!=NULL)
     {
      WinHttpCloseHandle(hSession);
      hSession=NULL;
      initialized=false;
     }

   clientState=CLOSED;
  }

//+---------------------------------------------------------------------+
//|helper method that sets up the required request and websocket handles|
//+---------------------------------------------------------------------+
bool CWebsocket::upgrade(void)
  {
   clientState=CONNECTING;

   hRequest=WinHttpOpenRequest(hConnection,"GET",serverPath,NULL,NULL,NULL,(isSecure)?WINHTTP_FLAG_SECURE:0);

   if(hRequest==NULL)
     {
      setErrorDescription();
      reset();
      return(false);
     }

   uint nullpointer[]= {};
   if(!WinHttpSetOption(hRequest,WINHTTP_OPTION_UPGRADE_TO_WEB_SOCKET,nullpointer,0))
     {
      setErrorDescription();
      reset();
      return(false);
     }

   if(!WinHttpSendRequest(hRequest,NULL,0,nullpointer,0,0,0))
     {
      setErrorDescription();
      reset();
      return(false);
     }

   if(!WinHttpReceiveResponse(hRequest,nullpointer))
     {
      setErrorDescription();
      reset();
      return(false);
     }

   ulong nv=0;
   hWebSocket=WinHttpWebSocketCompleteUpgrade(hRequest,nv);
   if(hWebSocket==NULL)
     {
      setErrorDescription();
      reset();
      return(false);
     }

   WinHttpCloseHandle(hRequest);
   hRequest=NULL;
   clientState=CONNECTED;

   return(true);

  }

//+------------------------------------------------------------------------------------------------------+
//|Connect method used to set server parameters and establish client connection                          |
//+------------------------------------------------------------------------------------------------------+
bool CWebsocket::Connect(const string _serveraddress, const INTERNET_PORT _port=443, const string _appname=NULL,bool _secure=true)
  {
   if(clientState==CONNECTED)
    {
     if(StringCompare(_serveraddress,serveraddress,false))
       Abort();
     else
       return(true);
    }    
     
   if(!initialize(_serveraddress,_port,appname,_secure))
     return(false);  

   return(upgrade());
  }

//+------------------------------------------------------------------+
//| helper method for sending data to the server                     |
//+------------------------------------------------------------------+
bool CWebsocket::clientsend(BYTE &txbuffer[], WINHTTP_WEB_SOCKET_BUFFER_TYPE buffertype)
{
    DWORD len = (ArraySize(txbuffer));

    if (len <= 0)
    {
        setErrorDescription(WEBSOCKET_ERROR_EMPTY_SEND_BUFFER);
        return false;
    }

    ulong send = WinHttpWebSocketSend(hWebSocket, WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE, txbuffer, len);

    if (!send) // Fix: Changed from if(send)
    {
        setErrorDescription();
        return false;
    }

    return true;
}


//+------------------------------------------------------------------+
//|public method for sending raw string messages                     |
//+------------------------------------------------------------------+
bool CWebsocket::SendString(const string msg)
  {
   if(!initialized)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_INITIALIZED);
      return(false);
     }

   if(clientState!=CONNECTED)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_CONNECTED);
      return(false);
     }

   if(StringLen(msg)<=0)
     {
      setErrorDescription(WEBSOCKET_ERROR_EMPTY_SEND_BUFFER);
      return(false);
     }

   BYTE msg_array[];

   StringToCharArray(msg,msg_array,0,WHOLE_ARRAY);

   ArrayRemove(msg_array,ArraySize(msg_array)-1,1);

   DWORD len=(ArraySize(msg_array));

   return(clientsend(msg_array,WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE));
  }

//+------------------------------------------------------------------+
//|Public method for sending data prepackaged in an array            |
//+------------------------------------------------------------------+
bool CWebsocket::Send(BYTE &buffer[])
  {
   if(!initialized)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_INITIALIZED);
      return(false);
     }

   if(clientState!=CONNECTED)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_CONNECTED);
      return(false);
     }

   return(clientsend(buffer,WINHTTP_WEB_SOCKET_BINARY_MESSAGE_BUFFER_TYPE));
  }

//+------------------------------------------------------------------+
//|helper method for reading received messages from the server       |
//+------------------------------------------------------------------+
void CWebsocket::clientread(BYTE &rbuffer[],ulong &bytes)
  {

   WINHTTP_WEB_SOCKET_BUFFER_TYPE rbuffertype=-1;

   ulong done=0;
   ulong transferred=0;
   ZeroMemory(rbuffer);
   ZeroMemory(rxbuffer);
   bytes=0;
   
   do
     {
      ulong get=WinHttpWebSocketReceive(hWebSocket,rxbuffer,rxsize,transferred,rbuffertype);
      if(get)
        {
         setErrorDescription();
         return;
        }

      ArrayCopy(rbuffer,rxbuffer,(int)done,0,(int)transferred);

      done+=transferred;

      ZeroMemory(rxbuffer);
      
      transferred=0;

     }
   while(rbuffertype==WINHTTP_WEB_SOCKET_UTF8_FRAGMENT_BUFFER_TYPE || rbuffertype==WINHTTP_WEB_SOCKET_BINARY_FRAGMENT_BUFFER_TYPE);

   bytes=done;

   return;

  }

//+------------------------------------------------------------------+
//|public method for reading data sent from the server               |
//+------------------------------------------------------------------+
ulong CWebsocket::Read(BYTE &buffer[])
  {
   if(!initialized)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_INITIALIZED);
      return(false);
     }

   if(clientState!=CONNECTED)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_CONNECTED);
      return(false);
     }

   ulong bytes_read_from_socket=0;

   clientread(buffer,bytes_read_from_socket);

   return(bytes_read_from_socket);

  }
//+------------------------------------------------------------------+
//|public method for reading data sent from the server               |
//+------------------------------------------------------------------+
ulong CWebsocket::ReadString(string &_response)
  {
   if(!initialized)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_INITIALIZED);
      return(false);
     }

   if(clientState!=CONNECTED)
     {
      setErrorDescription(WEBSOCKET_ERROR_NOT_CONNECTED);
      return(false);
     }

   ulong bytes_read_from_socket=0;
   BYTE buffer[];
   
   clientread(buffer,bytes_read_from_socket);
   
   _response=(bytes_read_from_socket)?CharArrayToString(buffer):NULL;
   
   return(bytes_read_from_socket);
 
  }

//+------------------------------------------------------------------+
//| Closes a websocket client connection                             |
//+------------------------------------------------------------------+
void CWebsocket::Close(void)
  {
   if(clientState==CLOSED)
     return;
   
   clientState=CLOSING;

   BYTE nullpointer[]= {};

   ulong result=WinHttpWebSocketClose(hWebSocket,WINHTTP_WEB_SOCKET_SUCCESS_CLOSE_STATUS,nullpointer,0);
   if(result)
      setErrorDescription();

   reset();

   return;
  }


//+--------------------------------------------------------------------------+
//|method for abandoning a client connection. All previous server connection |
//|   parameters are reset to their default state                            |                                      
//+--------------------------------------------------------------------------+
void CWebsocket::Abort(void)
  {
   Close();
   //---
   serveraddress=serverName=serverPath=NULL;
   serverPort=0;
   isSecure=false;
   last_error=0;
   StringFill(errormsg,0);
   //---
   return;
  }

//+------------------------------------------------------------------+
//|helper method that writes error messages to the internal buffer   |
//+------------------------------------------------------------------+
void CWebsocket::setErrorDescription(uint error=0)
  {
   if(!error)
      error=kernel32::GetLastError();

   if(error>0)
      StringFill(errormsg,0);
   else
      {
       last_error=0;
       return;
      } 
      
   last_error=error;  

   switch(error)
     {
      case  ERROR_WINHTTP_TIMEOUT                  :
         errormsg="The request has timed out";
         return;
      case  ERROR_WINHTTP_INTERNAL_ERROR           :
         errormsg="An internal error has occurred";
         return;
      case  ERROR_WINHTTP_INVALID_URL              :
         errormsg="The URL is not valid";
         return;
      case  ERROR_WINHTTP_UNRECOGNIZED_SCHEME      :
         errormsg="The URL specified an unfamiliar scheme";
         return;
      case  ERROR_WINHTTP_NAME_NOT_RESOLVED        :
         errormsg="The server name cannot be resolved";
         return;
      case  ERROR_WINHTTP_INVALID_OPTION           :
         errormsg="A request to WinHttpSetOption specified an invalid option value";
         return;
      case  ERROR_WINHTTP_OPTION_NOT_SETTABLE      :
         errormsg="The requested option cannot be set, only queried";
         return;
      case  ERROR_WINHTTP_SHUTDOWN                 :
         errormsg="The WinHTTP function support is being shut down or unloaded";
         return;
      case  ERROR_WINHTTP_LOGIN_FAILURE            :
         errormsg="The login attempt failed";
         return;
      case  ERROR_WINHTTP_OPERATION_CANCELLED      :
         errormsg="The operation was canceled";
         return;
      case  ERROR_WINHTTP_INCORRECT_HANDLE_TYPE    :
         errormsg="The type of handle supplied is incorrect for this operation";
         return;
      case  ERROR_WINHTTP_INCORRECT_HANDLE_STATE   :
         errormsg="The handle supplied is not in the correct state";
         return;
      case  ERROR_WINHTTP_CANNOT_CONNECT           :
         errormsg="Connection to the server failed.";
         return;
      case  ERROR_WINHTTP_CONNECTION_ERROR         :
         errormsg="The connection with the server has been reset or terminated, or an incompatible SSL protocol was encountered";
         return;
      case  ERROR_WINHTTP_RESEND_REQUEST           :
         errormsg="The WinHTTP function failed. The desired function can be retried on the same request handle";
         return;
      case  ERROR_WINHTTP_CLIENT_AUTH_CERT_NEEDED  :
         errormsg="the server requests client authentication";
         return;
      case  ERROR_WINHTTP_CANNOT_CALL_BEFORE_OPEN  :
         errormsg="requested operation cannot be performed before calling the Open method";
         return;
      case  ERROR_WINHTTP_CANNOT_CALL_BEFORE_SEND  :
         errormsg="requested operation cannot be performed before calling the Send method";
         return;
      case  ERROR_WINHTTP_CANNOT_CALL_AFTER_SEND   :
         errormsg="requested operation cannot be performed after calling the Send method";
         return;
      case  ERROR_WINHTTP_CANNOT_CALL_AFTER_OPEN   :
         errormsg="option cannot be requested after the Open method has been called";
         return;
      case  ERROR_WINHTTP_HEADER_NOT_FOUND             :
         errormsg="The requested header cannot be located";
         return;
      case  ERROR_WINHTTP_INVALID_SERVER_RESPONSE      :
         errormsg="The server response cannot be parsed";
         return;
      case  ERROR_WINHTTP_REDIRECT_FAILED              :
         errormsg="The redirection failed ";
         return;
      case  ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR  :
         errormsg="proxy for the specified URL cannot be located";
         return;
      case  ERROR_WINHTTP_SECURE_FAILURE           :
         errormsg="errors were found in the Secure Sockets Layer (SSL) certificate sent by the server";
         return;
      case  ERROR_WINHTTP_SECURE_CERT_DATE_INVALID    :
         errormsg="A required certificate is not within its validity period ";
         return;
      case  ERROR_WINHTTP_SECURE_CERT_CN_INVALID      :
         errormsg="Certificate CN name does not match the passed value ";
         return;
      case  ERROR_WINHTTP_SECURE_INVALID_CA           :
         errormsg="root certificate is not trusted by the trust provider ";
         return;
      case  ERROR_WINHTTP_SECURE_CERT_REV_FAILED      :
         errormsg="revocation cannot be checked because the revocation server was offline ";
         return;
      case  ERROR_WINHTTP_SECURE_CHANNEL_ERROR        :
         errormsg="error occurred having to do with a secure channel ";
         return;
      case  ERROR_WINHTTP_SECURE_INVALID_CERT         :
         errormsg="certificate is invalid";
         return;
      case  ERROR_WINHTTP_SECURE_CERT_REVOKED         :
         errormsg="certificate has been revoked ";
         return;
      case  ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE     :
         errormsg="certificate is not valid for the requested usage ";
         return;
      case  ERROR_WINHTTP_HEADER_COUNT_EXCEEDED                 :
         errormsg="larger number of headers present in response than WinHTTP could receive";
         return;
      case  ERROR_WINHTTP_HEADER_SIZE_OVERFLOW                  :
         errormsg=" size of headers received exceeds the limit for the request handle";
         return;
      case  ERROR_WINHTTP_CHUNKED_ENCODING_HEADER_SIZE_OVERFLOW :
         errormsg="overflow condition  encountered in the course of parsing chunked encoding";
         return;
      case  ERROR_WINHTTP_RESPONSE_DRAIN_OVERFLOW               :
         errormsg="response exceeds an internal WinHTTP size limit";
         return;
      case  ERROR_WINHTTP_CLIENT_CERT_NO_PRIVATE_KEY            :
         errormsg="The context for the SSL client certificate does not have a private key associated with it";
         return;
      case  ERROR_WINHTTP_CLIENT_CERT_NO_ACCESS_PRIVATE_KEY     :
         errormsg="The application does not have the required privileges to access the private key associated with the client certificate";
         return;
      case ERROR_INVALID_OPERATION                              :
         errormsg="Invalid operation";
         return;
      case ERROR_INVALID_PARAMETER                              :
         errormsg="Invalid parameter passed to function";
         return;      
      case WEBSOCKET_ERROR_NOT_INITIALIZED                      :
         errormsg="Websocket client has not been initialized";
         return;
      case WEBSOCKET_ERROR_EMPTY_SEND_BUFFER                    :
         errormsg="Send buffer is empty";
         return;
      case WEBSOCKET_ERROR_NOT_CONNECTED                        :
         errormsg="Websocket client is not connected to server";
         return;
         
      default:
         errormsg="Win32 API error "+IntegerToString(error);
         return;
     }

  }
//+------------------------------------------------------------------+
