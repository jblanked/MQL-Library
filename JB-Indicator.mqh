//+------------------------------------------------------------------+
//|                                                 JB-Indicator.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <jb-array.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CIndicator: public CJBArray
  {
public:
   //--- constructor - Init
                     CIndicator::CIndicator(void)
     {
      this.setAsSeries();
     };

   //--- deconstructor - deInit
   CIndicator::     ~CIndicator(void)
     {


     };

   //--- create indicator buffers with draw attributes
#ifdef __MQL5__
   bool              createBuffer(const string name, const ENUM_DRAW_TYPE drawType, const ENUM_LINE_STYLE style, const color color_, const int width, const int index, double & dataArray[], const bool showData = true, const ENUM_INDEXBUFFER_TYPE bufferType = INDICATOR_DATA, const int arrowCode = 233);
#else
   bool              createBuffer(const string name, const int drawType, const ENUM_LINE_STYLE style, const color color_, const int width, const int index, double & dataArray[], const bool showData = true, const ENUM_INDEXBUFFER_TYPE bufferType = INDICATOR_DATA, const int arrowCode = 233);
#endif

   //--- delete pointer safely
   bool              deletePointer(void *ptr)
     {
      if(CheckPointer(ptr) == POINTER_DYNAMIC)
        {
         delete ptr;
         ptr = NULL;
         return true;
        }
      return false;
     }

   //--- max bars
   int               getMaxBars(const string symbol, const ENUM_TIMEFRAMES timeframe, const int userMaximum = 5000)
     {
      return Bars(symbol,timeframe) > userMaximum ? userMaximum : Bars(symbol,timeframe);
     }

   //--- direct indcator values
   double            iMA(const string symbol, const ENUM_TIMEFRAMES timeframe, const int maPeriod, const int maShift, const ENUM_MA_METHOD maMethod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true);
   double            iRSI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int rsiPeriod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true);
   double            iATR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int atrPeriod, const int shift, const bool copyBuffer = true);
   double            iCustom(const string symbol,const ENUM_TIMEFRAMES timeframe,const string indicatorAndFolderNameOnly = "IndicatorName", const int buffer = 0, const int shift = 0, const bool copyBuffer=true);

private:

   //--- Helper class
   class CIndicatorHelper
     {
   public:
      string         name;
      int            handle;
      double         data[];
      int            lastSize;
      bool           isHandleSet;
      bool           isSetAsSeries;

                     CIndicatorHelper::CIndicatorHelper()
        {
         this.lastSize        = 0;
         this.isHandleSet     = false;
         this.isSetAsSeries   = false;
        }

      void              setAsSeries(void)
        {
         ::ArraySetAsSeries(this.data,true);
         ::ArrayInitialize(this.data,EMPTY_VALUE);
         this.isSetAsSeries = true;
        }

      void              resize(const int newSize)
        {
         ::ArrayResize(this.data,newSize);
        }

     };

   //--- get indicator data
   bool              getHelper(const string name, CIndicatorHelper & tempVar)
     {
      for(int i = 0; i < this.Count(this.data); i++)
        {
         if(data[i].name == name)
           {
            tempVar = data[i];
            return true;
           }
        }

      return false;
     };
   void              setAsSeries(void)
     {
      ::ArraySetAsSeries(this.data,true);
     }

   void              resize(const int newSize)
     {
      ::ArrayResize(this.data,newSize);
     }

   void              setHelper(const string nameOfHelper)
     {
      if(!this.getHelper(nameOfHelper, temp))
        {
         // set
         const int nSize = this.Count(this.data);

         this.Increase(this.data);  // increase array size by 1

         this.data[nSize].name   = this.helperName;
         this.data[nSize].setAsSeries();

         this.temp = this.data[nSize];
        }
     }


   CIndicatorHelper  temp;

protected:
   CIndicatorHelper  data[];


   string            helperName;

  };
//+------------------------------------------------------------------+
double CIndicator:: iMA(const string symbol, const ENUM_TIMEFRAMES timeframe, const int maPeriod, const int maShift, const ENUM_MA_METHOD maMethod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName ="iMA" + symbol + string(timeframe) + string(maPeriod) + string(maShift) + string(maMethod) + string(appliedPriceOrHandle);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift+3); // resize array
      this.temp.lastSize = shift;
     }

//--- set handle
   if(!this.temp.isHandleSet)
     {
      this.temp.handle = ::iMA(symbol, timeframe, maPeriod, maShift, maMethod, appliedPriceOrHandle);

      if(this.temp.handle == EMPTY_VALUE)
        {
         ::Print("Failed to set Moving Average.");

         return EMPTY_VALUE;
        }

      this.temp.isHandleSet = true;
     }

   if(copyBuffer)
     {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 3, this.temp.data);
     }
   return this.temp.data[shift+2];
#else
   return ::iMA(symbol, timeframe, maPeriod, maShift, maMethod, appliedPriceOrHandle, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iRSI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int rsiPeriod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName ="iRSI" + symbol + string(timeframe) + string(rsiPeriod) + string(appliedPriceOrHandle);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift+4); // resize array
      this.temp.lastSize = shift;
     }

