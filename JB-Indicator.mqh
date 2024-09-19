//+------------------------------------------------------------------+
//|                                                 JB-Indicator.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#include <jb-array.mqh> // download from https://github.com/jblanked/MQL-Library/blob/main/JB-Array.mqh
#ifdef __MQL4__ enum ENUM_APPLIED_VOLUME { VOLUME_TICK, VOLUME_REAL }; #endif
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

   //--- direct indicator values
   double            iMA(const string symbol, const ENUM_TIMEFRAMES timeframe, const int maPeriod, const int maShift, const ENUM_MA_METHOD maMethod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true);
   double            iMAOnArray(double & array[], const int period, const int maShift, const ENUM_MA_METHOD maMethod, const int shift);
   double            iRSI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int rsiPeriod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true);
   double            iATR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int atrPeriod, const int shift, const bool copyBuffer = true);
   double            iADX(const string symbol, const ENUM_TIMEFRAMES timeframe, const int adxPeriod, ENUM_APPLIED_PRICE appliedPrice, int adxMode = 0, const int shift = 0, const bool copyBuffer = true);
   double            iCustom(const string symbol, const ENUM_TIMEFRAMES timeframe, const string indicatorAndFolderNameOnly = "IndicatorName", const int buffer = 0, const int shift = 1, const bool copyBuffer = true);
   double            iEnvelopes(const string symbol, const ENUM_TIMEFRAMES timeframe, const int envPeriod, const int maShift,  const ENUM_MA_METHOD envMethod, const int appliedPriceOrHandle, const double envDeviation, const int envMode = 0, const int shift = 1, const bool copyBuffer = true);
   double            iADR(const string symbol, const int period, const int shift)
     {
      double val = 0;
      double sum1 = 0;
      for(int i = shift; i <= shift + period; i++)
         sum1 += (iHigh(symbol, PERIOD_D1, i) - iLow(symbol, PERIOD_D1, i));

      val = sum1 / period;
      return(val);
     }

   double            iVWAP(const string symbol, const ENUM_TIMEFRAMES timeframe, const int period, const int shift)
     {
      double val = 0;
      double sum1 = 0, sum2 = 0;
      for(int i = shift; i <= shift + period; i++)
        {
         sum1 += iClose(symbol, timeframe, i) * iVolume(symbol, timeframe, i);
         sum2 += (double)iVolume(symbol, timeframe, i);
        }
      if(sum2 > 0)
         val = sum1 / sum2;
      return(val);
     }

   //+------------------------------------------------------------------+
   //| Positive Volume Index (PVI)                                      |
   //+------------------------------------------------------------------+
   double            iPVI(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_VOLUME volumeType, const int shift)
     {
      static double lastValue = 1.0;  // Initialize lastValue to 1.0, if not already set

      long Vol0, Vol1;
      MqlRates mqlRates[];
      ArraySetAsSeries(mqlRates, true);  // Ensure array is set as series
      if(CopyRates(symbol, timeframe, shift, 2, mqlRates) < 2)  // Fetch the last 2 bars
        {
         return lastValue;
        }
      // Fetch volumes based on volume type (tick or real)
      if(volumeType == VOLUME_TICK)
        {
         Vol0 = mqlRates[0].tick_volume;
         Vol1 = mqlRates[1].tick_volume;
        }
      else
        {
         Vol0 = mqlRates[0].real_volume;
         Vol1 = mqlRates[1].real_volume;
        }

      // Calculate the new PVI value
      if(Vol0 > Vol1)
        {
         lastValue = lastValue * (1 + ((mqlRates[0].close - mqlRates[1].close) / mqlRates[1].close));
        }

      // Return the updated PVI value
      return lastValue;
     }
   double            iPVI(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_VOLUME volumeType, const double & closeData[], const int shift)
     {
      static double lastValue = 1.0;  // Initialize lastValue to 1.0, if not already set

      MqlRates mqlRates[];
      ArraySetAsSeries(mqlRates, true);  // Ensure array is set as series
      ArraySetAsSeries(closeData, true);    // Ensure array is set as series
      long Vol0, Vol1;
      if(CopyRates(symbol, timeframe, shift, 2, mqlRates) < 2)  // Fetch the last 2 bars
        {
         return lastValue;
        }
      if(ArraySize(closeData) <= (shift + 1))
        {
         return lastValue;
        }
      // Fetch volumes based on volume type (tick or real)
      if(volumeType == VOLUME_TICK)
        {
         Vol0 = mqlRates[0].tick_volume;
         Vol1 = mqlRates[1].tick_volume;
        }
      else
        {
         Vol0 = mqlRates[0].real_volume;
         Vol1 = mqlRates[1].real_volume;
        }

      // Calculate the new PVI value based on input data
      if(Vol0 > Vol1)
        {
         lastValue = lastValue * (1 + ((closeData[shift] - closeData[shift + 1]) / closeData[shift + 1]));
        }

      // Return the updated PVI value
      return lastValue;
     }
   //+------------------------------------------------------------------+



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
      return Bars(symbol, timeframe) > userMaximum ? userMaximum : Bars(symbol, timeframe);
     }

   string            uninitReasonText(int reasonCode)
     {
      string text = "";
      //---
      switch(reasonCode)
        {
         case REASON_ACCOUNT:
            text = "Account was changed.";
            break;
         case REASON_CHARTCHANGE:
            text = "Symbol or timeframe was changed.";
            break;
         case REASON_CHARTCLOSE:
            text = "Chart was closed.";
            break;
         case REASON_PARAMETERS:
            text = "Input-parameter was changed.";
            break;
         case REASON_RECOMPILE:
            text = "Program was recompiled.";
            break;
         case REASON_REMOVE:
            text = "Program was removed from chart.";
            break;
         case REASON_TEMPLATE:
            text = "New template was applied to chart.";
            break;
         case REASON_INITFAILED:
            text = "Failed to initialize.";
            break;
         case REASON_PROGRAM:
            text = "Removed by a script, indicator, or expert advisor.";
            break;
         case REASON_CLOSE:
            text = "Terminal was closed.";
            break;
         default:
            text = "Another reason.";
        }
      //---
      return text;
     }
