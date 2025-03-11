//+------------------------------------------------------------------+
//|                                       Engulfing-Candle-Alert.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property indicator_chart_window
#property strict
//--- indicator settings
#property indicator_buffers 4
#property indicator_plots 4
//
#property indicator_label1 "Buy"
#property indicator_color1 clrLime
#property indicator_width1 5
#property indicator_style1 STYLE_SOLID
//
#property indicator_label2 "Sell"
#property indicator_color2 clrMagenta
#property indicator_width2 5
#property indicator_style2 STYLE_SOLID
//
#property indicator_label3 "Round Level Buy"
#property indicator_color3 clrGreenYellow
#property indicator_width3 2
#property indicator_style3 STYLE_SOLID
//
#property indicator_label4 "Round Level Sell"
#property indicator_color4 clrOrangeRed
#property indicator_width4 2
#property indicator_style4 STYLE_SOLID
//--- includes
#include <jb-indicator.mqh> // from https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Indicator.mqh
//--- globals
double buys[], sells[], rbuys[], rsells[];
double pip;
string round_level;
//--- inputs
/*
I am looking to develop an Indicator to draw arrows (green=buy , red=sell) if there is an engulfment on the timeframe of my choice.

The buy engulfment must happen xx pips away (i need to be able to choose) from the
 - Low of the Day
 - Low of Previous Day
 - Low of the Week
 - Low of the Month
 - Low of the year.

(For Sell of course at the Highs)

If the engulfment is xx pips away from a Round Level (.500 and .000) then please mark it in a lighter green, or lighter red.

Please also add a time filter for showing arrows and sending alerts.
*/
enum enum_timeframe
{
   ENUM_DAY,          // Day
   ENUM_PREVIOUS_DAY, // Previous Day
   ENUM_WEEK,         // Week
   ENUM_MONTH,        // Month
   ENUM_YEAR          // Year
};
//
input ENUM_TIMEFRAMES inpIndicatorTimeframe  = PERIOD_CURRENT; // Indicator Timeframe
input enum_timeframe  inpEngulfmentTimeframe = ENUM_DAY;       // Timeframe
input double          inpXPipsAway           = 100.0;          // X Pips Away
input bool            inpSendAlert           = false;          // Allow Alerts?
input string          inpStartTime           = "01:00";        // Start Time
input string          inpEndTime             = "23:00";        // Stop Time
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if(TimeCurrent() >= D'12.03.2025') return INIT_FAILED;
//--- indicator buffers mapping
   CIndicator indi;
   if(!indi.createBuffer(indicator_label1, DRAW_ARROW, indicator_style1, indicator_color1, indicator_width1, 0, buys, true, INDICATOR_DATA, 233))
      return INIT_FAILED;
   if(!indi.createBuffer(indicator_label2, DRAW_ARROW, indicator_style2, indicator_color2, indicator_width2, 1, sells, true, INDICATOR_DATA, 234))
      return INIT_FAILED;
   if(!indi.createBuffer(indicator_label3, DRAW_ARROW, indicator_style3, indicator_color3, indicator_width3, 2, rbuys, true, INDICATOR_DATA, 151))
      return INIT_FAILED;
   if(!indi.createBuffer(indicator_label4, DRAW_ARROW, indicator_style4, indicator_color4, indicator_width4, 3, rsells, true, INDICATOR_DATA, 151))
      return INIT_FAILED;
   //
   pip = Point() * 10;
   //
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
//---
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
//---
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArrayInitialize(buys, EMPTY_VALUE);
      ArrayInitialize(sells, EMPTY_VALUE);
      ArraySetAsSeries(buys, true);
      ArraySetAsSeries(sells, true);
      //
      ArrayInitialize(rbuys, EMPTY_VALUE);
      ArrayInitialize(rsells, EMPTY_VALUE);
      ArraySetAsSeries(rbuys, true);
      ArraySetAsSeries(rsells, true);
   }
   else limit++;
//---
   const int arr_size = ArraySize(buys);
   int bar_shift = -1;
   int cnt = inpIndicatorTimeframe == PERIOD_CURRENT ? limit : rates_total;
   for(int x = cnt - 1; x >= 0; x--)
   {
      if((x + 1) >= arr_size || !time_allowed(true, inpStartTime, inpEndTime, iTime(_Symbol, PERIOD_CURRENT, x + 1))) continue;
      bar_shift = iBarShift(_Symbol, inpIndicatorTimeframe, iTime(_Symbol, PERIOD_CURRENT, x + 1));
      if((bar_shift) >= arr_size || bar_shift < 0) continue;
      if(is_near_level(true, bar_shift) && is_engulfing(_Symbol, inpIndicatorTimeframe, true, bar_shift))
      {
         double price_to_set = iLow(_Symbol, inpIndicatorTimeframe, bar_shift);
         if(!is_round_level(price_to_set))
            buys[x + 1] = price_to_set;
         else
            rbuys[x + 1] = price_to_set;
      }
      else if(is_near_level(false, bar_shift) && is_engulfing(_Symbol, inpIndicatorTimeframe, false, bar_shift))
      {
         double price_to_set = iHigh(_Symbol, inpIndicatorTimeframe, bar_shift);
         if(!is_round_level(price_to_set))
            sells[x + 1] = price_to_set;
         else
            rsells[x + 1] = price_to_set;
      }

   }
