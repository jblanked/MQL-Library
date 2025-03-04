//+------------------------------------------------------------------+
//|                                         Fib-Daily-Time-Input.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
#define CHART_ID 0

//--- inputs
input string inpStartTime = "01:00";  // Start Time (HH:MM)
input string inpEndTime   = "23:00";  // End Time (HH:MM)
input double inpFibLevel1 = 0.000000; // Fib Level 1
input double inpFibLevel2 = 0.236068; // Fib Level 2
input double inpFibLevel3 = 0.381966; // Fib Level 3
input double inpFibLevel4 = 0.500000; // Fib Level 4
input double inpFibLevel5 = 0.618034; // Fib Level 5
input double inpFibLevel6 = 1.000000; // Fib Level 6
input double inpFibLevel7 = 1.618034; // Fib Level 7
input double inpFibLevel8 = 2.618034; // Fib Level 8
input double inpFibLevel9 = 4.236068; // Fib Level 9
input color  inpFibColor  = clrYellow;// Fib Color
input int    inpFibWidth  = 1;        // Fib Width

//--- global variables for parsed start and end times
int startHour, startMinute;
int endHour, endMinute;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- parse start time input ("HH:MM")
   string parts[];
   if(StringSplit(inpStartTime, ':', parts) < 2)
   {
      Print("Invalid start time input");
      return(INIT_FAILED);
   }
   startHour   = (int)StringToInteger(parts[0]);
   startMinute = (int)StringToInteger(parts[1]);

   //--- parse end time input ("HH:MM")
   if(StringSplit(inpEndTime, ':', parts) < 2)
   {
      Print("Invalid end time input");
      return(INIT_FAILED);
   }
   endHour   = (int)StringToInteger(parts[0]);
   endMinute = (int)StringToInteger(parts[1]);

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
   if(prev_calculated > 0) limit++;

   int processed_day = -1;
   for(int i = limit - 1; i >= 0; i--)
   {
      //--- Get the date/time structure for the current bar
      MqlDateTime dt;
      TimeToStruct(time[i], dt);

      //--- Check if we already processed this day
      if(dt.day == processed_day)
         continue;
      processed_day = dt.day;

      //--- Build the datetime for the start time on this day
      MqlDateTime dtStart = dt;
      dtStart.hour = startHour;
      dtStart.min  = startMinute;
      dtStart.sec  = 0;
      datetime dayStart = StructToTime(dtStart);

      //--- Build the datetime for the end time on this day
      MqlDateTime dtEnd = dt;
      dtEnd.hour = endHour;
      dtEnd.min  = endMinute;
      dtEnd.sec  = 0;
      datetime dayEnd = StructToTime(dtEnd);

      //--- Use iBarShift to find the corresponding bar indices for the start and end times
      int start_index = iBarShift(_Symbol, PERIOD_CURRENT, dayStart, false);
      int end_index   = iBarShift(_Symbol, PERIOD_CURRENT, dayEnd, false);

      //--- If both bar indices are valid, draw the Fibonacci object for this day
      if(start_index >= 0 && end_index >= 0)
         draw_fib(start_index, end_index);
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Draw Fibonacci retracement between two bar indices               |
//+------------------------------------------------------------------+
void draw_fib(const int start_x, const int end_x)
{
   //--- Create a unique object name using the bar time for the starting bar
   string obj_name = "Fib-Daily-Time-Input-" + TimeToString(iTime(_Symbol, PERIOD_CURRENT, start_x), TIME_DATE | TIME_MINUTES);
   if(ObjectFind(CHART_ID, obj_name) < 0)
   {
      //--- Get prices and times for the start and end bars
      double price_1 = iOpen(_Symbol, PERIOD_CURRENT, start_x);
      double price_2 = iClose(_Symbol, PERIOD_CURRENT, end_x);
      datetime time_1 = iTime(_Symbol, PERIOD_CURRENT, start_x);
      datetime time_2 = iTime(_Symbol, PERIOD_CURRENT, end_x);

      //--- Create the Fibonacci retracement object
      ObjectCreate(CHART_ID, obj_name, OBJ_FIBO, 0, time_1, price_1, time_2, price_2);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_BACK, true);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_FILL, true);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELCOLOR, inpFibColor);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELWIDTH, inpFibWidth);
      ObjectSetInteger(CHART_ID, obj_name, OBJPROP_LEVELS, 9);

      //--- Loop through and assign each Fibonacci level
      for(int level = 0; level < 9; level++)
      {
         double f_val = inp_to_val(level + 1);
         ObjectSetDouble(CHART_ID, obj_name, OBJPROP_LEVELVALUE, level, f_val);
         ObjectSetString(CHART_ID, obj_name, OBJPROP_LEVELTEXT, level, DoubleToString(100.0 * f_val, 1) + "  %$");
      }
   }
}

//+------------------------------------------------------------------+
//| Convert input level number to corresponding Fibonacci value      |
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
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Delete all objects created by this indicator
   ObjectsDeleteAll(CHART_ID, "Fib-Daily-Time-Input-");
}
//+------------------------------------------------------------------+
