//+------------------------------------------------------------------+
//|                                                 JB-Indicator.mqh |
//|                                     Copyright 2024-2025,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked"
#property link      "https://www.jblanked.com/"
#property strict
//--- Last Updated: March 30th, 2025
#include <jb-array.mqh> // download from https://github.com/jblanked/MQL-Library/blob/main/JB-Array.mqh

#ifdef __MQL4__ enum ENUM_APPLIED_VOLUME { VOLUME_TICK, VOLUME_REAL };
#else
enum ENUM_ENVELOPE {MODE_LOWER = 1, MODE_UPPER = 0};
enum ENUM_MACD {MODE_SIGNAL = 1, MODE_MAIN = 0};
#endif

/*
   Best Expert Advisor Use (for getting indicator values):

      #include <jb-indicator.mqh>
      CIndicator indi;

      int OnInit()
      {
         //--- get your indicator value (must be done in MT5 to initialize)
         indi.iMA(_Symbol, PERIOD_CURRENT, 9, 0, MODE_EMA, PRICE_CLOSE, 1);
      }

      void OnTick()
      {
         //--- get indicator value again
         const double ema9 = indi.iMA(_Symbol, PERIOD_CURRENT, 9, 0, MODE_EMA, PRICE_CLOSE, 1);

         //--- do something with value
      }

   Best Indicator Use (for getting indicator values):

      #include <jb-indicator.mqh>
      CIndicator indi;

      int OnInit()
      {
         //--- get your indicator value (must be done in MT5 to initialize)
         indi.iMA(_Symbol, PERIOD_CURRENT, 9, 0, MODE_EMA, PRICE_CLOSE, 1);
      }

      int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
      {
         int limit = rates_total - prev_calculated;

         //---- set indicator values
         for(int i = limit - 1; i >= 0; i--)
         {

         //--- get indicator value again
         const double ema9 = indi.iMA(_Symbol, PERIOD_CURRENT, 9, 0, MODE_EMA, PRICE_CLOSE, i);

         //--- do something with value
         }

         return(rates_total);
      }
*/
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

#ifdef __MQL5__
   //--- uses objects to plot indicator values (I use this to display specific indicator values while backtesting)
   void              draw(double & bufferData[], const ENUM_DRAW_TYPE drawType, const ENUM_LINE_STYLE style, const color color_, const int width, const int arrowCode = 233);
#else
   void              draw(double & bufferData[], const int drawType, const ENUM_LINE_STYLE style, const color color_, const int width, const int arrowCode = 233);
#endif

   //--- direct indicator values
   double            iMA(const string symbol, const ENUM_TIMEFRAMES timeframe, const int maPeriod, const int maShift, const ENUM_MA_METHOD maMethod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true);
   double            iMAOnArray(double & array[], const int period, const int maShift, const ENUM_MA_METHOD maMethod, const int shift);
   double            iRSI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int rsiPeriod, const int appliedPriceOrHandle, const int shift, const bool copyBuffer = true);
   double            iATR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int atrPeriod, const int shift, const bool copyBuffer = true);
   double            iADX(const string symbol, const ENUM_TIMEFRAMES timeframe, const int adxPeriod, ENUM_APPLIED_PRICE appliedPrice, int adxMode = 0, const int shift = 0, const bool copyBuffer = true);
   double            iCustom(const string symbol, const ENUM_TIMEFRAMES timeframe, const string indicatorAndFolderNameOnly = "IndicatorName", const int buffer = 0, const int shift = 1, const bool copyBuffer = true);
   double            iEnvelopes(const string symbol, const ENUM_TIMEFRAMES timeframe, const int envPeriod, const int maShift,  const ENUM_MA_METHOD envMethod, const int appliedPriceOrHandle, const double envDeviation, const int envMode = 0, const int shift = 1, const bool copyBuffer = true);
   double            iFractals(const string symbol, const ENUM_TIMEFRAMES timeframe, const int fractalMode = 0, const int shift = 0, const bool copyBuffer = true);
   double            iMACD(const string symbol, const ENUM_TIMEFRAMES timeframe, const int fastPeriod, const int slowPeriod, const int signalPeriod, ENUM_APPLIED_PRICE appliedPrice, int macdMode = 0, const int shift = 0, const bool copyBuffer = true);
   double            iAO(const string symbol, const ENUM_TIMEFRAMES timeframe, const int shift = 0, const bool copyBuffer = true);
   double            iMomentum(const string symbol, const ENUM_TIMEFRAMES timeframe, const int momemtumPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true);
   double            iWPR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int wprPeriod, const int shift = 0, const bool copyBuffer = true);
   double            iBullsPower(const string symbol, const ENUM_TIMEFRAMES timeframe, const int bullPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true);
   double            iBearsPower(const string symbol, const ENUM_TIMEFRAMES timeframe, const int bearPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true);
   double            iATHR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int shift = 0, const bool copyBuffer = true);
   double            iStochastic(const string symbol, const ENUM_TIMEFRAMES timeframe, const int kPeriod, const int dPeriod, const int slowPeriod, const ENUM_MA_METHOD maMethod, ENUM_STO_PRICE stoPrice, const int stochMode = MODE_SIGNAL, const int shift = 0, const bool copyBuffer = true);
   double            iCCI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int cciPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true);
   double            iADR(const string symbol, const int period, const int shift);
   double            iVWAP(const string symbol, const ENUM_TIMEFRAMES timeframe, const int period, const int shift);
   double            iPVI(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_VOLUME volumeType, const int shift);
   double            iPVI(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_VOLUME volumeType, const double & closeData[], const int shift);
   double            iRSIOnArray(double &array[], int period, int shift, int total = 0);
   //--- others
   bool              deletePointer(void *ptr); //--- delete pointer safely
   int               getMaxBars(const string symbol, const ENUM_TIMEFRAMES timeframe, const int userMaximum = 5000); //--- maximum candles
   string            uninitReasonText(int reasonCode);
   int               windowFind(string name);

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
   double            tempProgress;
   double            tempVal;
   double            tempClose;
