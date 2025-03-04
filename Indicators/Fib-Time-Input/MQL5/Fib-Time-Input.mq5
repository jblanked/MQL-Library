//+------------------------------------------------------------------+
//|                                               Fib-Time-Input.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property  strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
#define CHART_ID 0
//---inputs
input datetime inpStartTime = D'2025.03.03 00:00'; // Start Time
input datetime inpEndTime   = D'2025.12.01 00:00'; // End Time
input double   inpFibLevel1 = 0.000000;            // Fib Level 1
input double   inpFibLevel2 = 0.236068;            // Fib Level 2
input double   inpFibLevel3 = 0.381966;            // Fib Level 3
input double   inpFibLevel4 = 0.500000;            // Fib Level 4
input double   inpFibLevel5 = 0.618034;            // Fib Level 5
input double   inpFibLevel6 = 1.000000;            // Fib Level 6
input double   inpFibLevel7 = 1.618034;            // Fib Level 7
input double   inpFibLevel8 = 2.618034;            // Fib Level 8
input double   inpFibLevel9 = 4.236068;            // Fib Level 9
input color    inpFibColor  = clrYellow;           // Fib Color
input int      inpFibWidth  = 1;                   // Fib Width
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping (nothing to do here)

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
   draw_fib();
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void draw_fib()
{
   const int start_x = iBarShift(_Symbol, PERIOD_CURRENT, inpStartTime);
   const string obj_name = "Fib-Time-Input-" + string(iTime(_Symbol, PERIOD_CURRENT, start_x));
   if(ObjectFind(CHART_ID, obj_name) <= 0)
   {
      // set end
      const int end_x = iBarShift(_Symbol, PERIOD_CURRENT, inpEndTime);

      // set price/time
      const double price_1 = iOpen(_Symbol, PERIOD_CURRENT, start_x);
      const double price_2 = iClose(_Symbol, PERIOD_CURRENT, end_x);
      const datetime time_1 = iTime(_Symbol, PERIOD_CURRENT, start_x);
      const datetime time_2 = iTime(_Symbol, PERIOD_CURRENT, end_x);

      // create object
      ObjectCreate(CHART_ID, obj_name, OBJ_FIBO, 0, time_1, price_1, time_2, price_2);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_BACK, true);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_FILL, true);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELCOLOR, inpFibColor);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELWIDTH, inpFibWidth);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELS, 9);

      // loop and set fib levels
      int x = 0;
      double f_val = 0.0;
      while(x < 9)
      {
         f_val = inp_to_val(x + 1);
         ObjectSetDouble(CHART_ID, obj_name, OBJPROP_LEVELVALUE, x, f_val);
         ObjectSetString(CHART_ID, obj_name, OBJPROP_LEVELTEXT, x, DoubleToString(100.0 * f_val, 1) + "  %$"); // MT4 replaces "%$" with the actual price at each level.
         x++;
      }
   }
};
//+------------------------------------------------------------------+
double inp_to_val(const int inp)
{
   switch(inp)
   {
   case 1:
      return inpFibLevel1;
   case 2:
      return inpFibLevel2;
   case 3:
      return inpFibLevel3;
   case 4:
      return inpFibLevel4;
   case 5:
      return inpFibLevel5;
   case 6:
      return inpFibLevel6;
   case 7:
      return inpFibLevel7;
   case 8:
      return inpFibLevel8;
   case 9:
      return inpFibLevel9;
   default:
      return 0.0;
   }
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(CHART_ID, "Fib");
}
//+------------------------------------------------------------------+
