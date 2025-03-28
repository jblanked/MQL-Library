//+------------------------------------------------------------------+
//|                                                 Divergence-2.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property strict
/*  https://www.mql5.com/en/job/233492
Hey, mt5 divergence indicator that gives buy sell arrows on histogram..
- once arrow pops the ea should take trade on the next candle open after arrow candle directly ..
- tp and sl should be in candles and we will call this exit candle ..
- for example if the option exit candle is set to one than to close the trade after one candle closes after arrow candle .
- Add lot size in 0.01 format add magic number.
*/
#include <Trade\Trade.mqh>
#define INDI_DIRECTORY "\\Indicators\\"
#define INDI_NAME "MACD Divergence MT5 - By TFLab"
#define INDI_FULL_PATH INDI_DIRECTORY INDI_NAME ".ex5"
#resource INDI_FULL_PATH
//--- enums
enum bns
{
   Buy, Sell, Both
};
//---inputs
input int    inpEntry   = 1;              // Entry Candle
input int    inpCandle  = 1;              // Close Candle
input bns    inpEnum    = Both;           // Trade Type
input double inpLotSize = 0.01;           // Lot Size
input long   inpMagic   = 51331;          // Magic Number
input string inpComment = "Divergence-2"; // Order Comment
//--- globals
datetime time_to_close;
int cm;
double empVal[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   CTrade trade;
   trade.SetExpertMagicNumber(inpMagic);
//---
   cm = iCustom(_Symbol, PERIOD_CURRENT, INDI_NAME);
   if(cm == INVALID_HANDLE) return INIT_FAILED;
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   IndicatorRelease(cm);
//---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   if(!PositionsTotal())
   {
      const int arrTrend = is_alert(inpEntry);
      if(arrTrend == 1)       send_trade(ORDER_TYPE_BUY);
      else if(arrTrend == -1) send_trade(ORDER_TYPE_SELL);
   }
   else if(time_to_close == iTime(_Symbol, PERIOD_CURRENT, 0))
   {
      close_trades();
   }
//---
}
//+------------------------------------------------------------------+
//| send_trade: returns true if the trade is placed successfully     |
//+------------------------------------------------------------------+
bool send_trade(ENUM_ORDER_TYPE order_type)
{
   if(order_type == ORDER_TYPE_BUY)
   {
      Alert("Bullish signal on " + _Symbol);
      if(inpEnum == Sell) return false;
   }
   else
   {
      Alert("Bearish signal on " + _Symbol);
      if(inpEnum == Buy) return false;
   }
   CTrade trade;
   trade.SetExpertMagicNumber(inpMagic);
   if (trade.PositionOpen(
            _Symbol,
            order_type,
            inpLotSize,
            order_type == ORDER_TYPE_BUY ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID),
            0,
            0,
            inpComment
         ))
   {
      time_to_close = iTime(_Symbol, PERIOD_CURRENT, 0) + (inpCandle * (PeriodSeconds(Period())));
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
struct MqlObject
{
   datetime          date;
   double            price;
   string            name;
   ENUM_OBJECT       type;
   string            info;
};
//+------------------------------------------------------------------+
//| get_chart_objects: returns amount of objects available and set   |
//+------------------------------------------------------------------+
int get_chart_objects(MqlObject &obj[], const int subWindow = -1, ENUM_OBJECT objType = -1, const int chartId = 0)
{
   const int obs = ObjectsTotal(chartId, subWindow, objType == -1 ? -1 : objType);
   ArrayResize(obj, obs);
   ArraySetAsSeries(obj, true);
   int x = 0;
   while(x < obs)
   {
      obj[x].name  = ObjectName(chartId, x);
      obj[x].price = ObjectGetDouble(chartId, obj[x].name, OBJPROP_PRICE);
      obj[x].date  = (datetime)ObjectGetInteger(chartId, obj[x].name, OBJPROP_TIME, 0);
      obj[x].type  = (ENUM_OBJECT)ObjectGetInteger(chartId, obj[x].name, OBJPROP_TYPE);
      obj[x].info  = ObjectGetString(chartId, obj[x].name, OBJPROP_TEXT);
      x++;
   }
   return x;
}
//+------------------------------------------------------------------+
//| is_alert: returns if the candle of the input shift has an arrow  |
//+------------------------------------------------------------------+
int is_alert(const int shift = 1)
{
   MqlObject obj[];
   const int obs = get_chart_objects(obj);
   for(int x = 0; x < obs; x++)
   {
      if(StringSubstr(obj[x].name, 0, 7) != "CB_Macd") continue;
      if(obj[x].date != iTime(_Symbol, PERIOD_CURRENT, shift)) continue;
      if(obj[x].type != OBJ_TEXT) continue;
      //
      if(obj[x].info == "Buy")  return 1;
      else if(obj[x].info == "Sell") return -1;
   }
   return 0;
}
//+------------------------------------------------------------------+
//| close_trades: closes all trades                                  |
//+------------------------------------------------------------------+
void close_trades()
{
   CTrade trade;
   CPositionInfo posi;
   for(int i = PositionsTotal(); i >= 0; i--)
   {
      if(posi.SelectByIndex(i))
      {
         if(posi.Magic() == inpMagic && posi.Comment() == inpComment && posi.Symbol() == _Symbol)
         {
            trade.PositionClose(posi.Ticket());
         }
      }
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
