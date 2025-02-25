//+------------------------------------------------------------------+
//|                                                     Twin-HMA.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property indicator_chart_window
#property strict
#property indicator_buffers 6
#property indicator_plots 6
#include <twin-hma.mqh>
#include <jb-indicator.mqh>
CTwinHMA *thma;
//---- input parameters
input int                  inpHMAPeriodFast = 12;          // HMA Period Fast
input int                  inpHMAPeriodSlow = 100;         // HMA Period Slow
//---- buffers
double UptrendFast[]; // Buffer 0
double DntrendFast[]; // Buffer 1
double UptrendSlow[]; // Buffer 2
double DntrendSlow[]; // Buffer 3
double BuyArrow[];    // BUffer 4
double SellArrow[];   // Buffer 5
//
int maxi_candles;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   CIndicator indi;

//--- indicator buffers mapping
   if(!indi.createBuffer("Fast-Up", DRAW_LINE, STYLE_SOLID, clrLime, 2, 0, UptrendFast, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Fast-Dn", DRAW_LINE, STYLE_SOLID, clrMagenta, 2, 1, DntrendFast, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Slow-Up", DRAW_LINE, STYLE_SOLID, clrLime, 3, 2, UptrendSlow, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Slow-Dn", DRAW_LINE, STYLE_SOLID, clrMagenta, 3, 3, DntrendSlow, true, INDICATOR_DATA))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Buy", DRAW_ARROW, STYLE_SOLID, clrLime, 5, 4, BuyArrow, true, INDICATOR_DATA, 233))
   {
      return INIT_FAILED;
   }
   if(!indi.createBuffer("Sell", DRAW_ARROW, STYLE_SOLID, clrMagenta, 5, 5, SellArrow, true, INDICATOR_DATA, 234))
   {
      return INIT_FAILED;
   }
//
   thma = new CTwinHMA(_Symbol, PERIOD_CURRENT, inpHMAPeriodFast, inpHMAPeriodSlow);
//
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "Twin Hull Moving Average(" + IntegerToString(inpHMAPeriodFast) + ", " + IntegerToString(inpHMAPeriodSlow) + ")");
//--- arrow shifts when drawing
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 20);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -20);
//---
   maxi_candles = MathMin(1000, Bars(_Symbol, PERIOD_CURRENT));
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

// Set buffers as series
   if(prev_calculated < 1)
   {
      ArrayInitialize(UptrendFast, EMPTY_VALUE);
      ArrayInitialize(DntrendFast, EMPTY_VALUE);
      ArrayInitialize(UptrendSlow, EMPTY_VALUE);
      ArrayInitialize(DntrendSlow, EMPTY_VALUE);
      ArrayInitialize(BuyArrow, EMPTY_VALUE);
      ArrayInitialize(SellArrow, EMPTY_VALUE);
      //
      ArraySetAsSeries(UptrendFast, true);
      ArraySetAsSeries(DntrendFast, true);
      ArraySetAsSeries(UptrendSlow, true);
      ArraySetAsSeries(DntrendSlow, true);
      ArraySetAsSeries(BuyArrow, true);
      ArraySetAsSeries(SellArrow, true);
   }
   else limit++;

   limit = MathMax(limit, maxi_candles);
   thma.run(limit);

   int x = limit - 1;
   int arr_size = ArraySize(thma.UptrendFast);
   
   while(x >= 0)
   {
      if(x >= arr_size)
      {
         x--;
         continue;
      }

      // set lines
      UptrendFast[x] = thma.UptrendFast[x];
      DntrendFast[x] = thma.DntrendFast[x];

      UptrendSlow[x] = thma.UptrendSlow[x];
      DntrendSlow[x] = thma.DntrendSlow[x];

      // set arrows
      BuyArrow[x]  = thma.BuyArrow[x];
      SellArrow[x] = thma.SellArrow[x];

      x--; // next iter
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   CIndicator indi;
   indi.deletePointer(thma);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