public:
   CJBRates          rates;
protected:
   CIndicatorHelper  data[];
   string            helperName;
};
//+------------------------------------------------------------------+
bool CIndicator::deletePointer(void *ptr)
{
   if(CheckPointer(ptr) == POINTER_DYNAMIC)
   {
      delete ptr;
      ptr = NULL;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
int CIndicator::getMaxBars(const string symbol, const ENUM_TIMEFRAMES timeframe, const int userMaximum = 5000)
{
   return MathMin(Bars(symbol, timeframe), userMaximum);
}
//+------------------------------------------------------------------+
string CIndicator::uninitReasonText(int reasonCode)
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
//+------------------------------------------------------------------+
double CIndicator::iADR(const string symbol, const int period, const int shift)
{
   double val = 0;
   double sum1 = 0;
   for(int i = shift; i <= shift + period; i++)
      sum1 += (iHigh(symbol, PERIOD_D1, i) - iLow(symbol, PERIOD_D1, i));

   val = sum1 / period;
   return(val);
}
//+------------------------------------------------------------------+
double CIndicator:: iVWAP(const string symbol, const ENUM_TIMEFRAMES timeframe, const int period, const int shift)
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
double CIndicator::iPVI(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_VOLUME volumeType, const int shift)
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
//+------------------------------------------------------------------+
double CIndicator::iPVI(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_VOLUME volumeType, const double & closeData[], const int shift)
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
double CIndicator:: iRSIOnArray(double &array[], int period, int shift, int total = 0)
{
   if(total == 0)
      total = ArraySize(array);
   int stop = total - shift;
   if(period <= 1 || shift < 0 || stop <= period)
      return 0;
   bool isSeries = ArrayGetAsSeries(array);
   if(isSeries)
      ArraySetAsSeries(array, false);
   int i;
   double SumP = 0;
   double SumN = 0;
   for(i = 1; i <= period; i++)
   {
      double diff = array[i] - array[i - 1];
      if(diff > 0)
         SumP += diff;
      else
         SumN += -diff;
   }
   double AvgP = SumP / period;
   double AvgN = SumN / period;
   for(; i < stop; i++)
   {
      double diff = array[i] - array[i - 1];
      AvgP = (AvgP * (period - 1) + (diff > 0 ? diff : 0)) / period;
      AvgN = (AvgN * (period - 1) + (diff < 0 ? -diff : 0)) / period;
   }
   double _rsi_;
   if(AvgN == 0.0)
   {
      _rsi_ = (AvgP == 0.0 ? 50.0 : 100.0);
   }
   else
   {
      _rsi_ = 100.0 - (100.0 / (1.0 + AvgP / AvgN));
   }
   if(isSeries)
      ArraySetAsSeries(array, true);
   return _rsi_;
}
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
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
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
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iRSI(symbol, timeframe, rsiPeriod, appliedPriceOrHandle, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iBullsPower(const string symbol, const ENUM_TIMEFRAMES timeframe, const int bullPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iBullsPower" + symbol + string(timeframe) + string(bullPeriod) + string(appliedPrice);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iBullsPower(symbol, timeframe, bullPeriod);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set Bulls Power");
         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iBullsPower(symbol, timeframe, bullPeriod, appliedPrice, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iBearsPower(const string symbol, const ENUM_TIMEFRAMES timeframe, const int bearPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iBearsPower" + symbol + string(timeframe) + string(bearPeriod) + string(appliedPrice);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iBearsPower(symbol, timeframe, bearPeriod);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set Bears Power");
         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iBearsPower(symbol, timeframe, bearPeriod, appliedPrice, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iWPR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int wprPeriod, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iWPR" + symbol + string(timeframe) + string(wprPeriod);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iWPR(symbol, timeframe, wprPeriod);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set Larry Williams' Percent Range.");
         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iWPR(symbol, timeframe, wprPeriod, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iMomentum(const string symbol, const ENUM_TIMEFRAMES timeframe, const int momemtumPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iMomentum" + symbol + string(timeframe) + string(momemtumPeriod) + string(appliedPrice);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iMomentum(symbol, timeframe, momemtumPeriod, appliedPrice);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set Momemtum");
         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iMomentum(symbol, timeframe, momemtumPeriod, appliedPrice, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iAO(const string symbol, const ENUM_TIMEFRAMES timeframe, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iAO" + symbol + string(timeframe);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iAO(symbol, timeframe);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set Awesome Oscillator");
         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iAO(symbol, timeframe, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iFractals(const string symbol, const ENUM_TIMEFRAMES timeframe, const int fractalMode = 0, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iFractals" + symbol + string(timeframe);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iFractals(symbol, timeframe);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set Fractals");
         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, fractalMode, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iFractals(symbol, timeframe, fractalMode, shift);
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
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
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
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iADX(symbol, timeframe, adxPeriod, appliedPrice, adxMode, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iStochastic(const string symbol, const ENUM_TIMEFRAMES timeframe, const int kPeriod, const int dPeriod, const int slowPeriod, const ENUM_MA_METHOD maMethod, ENUM_STO_PRICE stoPrice, const int stochMode = MODE_SIGNAL, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iStochastic" + symbol + string(timeframe) + string(kPeriod) + string(dPeriod) + string(slowPeriod) + EnumToString(maMethod) + EnumToString(stoPrice);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iStochastic(symbol, timeframe, kPeriod, dPeriod, slowPeriod, maMethod, stoPrice);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set Stochastic.");

         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, stochMode, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iStochastic(symbol, timeframe, kPeriod, dPeriod, slowPeriod, maMethod, stoPrice, stochMode, shift);
#endif
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CIndicator::iCCI(const string symbol, const ENUM_TIMEFRAMES timeframe, const int cciPeriod, ENUM_APPLIED_PRICE appliedPrice, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iCCI" + symbol + string(timeframe) + string(cciPeriod) + string(appliedPrice);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iCCI(symbol, timeframe, cciPeriod, appliedPrice);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set CCI");
         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, 0, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iCCI(symbol, timeframe, cciPeriod, appliedPrice, shift);
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
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
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
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iEnvelopes(symbol, timeframe, envPeriod, maShift, envMethod, appliedPriceOrHandle, envDeviation, envMode, shift);
#endif
}
//+------------------------------------------------------------------+
double CIndicator::iMACD(const string symbol, const ENUM_TIMEFRAMES timeframe, const int fastPeriod, const int slowPeriod, const int signalPeriod, ENUM_APPLIED_PRICE appliedPrice, int macdMode = 0, const int shift = 0, const bool copyBuffer = true)
{
#ifdef __MQL5__
   this.helperName = "iMACD" + symbol + string(timeframe) + string(fastPeriod) + string(slowPeriod) + string(signalPeriod) + string(appliedPrice) + string(macdMode);
   this.setHelper(this.helperName);

   if(shift > this.temp.lastSize || !this.temp.isHandleSet)
   {
      this.temp.resize(shift + 3); // resize array
      this.temp.lastSize = shift;
   }

//--- set handle
   if(!this.temp.isHandleSet)
   {
      this.temp.handle = ::iMACD(symbol, timeframe, fastPeriod, slowPeriod, signalPeriod, appliedPrice);

      if(this.temp.handle == EMPTY_VALUE)
      {
         ::Print("Failed to set MACD.");

         return EMPTY_VALUE;
      }

      this.temp.isHandleSet = true;
   }

   if(copyBuffer)
   {
      ::CopyBuffer(this.temp.handle, macdMode, 0, shift + 1, this.temp.value);
   }
   this.data[this.helperIndex] = this.temp;
   return shift >= ArraySize(this.temp.value) ? EMPTY_VALUE : this.temp.value[shift];
#else
   return ::iMACD(symbol, timeframe, fastPeriod, slowPeriod, signalPeriod, appliedPrice, macdMode, shift);
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
double CIndicator::iATHR(const string symbol, const ENUM_TIMEFRAMES timeframe, const int shift = 0, const bool copyBuffer = true)
{
   this.tempProgress = 0;
   this.tempVal = 0;
   this.tempClose = iClose(symbol, timeframe, shift);

//--- EMA and SMA Moving Averages (12 indicators)
   int ma_periods[] = {10, 20, 30, 50, 100, 200};
   for(int i = 0; i < ArraySize(ma_periods); i++)
   {
      // EMA
      this.tempVal = this.iMA(symbol, timeframe, ma_periods[i], 0, MODE_EMA, PRICE_CLOSE, shift, copyBuffer);
      this.tempProgress += (this.tempClose > this.tempVal) ? 1 : (this.tempClose < this.tempVal) ? -1 : 0;

      // SMA
      this.tempVal = this.iMA(symbol, timeframe, ma_periods[i], 0, MODE_SMA, PRICE_CLOSE, shift, copyBuffer);
      this.tempProgress += (this.tempClose > this.tempVal) ? 1 : (this.tempClose < this.tempVal) ? -1 : 0;
   }

//--- VMA 20
   this.tempVal = this.iMA(symbol, timeframe, 20, 0, MODE_LWMA, PRICE_WEIGHTED, shift, copyBuffer);
   this.tempProgress += (this.tempClose > this.tempVal) ? 1 : (this.tempClose < this.tempVal) ? -1 : 0;

//--- RSI 14
   this.tempVal = this.iRSI(symbol, timeframe, 14, PRICE_CLOSE, shift, copyBuffer);
   this.tempProgress += (this.tempVal < 30) ? -1 : (this.tempVal > 70) ? 1 : 0;

//--- Awesome Oscillator (AO)
   this.tempVal = this.iAO(symbol, timeframe);
   this.tempProgress += (this.tempVal > 0) ? 1 : (this.tempVal < 0) ? -1 : 0;

//--- Momentum
   this.tempVal = this.iMomentum(symbol, timeframe, 10, PRICE_CLOSE, shift, copyBuffer);
   this.tempProgress += (this.tempVal > 100) ? 1 : (this.tempVal < 100) ? -1 : 0;

//--- MACD
   this.tempVal = this.iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE, shift, copyBuffer);
   this.tempProgress += (this.tempVal > 0) ? 1 : (this.tempVal < 0) ? -1 : 0;

//--- Williams' Percent Range (WPR) 14
   this.tempVal = this.iWPR(symbol, timeframe, 14, shift, copyBuffer);
   this.tempProgress += (this.tempVal < -70) ? -1 : (this.tempVal > -30) ? 1 : 0;

//--- Bulls Power
   this.tempVal = this.iBullsPower(symbol, timeframe, 14, PRICE_CLOSE, shift, copyBuffer);
   this.tempProgress += (this.tempVal > 0) ? 1 : (this.tempVal < 0) ? -1 : 0;

//--- Bears Power
   this.tempVal = this.iBearsPower(symbol, timeframe, 14, PRICE_CLOSE, shift, copyBuffer);
   this.tempProgress += (this.tempVal > 0) ? -1 : (this.tempVal < 0) ? 1 : 0;

//--- Stochastic 14, 3, 3 SMA
   this.tempVal = this.iStochastic(symbol, timeframe, 14, 3, 3, MODE_SMA, STO_LOWHIGH, shift, copyBuffer);
   this.tempProgress += (this.tempVal < 30) ? -1 : (this.tempVal > 70) ? 1 : 0;

// Total indicators: 12 MAs + 1 VMA + 8 others = 21
// Each contributes between -1 and +1, so tempProgress ranges from -21 to +21

//--- Return a value between 0 and 100
   return ((this.tempProgress + 21.0) / 42.0) * 100.0;
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
      ::Print("Failed to set line width for " + name + " at index " + (string)index);
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
int CIndicator::windowFind(string name)
{
   int window = -1;
   if((ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_INDICATOR)
   {
      window = ChartWindowFind();
   }
   else
   {
      window = ChartWindowFind(0, name);
      if(window == -1) Print(__FUNCTION__ + "(): Error = ", GetLastError());
   }
   return(window);
}
//+------------------------------------------------------------------+
#define JB_ASK SymbolInfoDouble(_Symbol, SYMBOL_ASK)
#define JB_BID SymbolInfoDouble(_Symbol, SYMBOL_BID)
//+------------------------------------------------------------------+
