//+------------------------------------------------------------------+
//|                                                  Buzzer-2025.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC    |
//|                          https://www.jblanked.com/trading-tools/   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#define PI 3.1415926535

#include <jb-indicator.mqh> // https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Indicator.mqh
CIndicator indi; // from jb-indicator.mqh

//---- input parameters
input ENUM_APPLIED_PRICE inpAppliedPrice = PRICE_CLOSE;    // Applied Price
input int                inpLength       = 20;             // Length
input ENUM_TIMEFRAMES    inpTimeframe    = PERIOD_CURRENT; // Timeframe
input bool               inpAlertON      = false;          // Alert on?
input bool               inpEmailON      = false;          // Email on?
input bool               inpPushON       = false;          // Push on?

//---- buffers
double MABuffer[];
double UpBuffer[];
double DnBuffer[];
double trend[];

//---- globals
bool UpTrendAlert = false;
bool DownTrendAlert = false;
int most;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   if(!indi.createBuffer("Buzzer", DRAW_LINE, STYLE_SOLID, clrYellow, 2, 0, MABuffer))
      return INIT_FAILED;
   if(!indi.createBuffer("Up", DRAW_LINE, STYLE_SOLID, clrLime, 2, 1, UpBuffer))
      return INIT_FAILED;
   if(!indi.createBuffer("Down", DRAW_LINE, STYLE_SOLID, clrMagenta, 2, 2, DnBuffer))
      return INIT_FAILED;
   if(!indi.createBuffer("Trend", DRAW_NONE, STYLE_SOLID, clrWhite, 2, 3, trend, false, INDICATOR_CALCULATIONS))
      return INIT_FAILED;

   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   IndicatorSetString(INDICATOR_SHORTNAME, "Buzzer(" + (string)inpLength + ")");

   const int len = inpLength * 4 + inpLength + 1;

   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, len);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, len);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, len);

   buzz = new CBuzzer(_Symbol, inpTimeframe, inpAppliedPrice, inpLength);
   most = MathMin(Bars(_Symbol, inpTimeframe), MathMin(Bars(_Symbol, PERIOD_CURRENT), 10000));
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
      ArrayInitialize(MABuffer, 0);
      ArrayInitialize(UpBuffer, 0);
      ArrayInitialize(DnBuffer, 0);
      ArrayInitialize(trend, 0);

      ArraySetAsSeries(MABuffer, true);
      ArraySetAsSeries(UpBuffer, true);
      ArraySetAsSeries(DnBuffer, true);
      ArraySetAsSeries(trend, true);
   }
   else limit++;

   int bar_shift = 0;

   buzz.calculate(most);

// weirdly enough, passing limit instead of rates_total causes MTF not to work
// when using an EA, it's best to just use the current timeframe to ensure consistency
   int max_cnt = inpTimeframe == PERIOD_CURRENT ? limit : rates_total;
   for(int shift = max_cnt - 1; shift >= 0; shift--)
   {
      bar_shift = iBarShift(_Symbol, inpTimeframe, iTime(_Symbol, PERIOD_CURRENT, shift));

      if(bar_shift < 0 || bar_shift >= ArraySize(buzz.MABuffer))
         continue;

      MABuffer[shift] = buzz.MABuffer[bar_shift];
      UpBuffer[shift]  = buzz.UpBuffer[bar_shift];
      DnBuffer[shift]  = buzz.DnBuffer[bar_shift];
      trend[shift]     = buzz.trend[bar_shift];
   }

// added by BTE (below)
   string Message;
   if ( trend[2] < 0 && trend[1] > 0 && iVolume(_Symbol, inpTimeframe, 0) > 1 && !UpTrendAlert)
   {
      Message = _Symbol + " M" + (string)inpTimeframe + ": Signal for BUY";
      if(inpAlertON) Alert("Buzzer " + Message);
      if(inpEmailON) SendMail("Buzzer", "Buzzer " + Message);
      if(inpPushON) SendNotification("Buzzer " + Message);
      UpTrendAlert = true;
      DownTrendAlert = false;
   }
   if ( trend[2] > 0 && trend[1] < 0 && iVolume(_Symbol, inpTimeframe, 0) > 1 && !DownTrendAlert)
   {
      Message = _Symbol + " M" + (string)inpTimeframe + ": Signal for SELL";
      if(inpAlertON) Alert("Buzzer " + Message);
      if(inpEmailON) SendMail("Buzzer", "Buzzer " + Message);
      if(inpPushON) SendNotification("Buzzer " + Message);
      DownTrendAlert = true;
      UpTrendAlert = false;
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   indi.deletePointer(buzz);
}
//+------------------------------------------------------------------+
//|  CBuzzer class - jblanked                                        |
//+------------------------------------------------------------------+
class CBuzzer
{
public:
   double            MABuffer[];   // Buffer 0
   double            UpBuffer[];   // Buffer 1
   double            DnBuffer[];   // Buffer 2
   double            trend[];      // Buffer 3

