//+------------------------------------------------------------------+
//|                                                   AVWAP-BTEv.mq5 |
//|                         Copyright © BestTraderEv + JBlanked, LLC |
//|                        https://www.forexfactory.com/besttraderev |
//+------------------------------------------------------------------+
#property copyright "Copyright © BestTraderEv + JBlanked, LLC"
#property version   "1.02"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   7

// Set indicator labels
#property indicator_label1    "3STDEV_Resistance"
#property indicator_label2    "2STDEV_Resistance"
#property indicator_label3    "1STDEV_Resistance"
#property indicator_label4    "VWAP_Main"
#property indicator_label5    "1STDEV_Support"
#property indicator_label6    "2STDEV_Support"
#property indicator_label7    "3STDEV_Support"

// Set indicator types
#property indicator_type1    DRAW_LINE
#property indicator_type2    DRAW_LINE
#property indicator_type3    DRAW_LINE
#property indicator_type4    DRAW_LINE
#property indicator_type5    DRAW_LINE
#property indicator_type6    DRAW_LINE
#property indicator_type7    DRAW_LINE

// Set indicator colors
#property indicator_color1    clrRed
#property indicator_color2    clrRed
#property indicator_color3    clrRed
#property indicator_color4    clrDarkGray
#property indicator_color5    clrLimeGreen
#property indicator_color6    clrLimeGreen
#property indicator_color7    clrLimeGreen

// Set indicator styles
#property indicator_style1    STYLE_DASH
#property indicator_style2    STYLE_DASH
#property indicator_style3    STYLE_DASH
#property indicator_style4    STYLE_SOLID
#property indicator_style5    STYLE_DASH
#property indicator_style6    STYLE_DASH
#property indicator_style7    STYLE_DASH

// Set indicator widths
#property indicator_width1    1
#property indicator_width2    1
#property indicator_width3    1
#property indicator_width4    2
#property indicator_width5    1
#property indicator_width6    1
#property indicator_width7    1

// Define enum variables
enum enTimeframes
{
   Period_MN1 = PERIOD_MN1,
   Period_W1  = PERIOD_W1,
   Period_D1  = PERIOD_D1,
   Period_H6  = PERIOD_H6,
   Period_H4  = PERIOD_H4
};

// Define input variables
input enTimeframes VWAP_Plot_Period = Period_D1; // Select VWAP Plot Period
input int inpMaxPeriods = 30;                    // Periods To Calculate
input double One_Std_Dev = 1;                    // Define One Standard Deviation
input double Two_Std_Dev = 2;                    // Define Two Standard Deviations
input double Three_Std_Dev = 3;                  // Define Three Standard Deviations

