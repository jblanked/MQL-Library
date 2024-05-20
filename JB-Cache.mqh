//+------------------------------------------------------------------+
//|                                                     JB-Cache.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <jb-json.mqh>
#define None NULL
enum ENUM_DATA_TYPE
  {
   INT, DOUBLE, LONG, ULONG, STRING, CJAVAL, DATETIME, COLOR, BOOL
  };
//+------------------------------------------------------------------+
class CCache
  {
public:

   // constructor
   CCache::          CCache(void)
     {
      jaSon = new JSON();
      string currentTime = TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      StringReplace(currentTime,":","");
      StringReplace(currentTime,".","");
      StringReplace(currentTime," ","");
      ogName = currentTime;
     }
   
   // constructor
   CCache::          CCache(bool universalName)
     {
      jaSon = new JSON();
      string currentTime;
      if(!universalName) currentTime = TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      else currentTime = TimeToString(iTime(_Symbol,PERIOD_MN1,0),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      StringReplace(currentTime,":","");
      StringReplace(currentTime,".","");
      StringReplace(currentTime," ","");
      StringReplace(currentTime,"-","");
      ogName = currentTime;
     }

   // deconstructor
   CCache::         ~CCache(void)
     {
      //jaSon.FileDelete();
      delete jaSon;
     }

   string            get_or_set(const string key, const string value, const int timeoutInSeconds=15)
     {
      this.timeout(key);

      tempValue = this.read_string(key);

      if(tempValue != None && tempValue != " ")
         return tempValue;
      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }
     }


   int               get_or_set(const string key, const int value, const int timeoutInSeconds=15)
     {
      this.timeout(key);

      tempValue = this.read_int(key) == 0 ? None : string(this.read_int(key));

      if(tempValue != None && tempValue != " ")
         return int(tempValue);
      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }
     }

   double            get_or_set(const string key, const double value, const int timeoutInSeconds=15)
     {
      this.timeout(key);

      tempValue = this.read_double(key) == 0.0 ? None : string(this.read_double(key));

      if(tempValue != None && tempValue != " ")
         return double(tempValue);
      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }
     }

   datetime            get_or_set(const string key, const datetime value, const int timeoutInSeconds=15)
     {
      this.timeout(key);

      tempValue = this.read_datetime(key) == None ? None : TimeToString(this.read_datetime(key),TIME_DATE|TIME_MINUTES|TIME_SECONDS);

      if(tempValue != None && tempValue != " ")
         return StringToTime(tempValue);
      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }
     }

   ulong             get_or_set(const string key, const ulong value, const int timeoutInSeconds=15)
     {
      this.timeout(key);

      tempValue = this.read_ulong(key) == None ? None : string(this.read_ulong(key));

      if(tempValue != None && tempValue != " ")
         return ulong(tempValue);
      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }
     }

   long              get_or_set(const string key, const long value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      tempValue = this.read_long(key) == None ? None : string(this.read_long(key));

      if(tempValue != None && tempValue != " ")
         return long(tempValue);
      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }
     }

   color             get_or_set(const string key, const color value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      tempValue = this.read_color(key) == None ? None : string(this.read_color(key));

      if(tempValue != None && tempValue != " ")
         return color(tempValue);
      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }
     }


   CJAVal            get_or_set(const string key, CJAVal & value, const int timeoutInSeconds=15)
     {

      if(this.read_json(key)[key]["timeout"].ToStr() != "" && !this.timeout(key))

         return this.read_json(key);

      else
        {
         this.write(key,value,timeoutInSeconds);
         return value;
        }

     }

   void              set(const string key, CJAVal & value, const int timeoutInSeconds=15)
     {
      this.write(key,value,timeoutInSeconds);
     }


   CJAVal            get(const string key)
     {
      return this.read_json(key);
     }


   bool              find(const string key, const ENUM_DATA_TYPE dataType = CJAVAL)
     {

      if(this.timeout(key)) return false;
      
      get_result = false;
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";

      switch(dataType)
        {
         case BOOL:
            get_result = this.read_bool(key);
            break;
         case DATETIME:
            get_result = this.read_datetime(key) != None;
            break;
         case COLOR:
            get_result = this.read_color(key) != None;
            break;
         case DOUBLE:
            get_result = this.read_double(key) != None;
            break;
         case INT:
            get_result = this.read_int(key) != None;
            break;
         case ULONG:
            get_result = this.read_ulong(key) != None;
            break;
         case STRING:
            get_result = this.read_string(key) != None;
            break;
         case LONG:
            get_result = this.read_long(key) != None;
            break;
         case CJAVAL:
            get_result = this.read_json(key)[key]["timeout"].ToStr() != "";
            break;
         default:
            get_result = false;
            break;
        }

      return get_result;

     }

