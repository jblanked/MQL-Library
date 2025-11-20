//+------------------------------------------------------------------+
//|                                            Stochastic-Trrend.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property description"An alert indicator based on the Stochastic and two EMAs"
#property version   "1.00"
#property strict
//
#property indicator_buffers 6
#property indicator_plots 6
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_level1 15
#property indicator_level2 85
#property indicator_maximum 100
//---includes
#include <jb-indicator.mqh> // download from https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Indicator.mqh
#include <jb-array.mqh>     // download from https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Array.mqh
#include <chart-draw.mqh>   // download from https://github.com/jblanked/MQL-Library/blob/main/Include/Chart-Draw.mqh
//---defines
#define BUY_LINE 15
#define SELL_LINE 85
#define HEADER "St-Trend-"
//---enums
enum ENUM_STO_LINE
{
   ENUM_MAIN_LINE = 0,   // Main Line
   ENUM_SIGNAL_LINE = 1, // Signal Line
};
//---inputs
input group "Stochastic Settings"
input int                inpStoPeriodK = 14;             // Stochastic K Period
input int                inpStoPeriodD = 3;              // Stochastic D Period
input int                inpStoPeriodS = 3;              // Stochastic Slowing Period
input ENUM_MA_METHOD     inpStoMA      = MODE_EMA;       // Stochastic MA Method
input ENUM_STO_PRICE     inpStoPrice   = STO_CLOSECLOSE; // Stochastic Price
//
input group "Moving Average Fast Settings"
input int                inpMAPeriod1  = 74;             // Moving Average Period (Fast)
input ENUM_MA_METHOD     inpMAMethod1  = MODE_EMA;       // Moving Average Method (Fast)
input ENUM_APPLIED_PRICE inpMAPrice1   = PRICE_CLOSE;    // Moving Average Price (Fast)
//
input group "Moving Average Slow Settings"
input int                inpMAPeriod2  = 84;             // Moving Average Period (Slow)
input ENUM_MA_METHOD     inpMAMethod2  = MODE_EMA;       // Moving Average Method (Slow)
input ENUM_APPLIED_PRICE inpMAPrice2   = PRICE_CLOSE;    // Moving Average Price (Slow)
//
input group "General Settings"
input color              inpBullish    = clrLime;        // Bullish Color
input color              inpBearish    = clrMagenta;     // Bearish Color
input int                inpMaxBars    = 100;            // Maximum Bar Count
//---globals
double bufferStochMain[];
double bufferStochSignal[];
double bufferMaFast[];
double bufferMaSlow[];
double bufferBuy[];
double bufferSell[];
//
int handleStochastic;
int handleEMAFast;
int handleEMASlow;
//
CIndicator indi;
CChartDraw chart;
//
bool isInitialized = false;
double pipValue = 0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   if(!indi.createBuffer("Stochastic Main", DRAW_LINE, STYLE_SOLID, inpBullish, 3, 0, bufferStochMain, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Stochastic Signal", DRAW_LINE, STYLE_SOLID, inpBearish, 3, 1, bufferStochSignal, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Buy", DRAW_NONE, STYLE_SOLID, inpBullish, 10, 2, bufferBuy, true, INDICATOR_DATA, 233))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Sell", DRAW_NONE, STYLE_SOLID, inpBearish, 10, 3, bufferSell, true, INDICATOR_DATA, 234))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Fast MA", DRAW_NONE, STYLE_SOLID, inpBullish, 3, 4, bufferMaFast, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Slow MA", DRAW_NONE, STYLE_SOLID, inpBearish, 3, 5, bufferMaSlow, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
//--- configure
#ifdef __MQL5__
   handleStochastic = iStochastic(_Symbol, PERIOD_CURRENT, inpStoPeriodK, inpStoPeriodD, inpStoPeriodS, inpStoMA, inpStoPrice);
   handleEMAFast    = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod1, 0, inpMAMethod1, inpMAPrice1);
   handleEMASlow    = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod2, 0, inpMAMethod2, inpMAPrice2);
