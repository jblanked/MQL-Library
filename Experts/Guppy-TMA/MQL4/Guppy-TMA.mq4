//+------------------------------------------------------------------+
//|                                                    Guppy-TMA.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property description "Guppy and TMA-CG-2024 strategy from Darwati: https://www.forexfactory.com/thread/post/14989143#post14989143"
#property strict
//--- includes
#include <jb-trade.mqh>       // private CTrade class
#include <guppy.mqh>          // private Guppy classes
#include <tma-cg-2024.mqh>    // download from https://github.com/jblanked/TMA-CG-2024/blob/main/TMA-CG-2024.mqh
//--- objects
CGuppy *guppy;                // from guppy.mqh
CMladenTMACG *tma;            // from tma-cg-2024.mqh
CJBTrade jb;                  // from jb-trade.mqh
//--- enums
enum ENUM_TRAILING_CHOICE
{
   TRAILING_PERCENTS = 0,     // Trailing Percents
   TRAILING_CANDLE = 1,       // Trailing Candle
   TRAILING_ALL = 2,          // All
   TRAILING_NONE = -1         // No Trailing
};
//---
enum ENUM_GRID_STRATEGY
{
   ENUM_GRID_NONE = -1,       // None
   ENUM_GRID_REGULAR = 0,     // Grid
   ENUM_GRID_CANDLE = 1,      // Grid Candle
   ENUM_GRID_CANDLE_TREND = 2 // Grid Candle Trend
};
//--- indicator settings
#ifdef __MQL5__
input group                "Indicator Settings"
#else
input string               indicatorSettings    = "===Indicator Settings===";//------------------------------>
#endif
//----
input int                  inpPeriod            = 25;                      // Guppy Period
input int                  inpHalfLength        = 7;                       // TMA Half Length
input ENUM_APPLIED_PRICE   inpAppliedPrice      = PRICE_WEIGHTED;          // TMA Applied Price
input double               inpBandsDeviation    = 1.618;                   // TMA Bands Deviation
//--- trade settings
#ifdef __MQL5__
input group                "Trade Settings"
#else
input string               tradeSettings        = "===Trade Settings===";  //------------------------------>
#endif
//----
input double               inpRiskPerTrade      = 200.0;                   // Risk Per Trade (%)
input double               inpTakeProfitPips    = 1000.0;                  // Take Profit (Pips)
input double               inpStopLossPips      = 1000.0;                  // Stop Loss (Pips)
input long                 inpMagicNumber       = 328216;                  // Magic Number
input string               inpComment           = "Guppy-TMA";             // Order Comment
//--- trailing settings
#ifdef __MQL5__
input group                "Trailing Settings"
#else
input string               trailingSettings     = "===Trailing Settings===";  //------------------------------>
#endif
//----
input ENUM_TRAILING_CHOICE inpTrailChoice       = TRAILING_ALL;            // Trailing Strategy
input ENUM_TIMEFRAMES      inpAutoTrailTF       = PERIOD_CURRENT;          // Auto Trailing Timeframe
input double               trailStart           = 3.0;                     // Trailing Start
input double               trailStep            = 0.50;                    // Trailing Step
input double               trailStop            = 2.00;                    // Trailing Stop
//--- grid settings
#ifdef __MQL5__
input group                "Grid Settings"
#else
input string               gridSettings         = "===Grid Settings===";  //------------------------------>
#endif
//----
input ENUM_GRID_STRATEGY   inpGridStrategy      = ENUM_GRID_REGULAR;       // Grid Strategy
input double               inpGridActivate      = 34.0;                    // Grid Start (Pips)
input double               inpGridStep          = 32.0;                    // Grid Step (Pips)
input int                  inpMaxGridTrades     = 1000000000;              // Max Grid Trades
input double               inpGridMultiplier    = 1.1;                     // Order multiplier
//--- hedge settings
#ifdef __MQL5__
input group                "Hedge Settings"
#else
input string               hedgeSettings        = "===Hedge Settings===";  //----------------->
#endif
input bool                 inpUseHedge          = true;                    // Use Hedge?
input double               inpHedgeStart        = 85.0;                    // Start Hedge (Pips)
input double               inpHedgeMulti        = 2.0;                     // Hedge Multiplier
input double               inpHedgeTakeProfit   = 1000.0;                  // Hedge Take Profit (Pips)
input double               inpHedgeStoploss     = 1000.0;                  // Hedge Stop Loss (Pips)
//----
int lastTrade;
double originalBalance;
datetime lastRuntime;
double lastStopLoss;
bool isAProAcc;
double pipVal;
datetime currentTime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//--- check half length input
   if(inpHalfLength < 1)
   {
      Print("Half Length cannot be less than 1");
      return INIT_FAILED;
   }
