//+------------------------------------------------------------------+
//|                                           JB-Moving-Averages.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#property strict
enum ENUM_MOVING_AVERAGES
  {
   ENUM_MODE_SMA = 0, // SMA
   ENUM_MODE_EMA = 1, // EMA
   ENUM_MODE_SMMA = 2, // SMMA
   ENUM_MODE_LWMA = 3, // LWMA
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMovingAverage
  {
public:
   //--- public methods
   double            iMA(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_MOVING_AVERAGES maMethod, double & data[], int shift);
   double            iMA(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_MOVING_AVERAGES maMethod, string indicatorAndFolderNameOnly, int buffer, int shift);
   double            iMA(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_MOVING_AVERAGES maMethod, ENUM_APPLIED_PRICE price, int shift);

private:
   //--- private methods and variable
   double            valArray[];
   //+------------------------------------------------------------------+
   bool              loadCustomIndicator(string symbol, ENUM_TIMEFRAMES timeframe, string indicatorAndFolderNameOnly, int buffer, bool setAsSeries = true)
     {
      ArraySetAsSeries(valArray, setAsSeries);
#ifdef __MQL5__
      const int customHandle = iCustom(symbol, timeframe, "\\Indicators\\" + indicatorAndFolderNameOnly + ".ex5", buffer);
      if(customHandle == INVALID_HANDLE)
        {
         Print("Failed to load Custom Indicator at \\Indicators\\" + indicatorAndFolderNameOnly + ".ex5");
         return false;
        }
      int copied = CopyBuffer(customHandle, 0, 0, Bars(symbol, timeframe), valArray);
      if(copied <= 0)
        {
         Print("Failed to copy buffer from Custom Indicator.");
         return false;
        }
      return true;
#else
      for(int c = 0; c < Bars(symbol, timeframe); c++)
        {
         valArray[c] = ::iCustom(symbol, timeframe,  indicatorAndFolderNameOnly + ".ex4", buffer, c);
        }
      return true;
#endif
     }

   void              loadMovingAverage(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_APPLIED_PRICE priceType, bool setAsSeries = true)
     {
      ArraySetAsSeries(valArray, setAsSeries);
      switch(priceType)
        {
         case PRICE_CLOSE: // close price
            CopyClose(symbol, timeframe, 0, Bars(symbol, timeframe), valArray);
            break;
         case PRICE_HIGH: // The maximum price for the period
            CopyHigh(symbol, timeframe, 0, Bars(symbol, timeframe), valArray);
            break;
         case PRICE_OPEN: // open prices
            CopyOpen(symbol, timeframe, 0, Bars(symbol, timeframe), valArray);
            break;
         case PRICE_LOW: // The minimum price for the period
            CopyLow(symbol, timeframe, 0, Bars(symbol, timeframe), valArray);
            break;
         case PRICE_MEDIAN: // Median price, (high + low)/2
           {
            double tempHigh[], tempLow[];
            CopyHigh(symbol, timeframe, 0, Bars(symbol, timeframe), tempHigh);
            CopyLow(symbol, timeframe, 0, Bars(symbol, timeframe), tempLow);
            int size = MathMin(ArraySize(tempHigh), ArraySize(tempLow));
            ArrayResize(valArray, size);
            for(int i = 0; i < size; i++)
               valArray[i] = (tempHigh[i] + tempLow[i]) / 2.0;
           }
         break;
         case PRICE_TYPICAL: // Typical price, (high + low + close)/3
           {
            double tempHigh[], tempLow[], tempClose[];
            CopyHigh(symbol, timeframe, 0, Bars(symbol, timeframe), tempHigh);
            CopyLow(symbol, timeframe, 0, Bars(symbol, timeframe), tempLow);
            CopyClose(symbol, timeframe, 0, Bars(symbol, timeframe), tempClose);
            int size = MathMin(ArraySize(tempHigh), MathMin(ArraySize(tempLow), ArraySize(tempClose)));
            ArrayResize(valArray, size);
            for(int i = 0; i < size; i++)
               valArray[i] = (tempHigh[i] + tempLow[i] + tempClose[i]) / 3.0;
           }
         break;
         case PRICE_WEIGHTED: // Weighted price, (high + low + close + close)/4
           {
            double tempHigh[], tempLow[], tempClose1[], tempClose2[];
            CopyHigh(symbol, timeframe, 0, Bars(symbol, timeframe), tempHigh);
            CopyLow(symbol, timeframe, 0, Bars(symbol, timeframe), tempLow);
            CopyClose(symbol, timeframe, 0, Bars(symbol, timeframe), tempClose1);
            CopyClose(symbol, timeframe, 0, Bars(symbol, timeframe), tempClose2);
            int size = MathMin(ArraySize(tempHigh), MathMin(ArraySize(tempLow), MathMin(ArraySize(tempClose1), ArraySize(tempClose2))));
            ArrayResize(valArray, size);
            for(int i = 0; i < size; i++)
               valArray[i] = (tempHigh[i] + tempLow[i] + tempClose1[i] + tempClose2[i]) / 4.0;
           }
         break;
         default:
            Print("Invalid Price Type");
            ArrayInitialize(valArray, 0.0);
            break;
        };
     }

   //+------------------------------------------------------------------+
   //| Simple Moving Average                                            |
   //+------------------------------------------------------------------+
   double            SimpleMA(const int position, const int period, const double &price[])
     {
      double result = 0.0;

      //--- check if period is valid and if there are enough data points for the given period
      if(period > 0 && position >= (period - 1))
        {
         // Loop through the number of periods starting from the current position backwards
         for(int i = 0; i < period; i++)
            result += price[position - i];  // Sum up the prices from the current position backwards

         result /= period;  // Calculate the average
        }

      return(result);
     }

   //+------------------------------------------------------------------+
   //| Smoothed Moving Average                                          |
   //+------------------------------------------------------------------+
   double            SmoothedMA(int period, int shift, const double &price[])
     {
      // Ensure we have enough data to calculate SMMA
      if(ArraySize(price) < period + shift)
        {
         Print("Not enough data to calculate SMMA.");
         return 0.0;
        }

      double smma = 0.0;

      // Step 1: Calculate the initial SMA for the first 'period' prices
      double sma = 0.0;
      for(int i = 0; i < period; i++)
         sma += price[period - 1 - i];  // Sum the first 'period' prices
      sma /= period;  // Calculate SMA (initial SMMA)

      // Initialize SMMA with the SMA value
      smma = sma;

      // Step 2: Calculate the SMMA for each price starting from 'period' to the current price at 'shift'
      for(int i = period; i < ArraySize(price) - shift; i++)
        {
         smma = ((smma * (period - 1)) + price[i]) / period;  // Calculate the SMMA
        }

      // Return the SMMA value for the given shift
      return smma;
     }

   //+------------------------------------------------------------------+
   //| Linear Weighted Moving Average                                   |
   //+------------------------------------------------------------------+
   double            LinearWeightedMA(const int position, const int period, const double &price[])
     {
      double result = 0.0;
      //--- check period
      if(period > 0 && period <= (position + 1))
        {
         double sum = 0.0;
         int    wsum = 0;

         for(int i = period; i > 0; i--)
           {
            wsum += i;
            sum += price[position - i + 1] * (period - i + 1);
           }

         result = sum / wsum;
        }
      return(result);
     }

   //+------------------------------------------------------------------+
   //| Calculate Exponential Moving Average                             |
   //+------------------------------------------------------------------+
   double            CalculateEMA(int period, int shift, const double &price[])
     {
      // Ensure we have enough data to calculate EMA
      if(ArraySize(price) < period + shift)
        {
         Print("Not enough data to calculate EMA.");
         return 0.0;
        }

      double alpha = 2.0 / (period + 1.0);  // Smoothing factor for EMA
      double ema = 0.0;

      // Step 1: Calculate the SMA for the first 'period' prices (this is the initial EMA value)
      double sma = 0.0;
      for(int i = 0; i < period; i++)
         sma += price[period - 1 - i];  // Sum the first 'period' prices
      sma /= period;  // Calculate SMA

      // Initialize EMA with the SMA value
      ema = sma;

      // Step 2: Calculate the EMA for each price starting from 'period' to the current price at 'shift'
      for(int i = period; i < ArraySize(price) - shift; i++)
        {
         ema = price[i] * alpha + ema * (1.0 - alpha);  // Calculate the EMA
        }

      // Return the EMA value for the given shift
      return ema;
     }

  };
//+------------------------------------------------------------------+
//--- full code
double            CMovingAverage::iMA(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_MOVING_AVERAGES maMethod, double & data[], int shift)
  {

// Ensure the shift is within bounds
   if(shift < 0 || shift >= ArraySize(valArray))
     {
      Print("Invalid shift value.");
      return 0.0;
     }

   switch(maMethod)
     {
      case ENUM_MODE_SMA:
         // if maMethod is not SMA, rates should not be set as series
         if(!ArrayIsSeries(data))
           {
            Print("Array should be set as series");
           }
         return SimpleMA(period + shift - 1, period, valArray);
         break;
      case ENUM_MODE_LWMA:
         // if maMethod is not SMA, rates should not be set as series
         if(ArrayIsSeries(data))
           {
            Print("Array should not be set as series");
           }
         return LinearWeightedMA(ArraySize(valArray) - (shift + 1), period, valArray);
         break;
      case ENUM_MODE_EMA:
         // if maMethod is not SMA, rates should not be set as series
         if(ArrayIsSeries(data))
           {
            Print("Array should not be set as series");
           }
         return CalculateEMA(period, shift, valArray);
         break;
      case ENUM_MODE_SMMA:
         // if maMethod is not SMA, rates should not be set as series
         if(ArrayIsSeries(data))
           {
            Print("Array should not be set as series");
           }
         return SmoothedMA(period, shift, valArray);
         break;
      default:
         Print("Invalid MA Method");
         return 0.0;
     }
   return 0.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double            CMovingAverage::iMA(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_MOVING_AVERAGES maMethod, string indicatorAndFolderNameOnly, int buffer, int shift)
  {
   if(!loadCustomIndicator(symbol, timeframe, indicatorAndFolderNameOnly, buffer, maMethod != ENUM_MODE_LWMA))
      return 0.0;

// Ensure the shift is within bounds
   if(shift < 0 || shift >= ArraySize(valArray))
     {
      Print("Invalid shift value.");
      return 0.0;
     }

   switch(maMethod)
     {
      case ENUM_MODE_SMA:
         return SimpleMA(period + shift - 1, period, valArray);
         break;
      case ENUM_MODE_LWMA:
         return LinearWeightedMA(ArraySize(valArray) - (shift + 1), period, valArray);
         break;
      case ENUM_MODE_EMA:
         return CalculateEMA(period, shift, valArray);
         break;
      case ENUM_MODE_SMMA:
         return SmoothedMA(period, shift, valArray);
         break;
      default:
         Print("Invalid MA Method");
         return 0.0;
     }
   return 0.0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double            CMovingAverage::iMA(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_MOVING_AVERAGES maMethod, ENUM_APPLIED_PRICE price, int shift)
  {
// Load the price data into valArray based on the applied price
   loadMovingAverage(symbol, timeframe, period, price, maMethod == ENUM_MODE_SMA);

// Ensure the shift is within bounds
   if(shift < 0 || shift >= ArraySize(valArray))
     {
      Print("Invalid shift value.");
      return 0.0;
     }

   switch(maMethod)
     {
      case ENUM_MODE_SMA:
         return SimpleMA(period + shift - 1, period, valArray);
         break;
      case ENUM_MODE_LWMA:
         return LinearWeightedMA(ArraySize(valArray) - (shift + 1), period, valArray);
         break;
      case ENUM_MODE_EMA:
         return CalculateEMA(period, shift, valArray);
         break;
      case ENUM_MODE_SMMA:
         return SmoothedMA(period, shift, valArray);
         break;
      default:
         Print("Invalid MA Method");
         return 0.0;
     }
   return 0.0;
  }
//+------------------------------------------------------------------+