//--- check
   if(handleStochastic == INVALID_HANDLE)
   {
      ::Alert("Failed to acquire Stochastic indicator");
      return INIT_FAILED;
   }
   if(handleEMAFast == INVALID_HANDLE || handleEMASlow == INVALID_HANDLE)
   {
      ::Alert("Failed to acquire Moving Average indicator");
      return INIT_FAILED;
   }
#endif
//---set
   IndicatorSetString(INDICATOR_SHORTNAME, "Stochastic-Trend");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//--- set pip value
   pipValue = _Point * 10;
   if(StringFind("JPY", _Symbol) != -1)
   {
      pipValue *= 10;
   }
   else if(StringFind("NAS", _Symbol) != -1)
   {
      pipValue = 1.00;
   }
   else if(StringFind("US30", _Symbol) != -1)
   {
      pipValue = 1.00;
   }
   else if(StringFind("XAU", _Symbol) != -1)
   {
      pipValue = 0.10;
   }
//---
   isInitialized = true;
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, HEADER);
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
   if(!isInitialized)
   {
      return(rates_total);
   }
//---
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArraySetAsSeries(bufferBuy, true);
      ArraySetAsSeries(bufferSell, true);
      ArraySetAsSeries(bufferMaFast, true);
      ArraySetAsSeries(bufferMaSlow, true);
      ArraySetAsSeries(bufferStochMain, true);
      ArraySetAsSeries(bufferStochSignal, true);

      ArrayInitialize(bufferBuy, EMPTY_VALUE);
      ArrayInitialize(bufferSell, EMPTY_VALUE);
      ArrayInitialize(bufferMaFast, EMPTY_VALUE);
      ArrayInitialize(bufferMaSlow, EMPTY_VALUE);
      ArrayInitialize(bufferStochMain, EMPTY_VALUE);
      ArrayInitialize(bufferStochSignal, EMPTY_VALUE);
   }
//---
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(time, true);
//---
   limit = MathMax(limit, inpMaxBars);
//---
#ifdef __MQL5__
   if(CopyBuffer(handleEMAFast, 0, 0, limit + 3, bufferMaFast) == -1)
   {
      ::Print("Failed to fetch moving average indicator values");
      return(rates_total);
   }
   if(CopyBuffer(handleEMASlow, 0, 0, limit + 3, bufferMaSlow) == -1)
   {
      ::Print("Failed to fetch moving average indicator values");
      return(rates_total);
   }
   if(CopyBuffer(handleStochastic, ENUM_MAIN_LINE, 0, limit + 3, bufferStochMain) == -1)
   {
      ::Print("Failed to fetch stochastic main line indicator values");
      return(rates_total);
   }
   if(CopyBuffer(handleStochastic, ENUM_SIGNAL_LINE, 0, limit + 3, bufferStochSignal) == -1)
   {
      ::Print("Failed to fetch stochastic signal line indicator values");
      return(rates_total);
   }
#endif
//---
   const double arrSize = ArraySize(bufferMaFast);
//---
   int i = limit - 1;
   while(i >= 0)
   {
      if(i + 2 >= arrSize)
      {
         i--;
      }
      else
      {
#ifdef __MQL4__
         bufferStochMain[i]       = iStochastic(_Symbol, PERIOD_CURRENT, inpStoPeriodK, inpStoPeriodD, inpStoPeriodS, inpStoMA, inpStoPrice, ENUM_MAIN_LINE, i);
         bufferStochSignal[i]     = iStochastic(_Symbol, PERIOD_CURRENT, inpStoPeriodK, inpStoPeriodD, inpStoPeriodS, inpStoMA, inpStoPrice, ENUM_SIGNAL_LINE, i);
         bufferStochMain[i + 1]   = iStochastic(_Symbol, PERIOD_CURRENT, inpStoPeriodK, inpStoPeriodD, inpStoPeriodS, inpStoMA, inpStoPrice, ENUM_MAIN_LINE, i + 1);
         bufferStochSignal[i + 1] = iStochastic(_Symbol, PERIOD_CURRENT, inpStoPeriodK, inpStoPeriodD, inpStoPeriodS, inpStoMA, inpStoPrice, ENUM_SIGNAL_LINE, i + 1);
         bufferMaFast[i]          = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod1, 0, inpMAMethod1, inpMAPrice1, i);
         bufferMaFast[i + 1]      = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod1, 0, inpMAMethod1, inpMAPrice1, i + 1);
         bufferMaSlow[i]          = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod2, 0, inpMAMethod2, inpMAPrice2, i);
         bufferMaSlow[i + 1]      = iMA(_Symbol, PERIOD_CURRENT, inpMAPeriod2, 0, inpMAMethod2, inpMAPrice2, i + 1);
