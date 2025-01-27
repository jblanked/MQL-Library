//+------------------------------------------------------------------+
//|                                               VWAP-RSI-Cross.mq5 |
//|                                          Copyright 2024,JBlanked |
//|                                          https://www.jblanked.com|
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"

#include <jb-indicator.mqh>

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 4
#property indicator_plots   4

//--- indicator buffers
double         VWAPFastBuffer[];
double         VWAPSlowBuffer[];
double         BuyBuffer[];
double         SellBuffer[];

double fast[], slow[];

input int inpRSIPeriod  = 9;     // RSI Period
input int inpFastPeriod = 9;     // VWAP Fast Period
input int inpSlowPeriod = 21;    // VWAP Slow Period
input int inpMaxCandles = 1000;  // Max Candles
CIndicator indi;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   if(!indi.createBuffer("Fast", DRAW_LINE, STYLE_SOLID, clrYellow, 1, 0, VWAPFastBuffer))
     {
      return INIT_FAILED;
     }
   if(!indi.createBuffer("Slow", DRAW_LINE, STYLE_SOLID, clrOrange, 1, 1, VWAPSlowBuffer))
     {
      return INIT_FAILED;
     }
   if(!indi.createBuffer("Buy", DRAW_ARROW, STYLE_SOLID, clrBlue, 1, 2, BuyBuffer, true, INDICATOR_DATA, 233))
     {
      return INIT_FAILED;
     }
   if(!indi.createBuffer("Sell", DRAW_ARROW, STYLE_SOLID, clrRed, 1, 3, SellBuffer, true, INDICATOR_DATA, 234))
     {
      return INIT_FAILED;
     }
//---
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 20);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -20);
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
      ArrayInitialize(VWAPFastBuffer, EMPTY_VALUE);
      ArrayInitialize(VWAPSlowBuffer, EMPTY_VALUE);

      ArrayInitialize(BuyBuffer, EMPTY_VALUE);
      ArrayInitialize(SellBuffer, EMPTY_VALUE);

      ArrayInitialize(fast, EMPTY_VALUE);
      ArrayInitialize(slow, EMPTY_VALUE);

      ArraySetAsSeries(VWAPFastBuffer, true);
      ArraySetAsSeries(VWAPSlowBuffer, true);

      ArraySetAsSeries(BuyBuffer, true);
      ArraySetAsSeries(SellBuffer, true);

      ArraySetAsSeries(fast, true);
      ArraySetAsSeries(slow, true);

      ArrayResize(fast, inpMaxCandles);
      ArrayResize(slow, inpMaxCandles);
     }
   else
      limit++;

   for(int i = limit - 1; i >= 0; i--)
     {
      if(i >= inpMaxCandles)
        {
         continue;
        }
      fast[i] = indi.iVWAP(_Symbol, PERIOD_CURRENT, inpFastPeriod, i);
      slow[i] = indi.iVWAP(_Symbol, PERIOD_CURRENT, inpSlowPeriod, i);
      VWAPFastBuffer[i] = indi.iRSIOnArray(fast, inpRSIPeriod, i);
      VWAPSlowBuffer[i] = indi.iRSIOnArray(slow, inpRSIPeriod, i);

      if(VWAPFastBuffer[i + 1] < 20 && VWAPFastBuffer[i + 1] < VWAPSlowBuffer[i + 1] && VWAPFastBuffer[i] > VWAPSlowBuffer[i])
        {
         BuyBuffer[i + 1] = VWAPFastBuffer[i + 1];
        }

      if(VWAPFastBuffer[i + 1] > 80 && VWAPFastBuffer[i + 1] > VWAPSlowBuffer[i + 1] && VWAPFastBuffer[i] < VWAPSlowBuffer[i])
        {
         SellBuffer[i + 1] = VWAPSlowBuffer[i + 1];
        }

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
