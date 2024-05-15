//+------------------------------------------------------------------+
//|                                                      ChatGPT.mqh |
//|                                          Copyright 2023,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,JBlanked"
#property link      "https://www.jblanked.com/"
#include <jason_with_search.mqh>


class ChatGPT
{
   private:
      bool POST();
      string url;
      string text;
      string error;
      int length;
      int MaxTokens();
      string string_array[];
      CJAVal json;
   
   public:
      string key;
      string Chat(string prompt);  
};

ChatGPT gpt;

bool ChatGPT::POST()
{
    string result = "";
    char data[]; 
    
    ArrayResize(data, StringToCharArray(json.Serialize(), data, 0, WHOLE_ARRAY) - 1);
    
    //--- send data
    char res_data[];
    string res_headers = NULL;
    int r = WebRequest("POST", url, "Content-Type: application/json\r\nAuthorization: Bearer " + key, 60000, data, res_data, res_headers);
    
    if (r != -1)
    {
        result = CharArrayToString(res_data, 0, -1, CP_UTF8); 
        if (StringLen(result) > 0){
            json.Deserialize(result, CP_UTF8);
            error = json["error"]["message"].ToStr();
            
               if(error != " "){
                  //Print(result);
                  return true;
                  }
               else
               {
               Print("Error occured: " + error);
               return false;
               }
            }
        else
         return true;
    
    }
    else 
    {
    MessageBox("Add the address '"+url+"' to the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION); 
    return false;
    }

}

string ChatGPT::Chat(string prompt)
{
    url = "https://api.openai.com/v1/completions";
            
    json["model"] = "gpt-3.5-turbo-instruct";
    json["prompt"] = prompt;
    json["max_tokens"] = 1000;
    json["temperature"] = 0;
    
    if(POST()){
      text = json["choices"][0]["text"].ToStr();
      StringReplace(text,"\n",""); 
      StringReplace(text,"\n",""); 
      }
    else
      text = "";
      
    return text;
}
