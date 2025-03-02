//+------------------------------------------------------------------+
//|                                                     MA-Cross.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#include <jb-indicator.mqh>
//---inputs
input int                  inpMAPeriodFast = 7;             // Period (Fast)
input ENUM_MA_METHOD       inpMAMethodFast = MODE_EMA;      // Method (Fast)
input ENUM_APPLIED_PRICE   inpMAPriceFast  = PRICE_CLOSE;   // Price (Fast)
input int                  inpMAPeriodSlow = 25;            // Period (Slow)
input ENUM_MA_METHOD       inpMAMethodSlow = MODE_EMA;      // Method (Slow)
input ENUM_APPLIED_PRICE   inpMAPriceSlow  = PRICE_CLOSE;   // Price (Slow)
//
double maFast[], maSlow[];
double buy[], sell[];
CIndicator indi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   if(!indi.createBuffer("Fast", DRAW_LINE, STYLE_SOLID, clrLime, 2, 0, maFast, true))
      return INIT_FAILED;
   if(!indi.createBuffer("Slow", DRAW_LINE, STYLE_SOLID, clrMagenta, 2, 1, maSlow, true))
      return INIT_FAILED;
   if(!indi.createBuffer("Buy", DRAW_ARROW, STYLE_SOLID, clrBlue, 2, 2, buy, true, INDICATOR_DATA, 233))
      return INIT_FAILED;
   if(!indi.createBuffer("Sell", DRAW_ARROW, STYLE_SOLID, clrRed, 2, 3, sell, true, INDICATOR_DATA, 234))
      return INIT_FAILED;
   // initialize
   indi.iMA(_Symbol, PERIOD_CURRENT, inpMAPeriodFast, 0, inpMAMethodFast, inpMAPriceFast, 1);
   indi.iMA(_Symbol, PERIOD_CURRENT, inpMAPeriodSlow, 0, inpMAMethodSlow, inpMAPriceSlow, 1);
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
      ArrayInitialize(buy, EMPTY_VALUE);
      ArrayInitialize(sell, EMPTY_VALUE);
      ArrayInitialize(maFast, EMPTY_VALUE);
      ArrayInitialize(maSlow, EMPTY_VALUE);

      ArraySetAsSeries(buy, true);
      ArraySetAsSeries(sell, true);
      ArraySetAsSeries(maFast, true);
      ArraySetAsSeries(maSlow, true);
   }
   else limit++;

   int max_b = MathMin(limit, Bars(_Symbol, PERIOD_CURRENT));
   int arr_size = ArraySize(maFast);
   int x = max_b - 1;
   while(x >= 0)
   {
      if((x + 2) < arr_size)
      {
         maFast[x] = indi.iMA(_Symbol, PERIOD_CURRENT, inpMAPeriodFast, 0, inpMAMethodFast, inpMAPriceFast, x);
         maSlow[x] = indi.iMA(_Symbol, PERIOD_CURRENT, inpMAPeriodSlow, 0, inpMAMethodSlow, inpMAPriceSlow, x);

         // arrows
         if(maFast[x + 2] < maSlow[x + 2] && maFast[x + 1] > maSlow[x + 1])
            buy[x + 1] = iLow(_Symbol, PERIOD_CURRENT, x + 1);
         else if(maFast[x + 2] > maSlow[x + 2] && maFast[x + 1] < maSlow[x + 1])
            sell[x + 1] = iHigh(_Symbol, PERIOD_CURRENT, x + 1);
      }
      x--;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
