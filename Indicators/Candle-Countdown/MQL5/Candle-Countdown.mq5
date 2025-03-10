//+------------------------------------------------------------------+
//|                                             Candle-Countdown.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property indicator_chart_window
#property strict
#property indicator_buffers 0
#property indicator_plots 0
#define CHART_ID 0
#define CHART_TF (ENUM_TIMEFRAMES)Period()
#define OBJECT_NAME "Candle-Countdown"
#include <countdown.mqh> // https://github.com/jblanked/MQL-Library/blob/main/Include/Countdown.mqh
#include <jb-time.mqh>   // https://github.com/jblanked/MQL-Library/blob/main/Include/JB-Time.mqh
#include <chart-draw.mqh> // https://github.com/jblanked/MQL-Library/blob/main/Include/Chart-Draw.mqh
//---- inputs
input string inpFont     = "Arial";   // Font
input int    inpFontSize = 9;         // Font Size
input color  inpColor    = clrYellow; // Color
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   while(!EventSetTimer(1)) Sleep(1);
   CChartDraw draw;
   draw.ChartText(OBJECT_NAME, "", inpFont, inpFontSize, inpColor, iTime(_Symbol, PERIOD_CURRENT, 1), iClose(_Symbol, PERIOD_CURRENT, 0), ANCHOR_LEFT);
   timer();
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
//---nothing to do here

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer(void)
{
   timer(); // re-draw every second
}
//+------------------------------------------------------------------+
ENUM_TIME_INCREMENT get_increment_time(ENUM_TIMEFRAMES timeframe)
{
   switch(timeframe)
   {
   case PERIOD_H1:
   case PERIOD_H4:
#ifdef __MQL5__
   case PERIOD_H2:
   case PERIOD_H3:
   case PERIOD_H6:
   case PERIOD_H8:
   case PERIOD_H12:
#endif
      return ENUM_HOUR;
   case PERIOD_D1:
   case PERIOD_W1:
      return ENUM_DAY;
   case PERIOD_MN1:
      return ENUM_MONTH;
   default:
      return ENUM_MINUTE;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_increment_num(ENUM_TIMEFRAMES timeframe)
{
   return
      timeframe == PERIOD_M1 ? 1 :
      timeframe == PERIOD_M2 ? 2 :
      timeframe == PERIOD_M3 ? 3 :
      timeframe == PERIOD_M4 ? 4 :
      timeframe == PERIOD_M5 ? 5 :
      timeframe == PERIOD_M6 ? 6 :
      timeframe == PERIOD_M10 ? 10 :
      timeframe == PERIOD_M12 ? 12 :
      timeframe == PERIOD_M15 ? 15 :
      timeframe == PERIOD_M20 ? 20 :
      timeframe == PERIOD_M30 ? 30 :
//
      timeframe == PERIOD_H1 ? 1 :
      timeframe == PERIOD_H2 ? 2 :
      timeframe == PERIOD_H3 ? 3 :
      timeframe == PERIOD_H4 ? 4 :
      timeframe == PERIOD_H6 ? 6 :
      timeframe == PERIOD_H8 ? 8 :
      timeframe == PERIOD_H12 ? 12 :
//
      timeframe == PERIOD_D1 ? 1 :
      timeframe == PERIOD_W1 ? 7 :
//
      timeframe == PERIOD_MN1 ? 1 :
      0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void timer(int x = 0)
{
   CCountdown ccd;
   CTime tme;
   const datetime time =
      tme.changeTime(
         iTime(_Symbol, PERIOD_CURRENT, x),
         get_increment_num(CHART_TF),
         get_increment_time(CHART_TF)
      );
   update_label(ccd.timer(time), time, x);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, OBJECT_NAME);
}
//+------------------------------------------------------------------+
void update_label(string timer_str, datetime timer_date, int x = 0)
{
   ObjectSetInteger(CHART_ID, OBJECT_NAME, OBJPROP_TIME, 0, timer_date);
   ObjectSetDouble(CHART_ID, OBJECT_NAME, OBJPROP_PRICE, 0, iClose(_Symbol, PERIOD_CURRENT, x));
   ObjectSetString(CHART_ID, OBJECT_NAME, OBJPROP_TEXT, 0, timer_str);
}
//+------------------------------------------------------------------+
