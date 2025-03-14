//+------------------------------------------------------------------+
//|                                             EMA-Candle-Setup.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
//
#property indicator_label1 "Buy"
#property indicator_color1 clrLime
#property indicator_width1 5
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_ARROW
//
#property indicator_label2 "Sell"
#property indicator_color2 clrMagenta
#property indicator_width2 5
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_ARROW
//
#property indicator_label3 "MA"
#property indicator_color3 clrYellow
#property indicator_width3 2
#property indicator_style3 STYLE_SOLID
#property indicator_type3 DRAW_LINE
//
#include <jb-indicator.mqh> // https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Indicator.mqh
// from request https://www.forexfactory.com/thread/post/15178362#post15178362
/*
Time frame: 5 minutes
Indicators: 8 ema
Buy setup:
Market should be uptrend and moving above 8 ema. Wait for first bearish candle. Next candle must be bullish and first break the low of bearish candle and close bullish. We will buy at high of bullish candle. Or we set buy stop.
Sell setup:
Market should be downtrend and moving abelow 8 ema. Wait for first bullish candle. Next candle should be bearish but first break high of bullish candle. We we open trade at low of at low of bearicandle. Screenshot attached.
Need Indicator with alert notification for mt5 please
*/
//--- inputs
input int                inpPeriod = 8;          // Period
input ENUM_MA_METHOD     inpMethod = MODE_EMA;   // Method
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;// Applied Price
//--- globals
CIndicator indi; // from jb-indicator.mqh
double buy[], sell[], ma_val[];
int most;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   if(!indi.createBuffer(indicator_label1, indicator_type1, indicator_style1, indicator_color1, indicator_width1, 0, buy, true, INDICATOR_DATA, 233))
      return INIT_FAILED;
   if(!indi.createBuffer(indicator_label2, indicator_type2, indicator_style2, indicator_color2, indicator_width2, 1, sell, true, INDICATOR_DATA, 234))
      return INIT_FAILED;
   if(!indi.createBuffer(indicator_label3, indicator_type3, indicator_style3, indicator_color3, indicator_width3, 2, ma_val))
      return INIT_FAILED;
//---
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 20);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -20);
//---
   most = MathMin(Bars(_Symbol, PERIOD_CURRENT), 5000);
   indi.iMA(_Symbol, PERIOD_CURRENT, inpPeriod, 0, inpMethod, inpPrice, most);
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
      ArrayInitialize(ma_val, EMPTY_VALUE);
      //
      ArraySetAsSeries(buy, true);
      ArraySetAsSeries(sell, true);
      ArraySetAsSeries(ma_val, true);
   }
   else limit++;
   limit = MathMin(limit, most);
//--- set as series every call (important for last iteration(s))
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
//---
   const int arrr_size = ArraySize(buy);
   int x = limit - 1;
   while(x >= 0)
   {
      if((x + 2) < arrr_size)
      {
         ma_val[x] = indi.iMA(_Symbol, PERIOD_CURRENT, inpPeriod, 0, inpMethod, inpPrice, x);
         if(close[x + 2] > ma_val[x + 2] && close[x + 1] > ma_val[x + 1] &&
               close[x + 2] < open[x + 2] && close[x + 1] > open[x + 1]) // both above EMA, bearish then bullish
         {
            // if low of bullish candle broke the low of bearish candle
            if(low[x + 1] < low[x + 2])
            {
               buy[x] = low[x];
            }
         }
         else if(close[x + 2] < ma_val[x + 2] && close[x + 1] < ma_val[x + 1] &&
                 close[x + 2] > open[x + 2] && close[x + 1] < open[x + 1]) // both below EMA, bullish then bearish
         {
            // if high of bearish candle broke the high of bullish candle
            if(high[x + 1] > high[x + 2])
            {
               sell[x] = high[x];
            }
         }
      }
      x--;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