private:

   JSON              *jaSon;
   string            timeout(int amountOfSeconds)
     {
      //amountOfSeconds = amountOfSeconds > 1 ? amountOfSeconds - 1 : amountOfSeconds;
      return TimeToString(TimeCurrent() + amountOfSeconds,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
     }
   bool              timeout(const string key)
     {
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["timeout"].ToStr();

      if(StringToTime(tempValue) == 0 || TimeCurrent() >= StringToTime(tempValue))
        {
         this.erase(key);

         return true;
        }

      return false;
     }
   void              clear(void) {jaSon.json.Clear();}
   string            tempValue;
   string            ogName;
   bool              get_result;

   void              write(const string key, const int value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      jaSon.json[key]["value"] = value;
      jaSon.json[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.FileWrite(true);
     }
   void              write(const string key, const double value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      jaSon.json[key]["value"] = value;
      jaSon.json[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.FileWrite(true);
     }

   void              write(const string key, const string value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      jaSon.json[key]["value"] = value;
      jaSon.json[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.FileWrite(true);
     }
   void              write(const string key, const datetime value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.json[key]["value"] = TimeToString(value,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
      jaSon.json[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.FileWrite(true);
     }

   void              write(const string key, const ulong value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";

      jaSon.json[key]["value"] = string(value);
      jaSon.json[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.FileWrite(true);
     }

   void              write(const string key, const long value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";

      jaSon.json[key]["value"] = value;
      jaSon.json[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.FileWrite(true);
     }
   void              write(const string key, const color value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";

      jaSon.json[key]["value"] = string(value);
      jaSon.json[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.FileWrite(true);
     }
   void              write(const string key, const CJAVal & value, const int timeoutInSeconds=15)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";

      CJAVal temper = value;

      temper[key]["timeout"] = this.timeout(timeoutInSeconds);
      jaSon.json = temper;
      jaSon.FileWrite(true);
     }

   int               read_int(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();

      if(tempValue != "" && tempValue != " " && tempValue != None)
         return int(tempValue);
      else
         return None;
     }

   double            read_double(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();

      if(tempValue != "" && tempValue != " ")
         return double(tempValue);
      else
         return None;
     }

   string            read_string(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();

      if(tempValue != "" && tempValue != " ")
         return tempValue;
      else
         return None;
     }

   datetime          read_datetime(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();

      if(tempValue != "" && tempValue != " ")
         return StringToTime(tempValue);
      else
         return None;
     }

   ulong             read_ulong(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();

      if(tempValue != "" && tempValue != " ")
         return ulong(tempValue);
      else
         return None;
     }

   long              read_long(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();

      if(tempValue != "" && tempValue != " ")
         return long(tempValue);
      else
         return None;
     }

   color             read_color(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();

      if(tempValue != "" && tempValue != " ")
         return color(tempValue);
      else
         return None;
     }

   bool              read_bool(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      tempValue = jaSon.json[key]["value"].ToStr();
      
      if(tempValue != "" && tempValue != " " && tempValue != None)
         return tempValue == "true" ? true : false;
      else
         return false;
     }

   CJAVal            read_json(const string key)
     {
      this.timeout(key);
      this.clear();
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileRead();
      return jaSon.json;

     }


   void              erase(const string key)
     {
      jaSon.filename = keyToInt(key) + ogName + "-cache.json";
      jaSon.FileDelete();
     }

   string               keyToInt(const string key)
     {
      char goGet[];
      string opentest;
      StringToCharArray(key,goGet);

      for(int i = 0; i < ArraySize(goGet); i++)
        {
         opentest+=string(goGet[i]);
        }
      
      return opentest;
     }



  };
//+------------------------------------------------------------------+