private:

   class CJBRates
     {
   public:
                     CJBRates(const bool setAsSeries = true)
        {
         this.setAsSeries(setAsSeries);
        }

      MqlRates            operator[](const int shift)
        {
         CopyRates(_Symbol, PERIOD_CURRENT, shift, 1, this.m_rates);
         return this.m_rates[0];
        }

      void              setAsSeries(const bool status = true)
        {
         if(ArraySetAsSeries(this.m_rates, status))
           {
            this.isSetAsSeries = true;
           }
        }
   private:
      bool              isSetAsSeries;
      MqlRates          m_rates[];
     };

   //--- Helper class
   class CIndicatorHelper
     {
   public:
      string         name;
      int            handle;
      double         value[];
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
         ::ArraySetAsSeries(this.value, true);
         ::ArrayInitialize(this.value, EMPTY_VALUE);
         this.isSetAsSeries = true;
        }

      void              resize(const int newSize)
        {
         ::ArrayResize(this.value, newSize);
        }

     };

   //--- get indicator data
   int               getHelper(const string name, CIndicatorHelper & tempVar)
     {
      for(int i = 0; i < this.Count(this.data); i++)
        {
         if(data[i].name == name)
           {
            tempVar = data[i];
            return i;
           }
        }
      return -1;
     };
   void              setAsSeries(void)
     {
      ::ArraySetAsSeries(this.data, true);
     }

   void              resize(const int newSize)
     {
      ::ArrayResize(this.data, newSize);
     }

   void              setHelper(const string nameOfHelper)
     {
      this.helperIndex = this.getHelper(nameOfHelper, this.temp);
      if(helperIndex == -1)
        {
         // set
         const int nSize = this.Count(this.data);

         this.Increase(this.data);  // increase array size by 1

         this.data[nSize].name   = this.helperName;
         this.data[nSize].setAsSeries();

         this.temp = this.data[nSize];
         ArraySetAsSeries(this.temp.value, true);
         this.helperIndex = nSize;
        }
     }

   int               helperIndex;
   CIndicatorHelper  temp;
public:
   CJBRates          rates;
protected:
   CIndicatorHelper  data[];
   string            helperName;
  };
//+------------------------------------------------------------------+
double CIndicator:: iMA(const string symbol, const ENUM_TIMEFRAMES timeframe, const int maPeriod, const int maShift, const ENUM_MA_METHOD maMethod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName = "iMA" + symbol + string(timeframe) + string(maPeriod) + string(maShift) + string(maMethod) + string(appliedPriceOrHandle);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift + 3); // resize array
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
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
     }
   this.data[this.helperIndex] = this.temp;
   return this.temp.value[shift];
