///+------------------------------------------------------------------+
//|                                                 Fib-Sessions.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property indicator_chart_window
#property strict
#property description "Draws fibonacci retracement from the daily high to the daily low"
#property indicator_buffers 9
#property indicator_plots 9
#define CHART_ID 0
#define FIB_PREFIX "Fib-Daily-Range"
#include <jb-indicator.mqh>
//--- inputs
input double inpFibLevel1   = 0.000000;  // Fib Level 1
input double inpFibLevel2   = 0.236068;  // Fib Level 2
input double inpFibLevel3   = 0.381966;  // Fib Level 3
input double inpFibLevel4   = 0.500000;  // Fib Level 4
input double inpFibLevel5   = 0.618034;  // Fib Level 5
input double inpFibLevel6   = 1.000000;  // Fib Level 6
input double inpFibLevel7   = 1.618034;  // Fib Level 7
input double inpFibLevel8   = 2.618034;  // Fib Level 8
input double inpFibLevel9   = 4.236068;  // Fib Level 9
input color  inpFibColor    = clrYellow; // Fib Color
input int    inpFibWidth    = 1;         // Fib Width
//--- globals
double fib_1[], fib_2[], fib_3[], fib_4[], fib_5[], fib_6[], fib_7[], fib_8[], fib_9[];
double levels[9];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   CIndicator indi;
   if(!indi.createBuffer(DoubleToString(inpFibLevel1, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 0, fib_1))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel2, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 1, fib_2))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel3, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 2, fib_3))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel4, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 3, fib_4))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel5, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 4, fib_5))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel6, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 5, fib_6))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel7, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 6, fib_7))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel8, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 7, fib_8))
      return INIT_FAILED;
   if(!indi.createBuffer(DoubleToString(inpFibLevel9, 3), DRAW_NONE, STYLE_SOLID, inpFibColor, inpFibWidth, 8, fib_9))
      return INIT_FAILED;

   // set levels
   levels[0] = inpFibLevel1;
   levels[1] = inpFibLevel2;
   levels[2] = inpFibLevel3;
   levels[3] = inpFibLevel4;
   levels[4] = inpFibLevel5;
   levels[5] = inpFibLevel6;
   levels[6] = inpFibLevel7;
   levels[7] = inpFibLevel8;
   levels[8] = inpFibLevel9;

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
// Calculate how many bars to process.
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArrayInitialize(fib_1, EMPTY_VALUE);
      ArrayInitialize(fib_2, EMPTY_VALUE);
      ArrayInitialize(fib_3, EMPTY_VALUE);
      ArrayInitialize(fib_4, EMPTY_VALUE);
      ArrayInitialize(fib_5, EMPTY_VALUE);
      ArrayInitialize(fib_6, EMPTY_VALUE);
      ArrayInitialize(fib_7, EMPTY_VALUE);
      ArrayInitialize(fib_8, EMPTY_VALUE);
      ArrayInitialize(fib_9, EMPTY_VALUE);

      ArraySetAsSeries(fib_1, true);
      ArraySetAsSeries(fib_2, true);
      ArraySetAsSeries(fib_3, true);
      ArraySetAsSeries(fib_4, true);
      ArraySetAsSeries(fib_5, true);
      ArraySetAsSeries(fib_6, true);
      ArraySetAsSeries(fib_7, true);
      ArraySetAsSeries(fib_8, true);
      ArraySetAsSeries(fib_9, true);
   }
   else limit++;

   limit = MathMin(limit, 10000);

   int candle_low, candle_high;
   int bar_shift;
   datetime daily, current, daily_end;

   for(int x = limit - 1; x >= 0; x--)
   {
      current   = iTime(_Symbol, PERIOD_CURRENT, x);
      bar_shift = iBarShift(_Symbol, PERIOD_D1, current);
      daily     = iTime(_Symbol, PERIOD_D1, bar_shift);

#ifdef __MQL4__
      //--- only show today
      if(daily != iTime(_Symbol, PERIOD_D1, 0))
         continue;
#endif

      // Compute end of daily candle
      daily_end = daily + PeriodSeconds(PERIOD_D1) - 1;

      // Find the current timeframe candle indices corresponding to the daily high and low
      candle_high = price_to_candle(_Symbol, PERIOD_CURRENT, iHigh(_Symbol, PERIOD_D1, bar_shift), daily, daily_end, false);
      candle_low  = price_to_candle(_Symbol, PERIOD_CURRENT, iLow(_Symbol, PERIOD_D1, bar_shift), daily, daily_end, true);

      // Only draw if valid candle indices were found
      if(candle_high != -1 && candle_low != -1)
         draw_fib(_Symbol, PERIOD_CURRENT, levels, candle_high, candle_low);
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Draw Fibonacci retracement between two bar indices               |
//+------------------------------------------------------------------+
void draw_fib(
   string symbol,
   ENUM_TIMEFRAMES timeframe,
   double &fib_levels[],
   int start_x,
   int end_x,
   color fib_color = clrYellow,
   int fib_width = 1)
{
// Create a unique object name using the bar time for the starting bar
   const string obj_name = FIB_PREFIX + TimeToString(iTime(symbol, timeframe, start_x), TIME_DATE | TIME_MINUTES);
   if(ObjectFind(CHART_ID, obj_name) < 0)
   {
      const int arr_size = ArraySize(fib_levels);
      double price_1 = iHigh(symbol, timeframe, start_x);
      double price_2 = iLow(symbol, timeframe, end_x);
      const datetime time_1 = iTime(symbol, timeframe, start_x);
      const datetime time_2 = iTime(symbol, timeframe, end_x);

      // Make sure price_1 is the lower value
      if(price_2 > price_1)
      {
         price_1 = iLow(symbol, timeframe, start_x);
         price_2 = iHigh(symbol, timeframe, end_x);
      }

      // Create the Fibonacci retracement object
      ObjectCreate(CHART_ID, obj_name, OBJ_FIBO, 0, time_1, price_1, time_2, price_2);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_BACK, true);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_FILL, true);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELCOLOR, fib_color);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELWIDTH, fib_width);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELS, arr_size);

      // Assign each Fibonacci level
      for(int level = 0; level < arr_size; level++)
      {
         ObjectSetDouble(CHART_ID, obj_name, OBJPROP_LEVELVALUE, level, fib_levels[level]);
         ObjectSetString(CHART_ID, obj_name, OBJPROP_LEVELTEXT, level, DoubleToString(100.0 * fib_levels[level], 1) + "  %$");
         set_buffer(level, 0, fib_price(obj_name, level));
      }
   }
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(CHART_ID, FIB_PREFIX);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int price_to_candle(string symbol, ENUM_TIMEFRAMES timeframe, double price, datetime begin, datetime ending, bool use_low)
{
   int s = iBarShift(symbol, timeframe, begin);
   int e = iBarShift(symbol, timeframe, ending);
   for(; s >= e; s--)
   {
      if(use_low && price == iLow(symbol, timeframe, s))
         return s;
      else if(!use_low && price == iHigh(symbol, timeframe, s))
         return s;
   }
   return -1;
}
//+------------------------------------------------------------------+
void set_buffer(int buffer, int index, double val)
{
   switch(buffer)
   {
   case 0:
      fib_1[index] = val;
      break;
   case 1:
      fib_2[index] = val;
      break;
   case 2:
      fib_3[index] = val;
      break;
   case 3:
      fib_4[index] = val;
      break;
   case 4:
      fib_5[index] = val;
      break;
   case 5:
      fib_6[index] = val;
      break;
   case 6:
      fib_7[index] = val;
      break;
   case 7:
      fib_8[index] = val;
      break;
   case 8:
      fib_9[index] = val;
      break;
   }
}
//+------------------------------------------------------------------+
double fib_price(string fib_object_name, int fib_level)
{
   const double onePrice = ObjectGetDouble(CHART_ID, fib_object_name, OBJPROP_PRICE, 0); //get   0% price
   const double zeroPrice = ObjectGetDouble(CHART_ID, fib_object_name, OBJPROP_PRICE, 1); //get 100% price
   const double range = onePrice - zeroPrice;
   const double value = ObjectGetDouble(CHART_ID, fib_object_name, OBJPROP_LEVELVALUE, fib_level);
   return zeroPrice + range * value;
}
//+------------------------------------------------------------------+