                     CBuzzer(string symbol, ENUM_TIMEFRAMES timeframe, ENUM_APPLIED_PRICE applied_price, int length)
      :              m_symbol(symbol), m_timeframe(timeframe), is_set(false),
                     PctFilter(1.36), ColorBarBack(1), Deviation(0),
                     Phase(4), Len(4), Cycle(4), Coeff(3 * PI), rates_total(Bars(symbol, timeframe)),
                     m_applied_price(applied_price), m_length(length)
   {
      indi.iMA(symbol, timeframe, 1, 0, MODE_LWMA, applied_price, Bars(symbol, timeframe));
      Phase = length - 1;
      Len = length * 4 + Phase;
      ArrayResize(alfa, Len);
      Weight = 0;
      for (int i = 0; i < Len; i++)
      {
         if (i <= Phase - 1)
            t = 1.0 * i / (Phase - 1);
         else
            t = 1.0 + (i - Phase + 1) * (2.0 * Cycle - 1.0) / (Cycle * length - 1.0);

         beta = MathCos(PI * t);
         g = 1.0 / (Coeff * t + 1);
         if (t <= 0.5)
            g = 1;
         alfa[i] = g * beta;
         Weight += alfa[i];
      }
   }

   void              calculate(int limit);

protected:
   string             m_symbol;
   ENUM_TIMEFRAMES    m_timeframe;
   ENUM_APPLIED_PRICE m_applied_price;
   int                m_length;
private:
   double            PctFilter;
   int               ColorBarBack;
   double            Deviation;
   double            alfa[];
   int               Phase, Len, Cycle;
   double            Coeff, beta, t, Sum, Weight, g;
   bool              is_set;
   int               rates_total;
   double            Del[];        // Buffer 4
   double            AvgDel[];     // Buffer 5
   //
   void              set_as_series(int countr);
};
//+------------------------------------------------------------------+
void CBuzzer::calculate(int limit)
{
   if(!this.is_set) set_as_series(limit);

   const int arr_size = ArraySize(MABuffer);

   int neededCount = limit + Len;

   if(neededCount > rates_total)
      neededCount = rates_total;

   double maSeries[];

   ArrayResize(maSeries, neededCount);

   for (int j = 0; j < neededCount; j++)
   {
      maSeries[j] = indi.iMA(this.m_symbol, this.m_timeframe, 1, 0, MODE_LWMA, this.m_applied_price, j);
   }

   double Filter;

   for(int shift = limit - 1; shift >= 0; shift--)
   {
      if((shift + 1) >= arr_size)
         continue;

      Sum = 0;
      for (int i = 0; i < Len; i++)
      {
         int idx = i + shift;
         if(idx >= neededCount)
            break;
         Sum += alfa[i] * maSeries[idx];
      }

      if (Weight > 0)
         MABuffer[shift] = (1.0 + Deviation / 100.0) * Sum / Weight;

      Del[shift] = MathAbs(MABuffer[shift] - MABuffer[shift + 1]);

      double sumd = 0.0, sumd2 = 0.0;
      int count = 0;
      for (int i = 0; i < this.m_length; i++)
      {
         int idx = shift + i;
         if(idx >= arr_size)
            break;
         double d = Del[idx];
         sumd  += d;
         sumd2 += d * d;
         count++;
      }
      if(count > 0)
      {
         AvgDel[shift] = sumd / count;
         double variance = (sumd2 / count) - (AvgDel[shift] * AvgDel[shift]);
         double StdDev = (variance > 0) ? MathSqrt(variance) : 0;
         Filter = PctFilter * StdDev;
      }
      else
      {
         Filter = 0;
      }

      if( MathAbs(MABuffer[shift] - MABuffer[shift + 1]) < Filter )
         MABuffer[shift] = MABuffer[shift + 1];

      // Carry forward the previous trend
      trend[shift] = trend[shift + 1];

      if (MABuffer[shift] - MABuffer[shift + 1] > Filter)
         trend[shift] = 1;
      else if (MABuffer[shift + 1] - MABuffer[shift] > Filter)
         trend[shift] = -1;

      if (trend[shift] > 0)
      {
         UpBuffer[shift] = MABuffer[shift];
         if ((shift + ColorBarBack) < arr_size && trend[shift + ColorBarBack] < 0)
            UpBuffer[shift + ColorBarBack] = MABuffer[shift + ColorBarBack];
         DnBuffer[shift] = EMPTY_VALUE;
      }
      else if (trend[shift] < 0)
      {
         DnBuffer[shift] = MABuffer[shift];
         if ((shift + ColorBarBack) < arr_size && trend[shift + ColorBarBack] > 0)
            DnBuffer[shift + ColorBarBack] = MABuffer[shift + ColorBarBack];
         UpBuffer[shift] = EMPTY_VALUE;
      }
   }
}
//+------------------------------------------------------------------+
void CBuzzer::set_as_series(int countr)
{
   ArrayInitialize(MABuffer, 0);
   ArrayInitialize(UpBuffer, 0);
   ArrayInitialize(DnBuffer, 0);
   ArrayInitialize(trend, 0);
   ArrayInitialize(Del, 0);
   ArrayInitialize(AvgDel, 0);

   ArraySetAsSeries(MABuffer, true);
   ArraySetAsSeries(UpBuffer, true);
   ArraySetAsSeries(DnBuffer, true);
   ArraySetAsSeries(trend, true);
   ArraySetAsSeries(Del, true);
   ArraySetAsSeries(AvgDel, true);

   ArrayResize(MABuffer, countr + 3);
   ArrayResize(UpBuffer, countr + 3);
   ArrayResize(DnBuffer, countr + 3);
   ArrayResize(trend, countr + 3);
   ArrayResize(Del, countr + 3);
   ArrayResize(AvgDel, countr + 3);

   this.is_set = true;
}
//+------------------------------------------------------------------+
CBuzzer *buzz;
//+------------------------------------------------------------------+
