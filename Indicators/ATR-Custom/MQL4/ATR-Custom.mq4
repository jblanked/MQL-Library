//+------------------------------------------------------------------+
//|                                                   ATR-Custom.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property strict
//--- indicator properties
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_color1 clrYellow
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
//--- includes
#include <jb-indicator.mqh> // https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Indicator.mqh
//--- objects
CIndicator indi; // from jb-indicator.mqh
//--- inputs
input int             inpATRPeriod = 10;             // ATR Period
input ENUM_TIMEFRAMES inpTimeframe = PERIOD_CURRENT; // Timeframe
input int             inpCandleCnt = 1;              // Candle Count
//--- globals
double atr[], pips[], points[], _atr[];
int most, incre;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   if(!indi.createBuffer("ATR", DRAW_LINE, indicator_style1, indicator_color1, indicator_width1, 0, atr))
      return INIT_FAILED;
   if(!indi.createBuffer("Pips", DRAW_NONE, indicator_style1, indicator_color1, indicator_width1, 1, pips))
      return INIT_FAILED;
   if(!indi.createBuffer("Points", DRAW_NONE, indicator_style1, indicator_color1, indicator_width1, 2, points))
      return INIT_FAILED;
   if(!indi.createBuffer("_ATR", DRAW_NONE, indicator_style1, indicator_color1, indicator_width1, 3, _atr, false, INDICATOR_CALCULATIONS))
      return INIT_FAILED;
   //
   incre = inpCandleCnt < 1 ? 1 : inpCandleCnt; // not less than 1
   incre = MathMin(incre, Bars(_Symbol, PERIOD_CURRENT)); // not more than current bars
   most = MathMin(Bars(_Symbol, inpTimeframe), MathMin(Bars(_Symbol, PERIOD_CURRENT), 10000 + incre)); // 10k candle limit
   indi.iATR(_Symbol, inpTimeframe, inpATRPeriod, most);
//---
   return INIT_SUCCEEDED;
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
   const int arr_size = ArraySize(atr);
//---
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArrayInitialize(atr, EMPTY_VALUE);
      ArraySetAsSeries(atr, true);

      ArrayInitialize(_atr, EMPTY_VALUE);
      ArraySetAsSeries(_atr, true);

      ArrayInitialize(pips, EMPTY_VALUE);
      ArraySetAsSeries(pips, true);

      ArrayInitialize(points, EMPTY_VALUE);
      ArraySetAsSeries(points, true);
   }
   else limit++;
   limit = MathMin(limit, most);
//---
   int bar_shift = 0;
   int lim = inpTimeframe == PERIOD_CURRENT ? limit : rates_total;
   set_atr(lim, arr_size); // pre-compute
   for(int x = lim - 1; x >= 0; x--)
   {
      if((x + inpCandleCnt) >= arr_size) continue;
      bar_shift = iBarShift(_Symbol, inpTimeframe, iTime(_Symbol, PERIOD_CURRENT, x));
      if((bar_shift + inpCandleCnt) >= arr_size || bar_shift < 0) continue;
      atr[x] = atr_val(bar_shift);
      points[x] = atr[x] / _Point;
      pips[x] = points[x] / 10;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
double atr_val(const int x)
{
   double val = 0.0;
   for(int i = x; i < (x + inpCandleCnt); i++)
      val += _atr[i];
   return val / incre; // average ATR
}
//+------------------------------------------------------------------+
void set_atr(int limit, int array_size)
{
   for(int i = limit - 1; i >= 0; i--)
   {
      if(i >= array_size) continue;
      _atr[i] = indi.iATR(_Symbol, inpTimeframe, inpATRPeriod, i);
   }
}
//+------------------------------------------------------------------+
