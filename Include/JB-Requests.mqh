//+------------------------------------------------------------------+
//|                                                  JB-Requests.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <jason_with_search.mqh>
class CRequests
{
   private:
      string res_headers;
      int r;
      int bytesRead;
      string headers;
      uchar buffer[1024];
      int hInternet;
      int hUrl;
         
   public:
      string url;
      CJAVal loader;
      string result;
      string key;
      
      bool GET(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
      bool GET(CJAVal &json_object, int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");

      bool POST(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
      bool POST(CJAVal &json_object,int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
      
      bool PUT(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
      
      bool DELETE(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
      bool DELETE(CJAVal &json_object,int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/");
};

bool CRequests::GET(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
    //--- serialize to string 
    result = "";
    char data[];  
    //Print(loader.Serialize());
    ArrayResize(data, StringToCharArray(this.loader.Serialize(), data, 0, WHOLE_ARRAY) - 1);
    
    headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers,0,22) == "Authorization: Api-Key" ?
    "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;
    
    //--- send data
    char res_data[];
    res_headers = NULL;
    r = WebRequest("GET", this.url, headers, timeout, data, res_data, res_headers);
    
    if (r != -1)
    {
        result = CharArrayToString(res_data, 0, -1, CP_UTF8); 
        
        if (StringLen(result) > 0){
            this.loader.Clear();
            this.loader.Deserialize(result, CP_UTF8);
            }
            
         
        return true;
    }
    else 
    {
    MessageBox("Add the address " + " ' " + urlToShow + " ' " + " to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
    return false;
    }
      
}

bool CRequests::GET(CJAVal &json_object, int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
    //--- serialize to string 
    result = "";
    char data[];  
    //Print(loader.Serialize());
    ArrayResize(data, StringToCharArray(json_object.Serialize(), data, 0, WHOLE_ARRAY) - 1);
    
    headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers,0,22) == "Authorization: Api-Key" ?
    "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;
    
    //--- send data
    char res_data[];
    res_headers = NULL;
    r = WebRequest("GET", this.url, headers, timeout, data, res_data, res_headers);
    
    if (r != -1)
    {
        result = CharArrayToString(res_data, 0, -1, CP_UTF8); 
        
        if (StringLen(result) > 0){
            json_object.Clear();
            json_object.Deserialize(result, CP_UTF8);
            }
            
         
        return true;
    }
    else 
    {
    MessageBox("Add the address " + " ' " + urlToShow + " ' " + " to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
    return false;
    }
      
}


bool CRequests::POST(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
    //--- serialize to string 
    result = "";
    char data[];  
    //Print(loader.Serialize());
    ArrayResize(data, StringToCharArray(loader.Serialize(), data, 0, WHOLE_ARRAY) - 1);
    
    headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers,0,22) == "Authorization: Api-Key" ?
    "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;
    
    //--- send data
    char res_data[];
    res_headers = NULL;
    r = WebRequest("POST", this.url, headers, timeout, data, res_data, res_headers);
    
    if (r != -1)
    {
        result = CharArrayToString(res_data, 0, -1, CP_UTF8); 
        
        if (StringLen(result) > 0){
            this.loader.Clear();
            this.loader.Deserialize(result, CP_UTF8);
            }
            
         
        return true;
    }
    else 
    {
    MessageBox("Add the address " + " ' " + urlToShow + " ' " + " to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
    return false;
    }
      
}
 

bool CRequests::POST(CJAVal &json_object,int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
    //--- serialize to string 
    result = "";
    char data[]; 
    //Print(loader.Serialize());
    ArrayResize(data, StringToCharArray(json_object.Serialize(), data, 0, WHOLE_ARRAY) - 1);
    
    headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers,0,22) == "Authorization: Api-Key" ?
    "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;
    
    //--- send data
    char res_data[];
    res_headers = NULL;
    r = WebRequest("POST", this.url, headers, timeout, data, res_data, res_headers);
    
    if (r != -1)
    {
        result = CharArrayToString(res_data, 0, -1, CP_UTF8); 
        
        if (StringLen(result) > 0){
            json_object.Clear();
            json_object.Deserialize(result, CP_UTF8);
            }
            
         
        return true;
    }
    else 
    {
    MessageBox("Add the address " + " ' " + urlToShow + " ' " + " to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
    return false;
    }
      
}
 


bool CRequests::PUT(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
   //--- serialize to string 
   char data[]; 
   ArrayResize(data, StringToCharArray(loader.Serialize(), data, 0, WHOLE_ARRAY)-1);
   
   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers,0,22) == "Authorization: Api-Key" ?
    "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;
   
   //--- send data
   char res_data[];
   res_headers=NULL;
   r=WebRequest("PUT",  this.url, headers, timeout, data, res_data, res_headers);
   
   if(r == -1){
   MessageBox("Add the address '"+urlToShow+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
   return false;
   }
   else
   {
   return true;
   }
   
}

bool CRequests::DELETE(int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
   //--- serialize to string 
   char data[]; 
   ArrayResize(data, StringToCharArray(loader.Serialize(), data, 0, WHOLE_ARRAY)-1);
   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers,0,22) == "Authorization: Api-Key" ?
    "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;
   
   //--- send data
   char res_data[];
   res_headers=NULL;
   r=WebRequest("DELETE",  this.url, headers, timeout, data, res_data, res_headers);
   if (r != -1)
    {
        result = CharArrayToString(res_data, 0, -1, CP_UTF8); 
        
        if (StringLen(result) > 0){
            this.loader.Clear();
            this.loader.Deserialize(result, CP_UTF8);
            }
            
         
        return true;
    }
   else
   {
   MessageBox("Add the address '"+urlToShow+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
   return false;
   }
   
}

bool CRequests::DELETE(CJAVal &json_object,int timeout = 5000,string addon_headers = "Authorization: Api-Key ", string urlToShow = "https://www.jblanked.com/")
{
   //--- serialize to string 
   char data[]; 
   ArrayResize(data, StringToCharArray(json_object.Serialize(), data, 0, WHOLE_ARRAY)-1);
   headers = addon_headers == NULL ? "Content-Type: application/json" : StringSubstr(addon_headers,0,22) == "Authorization: Api-Key" ?
    "Content-Type: application/json" + "\r\n" + addon_headers + key : addon_headers;
   
   //--- send data
   char res_data[];
   res_headers=NULL;
    r=WebRequest("DELETE",  this.url, headers, timeout, data, res_data, res_headers);
   if (r != -1)
    {
        result = CharArrayToString(res_data, 0, -1, CP_UTF8); 
        
        if (StringLen(result) > 0){
            json_object.Clear();
            json_object.Deserialize(result, CP_UTF8);
            }
            
         
        return true;
    }
   else
   {
   MessageBox("Add the address '"+urlToShow+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
   return false;
   }
}