//--- set guppy
   guppy = new CGuppy(_Symbol, PERIOD_CURRENT, inpPeriod);
//--- set tma
   tma = new CMladenTMACG(_Symbol, PERIOD_CURRENT, inpHalfLength, inpAppliedPrice, inpBandsDeviation, 5000);
//---
   isAProAcc = jb.IsPRO(_Symbol);
   pipVal = jb.GetPipValue(_Symbol, isAProAcc);
   calc();
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   jb.deletePointer(tma);
   jb.deletePointer(guppy);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   trade();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calc()
{
   const int limit = MathMin(Bars(_Symbol, PERIOD_CURRENT), 5000);
   guppy.run(limit - 3);
   tma.run(limit);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleGrid()   // grid
{
   switch(inpGridStrategy)
   {
   case ENUM_GRID_REGULAR:
      jb.grid(_Symbol, inpMagicNumber, inpComment, inpMaxGridTrades, inpGridMultiplier, inpGridActivate, inpGridStep, lastStopLoss, 0, isAProAcc);
      break;

   case ENUM_GRID_CANDLE:
      jb.gridCandles(_Symbol, inpMagicNumber, inpComment, PERIOD_CURRENT, inpMaxGridTrades, inpGridMultiplier, isAProAcc);
      break;

   case ENUM_GRID_CANDLE_TREND:
      jb.gridTrendCandles(_Symbol, inpMagicNumber, inpComment, PERIOD_CURRENT, inpMaxGridTrades, inpGridMultiplier, isAProAcc);
      break;
   default:
      break;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleTrail()   // trailing
{
   switch(inpTrailChoice)
   {
   case TRAILING_PERCENTS:
      jb.TrailingStopPercent(_Symbol, inpComment, trailStart, trailStop, trailStep, 0, originalBalance);
      break;

   case TRAILING_CANDLE:
      jb.TrailingCandle(inpMagicNumber, inpComment, _Symbol, inpAutoTrailTF);
      break;

   case TRAILING_ALL:
      jb.TrailingStopPercent(_Symbol, inpComment, trailStart, trailStop, trailStep, 0, originalBalance);
      jb.TrailingCandle(inpMagicNumber, inpComment, _Symbol, inpAutoTrailTF);
      break;
   default:
      break;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleHedge()
{
//--- hedge
   if(inpUseHedge)
   {
      if(jb.Hedge(_Symbol, inpMagicNumber, inpComment, inpHedgeStart, inpHedgeMulti, inpHedgeTakeProfit, inpHedgeStoploss, 1, 13, 0, Hedge_Pips))
      {
         //--- do something
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool sendTrade(ENUM_ORDER_TYPE orderType)
{
   if(jb.Trade(
            _Symbol,
            orderType,
            jb.GetRisk(ENUM_RISK_PER_TRADE, inpRiskPerTrade, inpStopLossPips, inpRiskPerTrade, _Symbol, isAProAcc),
            0,
            inpStopLossPips,
            inpTakeProfitPips,
            inpComment,
            inpMagicNumber,
            0,
            0,
            isAProAcc
         ))
   {
      originalBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      switch(orderType)
      {
      case ORDER_TYPE_BUY:
         lastTrade = 1;
         lastStopLoss = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (inpStopLossPips * pipVal);
         break;
      case ORDER_TYPE_SELL:
         lastTrade = -1;
         lastStopLoss = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (inpStopLossPips * pipVal);
         break;
      };
   }
   return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void strategy()
{
   const double ask_price = iOpen(_Symbol, PERIOD_CURRENT, 1);
   if(ask_price < tma.dnBuffer[1] && guppy.upSignal[1] != EMPTY_VALUE && guppy.upSignal[1] < tma.dnBuffer[1])
      sendTrade(ORDER_TYPE_BUY);
   else if(ask_price > tma.upBuffer[1] && guppy.dnSignal[1] != EMPTY_VALUE && guppy.dnSignal[1] > tma.upBuffer[1])
      sendTrade(ORDER_TYPE_SELL);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trade()
{
   if(jb.CountOpenPositionsByComment(inpComment, _Symbol))
   {
      handleGrid();
      handleTrail();
      handleHedge();
   }
   else
   {
      currentTime = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(currentTime != lastRuntime)
      {
         // set last run time
         lastRuntime = currentTime;

         // set indicator values
         calc();

         // check trading conditions
         strategy();
      }
   }
}
//+------------------------------------------------------------------+