// Define indicator buffers
double STDEV3_Resistance_Buffer[];
double STDEV2_Resistance_Buffer[];
double STDEV1_Resistance_Buffer[];
double VWAP_Main_Buffer[];
double STDEV1_Support_Buffer[];
double STDEV2_Support_Buffer[];
double STDEV3_Support_Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Map indicator buffers
   SetIndexBuffer(0, STDEV3_Resistance_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, STDEV2_Resistance_Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, STDEV1_Resistance_Buffer, INDICATOR_DATA);
   SetIndexBuffer(3, VWAP_Main_Buffer, INDICATOR_DATA);
   SetIndexBuffer(4, STDEV1_Support_Buffer, INDICATOR_DATA);
   SetIndexBuffer(5, STDEV2_Support_Buffer, INDICATOR_DATA);
   SetIndexBuffer(6, STDEV3_Support_Buffer, INDICATOR_DATA);

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
      // Resize and initialize buffers
      ArrayResize(STDEV3_Resistance_Buffer, rates_total);
      ArrayResize(STDEV2_Resistance_Buffer, rates_total);
      ArrayResize(STDEV1_Resistance_Buffer, rates_total);
      ArrayResize(VWAP_Main_Buffer, rates_total);
      ArrayResize(STDEV1_Support_Buffer, rates_total);
      ArrayResize(STDEV2_Support_Buffer, rates_total);
      ArrayResize(STDEV3_Support_Buffer, rates_total);

      ArrayInitialize(STDEV3_Resistance_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV2_Resistance_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV1_Resistance_Buffer, EMPTY_VALUE);
      ArrayInitialize(VWAP_Main_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV1_Support_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV2_Support_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV3_Support_Buffer, EMPTY_VALUE);

      // Set buffers as series
      ArraySetAsSeries(STDEV3_Resistance_Buffer, true);
      ArraySetAsSeries(STDEV2_Resistance_Buffer, true);
      ArraySetAsSeries(STDEV1_Resistance_Buffer, true);
      ArraySetAsSeries(VWAP_Main_Buffer, true);
      ArraySetAsSeries(STDEV1_Support_Buffer, true);
      ArraySetAsSeries(STDEV2_Support_Buffer, true);
      ArraySetAsSeries(STDEV3_Support_Buffer, true);
   }
   else limit++;

   limit = MathMin(limit, inpMaxPeriods);

   // Determine the period for VWAP calculations
   ENUM_TIMEFRAMES vwapPeriod = (ENUM_TIMEFRAMES)VWAP_Plot_Period;
   int periodSeconds = PeriodSeconds(vwapPeriod);

   // Process each period (e.g., day, week) only for the new/updated bars
   for (int i = 0; i < limit; i++)
   {
      // Get the start and end times of the current period
      datetime periodStart = iTime(_Symbol, vwapPeriod, i);
      datetime periodEnd = periodStart + periodSeconds;

      // Find corresponding bar shifts on the current chart timeframe
      int shiftStart = iBarShift(_Symbol, _Period, periodStart, false);
      int shiftEnd   = iBarShift(_Symbol, _Period, periodEnd, false);

      if (shiftStart < 0 || shiftEnd < 0)
         continue;

      // For the current period, calculate up to the current bar
      if (i == 0)
         shiftEnd = 0;

      // Initialize cumulative sums for the rolling calculation
      double cumVolume = 0.0;
      double cumPV     = 0.0;
      double cumPV2    = 0.0;

      // Loop backwards through bars in the period and update cumulative sums
      for (int j = shiftStart; j >= shiftEnd; j--)
      {
         // Calculate the typical price
         double price = ( iHigh(_Symbol, PERIOD_CURRENT, j) +
                          iLow(_Symbol, PERIOD_CURRENT, j) +
                          iClose(_Symbol, PERIOD_CURRENT, j) ) / 3.0;
         long vol = iVolume(_Symbol, PERIOD_CURRENT, j);

         // Update cumulative values
         cumVolume += (double)vol;
         cumPV     += price * vol;
         cumPV2    += price * price * vol;

         double vwap  = 0.0;
         double stdDev = 0.0;
         if(cumVolume > 0)
         {
            vwap = cumPV / cumVolume;
            double variance = (cumPV2 - (vwap * vwap * cumVolume)) / cumVolume;
            stdDev = (variance > 0) ? MathSqrt(variance) : 0.0;
         }

         // Update indicator buffers
         VWAP_Main_Buffer[j] = vwap;
         STDEV1_Resistance_Buffer[j] = vwap + (One_Std_Dev * stdDev);
         STDEV2_Resistance_Buffer[j] = vwap + (Two_Std_Dev * stdDev);
         STDEV3_Resistance_Buffer[j] = vwap + (Three_Std_Dev * stdDev);
         STDEV1_Support_Buffer[j]    = vwap - (One_Std_Dev * stdDev);
         STDEV2_Support_Buffer[j]    = vwap - (Two_Std_Dev * stdDev);
         STDEV3_Support_Buffer[j]    = vwap - (Three_Std_Dev * stdDev);
      }

      // For non-current periods, break the line by setting the first bar to EMPTY_VALUE
      if (i > 0 && shiftEnd >= 0 && shiftEnd < rates_total)
      {
         VWAP_Main_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV1_Resistance_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV2_Resistance_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV3_Resistance_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV1_Support_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV2_Support_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV3_Support_Buffer[shiftEnd] = EMPTY_VALUE;
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
