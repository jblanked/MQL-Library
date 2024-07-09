//+------------------------------------------------------------------+
//|                                                     JB-Array.mqh |
//|                                          Copyright 2023,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,JBlanked"
#property link      "https://www.jblanked.com/"
#include <custompairsmt5.mqh>
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
      ArrayResize(Array, ArraySize(Array) + 1); // increase the size by one
      Array[ArraySize(Array) - 1] = arrayValue; // assign the last value as the input array value
     }

   template<typename T>
   bool              Search(const T & Array[], const T & value)
     {
      bool is_in = false; // default value
      for(int i = 0; i < ArraySize(Array); i++) // loop through the items in the list
        {
         is_in = is_in || (Array[i] == value) ? true : false; // if item is same as user input then return true
        }
      return is_in; // return the result
     }

   template<typename T>
   void              Delete(T & Array[], T value)
     {
      for(int i = 0; i < ArraySize(Array); i++)
         if(Array[i] == value)
            ArrayRemove(Array,i,1);
     }

   template<typename T>
   void              Erase(T & Array[][], const datetime timeToStartOver)
     {
      if(TimeCurrent() == timeToStartOver)
         ArrayRemove(Array,0);
     };

   template<typename T>
   void              Custom(T & Array[], T value, datetime timeToStartOver)
     {
      Erase(Array,timeToStartOver);
      if(!Search(Array,value)) // if user input value isnt in the list
         Append(Array,value); // create/add the item to the list
     };

   void              String_List_To_Array(string string_list, string & Array[], ushort list_separator = ',');
   void              Append_Current_Symbols_To_list(string & Array[]);
   int               Size(string & Array[][])
     {
      array_counter = 0;
      for(int i = 1; i < ArraySize(Array); i++)
         if(Array[i][0] != " " && Array[i][0] != "null" && Array[i][0] != NULL)
            array_counter++;
         else
            break;

      return array_counter;

     }

   template<typename T>
   T                 GetValue(T & Array[], enum_highest_or_lowest highestOrLowestValue)
     {
      if(ArraySize(Array)<1)
         return EMPTY_VALUE;

      T tempValue = Array[0];

      for(int i=0;i<ArraySize(Array);i++)
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
      if(ArraySize(Array)<1)
         return EMPTY_VALUE;

      T tempValue = Array[0];
      int tempIndex = 0;

      for(int i=0;i<ArraySize(Array);i++)
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