#endif
         switch(tradingSignal(i + 1))
         {
         case 1:
            bufferBuy[i + 1] = low[i + 1];
            drawArrow(bufferBuy[i + 1], time[i + 1], ENUM_UP);
            break;
         case -1:
            bufferSell[i + 1] = high[i + 1];
            drawArrow(bufferSell[i + 1], time[i + 1], ENUM_DOWN);
            break;
         };
         drawLine(time[i], bufferMaFast[i], time[i + 1], bufferMaFast[i + 1], true);
         drawLine(time[i], bufferMaSlow[i], time[i + 1], bufferMaSlow[i + 1], false);
         i--;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Draw an arrow                                                    |
//+------------------------------------------------------------------+
void drawArrow(const double price, const datetime time, const ENUM_UP_DOWN up_or_down = ENUM_UP)
{
   static const double adjustment = 3 * pipValue;
   chart.Chart_Arrow(
      HEADER + "arrow-" + string(time),
      up_or_down,
      up_or_down == ENUM_UP ? price - adjustment : price + adjustment,
      time,
      up_or_down == ENUM_UP ? inpBullish : inpBearish,
      1,
      0,
      233,
      234,
      false
   );
}
//+------------------------------------------------------------------+
//| Draw a line                                                      |
//+------------------------------------------------------------------+
void drawLine(const datetime time1, const double price1, const datetime time2, const double price2, const bool fastMa = true)
{
   chart.Chart_Trend_Line(
      HEADER + "line-" + string(time1) + (fastMa ? "-fast" : "-slow"),
      time1,
      price1,
      time2,
      price2,
      3,
      fastMa ? inpBullish : inpBearish,
      0,
      false
   );
}
//+------------------------------------------------------------------+
//| Check if there's a trading signal                                |
//+------------------------------------------------------------------+
int tradingSignal(const int shift)
{
   if(ArraySize(bufferStochMain) < shift + 2) return 0;
   if(ArraySize(bufferStochSignal) < shift + 2) return 0;
   if(ArraySize(bufferMaFast) < shift + 1) return 0;
   if(ArraySize(bufferMaSlow) < shift + 1) return 0;
   return
      bufferMaFast[shift] > bufferMaSlow[shift] &&
      bufferStochSignal[shift] < BUY_LINE && bufferStochSignal[shift + 1] < BUY_LINE &&
      bufferStochMain[shift] < BUY_LINE && bufferStochMain[shift + 1] < BUY_LINE &&
      bufferStochSignal[shift + 1] < bufferStochMain[shift + 1] && bufferStochSignal[shift] > bufferStochMain[shift]
      ?
      1
      :
      bufferMaFast[shift] < bufferMaSlow[shift] &&
      bufferStochSignal[shift] > SELL_LINE && bufferStochSignal[shift + 1] > SELL_LINE &&
      bufferStochMain[shift] > SELL_LINE && bufferStochMain[shift + 1] > SELL_LINE &&
      bufferStochSignal[shift + 1] > bufferStochMain[shift + 1] && bufferStochSignal[shift] < bufferStochMain[shift]
      ?
      -1
      :
      0;
}
//+------------------------------------------------------------------+
