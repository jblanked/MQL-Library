//+------------------------------------------------------------------+
//|                                                     JB-Array.mqh |
//|                                          Copyright 2023,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"

enum enum_highest_or_lowest
  {
   ENUM_HIGHEST = 0, // Highest
   ENUM_LOWEST = 1, // Lowest
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CJBArray
  {
private:

   int               array_counter;

public:
   // add a value to end of list
   template<typename T>
   void                 Append(T & Array[], T arrayValue)
     {
      if(!this.Increase(Array))
         return; // increase array size

      // set last item of list as value
      Array[this.Count(Array) - 1] = arrayValue;
     }

   // add a value to beginning of list
   template<typename T>
   void                 Add(T & Array[], T arrayValue)
     {
      if(!this.Increase(Array))
         return;

      // shift all elements to the right
      for(int i = this.Count(Array) - 1; i > 0; i--)
        {
         Array[i] = Array[i-1];
        }

      // set first value as value
      Array[0] = arrayValue;
     }

   template<typename T>
   int               Index(T & Array[], T arrayValue)
     {
      for(int i = 0; i < this.Count(Array); i++)
        {
         if(Array[i] == arrayValue)
           {
            return i;
           }
        }
      return -1;
     }

   template <typename T>
   bool              Increase(T & Array[])
     {
      return ArrayResize(Array,this.Count(Array)+1) > 0;
     }

   template <typename T>
   bool              Decrease(T & Array[])
     {
      if(this.Count(Array) < 1)
         return false;

      return ArrayResize(Array,this.Count(Array)-1) >= 0;
     }

   template <typename T>
   void              Insert(T & Array[], const T value, const int index)
     {
      if(!this.Increase(Array))
         return;

      // shift all elements to the right
      for(int i = this.Count(Array) - 1; i > index; i--)
        {
         Array[i] = Array[i-1];
        }

      // set the new value at index
      Array[index] = value;
     }

   template <typename T>
   int               Count(T & Array[])
     {
      return ArraySize(Array);
     }

   template <typename T>
   int               Count(T & Array[][])
     {
      array_counter = 0;
      for(int i = 0; i < ArraySize(Array); i++)
        {
         const string tempV = string(Array[i][0]);

         if(Array[i][0] != " " && Array[i][0] != "null" && Array[i][0] != NULL)
            array_counter++;
         else
            break;
        }

      return array_counter;
     }

   template<typename T>
   bool              Search(T & Array[], const T value)
     {
      for(int i = 0; i < this.Count(Array); i++) // loop through the items in the list
        {
         if(Array[i] == value)
           {
            return true;
           }
        }
      return false;
     }

   template<typename T>
   void              Delete(T & Array[], const T value)
     {
      for(int i = 0; i < this.Count(Array); i++)
         if(Array[i] == value)
            ArrayRemove(Array,i,1);
     }


   template<typename T>
   void              Erase(T & Array[][], const datetime timeToStartOver)
     {
      if(TimeCurrent() == timeToStartOver)
         ZeroMemory(Array);
     };

   template<typename T>
   void              Erase(T & Array[], const datetime timeToStartOver)
     {
      if(TimeCurrent() == timeToStartOver)
         ZeroMemory(Array);
     };

   template<typename T>
   void              Custom(T & Array[], T value, datetime timeToStartOver)
     {
      this.Erase(Array,timeToStartOver); // check erase

      if(!this.Search(Array,value)) // if user input value isnt in the list
        {
         this.Append(Array,value); // add the item to the list
        }

     };

   void              String_List_To_Array(string string_list, string & Array[], ushort list_separator = ',');
   void              Append_Current_Symbols_To_list(string & Array[]);

   template<typename T>
   T                 GetValue(T & Array[], enum_highest_or_lowest highestOrLowestValue)
     {
      if(ArraySize(Array)<1)
         return EMPTY_VALUE;

      T tempValue = Array[0];

      for(int i=0;i<this.Count(Array);i++)
        {

         switch(highestOrLowest)
           {
            case ENUM_HIGHEST:
               if(Array[i] > tempValue)
                 {
                  tempValue = Array[i];
                 }
               break;

            case ENUM_LOWEST:
               if(Array[i] < tempValue)
                 {
                  tempValue = Array[i];
                 }
               break;
           };

        }

      return tempValue;
     }

   template<typename T>
   int                 GetIndex(T & Array[], enum_highest_or_lowest highestOrLowestValue)
     {
      if(this.Count(Array)<1)
         return EMPTY_VALUE;

      T tempValue = Array[0];
      int tempIndex = 0;

      for(int i=0;i<this.Count(Array);i++)
        {

         switch(highestOrLowestValue)
           {
            case Highest:
               if(Array[i] > tempValue)
                 {
                  tempValue = Array[i];
                  tempIndex = i;
                 }
               break;

            case Lowest:
               if(Array[i] < tempValue)
                 {
                  tempValue = Array[i];
                  tempIndex = i;
                 }
               break;
           };

        }

      return tempIndex;
     }


  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CJBArray::String_List_To_Array(string string_list, string & Array[], ushort list_separator = ',')
  {
// Convert comma-separated pair list to an array
   string pairArray[];
   int pairCount = StringSplit(string_list, ',', pairArray);

// Print the pairs in the array
   for(int i = 0; i < pairCount; i++)
     {
      Append(Array,pairArray[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CJBArray::Append_Current_Symbols_To_list(string & Array[])
  {
   long chartID=ChartFirst();
   while(chartID >= 0)
     {
      Append(Array,ChartSymbol(chartID));
      chartID = ChartNext(chartID);
     }
  }
//+------------------------------------------------------------------+
