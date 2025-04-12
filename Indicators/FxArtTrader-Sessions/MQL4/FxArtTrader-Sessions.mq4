//+------------------------------------------------------------------+
//|                                         FxArtTrader-Sessions.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.06"
#property indicator_chart_window
#property strict
#property indicator_buffers 2
#property indicator_plots 2
//---- indicator settings
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW
//
#property indicator_color1 clrLime
#property indicator_color2 clrMagenta
//
#property indicator_width1 10
#property indicator_width2 10
//
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
//
#property indicator_label1 "Buy"
#property indicator_label2 "Sell"
//---- definitions
#define CANDLE_LIMIT   5000  // Max Candles to calculate (for the indicator)
#define DEBUG false          // shows ZigZag labels on chart
//---- includes
#include <FxArtTrader-Sessions.mqh> // private (currently)
#include <jb-indicator.mqh>         // from https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Indicator.mqh
//---- inputs
input int   inpDepth         = 5;                 // Depth
input int   inpDeviation     = 0;                 // Deviation
input int   inpBackstep      = 0;                 // Backstep
input color inpAsianColor    = clrLightSteelBlue; // Asian Zone Color
input color inpLondonColor   = clrLightGreen;     // London Zone Color
input color inpLondon2Color  = clrGoldenrod;      // London Lunch Zone Color
input color inpNewYorkColor  = clrLightBlue;      // New York 1 Color
input color inpNewYork2Color = clrCoral;          // New York 2 Color
//---- globals
CFxArtTradeSession *fxArt;
double buy[], sell[]; // indicator buffers
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   CIndicator indi; // from jb-indicator.mqh
//---
   if(!indi.createBuffer("Buy", DRAW_ARROW, indicator_style1, indicator_color1, indicator_width1, 0, buy, true, INDICATOR_DATA, 233))
      return INIT_FAILED;
   if(!indi.createBuffer("Sell", DRAW_ARROW, indicator_style2, indicator_color2, indicator_width2, 1, sell, true, INDICATOR_DATA, 234))
      return INIT_FAILED;
//---
   fxArt = new CFxArtTradeSession(
      _Symbol,        // Symbol
      PERIOD_CURRENT, // Timeframe
      inpDepth,       // Depth
      inpDeviation,   // Deviation
      inpBackstep,    // Backstep
      CANDLE_LIMIT,   // Candle Limit
      DEBUG,          // Allow drawing?
      inpAsianColor,  // Asian Color
      inpLondonColor, // London Color
      inpLondon2Color,// London Color 2
      inpNewYorkColor,// New York Color
      inpNewYork2Color// New York Color 2
   );
//---
#ifdef __MQL5__
   ::PlotIndexSetInteger(0, PLOT_ARROW, 233);
   ::PlotIndexSetInteger(1, PLOT_ARROW, 234);
#else
   ::SetIndexArrow(0, 233);
   ::SetIndexArrow(1, 234);
#endif
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
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArrayInitialize(buy, EMPTY_VALUE);
      ArrayInitialize(sell, EMPTY_VALUE);
      ArraySetAsSeries(buy, true);
      ArraySetAsSeries(sell, true);
   }
   else limit++;
   limit = MathMin(limit, CANDLE_LIMIT);
   fxArt.run(limit);
   const int arr_size = ArraySize(buy);
   const int art_size = ArraySize(fxArt.buy);
   for(int x = limit - 1; x >= 0; x--)
   {
      if(x >= arr_size || x >= art_size) continue;
      buy[x] = fxArt.buy[x];
      sell[x] = fxArt.sell[x];
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//| OnDeinit: delete all objects                                     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   CIndicator indi; // from jb-indicator.mqh
   indi.deletePointer(fxArt);
}
//+------------------------------------------------------------------+
/*
   How To Use In An Expert Advisor


CFxArtTradeSession *fxArt;
datetime last_check, current_time;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
fxArt = new CFxArtTradeSession(
      _Symbol,        // Symbol
      PERIOD_CURRENT, // Timeframe
      inpDepth,       // Depth
      inpDeviation,   // Deviation
      inpBackstep,    // Backstep
      50,             // Candle Limit
   );
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   delete fxArt;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   current_time = iTime(_Symbol,PERIOD_CURRENT,1);

   if(last_check != current_time)
   {

   last_check = current_time;

   fxArt.run(3);

   if(fxArt.buy[1] != EMPTY_VALUE && fxArt.buy[1] != 0)
   {
      // buy
   }
   else if(fxArt.sell[1] != EMPTY_VALUE && fxArt.sell[1] != 0)
   {
      // sell
   }

   }
}
*/
//+------------------------------------------------------------------+
