//+------------------------------------------------------------------+
//|                                                 ZigZag-HH-LL.mq5 |
//|                                     Copyright 2023-2025,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023-2025,JBlanked"
#property link      "https://www.jblanked.com/"
#property version   "1.06"
#property indicator_chart_window
#property strict
//---- includes
#include <jb-zigzag.mqh>
//---- indicator properties
#property indicator_buffers 5
#property indicator_plots 5
//--label
#property indicator_label1 "ZigZag"
#property indicator_label2 "HH"
#property indicator_label3 "LH"
#property indicator_label4 "HL"
#property indicator_label5 "LL"
//--type
#property indicator_type1 DRAW_SECTION
#property indicator_type2 DRAW_NONE
#property indicator_type3 DRAW_NONE
#property indicator_type4 DRAW_NONE
#property indicator_type5 DRAW_NONE
//--other
#property indicator_color1 clrOrange
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
//---- definitions
#define CANDLE_MAX 500 // maximum bars to calculate for
#define RECOUNT 50     // re-calculate the last x bars
//---- inputs
input int      ExtDepth           = 5 ; // Depth
input int      ExtDeviation       = 0 ; // Deviation
input int      ExtBackstep        = 0 ; // Backstep
input color    TopColorHH         = clrYellow; // HH Color
input color    TopColorLH         = clrLime; // LH Color
input color    BotColorHL         = clrRed ; // HL Color
input color    BotColorLL         = clrYellow; // LL Color
input int      Labeldistance      = 2; // Label Distance
input int      TxtSize1           = 7; // Text Size 1
input int      TxtSize2           = 6; // Text Size 2
input string   Fonts              = "Arial Black"; // Font
input bool     show_zz            = true; // Show ZZ?
input bool     show_label         = true; // Show Labels?
//---- globals
double ZigZagBuffer[];
double HighMapBuffer[];
double LowMapBuffer[];
double HH[], LH[], HL[], LL[];
double previousHigh;
double previousLow;
CZigZag *zz; // from jb-zigzag.mqh
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//----
   SetIndexBuffer(0, ZigZagBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HH, INDICATOR_DATA); // higher high
   SetIndexBuffer(2, LH, INDICATOR_DATA); // lower high
   SetIndexBuffer(3, HL, INDICATOR_DATA); // higher low
   SetIndexBuffer(4, LL, INDICATOR_DATA); // lower low
//----
   IndicatorSetString(INDICATOR_SHORTNAME, "ZigZag(" + string(ExtDepth) + "," + string(ExtDeviation) + "," + string(ExtBackstep) + ")");

   if(!show_zz)
   {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   }

   ObjectsDeleteAll(0, "statusLabel"); // delete all objects

   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
//----
   zz = new CZigZag(_Symbol, PERIOD_CURRENT, show_zz || show_label, ExtDepth, ExtDeviation, ExtBackstep, CANDLE_MAX, RECOUNT);
//----
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "statusLabel");
   delete zz;
}
//+------------------------------------------------------------------+
//|                                                                  |
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
   int counted_bars = prev_calculated;
   int limit = 0;

//--- Determine the starting bar for recalculation.
   if(counted_bars == 0)
   {
      limit = MathMin(Bars(_Symbol, PERIOD_CURRENT) - ExtDepth, CANDLE_MAX);

      ArrayInitialize(ZigZagBuffer, EMPTY_VALUE);
      ArrayInitialize(HH, EMPTY_VALUE);
      ArrayInitialize(LH, EMPTY_VALUE);
      ArrayInitialize(HL, EMPTY_VALUE);
      ArrayInitialize(LL, EMPTY_VALUE);

      ArraySetAsSeries(ZigZagBuffer, true);
      ArraySetAsSeries(HH, true);
      ArraySetAsSeries(LH, true);
      ArraySetAsSeries(HL, true);
      ArraySetAsSeries(LL, true);
   }
   else
   {
      // step back by ExtDepth bars.
      limit = rates_total - prev_calculated - ExtDepth;
      if(limit < 0) limit = 0;
   }
//---
   if(show_zz || show_label)
   {
      ObjectsDeleteAll(0, "statusLabel"); // delete all objects each call (not needed if not showing chart objects)
      if(prev_calculated > 0) limit += CANDLE_MAX; // redraw all candles again
   }
   else
   {
      if(prev_calculated > 0) limit += RECOUNT; // redraw all candles again (only the recount amount)
   }

//--- refresh values
   for (int i = (rates_total - prev_calculated - 1); i >= 0; i--)
   {
      ZigZagBuffer[i] = EMPTY_VALUE;
      HH[i]           = EMPTY_VALUE;
      LH[i]           = EMPTY_VALUE;
      HL[i]           = EMPTY_VALUE;
      LL[i]           = EMPTY_VALUE;
   }

   zz.run(limit);

   for(int i = limit - 1; i >= 0; i--)
   {
      ZigZagBuffer[i] = zz.ZigZagBuffer[i];
      HH[i]           = zz.HH[i];
      LH[i]           = zz.LH[i];
      HL[i]           = zz.HL[i];
      LL[i]           = zz.LL[i];
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