#else
   return ::iMA(symbol, timeframe, maPeriod, maShift, maMethod, appliedPriceOrHandle, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iRSI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int rsiPeriod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName = "iRSI" + symbol + string(timeframe) + string(rsiPeriod) + string(appliedPriceOrHandle);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift + 3); // resize array
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
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
     }
   this.data[this.helperIndex] = this.temp;
   return this.temp.value[shift];
#else
   return ::iRSI(symbol, timeframe, rsiPeriod, appliedPriceOrHandle, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iATR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int atrPeriod, const int shift, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName = "iATR" + symbol + string(timeframe) + string(atrPeriod);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift + 3); // resize array
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
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
     }
   this.data[this.helperIndex] = this.temp;
   return this.temp.value[shift];
#else
   return ::iATR(symbol, timeframe, atrPeriod, shift);
#endif
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CIndicator::iADX(const string symbol, const ENUM_TIMEFRAMES timeframe, const int adxPeriod, ENUM_APPLIED_PRICE appliedPrice, int adxMode = 0, const int shift = 0, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName = "iADX" + symbol + string(timeframe) + string(adxPeriod);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
     }

//--- set handle
   if(!this.temp.isHandleSet)
     {
      this.temp.handle = ::iADX(symbol, timeframe, adxPeriod);

      if(this.temp.handle == EMPTY_VALUE)
        {
         ::Print("Failed to set ADX.");

         return EMPTY_VALUE;
        }

      this.temp.isHandleSet = true;
     }

   if(copyBuffer)
     {
      ::CopyBuffer(this.temp.handle, adxMode, 0, shift + 1, this.temp.value);
     }
   this.data[this.helperIndex] = this.temp;
   return this.temp.value[shift];
#else
   return ::iADX(symbol, timeframe, adxPeriod, appliedPrice, adxMode, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iCustom(const string symbol, const ENUM_TIMEFRAMES timeframe, const string indicatorAndFolderNameOnly = "IndicatorName", const int buffer = 0, const int shift = 1, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName = "iCustom" + indicatorAndFolderNameOnly + symbol + string(timeframe) + string(buffer) + string(shift);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift + 3);  // resize array
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
      ::CopyBuffer(this.temp.handle, buffer, 0, shift + 1, this.temp.value);
     }
   this.data[this.helperIndex] = this.temp;
   return this.temp.value[shift];