//--- set handle
   if(!this.temp.isHandleSet)
     {
      this.temp.handle = ::iRSI(symbol, timeframe, rsiPeriod, appliedPriceOrHandle);

      if(this.temp.handle == EMPTY_VALUE)
        {
         ::Print("Failed to set RSI");

         return EMPTY_VALUE;
        }

      this.temp.isHandleSet = true;
     }

   if(copyBuffer)
     {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 3, this.temp.data);
     }
   return this.temp.data[shift+2];
#else
   return ::iRSI(symbol, timeframe, rsiPeriod, appliedPriceOrHandle, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iATR(const string symbol,const ENUM_TIMEFRAMES timeframe,const int atrPeriod, const int shift, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName ="iATR" + symbol + string(timeframe) + string(atrPeriod);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift+4); // resize array
      this.temp.lastSize = shift;
     }

//--- set handle
   if(!this.temp.isHandleSet)
     {
      this.temp.handle = ::iATR(symbol, timeframe, atrPeriod);

      if(this.temp.handle == EMPTY_VALUE)
        {
         ::Print("Failed to set ATR");

         return EMPTY_VALUE;
        }

      this.temp.isHandleSet = true;
     }

   if(copyBuffer)
     {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 3, this.temp.data);
     }
   return this.temp.data[shift+2];
#else
   return ::iATR(symbol, timeframe, atrPeriod, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iCustom(const string symbol,const ENUM_TIMEFRAMES timeframe,const string indicatorAndFolderNameOnly = "IndicatorName", const int buffer = 0, const int shift = 0, const bool copyBuffer=true)
  {
#ifdef __MQL5__
   this.helperName ="iCustom" + indicatorAndFolderNameOnly + symbol + string(timeframe) + string(buffer) + string(shift);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift+4);    // resize array
      this.temp.lastSize = shift;   // set last size
     }

//--- set handle
   if(!this.temp.isHandleSet)
     {
      this.temp.handle = ::iCustom(symbol, timeframe, "\\Indicators\\" + indicatorAndFolderNameOnly + ".ex5");

      if(this.temp.handle == EMPTY_VALUE)
        {
         ::Alert("Failed to set ", indicatorAndFolderNameOnly);

         return EMPTY_VALUE;
        }

      this.temp.isHandleSet = true;
     }

   if(copyBuffer)
     {
      ::CopyBuffer(this.temp.handle, buffer, 0, shift + 3, this.temp.data);
     }
   return this.temp.data[shift+2];
#else
   return ::iCustom(symbol, timeframe,  indicatorAndFolderNameOnly + ".ex4", buffer, shift);
#endif
  }
//+------------------------------------------------------------------+
#ifdef __MQL5__
bool CIndicator::createBuffer(const string name,const ENUM_DRAW_TYPE drawType,const ENUM_LINE_STYLE style,const color color_,const int width,const int index,double &dataArray[],const bool showData=true,const ENUM_INDEXBUFFER_TYPE bufferType=0,const int arrowCode=233)
#else
bool CIndicator::createBuffer(const string name,const int drawType,const ENUM_LINE_STYLE style,const color color_,const int width,const int index,double &dataArray[],const bool showData=true,const ENUM_INDEXBUFFER_TYPE bufferType=0,const int arrowCode=233)
#endif
  {
   if(!::SetIndexBuffer(index,dataArray,bufferType))
     {
      ::Print("Failed to set buffer for " + name + " at index " + (string)index);
      return false;
     }

#ifdef __MQL5__
   if(!::PlotIndexSetString(index,PLOT_LABEL,name))
     {
      ::Print("Failed to set label for " + name + " at index " + (string)index);
      return false;
     }
   if(!::PlotIndexSetInteger(index,PLOT_DRAW_TYPE,drawType))
     {
      ::Print("Failed to set draw type for " + name + " at index " + (string)index);
      return false;
     }
   if(!::PlotIndexSetInteger(index,PLOT_LINE_STYLE,style))
     {
      ::Print("Failed to set draw style for " + name + " at index " + (string)index);
      return false;
     }

   if(!::PlotIndexSetInteger(index,PLOT_LINE_COLOR,color_))
     {
      ::Print("Failed to set color for " + name + " at index " + (string)index);
      return false;
     }

   if(!::PlotIndexSetInteger(index,PLOT_LINE_WIDTH,width))
     {
      ::Print("Failed to set width for " + name + " at index " + (string)index);
      return false;
     }

   if(!::PlotIndexSetInteger(index,PLOT_ARROW,arrowCode))
     {
      ::Print("Failed to set arrow code for " + name + " at index " + (string)index);
      return false;
     }

   if(!PlotIndexSetInteger(index,PLOT_SHOW_DATA,showData))
     {
      ::Print("Failed to set data display for " + name + " at index " + (string)index);
      return false;
     }

#else
   ::SetIndexStyle(index,DRAW_LINE,style,width,color_);
   ::SetIndexLabel(index,name);
   ::SetIndexArrow(index,arrowCode);
#endif


//::ArraySetAsSeries(dataArray,true);
//::ArrayInitialize(dataArray,EMPTY_VALUE);

   return true;
  }
//+------------------------------------------------------------------+
