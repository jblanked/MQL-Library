//+------------------------------------------------------------------+
//|                                                     JB-Cache.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <jb-json.mqh>
#define None NULL

/* ---- Examples

   CCache cache("Test");

   //--- Hash/UnHash:
      const string hashedValue = cache.hash(false);
      Print("Hashed Value: ", hashedValue);
      Print("UnHashed Value: ", cache.unHash<string>(hashedValue));

   //--- Cache
      const string ceoMember = cache.get_or_set<string>("ceo", "JBlanked", 60 * 15);
      Print(ceoMember);

   //--- Both
      CJAVal test;
      test["Name"] = "Jacobie";
      test["Date"] = TimeToString(TimeCurrent());
      test["These"] = 1;
      test["These2"] = 2;
      test["These3"] = 3;
      test["These4"] = 4;
      test["These5"] = 5;

     const string hashedValue = cache.hash(test.Serialize());

     Print("Hashed Value: ",hashedValue);

     cache.set("test",hashedValue);

     const string cacheValue = cache.get<string>("test");

     Print("Cached Value: " , cacheValue);

     const string unashedValue = cache.unHash<string>(cacheValue);

     Print("UnHashed UnCached Value: ", unashedValue);

     CJAVal temp2 = cache.toJSON(unashedValue);

     Print("Name from cache: ", temp2["Name"].ToStr());
*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCache : private JSON
  {
public:
   // Constructor
                     CCache(const string universalName)
     {
      if(universalName != NULL)
        {
         string currentTime = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
         StringReplace(currentTime, ":", "");
         StringReplace(currentTime, ".", "");
         StringReplace(currentTime, " ", "");
         ogName = universalName;
        }
      else
        {
         ogName = "General";
        }

     }


   // Destructor
                    ~CCache(void) {}

   CJAVal            get_or_set_cj(const string key, CJAVal & value, const int timeoutInSeconds = 15)
     {

      if(this.isExpired(key))
        {
         this.writeCJAVal(key, value, timeoutInSeconds);
         return value;
        }
      this.tempKey = keyToInt(key);
      if(this.readCJAVal(key)[this.tempKey]["timeout"].ToStr() != "")
        {
         return this.readCJAVal(key);
        }
      else
        {
         this.writeCJAVal(key, value, timeoutInSeconds);
         return value;
        }
     }

   template<typename T>
   T                 get_or_set(const string key, const T &value, const int timeoutInSeconds = 15)
     {
      if(this.isExpired(key))
        {
         this.write(key, value, timeoutInSeconds);
         return value;
        }

      const string type = typename(value);
      this.tempKey = keyToInt(key);



      if(type == "string")
        {
         tempValue = this.read<string>(key);
         if(tempValue != None)
            return (T)tempValue;
         else
           {
            this.write(key, value, timeoutInSeconds);
            return value;
           }
        }
      else
         if(type == "datetime")
           {
            tempValue = this.read<string>(key);
            if(tempValue != None)
               return (T)StringToTime(tempValue);
            else
              {
               this.write(key, value, timeoutInSeconds);
               return value;
              }
           }
         else
           {
            tempValue = this.read<string>(key);
            if(tempValue != None)
               return (T)tempValue;
            else
              {
               this.write(key, value, timeoutInSeconds);
               return value;
              }
           }
     }

   template<typename T>
   bool              find(const string key)
     {
      if(this.isExpired(key))
         return false;

      this.get_result = false;
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";

      const string type = typename(T);

      if(type == "bool")
        {
         get_result = this.readBool(key);
        }
      else
         if(type == "CJAVal")
           {
            get_result = this.readCJAVal(key)[this.tempKey]["timeout"].ToStr() != "";
           }
         else
           {
            get_result = this.read<T>(key) != None;
           }

      return get_result;
     }

   bool              findCJAVal(const string key)
     {
      if(this.isExpired(key))
        {
         return false;
        }


      this.get_result = false;
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";

      get_result = this.readCJAVal(key)[this.tempKey]["timeout"].ToStr() != "";
      return get_result;
     }

   template<typename T>
   void              set(const string key, const T value, const int timeoutInSeconds = 15)
     {
      this.write(key, value, timeoutInSeconds);
     }

   void              setCJAVal(const string key, CJAVal & value, const int timeoutInSeconds = 15)
     {
      this.writeCJAVal(key, value, timeoutInSeconds);
     }

   template<typename T>
   T                 get(const string key)
     {
      //     const string type = typename(T);
      //
      //      if(type == "bool")
      //        {
      //        return this.readBool(key);
      //        }
      //
      //        else if(type == "CJAVal")
      //        {
      //         return this.readCJAVal(key);
      //        }

      return this.read<T>(key);
     }

   CJAVal            getCJAVal(const string key)
     {
      return this.readCJAVal(key);
     }

private:
   string            timeout(const int amountOfSeconds)
     {
      return TimeToString(TimeCurrent() + amountOfSeconds, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
     }

   bool              isExpired(const string key)
     {
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileRead();
      tempValue = this.json[this.tempKey]["timeout"].ToStr();

      if(StringToTime(tempValue) == 0 || TimeCurrent() >= StringToTime(tempValue))
        {
         this.erase(key);
         return true;
        }

      return false;
     }

   void              clear(void) { this.json.Clear(); }
   string            tempValue;
   string            ogName;
   bool              get_result;
   string               tempKey;

   void              erase(const string key)
     {
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileDelete();
     }

   string            keyToInt(const string key)
     {
      char goGet[];
      string opentest;
      StringToCharArray(key, goGet);

      for(int i = 0; i < ArraySize(goGet); i++)
        {
         opentest += string(goGet[i]);
        }

      return opentest;
     }

   template<typename T>
   void              write(const string key, const T &value, const int timeoutInSeconds = 15)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";

      const string type = typename(value);

      if(type == "string")
        {
         this.json[this.tempKey]["value"] = string(value);
         this.json[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
        }
      else
         if(type == "datetime")
           {
            this.json[this.tempKey]["value"] = TimeToString((datetime)value, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
            this.json[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
           }
         else
            if(type == "CJAVal")
              {
               CJAVal temper;
               temper[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
               this.json = temper;
              }
            else
              {
               this.json[this.tempKey]["value"] = string(value);
               this.json[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
              }

      this.FileWrite(true);
     }

   template<typename T>
   T                 read(const string key)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileRead();
      tempValue = this.json[this.tempKey]["value"].ToStr();

      const string type = typename(T);

      //if(type == "CJAVal")
      //{
      //   return this.json;
      //}

      if(type == "datetime")
        {
         if(tempValue != "" && tempValue != " ")
            return (T)StringToTime(tempValue);
         else
            return (T)None;
        }

      tempValue = this.json[this.tempKey]["value"].ToStr();

      if(tempValue != "" && tempValue != " " && tempValue != None)
         return (T)tempValue;
      else
         return (T)None;
     }

   bool                 readBool(const string key)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileRead();
      tempValue = this.json[this.tempKey]["value"].ToStr();

      if(tempValue != "" && tempValue != " " && tempValue != None)
         return (tempValue == "true");
      else
         return false;
     }

   CJAVal                 readCJAVal(const string key)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileRead();
      return this.json;
     }


   void              writeCJAVal(const string key, CJAVal & value, const int timeoutInSeconds = 15)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";

      this.json[this.tempKey]["value"] = value;
      this.json[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);

      this.FileWrite(true);
     }
public:
   template <typename T>
   string            hash(const T value)
     {

      uchar  tmp[];
      int    len  = StringToCharArray(string(value), tmp, 0, StringLen(string(value)));
      string hash = "";
      for(int i = 0; i < len; i++)
         hash += StringFormat("%02X", tmp[i]);
      return (hash);

     }

   template <typename T>
   T                 unHash(const string hash)
     {
      string item = "";
      for(int i = 0; i < StringLen(hash); i += 2)
        {
         item += CharToString((char)hexToNum(StringSubstr(hash, i, 2)));
        }

      return (T)item;
     }

   CJAVal            toJSON(const string stringHash)
     {
      CJAVal temp;
      temp.Deserialize(stringHash, CP_UTF8);
      return temp;
     };

   string            toStr(CJAVal & jsonHash)
     {
      return jsonHash.Serialize();
     };
private:

   int               hexToNum(const string hex)
     {
      int num = 0;
      for(int i = 0; i < StringLen(hex); i++)
        {
         num *= 16;
         if(hex[i] >= '0' && hex[i] <= '9')
            num += (int)(hex[i] - '0');
         else
            if(hex[i] >= 'A' && hex[i] <= 'F')
               num += (int)(hex[i] - 'A' + 10);
            else
               if(hex[i] >= 'a' && hex[i] <= 'f')
                  num += (int)(hex[i] - 'a' + 10);
        }
      return num;
     }





  };
//+------------------------------------------------------------------+