#else
   return ::iCustom(symbol, timeframe,  indicatorAndFolderNameOnly + ".ex4", buffer, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iEnvelopes(const string symbol, const ENUM_TIMEFRAMES timeframe, const int envPeriod, const int maShift, const ENUM_MA_METHOD envMethod, const int appliedPriceOrHandle, const double envDeviation, const int envMode = 0, const int shift = 1, const bool copyBuffer = true)
  {
#ifdef __MQL5__
   this.helperName = "iEnvelopes" + symbol + string(timeframe) + string(envPeriod) + string(envMethod) + string(appliedPriceOrHandle);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
     {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
     }

//--- set handle
   if(!this.temp.isHandleSet)
     {
      this.temp.handle = ::iEnvelopes(symbol, timeframe, envPeriod, maShift, envMethod, appliedPriceOrHandle, envDeviation);

      if(this.temp.handle == EMPTY_VALUE)
        {
         ::Print("Failed to set Envelopes.");

         return EMPTY_VALUE;
        }

      this.temp.isHandleSet = true;
     }

   if(copyBuffer)
     {
      ::CopyBuffer(this.temp.handle, envMode, 0, shift + 1, this.temp.value);
     }
   this.data[this.helperIndex] = this.temp;
   return this.temp.value[shift];
#else
   return ::iEnvelopes(symbol, timeframe, envPeriod, maShift, envMethod, appliedPriceOrHandle, envDeviation, envMode, shift);
#endif
  }
//+------------------------------------------------------------------+
double CIndicator::iMAOnArray(double &array[], const int period, const int maShift, const ENUM_MA_METHOD maMethod, const int shift)
  {

   double buf[], arr[];
   int total = ArraySize(array);

   if(total <= period)
      return 0;

   if(shift > total - period - maShift)
      return 0;

   switch(maMethod)
     {

      case MODE_SMA:
        {

         total = ArrayCopy(arr, array, 0, shift + maShift, period);
         if(ArrayResize(buf, total) < 0)
            return 0;

         double sum = 0;
         int i, pos = total - 1;

         for(i = 1; i < period; i++, pos--)

            sum += arr[pos];

         while(pos >= 0)
           {

            sum += arr[pos];

            buf[pos] = sum / period;

            sum -= arr[pos + period - 1];

            pos--;

           }

         return buf[0];

        }



      case MODE_EMA:
        {

         if(ArrayResize(buf, total) < 0)

            return 0;

         double pr = 2.0 / (period + 1);

         int posti = total - 2;



         while(posti >= 0)
           {

            if(posti == total - 2)

               buf[posti + 1] = array[posti + 1];

            buf[posti] = array[posti] * pr + buf[posti + 1] * (1 - pr);

            posti--;

           }

         return buf[shift + maShift];

        }



      case MODE_SMMA:
        {

         if(ArrayResize(buf, total) < 0)

            return(0);

         double summ = 0;

         int j, k, poss;



         poss = total - period;

         while(poss >= 0)
           {

            if(poss == total - period)
              {

               for(j = 0, k = poss; j < period; j++, k++)
                 {

                  summ += array[k];

                  buf[k] = 0;

                 }

              }

            else

               summ = buf[poss + 1] * (period - 1) + array[poss];

            buf[poss] = summ / period;

            poss--;

           }

         return buf[shift + maShift];

        }



      case MODE_LWMA:
        {

         if(ArrayResize(buf, total) < 0)

            return 0;

         double dsum = 0.0, lsum = 0.0;

         double price;

         int m, weight = 0, posit = total - 1;



         for(m = 1; m <= period; m++, posit--)
           {

            price = array[posit];

            dsum += price * m;

            lsum += price;

            weight += m;

           }

         posit++;

         m = posit + period;

         while(posit >= 0)
           {

            buf[posit] = dsum / weight;

            if(posit == 0)

               break;

            posit--;

            m--;

            price = array[posit];

            dsum = dsum - lsum + price * period;

            lsum -= array[m];

            lsum += price;

           }

         return buf[shift + maShift];

        }

     }

   return 0;

  }
//+------------------------------------------------------------------+
#ifdef __MQL5__
bool CIndicator::createBuffer(const string name, const ENUM_DRAW_TYPE drawType, const ENUM_LINE_STYLE style, const color color_, const int width, const int index, double &dataArray[], const bool showData = true, const ENUM_INDEXBUFFER_TYPE bufferType = INDICATOR_DATA, const int arrowCode = 233)
#else
bool CIndicator::createBuffer(const string name, const int drawType, const ENUM_LINE_STYLE style, const color color_, const int width, const int index, double &dataArray[], const bool showData = true, const ENUM_INDEXBUFFER_TYPE bufferType = INDICATOR_DATA, const int arrowCode = 233)
#endif
  {
   if(!::SetIndexBuffer(index, dataArray, bufferType))
     {
      ::Print("Failed to set buffer for " + name + " at index " + (string)index);
      return false;
     }

#ifdef __MQL5__
   if(!::PlotIndexSetString(index, PLOT_LABEL, name))
     {
      ::Print("Failed to set label for " + name + " at index " + (string)index);
      return false;
     }
   if(!::PlotIndexSetInteger(index, PLOT_DRAW_TYPE, drawType))
     {
      ::Print("Failed to set draw type for " + name + " at index " + (string)index);
      return false;
     }
   if(!::PlotIndexSetInteger(index, PLOT_LINE_STYLE, style))
     {
      ::Print("Failed to set draw style for " + name + " at index " + (string)index);
      return false;
     }

   if(!::PlotIndexSetInteger(index, PLOT_LINE_COLOR, color_))
     {
      ::Print("Failed to set color for " + name + " at index " + (string)index);
      return false;
     }

   if(!::PlotIndexSetInteger(index, PLOT_LINE_WIDTH, width))
     {
      ::Print("Failed to set width for " + name + " at index " + (string)index);
      return false;
     }

   if(!::PlotIndexSetInteger(index, PLOT_ARROW, arrowCode))
     {
      ::Print("Failed to set arrow code for " + name + " at index " + (string)index);
      return false;
     }

   if(!PlotIndexSetInteger(index, PLOT_SHOW_DATA, showData))
     {
      ::Print("Failed to set data display for " + name + " at index " + (string)index);
      return false;
     }

#else
   ::SetIndexStyle(index, drawType, style, width, color_);
   ::SetIndexLabel(index, name);
   ::SetIndexArrow(index, arrowCode);
#endif

   return true;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#define JB_ASK SymbolInfoDouble(_Symbol, SYMBOL_ASK)
#define JB_BID SymbolInfoDouble(_Symbol, SYMBOL_BID)
//+------------------------------------------------------------------+