//--- send alerts
   if(inpSendAlert) alert();
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------------------------------------+
//| returns true if a candle that closes above the previous candle for a buy and below for a sell. |
//+------------------------------------------------------------------------------------------------+
bool is_engulfing(string symbol, ENUM_TIMEFRAMES timeframe, bool bullish, const int i)
{
   return
      bullish ? iClose(symbol, timeframe, i) > iHigh(symbol, timeframe, i + 1) : // selected candle closes above previous high
      !bullish ? iClose(symbol, timeframe, i) < iLow(symbol, timeframe, i + 1) : // selected candle closes below previous low
      false;
}
//+------------------------------------------------------------------+
//| returns true if near low/high of user selected timeframe         |
//+------------------------------------------------------------------+
bool is_near_level(bool bullish, const int x)
{
   const double current = iClose(_Symbol, inpIndicatorTimeframe, x);
   double price_point = 0.0;
   switch(inpEngulfmentTimeframe)
   {
   case ENUM_DAY:
      price_point = bullish ? iLow(_Symbol, PERIOD_D1, x) : iHigh(_Symbol, PERIOD_D1, x);
      break;
   case ENUM_PREVIOUS_DAY:
      price_point = bullish ? iLow(_Symbol, PERIOD_D1, x + 1) : iHigh(_Symbol, PERIOD_D1, x + 1);
      break;
   case ENUM_WEEK:
      price_point = bullish ? iLow(_Symbol, PERIOD_W1, x) : iHigh(_Symbol, PERIOD_W1, x);
      break;
   case ENUM_MONTH:
      price_point = bullish ? iLow(_Symbol, PERIOD_MN1, x) : iHigh(_Symbol, PERIOD_MN1, x);
      break;
   case ENUM_YEAR:
      price_point =
         bullish
         ?
         iLow(_Symbol, PERIOD_MN1, iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, 12, x))
         :
         iHigh(_Symbol, PERIOD_MN1, iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, 12, x));
      break;
   }
   return MathAbs(current - price_point) < (inpXPipsAway * pip);
}
datetime last_alert;
//+------------------------------------------------------------------+
void alert(int x = 1)
{
   if(last_alert != iTime(_Symbol, PERIOD_CURRENT, x))
   {
      last_alert = iTime(_Symbol, PERIOD_CURRENT, x);

      string msg = "";

      if(buys[x] != EMPTY_VALUE && sells[x] == EMPTY_VALUE && rbuys[x] == EMPTY_VALUE && rsells[x] == EMPTY_VALUE)
      {
         // send buy alert
         msg = message(true);
         Alert(msg);
         SendNotification(msg);
      }
      else if(buys[x] == EMPTY_VALUE && sells[x] != EMPTY_VALUE && rbuys[x] == EMPTY_VALUE && rsells[x] == EMPTY_VALUE)
      {
         // send sell alert
         msg = message(false);
         Alert(msg);
         SendNotification(msg);
      }
      else if(rbuys[x] != EMPTY_VALUE && rsells[x] == EMPTY_VALUE && buys[x] == EMPTY_VALUE && sells[x] == EMPTY_VALUE)
      {
         // send buy alert
         msg = message(true);
         msg += " & Round Level " + round_level;
         Alert(msg);
         SendNotification(msg);
      }
      else if(rbuys[x] == EMPTY_VALUE && rsells[x] != EMPTY_VALUE && buys[x] == EMPTY_VALUE && sells[x] == EMPTY_VALUE)
      {
         // send sell alert
         msg = message(false);
         msg += " & Round Level " + round_level;
         Alert(msg);
         SendNotification(msg);
      }
   }
}
//+------------------------------------------------------------------+
string message(bool bullish)
{
   string msg = bullish ? "BUY - " : "SELL - ";

   switch(inpIndicatorTimeframe)
   {
   case PERIOD_M1:
      msg +=  bullish ? "M1 - Engulfment at Low of " : "M1 - Engulfment at High of ";
      break;
#ifdef __MQL5__
   case PERIOD_M2:
      msg +=  bullish ? "M2 - Engulfment at Low of " : "M2 - Engulfment at High of ";
      break;
   case PERIOD_M3:
      msg +=  bullish ? "M3 - Engulfment at Low of " : "M3 - Engulfment at High of ";
      break;
   case PERIOD_M4:
      msg +=  bullish ? "M4 - Engulfment at Low of " : "M4 - Engulfment at High of ";
      break;
#endif
   case PERIOD_M5:
      msg +=  bullish ? "M5 - Engulfment at Low of " : "M5 - Engulfment at High of ";
      break;
#ifdef __MQL5__
   case PERIOD_M6:
      msg +=  bullish ? "M6 - Engulfment at Low of " : "M6 - Engulfment at High of ";
      break;
   case PERIOD_M10:
      msg +=  bullish ? "M10 - Engulfment at Low of " : "M10 - Engulfment at High of ";
      break;
   case PERIOD_M12:
      msg +=  bullish ? "M12 - Engulfment at Low of " : "M12 - Engulfment at High of ";
      break;
#endif
   case PERIOD_M15:
      msg +=  bullish ? "M15 - Engulfment at Low of " : "M15 - Engulfment at High of ";
      break;
   case PERIOD_M30:
      msg +=  bullish ? "M30 - Engulfment at Low of " : "M30 - Engulfment at High of ";
      break;
   case PERIOD_H1:
      msg +=  bullish ? "H1 - Engulfment at Low of " : "H1 - Engulfment at High of ";
      break;
#ifdef __MQL5__
   case PERIOD_H2:
      msg +=  bullish ? "H2 - Engulfment at Low of " : "H2 - Engulfment at High of ";
      break;
   case PERIOD_H3:
      msg +=  bullish ? "H3 - Engulfment at Low of " : "H3 - Engulfment at High of ";
      break;
#endif
   case PERIOD_H4:
      msg +=  bullish ? "H4 - Engulfment at Low of " : "H4 - Engulfment at High of ";
      break;
#ifdef __MQL5__
   case PERIOD_H6:
      msg +=  bullish ? "H6 - Engulfment at Low of " : "H6 - Engulfment at High of ";
      break;
   case PERIOD_H12:
      msg +=  bullish ? "H12 - Engulfment at Low of " : "H12 - Engulfment at High of ";
      break;
#endif
   case PERIOD_D1:
      msg +=  bullish ? "D1 - Engulfment at Low of " : "D1 - Engulfment at High of ";
      break;
   case PERIOD_W1:
      msg +=  bullish ? "W1 - Engulfment at Low of " : "W1 - Engulfment at High of ";
      break;
   case PERIOD_MN1:
      msg +=  bullish ? "MN1 - Engulfment at Low of " : "MN1 - Engulfment at High of ";
      break;
   }
   switch(inpEngulfmentTimeframe)
   {
   case ENUM_DAY:
      msg += "Day";
      break;
   case ENUM_PREVIOUS_DAY:
      msg += "Previous Day";
      break;
   case ENUM_WEEK:
      msg += "Week";
      break;
   case ENUM_MONTH:
      msg += "Month";
      break;
   case ENUM_YEAR:
      msg += "Year";
      break;
   }
   return msg;
}
//+------------------------------------------------------------------+
datetime stringToTime(const string time, const datetime timeCurrent = 0) // replaces MQL5's StringToTime function'
{
   MqlDateTime day; // define today as a datetime object

   if((timeCurrent == 0) || (StringToTime(time) >= iTime(_Symbol, PERIOD_D1, 0)))
   {
      TimeCurrent(day); // grab the current date's info
   }

   else if(timeCurrent != 0)
   {
      TimeToStruct(timeCurrent, day);
   }

   else
   {
      TimeToStruct(StringToTime(time), day);
   }


   const int hour = (int)StringToInteger(StringSubstr(time, 0, 2)); // set hour as an integer
   const int minute = (int)StringToInteger(StringSubstr(time, 3, 2)); // set minutes as an integer
   const int second = (int)StringToInteger(StringSubstr(time, 6, 2)); // set seconds as an integer

   day.hour = hour; // set the hour to today's hours
   day.min = minute; // set the minutes to today's minutes
   day.sec = second; // set seconds to today's seconds

   return StructToTime(day); // return user input's time as the hour, minutes, and seconds set to 0
}
//+------------------------------------------------------------------+
bool time_allowed(const bool usetimer, const string startTime, const string stopTime, datetime timeCurrent = 0)
{
   timeCurrent = timeCurrent == 0 ? TimeCurrent() : timeCurrent;
// ternary operator to return true if current time is allwoed
   return !usetimer ? true : // if user selects dont use time, return true

          (usetimer &&  // if user select use timer and
           timeCurrent >= stringToTime(startTime, timeCurrent) && // time is greater than the start time and
           timeCurrent < stringToTime(stopTime, timeCurrent)) // time is less than the stop time
          ? // if so
          true // return true
          : // otherwise
          false; // return false
}
//+------------------------------------------------------------------+
//| returns true if price ends with .500 or .000                     |
//+------------------------------------------------------------------+
bool is_round_level(double price)
{
   string to_str = DoubleToString(price, 3);
   string subt = StringSubstr(to_str, StringLen(to_str) - 3, 3);
   round_level = subt;
   return subt == "000" || subt == "500";
}
//+------------------------------------------------------------------+
