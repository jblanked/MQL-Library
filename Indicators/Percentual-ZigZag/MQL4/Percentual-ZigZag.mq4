//+------------------------------------------------------------------+
//|                                            Percentual-ZigZag.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- includes
#include <jb-indicator.mqh> // from https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Indicator.mqh
//--- indicator
#property indicator_buffers 3
#property indicator_plots 3
//
#property indicator_color1 clrLime
#property indicator_color2 clrMagenta
#property indicator_color3 clrYellow
//
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
//
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- inputs
input double          inpPercent   = 0.04;           // Percent
input ENUM_TIMEFRAMES inpTimeframe = PERIOD_CURRENT; // Timeframe
//---- globals
double bullish[];
double bearish[];
double neutral[];
double prices[];
//
int most;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   CIndicator indi;
//--- indicator buffers mapping
   if(!indi.createBuffer("Bullish", DRAW_LINE, indicator_style1, indicator_color1, indicator_width1, 0, bullish))
      return INIT_FAILED;
   if(!indi.createBuffer("Bearish", DRAW_LINE, indicator_style2, indicator_color2, indicator_width2, 1, bearish))
      return INIT_FAILED;
   if(!indi.createBuffer("Neutral", DRAW_LINE, indicator_style3, indicator_color3, indicator_width3, 2, neutral))
      return INIT_FAILED;
   //
   IndicatorSetString(INDICATOR_SHORTNAME, "Percentual-ZigZag(" + (string)inpPercent + ")");
   most = MathMin(Bars(_Symbol, PERIOD_CURRENT), MathMin(10000, Bars(_Symbol, inpTimeframe)));
   zz = new CPercentualZigZag(_Symbol, inpTimeframe, inpPercent);
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
//----
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArrayInitialize(bullish, EMPTY_VALUE);
      ArrayInitialize(bearish, EMPTY_VALUE);
      ArrayInitialize(neutral, EMPTY_VALUE);
      //
      ArraySetAsSeries(bullish, true);
      ArraySetAsSeries(bearish, true);
      ArraySetAsSeries(neutral, true);
   }
   else limit++;

   limit = MathMin(limit, most);

   zz.calculate(limit);

   const int arr_size = ArraySize(bullish);
   const int rr_size = ArraySize(zz.bullish);
   int iter = inpTimeframe == PERIOD_CURRENT ? limit : rates_total;
   int bar_shift = -1;

   for(int shift = iter - 1; shift >= 0; shift--)
   {
      bar_shift = iBarShift(_Symbol, inpTimeframe, iTime(_Symbol, PERIOD_CURRENT, shift));
      //
      if(bar_shift >= arr_size || (shift + 1) >= arr_size || bar_shift < 0 || bar_shift >= rr_size) continue;
      //
      neutral[shift] = zz.neutral[bar_shift];
      bullish[shift] = zz.bullish[bar_shift];
      bearish[shift] = zz.bearish[bar_shift];
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   CIndicator indi;
   indi.deletePointer(zz);
}
//+------------------------------------------------------------------+
class CPercentualZigZag
{
public:
   double bullish[]; // Buffer 0
   double bearish[]; // Buffer 1
   double neutral[]; // Buffer 2
   //
   CPercentualZigZag(string symbol, ENUM_TIMEFRAMES timeframe, double percentage) :
      m_symbol(symbol), m_timeframe(timeframe), m_percentage(percentage / 100), m_value(-1),
      m_pip(SymbolInfoDouble(symbol, SYMBOL_POINT) * 10)
   {
      // nothing to do
   }
   //
   void calculate(const int limit);
protected:
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   double m_pip;
private:
   double prices[];
   //
   double m_percentage;
   bool is_set;
   double m_value;
   int arr_size;
   //
   void set_as_series(const int candle_max);
   double bar_price(const int shift);
   double neutral_price(const int x);
   void set_prices(const int limit);
   double last_value(const int x);
};
//+------------------------------------------------------------------+
void CPercentualZigZag::calculate(const int limit)
{
   if(!this.is_set) this.set_as_series(limit);

   set_prices(limit);

   for(int shift = limit - 1; shift >= 0; shift--)
   {
      if((shift + 1) >= this.arr_size) continue;
      //
      if(m_value == -1) m_value = prices[shift];
      //
      if(prices[shift] > m_value + m_percentage * m_value)
      {
         bullish[shift] = iLow(this.m_symbol, this.m_timeframe, shift) - m_pip;
         bullish[shift + 1] = this.last_value(shift + 1);
         bearish[shift] = EMPTY_VALUE;
         neutral[shift] = EMPTY_VALUE;
         m_value = m_value + m_percentage * m_value;
      }
      else if(prices[shift] < m_value - m_percentage * m_value)
      {
         bearish[shift] = iHigh(this.m_symbol, this.m_timeframe, shift) + m_pip;
         bearish[shift + 1] = this.last_value(shift + 1);
         bullish[shift] = EMPTY_VALUE;
         neutral[shift] = EMPTY_VALUE;
         m_value = m_value - m_percentage * m_value;
      }
      else
      {
         neutral[shift] = this.neutral_price(shift);
         neutral[shift + 1] = this.last_value(shift + 1);
         bullish[shift] = EMPTY_VALUE;
         bearish[shift] = EMPTY_VALUE;
      }
   }
}
//+------------------------------------------------------------------+
void CPercentualZigZag::set_as_series(const int candle_max)
{
   ArrayInitialize(bullish, EMPTY_VALUE);
   ArrayInitialize(bearish, EMPTY_VALUE);
   ArrayInitialize(neutral, EMPTY_VALUE);
   ArrayInitialize(prices, EMPTY_VALUE);
   //
   ArraySetAsSeries(bullish, true);
   ArraySetAsSeries(bearish, true);
   ArraySetAsSeries(neutral, true);
   ArraySetAsSeries(prices, true);
   //
   ArrayResize(bullish, candle_max + 3);
   ArrayResize(bearish, candle_max + 3);
   ArrayResize(neutral, candle_max + 3);
   ArrayResize(prices, candle_max + 3);
   //
   this.arr_size = candle_max;
   this.is_set = true;
}
//+------------------------------------------------------------------+
double CPercentualZigZag::bar_price(const int shift)
{
   return (shift < 0 ? 0.0 :
           (iOpen(this.m_symbol, this.m_timeframe, shift) +
            iClose(this.m_symbol, this.m_timeframe, shift) +
            iLow(this.m_symbol, this.m_timeframe, shift) +
            iHigh(this.m_symbol, this.m_timeframe, shift)) / 4);
}
//+------------------------------------------------------------------+
double CPercentualZigZag::neutral_price(const int x)
{
   return ((iHigh(this.m_symbol, this.m_timeframe, x) + iLow(this.m_symbol, this.m_timeframe, x)) / 2);
}
//+------------------------------------------------------------------+
void CPercentualZigZag::set_prices(const int limit)
{
   for(int x = limit - 1; x >= 0; x--)
   {
      if(x >= this.arr_size)
         continue;
      this.prices[x] = this.bar_price(x);
   }
}
//+------------------------------------------------------------------+
double CPercentualZigZag::last_value(const int x)
{
   return
      neutral[x] != EMPTY_VALUE ? neutral[x] :
      bullish[x] != EMPTY_VALUE ? bullish[x] :
      bearish[x] != EMPTY_VALUE ? bearish[x] :
      this.neutral_price(x);
}
//+------------------------------------------------------------------+
CPercentualZigZag *zz;
//+------------------------------------------------------------------+
