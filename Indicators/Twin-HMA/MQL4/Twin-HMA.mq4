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
#include <hull-ma.mqh>
#include <jb-indicator.mqh>
CHullMA *hmaFast, *hmaSlow;
//---- input parameters
input int                  inpHMAPeriodFast = 12;          // HMA Period Fast
input ENUM_MA_METHOD       inpHMAMethodFast = MODE_EMA;    // HMA Method Fast
input ENUM_APPLIED_PRICE   inpHMAPriceFast  = PRICE_CLOSE; // HMA Applied Price Fast
//
input int                  inpHMAPeriodSlow = 100;         // HMA Period Slow
input ENUM_MA_METHOD       inpHMAMethodSlow = MODE_EMA;    // HMA Method Slow
input ENUM_APPLIED_PRICE   inpHMAPriceSlow  = PRICE_CLOSE; // HMA Applied Price Slow
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
   hmaFast = new CHullMA(_Symbol, PERIOD_CURRENT, inpHMAPeriodFast, inpHMAMethodFast, inpHMAPriceFast);
   hmaSlow = new CHullMA(_Symbol, PERIOD_CURRENT, inpHMAPeriodSlow, inpHMAMethodSlow, inpHMAPriceSlow);
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
   hmaFast.run(MathMin(limit, maxi_candles));
   hmaSlow.run(MathMin(limit, maxi_candles));

   int x = limit - 1;
   int arr_size = ArraySize(hmaFast.Uptrend);
   while(x >= 0)
   {
      if(x >= arr_size)
      {
         x--;
         continue;
      }

      // set lines
      UptrendFast[x] = hmaFast.Uptrend[x];
      DntrendFast[x] = hmaFast.Dntrend[x];
      //
      UptrendSlow[x] = hmaSlow.Uptrend[x];
      DntrendSlow[x] = hmaSlow.Dntrend[x];

      // set arrows
      if(hmaFast.BuyArrow[x] != EMPTY_VALUE &&
            hmaFast.Uptrend[x] != EMPTY_VALUE &&
            hmaSlow.Uptrend[x] != EMPTY_VALUE &&
            hmaSlow.Dntrend[x] == EMPTY_VALUE &&
            hmaFast.Dntrend[x] == EMPTY_VALUE)
      {
         BuyArrow[x] = hmaFast.BuyArrow[x];
         SellArrow[x] = EMPTY_VALUE;
      }
      else if(hmaFast.SellArrow[x] != EMPTY_VALUE &&
              hmaFast.Dntrend[x] != EMPTY_VALUE &&
              hmaSlow.Dntrend[x] != EMPTY_VALUE &&
              hmaSlow.Uptrend[x] == EMPTY_VALUE &&
              hmaFast.Uptrend[x] == EMPTY_VALUE)
      {
         SellArrow[x] = hmaFast.SellArrow[x];
         BuyArrow[x] = EMPTY_VALUE;
      }
      else
      {
         BuyArrow[x] = EMPTY_VALUE;
         SellArrow[x] = EMPTY_VALUE;
      }

      x--; // next iter
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   CIndicator indi;
   indi.deletePointer(hmaFast);
   indi.deletePointer(hmaSlow);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
