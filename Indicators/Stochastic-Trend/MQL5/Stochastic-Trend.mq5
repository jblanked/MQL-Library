//+------------------------------------------------------------------+
//|                                            Stochastic-Trrend.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property description"An alert indicator based on the Stochastic and two EMAs"
#property version   "1.01"
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
#include <stochastic-trend.mqh> // download fom https://github.com/jblanked/MQL-Library/blob/main/Indicators/Stochastic-Trend/Include/Stochastic-Trend.mqh
//---defines
#define BUY_LINE 15
#define SELL_LINE 85
#define HEADER "St-Trend-"
//---inputs
input group "Stochastic Settings"
input int                inpStoPeriodK  = 14;             // Stochastic K Period
input int                inpStoPeriodD  = 3;              // Stochastic D Period
input int                inpStoPeriodS  = 3;              // Stochastic Slowing Period
input ENUM_MA_METHOD     inpStoMA       = MODE_EMA;       // Stochastic MA Method
input ENUM_STO_PRICE     inpStoPrice    = STO_CLOSECLOSE; // Stochastic Price
//
input group "Moving Average Fast Settings"
input int                inpMAPeriod1   = 74;             // Moving Average Period (Fast)
input ENUM_MA_METHOD     inpMAMethod1   = MODE_EMA;       // Moving Average Method (Fast)
input ENUM_APPLIED_PRICE inpMAPrice1    = PRICE_CLOSE;    // Moving Average Price (Fast)
//
input group "Moving Average Slow Settings"
input int                inpMAPeriod2   = 84;             // Moving Average Period (Slow)
input ENUM_MA_METHOD     inpMAMethod2   = MODE_EMA;       // Moving Average Method (Slow)
input ENUM_APPLIED_PRICE inpMAPrice2    = PRICE_CLOSE;    // Moving Average Price (Slow)
//
input group "General Settings"
input color              inpBullish     = clrLime;        // Bullish Color
input color              inpBearish     = clrMagenta;     // Bearish Color
input int                inpMaxBars     = 500;            // Maximum Bar Count
input bool               inpPriceFilter = true;           // Use Price Filter?
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
CStochasticTrend *trend;
//
bool isInitialized = false;
double pipValue = 0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   ObjectsDeleteAll(0, HEADER);
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
   trend = NULL;
   trend = new CStochasticTrend(_Symbol, PERIOD_CURRENT, BUY_LINE, SELL_LINE, inpMAPeriod1,  inpMAPeriod2, inpStoPeriodK, inpStoPeriodD, inpStoPeriodS, inpPriceFilter);
//--- check
   if(trend == NULL)
   {
      return INIT_FAILED;
   }
//---set
   IndicatorSetString(INDICATOR_SHORTNAME, "Stochastic-Trend");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
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
   indi.deletePointer(trend);
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
      Print("indicator not initialized...");
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
   else limit++;
//---
   ArraySetAsSeries(time, true);
//---
   limit = MathMin(limit, inpMaxBars);
//---
   trend.run(limit + 3);
//---
   if(!trend.memcpy(0, bufferStochMain))
   {
      ::Print("Failed to copy stoch main buffer");
      return(rates_total);
   }
   if(!trend.memcpy(1, bufferStochSignal))
   {
      ::Print("Failed to copy stoch signal buffer");
      return(rates_total);
   }
   if(!trend.memcpy(2, bufferBuy))
   {
      ::Print("Failed to copy buy buffer");
      return(rates_total);
   }
   if(!trend.memcpy(3, bufferSell))
   {
      ::Print("Failed to copy sell buffer");
      return(rates_total);
   }
   if(!trend.memcpy(4, bufferMaFast))
   {
      ::Print("Failed to copy ma fast buffer");
      return(rates_total);
   }
   if(!trend.memcpy(5, bufferMaSlow))
   {
      ::Print("Failed to copy ma slow buffer");
      return(rates_total);
   }
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
         drawArrow(bufferBuy[i + 1], time[i + 1], ENUM_UP);
         drawArrow(bufferSell[i + 1], time[i + 1], ENUM_DOWN);
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
void drawArrow(double price, const datetime time, const ENUM_UP_DOWN up_or_down = ENUM_UP)
{
   if(isEmpty(price)) return;
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
      true
   );
}
//+------------------------------------------------------------------+
//| Draw a line                                                      |
//+------------------------------------------------------------------+
void drawLine(const datetime time1, double price1, const datetime time2, double price2, const bool fastMa = true)
{
   if(isEmpty(price1)) return;
   if(isEmpty(price2)) return;

   chart.Chart_Trend_Line(
      HEADER + "line-" + string(time1) + (fastMa ? "-fast" : "-slow"),
      time1,
      price1,
      time2,
      price2,
      3,
      fastMa ? inpBullish : inpBearish,
      0,
      true
   );
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isEmpty(double val)
{
   return val == EMPTY_VALUE || val == 0;
}
//+------------------------------------------------------------------+
