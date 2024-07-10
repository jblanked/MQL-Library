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

   CJAVal            get_or_set_cj(const string key, CJAVal & value, const int timeoutInSeconds = 15, const bool hashValue = false)
     {

      if(this.isExpired(key))
        {
         this.writeCJAVal(key, value, timeoutInSeconds, hashValue);
         return value;
        }
      this.tempKey = keyToInt(key);
      if(this.readCJAVal(key, hashValue)[this.tempKey]["timeout"].ToStr() != "")
        {
         return this.readCJAVal(key, hashValue);
        }
      else
        {
         this.writeCJAVal(key, value, timeoutInSeconds, hashValue);
         return value;
        }
     }

   template<typename T>
   T                 get_or_set(const string key, const T &value, const int timeoutInSeconds = 15, const bool hashValue = false)
     {
      if(this.isExpired(key))
        {
         this.write(key, value, timeoutInSeconds, hashValue);
         return value;
        }

      const string type = typename(value);
      this.tempKey = keyToInt(key);



      if(type == "string")
        {
         tempValue = this.read<string>(key, hashValue);
         if(tempValue != None)
            return (T)tempValue;
         else
           {
            this.write(key, value, timeoutInSeconds, hashValue);
            return value;
           }
        }
      else
         if(type == "datetime")
           {
            tempValue = this.read<string>(key, hashValue);
            if(tempValue != None)
               return (T)StringToTime(tempValue);
            else
              {
               this.write(key, value, timeoutInSeconds, hashValue);
               return value;
              }
           }
         else
           {
            tempValue = this.read<string>(key, hashValue);
            if(tempValue != None)
               return (T)tempValue;
            else
              {
               this.write(key, value, timeoutInSeconds, hashValue);
               return value;
              }
           }
     }

   template<typename T>
   bool              find(const string key, const bool unHashValue = false)
     {
      if(this.isExpired(key))
         return false;

      this.get_result = false;
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";

      const string type = typename(T);

      if(type == "bool")
        {
         get_result = this.readBool(key,unHashValue);
        }
      else
         if(type == "CJAVal")
           {
            get_result = this.readCJAVal(key,unHashValue, true)[this.tempKey]["timeout"].ToStr() != "";
           }
         else
           {
            get_result = this.read<T>(key,unHashValue) != None;
           }

      return get_result;
     }

   bool              findCJAVal(const string key, const bool unHashValue = false)
     {
      if(this.isExpired(key))
        {
         return false;
        }


      this.get_result = false;
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";

      get_result = this.readCJAVal(key,unHashValue, true)["timeout"].ToStr() != "";
      return get_result;
     }

   template<typename T>
   void              set(const string key, const T value, const int timeoutInSeconds = 15, const bool hashValue = false)
     {
      this.write(key, value, timeoutInSeconds, hashValue);
     }

   void              setCJAVal(const string key, CJAVal & value, const int timeoutInSeconds = 15, const bool hashValue = false)
     {
      this.writeCJAVal(key, value, timeoutInSeconds, hashValue);
     }

   template<typename T>
   T                 get(const string key, const bool unHashValue = false)
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

      return this.read<T>(key, unHashValue);
     }

   CJAVal            getCJAVal(const string key, const bool unHashValue = false)
     {
      return this.readCJAVal(key, unHashValue, false);
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
   string            tempTimeout;
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
   void              write(const string key, const T &value, const int timeoutInSeconds = 15, const bool hashValue = false)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";

      const string type = typename(value);

      if(type == "string")
        {
         this.json[this.tempKey]["value"] = hashValue ? this.hash(value) : (string)value;
         this.json[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
        }
      else
         if(type == "datetime")
           {
            this.json[this.tempKey]["value"] = TimeToString(hashValue ? (datetime)this.hash(value) : (datetime)value, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
            this.json[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
           }
         else
            if(type == "CJAVal")
              {
               CJAVal temper;
               temper[this.tempKey]["value"] = hashValue ? this.hash(value) : (string)value;
               temper[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
               this.json = temper;
              }
            else
              {
               this.json[this.tempKey]["value"] = hashValue ? this.hash(value) : (string)value;
               this.json[this.tempKey]["timeout"] = this.timeout(timeoutInSeconds);
              }

      this.FileWrite(true);
     }

   template<typename T>
   T                 read(const string key, const bool unHashValue = false)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileRead();

      tempValue = this.json[this.tempKey]["value"].ToStr();

      if(unHashValue)
        {
         tempValue = this.unHash<string>(tempValue);
        }


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


      if(tempValue != "" && tempValue != " " && tempValue != None)
         return (T)tempValue;
      else
         return (T)None;
     }

   bool                 readBool(const string key, const bool unHashValue = false)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileRead();
      tempValue = this.json[this.tempKey]["value"].ToStr();

      if(!unHashValue)
        {
         return tempValue == "true";
        }
      else
        {
         return this.unHash<string>(tempValue) == "true";
        }

      return false;
     }

   CJAVal                 readCJAVal(const string key, const bool unHashValue = false, bool forCheck = false)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.FileRead();
      this.tempValue = this.json[this.tempKey]["value"].ToStr();
      this.tempTimeout = this.json[this.tempKey]["timeout"].ToStr();

      CJAVal tempJSON;

      if(unHashValue)
        {

         const string hashed = this.unHash<string>(this.tempValue);
         tempJSON.Deserialize(hashed, CP_UTF8);

         if(forCheck)
           {
            tempJSON["timeout"] = tempTimeout;
           }

         // return entire JSON
         return tempJSON;
        }

      // deserialize value and return
      tempJSON.Deserialize(this.tempValue, CP_UTF8);

      if(forCheck)
        {
         tempJSON["timeout"] = tempTimeout;
        }


      // return entire JSON
      return tempJSON;

     }


   void              writeCJAVal(const string key, CJAVal & value, const int timeoutInSeconds = 15, const bool hashValue = false)
     {
      this.isExpired(key);
      this.clear();
      this.tempKey = keyToInt(key);
      this.filename = "cache" + "\\" + ogName + "\\" + this.tempKey + ".json";
      this.json[this.tempKey]["value"] = value.Serialize();

      if(hashValue)
        {
         this.json[this.tempKey]["value"] = this.hash(value.Serialize());
        }

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
