//+------------------------------------------------------------------+
//|                                                Symbol-Levels.mq4 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                                         https://www.jblanked.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property strict
// indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

// includes
#include <jb-indicator.mqh> // https://github.com/jblanked/MQL-Library

// enums
enum ENUM_PRICE_LEVELS
{
   ENUM_OPEN, // Open
   ENUM_CLOSE,// Close
   ENUM_LOW,  // Low
   ENUM_HIGH  // High
};

// input settings
input ENUM_TIMEFRAMES   inpTimeframe   = PERIOD_CURRENT; // Timeframe
input ENUM_PRICE_LEVELS inpPriceLevel  = ENUM_OPEN;      // Level
input int               inpCandle      = 0;              // Candle (0 = Current)

// global variables
double prices[];     // array to hold prices
datetime last_check; // track time for alerts
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
// create CIndicator instance
   CIndicator indi;

// create buffer
   if(!indi.createBuffer("Price", DRAW_LINE, STYLE_SOLID, clrRed, 2, 0, prices))
      return INIT_FAILED;

//--- return success
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
// check if price hits the selected timeframe level
   price_alert();

// set limit and array
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArraySetAsSeries(prices, true);
      //ArrayInitialize(prices, EMPTY_VALUE);
   }
   else
      limit++;

// draw select level
   draw_level(limit);

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------+
//|timeframe_to_str: converts ENUM_TIMEFRAMES to string and returns it|
//+-------------------------------------------------------------------+
string timeframe_to_str(const ENUM_TIMEFRAMES timeframe)
{
   return
      timeframe == PERIOD_M1  ? "1-Minute" :
      timeframe == PERIOD_M5  ? "5-Minute" :
      timeframe == PERIOD_M15 ? "15-Minute" :
      timeframe == PERIOD_M30 ? "30-Minute" :
      timeframe == PERIOD_H1  ? "1-Hour" :
      timeframe == PERIOD_H4  ? "4-Hour" :
      timeframe == PERIOD_D1  ? "Daily" :
      timeframe == PERIOD_W1  ? "Weekly" :
      timeframe == PERIOD_MN1 ? "Monthly" :
      ""
      ;
}
//+-------------------------------------------------------------------+
//|is_at_level: returns if price is at the specified level            |
//+-------------------------------------------------------------------+
bool is_at_level(const string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_PRICE_LEVELS price_level, const int candle)
{
   const double symbol_ask_price = SymbolInfoDouble(symbol, SYMBOL_ASK);

   return
      price_level == ENUM_OPEN && symbol_ask_price == iOpen(symbol, timeframe, candle) ? true :
      price_level == ENUM_CLOSE && symbol_ask_price == iClose(symbol, timeframe, candle) ? true :
      price_level == ENUM_HIGH && symbol_ask_price == iHigh(symbol, timeframe, candle) ? true :
      price_level == ENUM_LOW && symbol_ask_price == iLow(symbol, timeframe, candle) ? true :
      false;
}
//+-------------------------------------------------------------------+
//|price_alert: sends an alert when price reaches the timeframe open  |
//+-------------------------------------------------------------------+
void price_alert()
{
// one minute wait per alert
   if(last_check != iTime(_Symbol, PERIOD_M1, 1))
   {
      // check if price hits the timeframe level
      if(is_at_level(_Symbol, inpTimeframe, inpPriceLevel, inpCandle))
      {
         // send alert
         Alert("Price is at the " + timeframe_to_str(inpTimeframe) + " open");

         // set the last check to one minute ago
         last_check = iTime(_Symbol, PERIOD_M1, 1);
      }
   }
};
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|draw_level: fills the prices array                                |
//+------------------------------------------------------------------+
void draw_level(const int limit)
{
   int bar_shift = 0;
   for(int i = limit - 1; i >= 0; i--)
   {
      bar_shift = iBarShift(_Symbol,inpTimeframe,iTime(_Symbol,PERIOD_CURRENT,i));
      prices[i] =
         inpPriceLevel == ENUM_OPEN  ? iOpen(_Symbol, inpTimeframe, bar_shift) :
         inpPriceLevel == ENUM_CLOSE ? iClose(_Symbol, inpTimeframe, bar_shift) :
         inpPriceLevel == ENUM_HIGH  ? iHigh(_Symbol, inpTimeframe, bar_shift) :
         inpPriceLevel == ENUM_LOW   ? iLow(_Symbol, inpTimeframe, bar_shift) :
         EMPTY_VALUE;
   }
}
//+------------------------------------------------------------------+
