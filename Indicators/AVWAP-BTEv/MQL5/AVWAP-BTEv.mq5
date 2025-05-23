//+------------------------------------------------------------------+
//|                                                   AVWAP-BTEv.mq5 |
//|                         Copyright © BestTraderEv + JBlanked, LLC |
//|                        https://www.forexfactory.com/besttraderev |
//+------------------------------------------------------------------+
#property copyright "Copyright © BestTraderEv + JBlanked, LLC"
#property version   "1.03"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   7

/* For expert advisor use:

   1. Copy and paste the CAnchoredVWAP class
   2. Make a global pointer of the class (e.g. -  CAnchoredVWAP *avwap)
   3. Initialize the pointer in the OnInit (e.g - avwap = new CAnchoredVWAP(_Symbol, PERIOD_CURRENT, etc...)
   4. Call the run method once per candle in the OnTick
   5. Access the values needed per your trading strategy using the arrays (e.g. - avwap.STDEV1_Resistance_Buffer[1])

   Those steps are similar to the indicator implementation of the class below.
*/

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

   avwap = new CAnchoredVWAP(_Symbol, PERIOD_CURRENT, inpMaxPeriods, (ENUM_TIMEFRAMES)VWAP_Plot_Period, One_Std_Dev, Two_Std_Dev, Three_Std_Dev);

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
      ArrayInitialize(STDEV3_Resistance_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV2_Resistance_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV1_Resistance_Buffer, EMPTY_VALUE);
      ArrayInitialize(VWAP_Main_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV1_Support_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV2_Support_Buffer, EMPTY_VALUE);
      ArrayInitialize(STDEV3_Support_Buffer, EMPTY_VALUE);

      ArraySetAsSeries(STDEV3_Resistance_Buffer, true);
      ArraySetAsSeries(STDEV2_Resistance_Buffer, true);
      ArraySetAsSeries(STDEV1_Resistance_Buffer, true);
      ArraySetAsSeries(VWAP_Main_Buffer, true);
      ArraySetAsSeries(STDEV1_Support_Buffer, true);
      ArraySetAsSeries(STDEV2_Support_Buffer, true);
      ArraySetAsSeries(STDEV3_Support_Buffer, true);
   }
   else limit++;

   avwap.run(inpMaxPeriods);

   const int arr_size = ArraySize(avwap.VWAP_Main_Buffer);

   for (int i = limit - 1; i >= 0; i--)
   {
      if(i >= arr_size) continue;
      VWAP_Main_Buffer[i] = avwap.VWAP_Main_Buffer[i];
      STDEV1_Resistance_Buffer[i] = avwap.STDEV1_Resistance_Buffer[i];
      STDEV2_Resistance_Buffer[i] = avwap.STDEV2_Resistance_Buffer[i];
      STDEV3_Resistance_Buffer[i] = avwap.STDEV3_Resistance_Buffer[i];
      STDEV1_Support_Buffer[i]    = avwap.STDEV1_Support_Buffer[i];
      STDEV2_Support_Buffer[i]    = avwap.STDEV2_Support_Buffer[i];
      STDEV3_Support_Buffer[i]    = avwap.STDEV3_Support_Buffer[i];
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(avwap != NULL)
   {
      delete avwap;
      avwap = NULL;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAnchoredVWAP
{
public:
   double STDEV3_Resistance_Buffer[]; // Buffer 0
   double STDEV2_Resistance_Buffer[]; // Buffer 1
   double STDEV1_Resistance_Buffer[]; // Buffer 2
   double VWAP_Main_Buffer[];         // Buffer 3
   double STDEV1_Support_Buffer[];    // Buffer 4
   double STDEV2_Support_Buffer[];    // BUffer 5
   double STDEV3_Support_Buffer[];    // Buffer 6
//
   CAnchoredVWAP(
      string symbol,
      ENUM_TIMEFRAMES timeframe,
      int period_count = 1,
      ENUM_TIMEFRAMES vwap_timeframe = PERIOD_D1,
      double deviation_1 = 1,
      double deviation_2 = 2,
      double deviation_3 = 3
   ):
      m_symbol(symbol), m_timeframe(timeframe), m_period_count(period_count),
      m_deviation_1(deviation_1), m_deviation_2(deviation_2), m_deviation_3(deviation_3),
      is_set(false), m_vwap_timeframe(vwap_timeframe), maxi(Bars(symbol, timeframe))
   {
      // nothing to do here
   };
   ~CAnchoredVWAP()
   {

   }
   void run(int limit);
protected:
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   int m_period_count;
   ENUM_TIMEFRAMES m_vwap_timeframe;
   double m_deviation_1;
   double m_deviation_2;
   double m_deviation_3;
private:
   bool is_set;
   void set();
   int maxi;
};
//+------------------------------------------------------------------+
void CAnchoredVWAP::run(int limit)
{
   if(!this.is_set) this.set();

   const int periodSeconds = PeriodSeconds(this.m_vwap_timeframe);

   // Process each period (e.g., day, week) only for the new/updated bars
   for (int i = 0; i < limit; i++)
   {
      // Get the start and end times of the current period
      datetime periodStart = iTime(this.m_symbol, this.m_vwap_timeframe, i);
      datetime periodEnd = periodStart + periodSeconds;

      // Find corresponding bar shifts on the current chart timeframe
      int shiftStart = iBarShift(this.m_symbol, this.m_timeframe, periodStart, false);
      int shiftEnd   = iBarShift(this.m_symbol, this.m_timeframe, periodEnd, false);

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
         if(j >= this.maxi) continue;

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
         STDEV1_Resistance_Buffer[j] = vwap + (this.m_deviation_1 * stdDev);
         STDEV2_Resistance_Buffer[j] = vwap + (this.m_deviation_2 * stdDev);
         STDEV3_Resistance_Buffer[j] = vwap + (this.m_deviation_3 * stdDev);
         STDEV1_Support_Buffer[j]    = vwap - (this.m_deviation_1 * stdDev);
         STDEV2_Support_Buffer[j]    = vwap - (this.m_deviation_2 * stdDev);
         STDEV3_Support_Buffer[j]    = vwap - (this.m_deviation_3 * stdDev);
      }

      // For non-current periods, break the line by setting the first bar to EMPTY_VALUE
      if (i > 0 && shiftEnd >= 0 && shiftEnd < this.maxi)
      {
         VWAP_Main_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV1_Resistance_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV2_Resistance_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV3_Resistance_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV1_Support_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV2_Support_Buffer[shiftEnd] = EMPTY_VALUE;
         STDEV3_Support_Buffer[shiftEnd] = EMPTY_VALUE;
      }

      if (shiftStart + 1 > 0 && shiftStart + 1 < this.maxi)
      {
         VWAP_Main_Buffer[shiftStart + 1] = EMPTY_VALUE;
         STDEV1_Resistance_Buffer[shiftStart + 1] = EMPTY_VALUE;
         STDEV2_Resistance_Buffer[shiftStart + 1] = EMPTY_VALUE;
         STDEV3_Resistance_Buffer[shiftStart + 1] = EMPTY_VALUE;
         STDEV1_Support_Buffer[shiftStart + 1] = EMPTY_VALUE;
         STDEV2_Support_Buffer[shiftStart + 1] = EMPTY_VALUE;
         STDEV3_Support_Buffer[shiftStart + 1] = EMPTY_VALUE;
      }

   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAnchoredVWAP::set()
{
   ArrayResize(STDEV3_Resistance_Buffer, this.maxi);
   ArrayResize(STDEV2_Resistance_Buffer, this.maxi);
   ArrayResize(STDEV1_Resistance_Buffer, this.maxi);
   ArrayResize(VWAP_Main_Buffer, this.maxi);
   ArrayResize(STDEV1_Support_Buffer, this.maxi);
   ArrayResize(STDEV2_Support_Buffer, this.maxi);
   ArrayResize(STDEV3_Support_Buffer, this.maxi);

   ArrayInitialize(STDEV3_Resistance_Buffer, EMPTY_VALUE);
   ArrayInitialize(STDEV2_Resistance_Buffer, EMPTY_VALUE);
   ArrayInitialize(STDEV1_Resistance_Buffer, EMPTY_VALUE);
   ArrayInitialize(VWAP_Main_Buffer, EMPTY_VALUE);
   ArrayInitialize(STDEV1_Support_Buffer, EMPTY_VALUE);
   ArrayInitialize(STDEV2_Support_Buffer, EMPTY_VALUE);
   ArrayInitialize(STDEV3_Support_Buffer, EMPTY_VALUE);

   ArraySetAsSeries(STDEV3_Resistance_Buffer, true);
   ArraySetAsSeries(STDEV2_Resistance_Buffer, true);
   ArraySetAsSeries(STDEV1_Resistance_Buffer, true);
   ArraySetAsSeries(VWAP_Main_Buffer, true);
   ArraySetAsSeries(STDEV1_Support_Buffer, true);
   ArraySetAsSeries(STDEV2_Support_Buffer, true);
   ArraySetAsSeries(STDEV3_Support_Buffer, true);

   this.is_set = true;
}
//+------------------------------------------------------------------+
CAnchoredVWAP *avwap;
//+------------------------------------------------------------------+
