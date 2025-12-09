//+------------------------------------------------------------------+
//|                                              Indicator-Stats.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.00"
#property description "Quickly test the profitability of any custom indicator."
#property description "Select your buy and sell buffer in the inputs and let the indicatr do the rest"
#property strict
//
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 2
//---includes
#include <jb-indicator.mqh>
//---defines
#define MAX_CANDLES 5000
#define BUY 1
#define SELL -1
//---enums
enum ENUM_TRADE_STRATEGY
{
   TRADE_STRATEGY_BUFFERS     = 0, // Buffers
   TRADE_STRATEGY_PRICE_CROSS = 1, // Price Crosses Line
};
enum ENUM_CHART_STRATEGY
{
   CHART_STRATEGY_TOTAL  = 0, // Total (All)
   CHART_STRATEGY_SINGLE = 1, // Per Trade (Single)
   CHART_STRATEGY_DAILY  = 2, // Daily
   CHART_STRATEGY_WEEKLY = 3, // Weekly
   CHART_STRATEGY_MONTHLY = 4, // Monthly
};
enum ENUM_ENTRY_STRATEGY
{
   ENTRY_NOT_EMPTY_VALUE = 0,          // Not Empty Value
   ENTRY_NOT_0 = 1,                    // Not 0
   ENTRY_NEITHER_EMPTY_VALUE_OR_0 = 2, // Neither Empty Value or 0
};
enum ENUM_CLOSE_STRATEGY
{
   CLOSE_ON_OPPOSITE, // Opposite Trades
   CLOSE_ON_TP,       // Take Profit
};
enum ENUM_TREND
{
   TREND_BEARISH = -1, // Bearish
   TREND_NEUTRAL = 0,  // Neutral
   TREND_BULLISH = 2   // Bullish
};
enum ENUM_INDICATOR_TYPE
{
   INDICATOR_ICUSTOM = 0, // Custom
   INDICATOR_IMA     = 1, // Moving Average
};
//---inputs
input group               "Indicator Settings"
input ENUM_INDICATOR_TYPE inpIndicatorType   = INDICATOR_ICUSTOM; // Type
input string              inpIndicatorParams = "";                // Parameters (separated by commas)
input string              inpIndicatorName   = "IndicatorName";   // Custom Name
input int                 inpBuyEntryBuffer  = 0;                 // Buy Entry Buffer
input int                 inpSellEntryBuffer = 1;                 // Sell Entry Buffer

input group               "Entry Settings"
input int                 inpEntryCandle     = 1;                              // Entry Candle
input ENUM_ENTRY_STRATEGY inpEntryStrategy   = ENTRY_NEITHER_EMPTY_VALUE_OR_0; // Entry Rules

input group               "Close Settings"
input int                 inpCloseCandle     = 1;                     // Close Candle
input ENUM_CLOSE_STRATEGY inpCloseStrategy   = CLOSE_ON_OPPOSITE;     // Close Strategy
input double              inpCloseTakeProfit = 10.00;                 // Close Take Profit Pips

input group               "Chart Settings"
input ENUM_CHART_STRATEGY inpChartStrategy   = CHART_STRATEGY_TOTAL;  // Chart Display Strategy
input color               inpProfitColor     = clrLime;               // Profit Color
input color               inpDrawdownColor   = clrMagenta;            // Drawdown Color

input group               "General Settings"
input ENUM_TRADE_STRATEGY inpTradeStrategy   = TRADE_STRATEGY_BUFFERS; // Trade Strategy
input bool                DEBUG              = true;                   // Debug?

//---structs
struct STradeInfo
{
public:
   double entry_price;   // entry price
   double drawdown_pips; // drawdown (pips)
   double profit_pips;   // profit (pips)
   double close_price;   // close price
   datetime time_open;   // entry time
   datetime time_close;  // close time
   bool in_progress;     // open status
   int trend_of_trade;   // order type (1 for buy, -1 for sell)
   long ticket;          // order ticket
   //
   void reset()
   {
      this.entry_price    = EMPTY_VALUE;
      this.drawdown_pips  = 0.0;
      this.profit_pips    = 0.0;
      this.close_price    = EMPTY_VALUE;
      this.time_open      = 0;
      this.time_close     = 0;
      this.in_progress    = false;
      this.trend_of_trade = 0;
      this.ticket         = 0;
   }
};
//---classes
class CMentalTrader: protected CJBArray
{
public:
   CMentalTrader() {}
   ~CMentalTrader() {}
   bool addTrade(STradeInfo&trade)
   {
      // increase array size
      if(!this.Increase(trades)) return false;

      // set last item of list as value
      trades[this.count() - 1] = trade;

      return true;
   }
   bool closeCurrentTrade(const int currentCandleIndex)
   {
      static STradeInfo _info;
      _info.reset();
      if(!this.currentTradeGet(_info)) return false;
      if(!_info.in_progress) return false;
      //
      MqlRates rates[];
      if(::CopyRates(_Symbol, PERIOD_CURRENT, currentCandleIndex, 1, rates) != 1) return false;
      //
      _info.close_price = rates[0].close;
      _info.time_close  = rates[0].time;
      _info.in_progress = false;
      if(_info.trend_of_trade == BUY)
      {
         _info.profit_pips = (rates[0].close - _info.entry_price) / this.pipValue();
      }
      else if(_info.trend_of_trade == SELL)
      {
         _info.profit_pips = (_info.entry_price - rates[0].close) / this.pipValue();
      }
      else
      {
         ::Print("Unexpected order type...");
         return false;
      }
      if(_info.profit_pips < _info.drawdown_pips)
      {
         _info.drawdown_pips = _info.profit_pips;
      }
      return this.currentTradeUpdate(_info);
   }
   int count()
   {
      return this.Count(trades);
   }
   bool currentTradeGet(STradeInfo&_info)
   {
      const int _count = this.count();
      if(_count > 0)
      {
         _info = this.trades[_count - 1];
         return true;
      }
      return false;
   }
   bool currentTradeUpdate(STradeInfo&_info)
   {
      const int _count = this.count();
      if(_count > 0)
      {
         this.trades[_count - 1] = _info;
         return true;
      }
      return false;
   }
   double drawdown(const int shift, const ENUM_CHART_STRATEGY strategy)
   {
      const int _count = this.count();
      double _drawdown = 0.0;
      const datetime currentTime = ::iTime(_Symbol, PERIOD_CURRENT, shift);

      switch(strategy)
      {
      case CHART_STRATEGY_TOTAL:
         for(int i = 0; i < _count; i++)
         {
            if(this.trades[i].drawdown_pips < _drawdown)
            {
               _drawdown = this.trades[i].drawdown_pips;
            }
         }
         break;

      case CHART_STRATEGY_SINGLE:
         // Only current trade (last trade)
         if(_count > 0)
         {
            _drawdown = this.trades[_count - 1].drawdown_pips;
         }
         break;

      case CHART_STRATEGY_DAILY:
         // Only trades opened today
      {
         MqlDateTime currentDT, tradeDT;
         ::TimeToStruct(currentTime, currentDT);

         for(int i = 0; i < _count; i++)
         {
            ::TimeToStruct(this.trades[i].time_open, tradeDT);
            if(tradeDT.year == currentDT.year &&
                  tradeDT.mon == currentDT.mon &&
                  tradeDT.day == currentDT.day)
            {
               if(this.trades[i].drawdown_pips < _drawdown)
               {
                  _drawdown = this.trades[i].drawdown_pips;
               }
            }
         }
         break;
      }

      case CHART_STRATEGY_WEEKLY:
         // Only trades opened this week
      {
         // Calculate start of current week (Monday)
         MqlDateTime currentDT;
         ::TimeToStruct(currentTime, currentDT);

         // Get day of week (0=Sunday, 1=Monday, etc.)
         int dayOfWeek = currentDT.day_of_week;
         if(dayOfWeek == 0) dayOfWeek = 7; // Make Sunday = 7

         // Calculate seconds to subtract to get to Monday 00:00:00
         int daysToMonday = dayOfWeek - 1;
         datetime weekStart = currentTime - (daysToMonday * 86400); // 86400 seconds in a day

         // Set to start of day
         MqlDateTime weekStartDT;
         ::TimeToStruct(weekStart, weekStartDT);
         weekStartDT.hour = 0;
         weekStartDT.min = 0;
         weekStartDT.sec = 0;
         weekStart = ::StructToTime(weekStartDT);

         for(int i = 0; i < _count; i++)
         {
            if(this.trades[i].time_open >= weekStart)
            {
               if(this.trades[i].drawdown_pips < _drawdown)
               {
                  _drawdown = this.trades[i].drawdown_pips;
               }
            }
         }
         break;
      }

      case CHART_STRATEGY_MONTHLY:
         // Only trades opened this month
      {
         MqlDateTime currentDT, tradeDT;
         ::TimeToStruct(currentTime, currentDT);

         for(int i = 0; i < _count; i++)
         {
            ::TimeToStruct(this.trades[i].time_open, tradeDT);
            if(tradeDT.year == currentDT.year &&
                  tradeDT.mon == currentDT.mon)
            {
               if(this.trades[i].drawdown_pips < _drawdown)
               {
                  _drawdown = this.trades[i].drawdown_pips;
               }
            }
         }
         break;
      }
      default:
         break;
      };

      return _drawdown;
   }
//+------------------------------------------------------------------+
//| checks all current orders and returns true is one if opened      |
//+------------------------------------------------------------------+
   bool isOrderOpen()
   {
      const int _count = this.count();
      for(int i = 0; i < _count; i++)
         if(trades[i].in_progress) return true;
      return false;
   }
//+------------------------------------------------------------------+
//| returns the pip value of the current symbol                      |
//+------------------------------------------------------------------+
   double pipValue()
   {
      double _value = ::SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;
      if(::StringFind("JPY", _Symbol) != -1)
      {
         _value *= 10;
      }
      else if(::StringFind("NAS", _Symbol) != -1)
      {
         _value = 1.00;
      }
      else if(::StringFind("US30", _Symbol) != -1)
      {
         _value = 1.00;
      }
      else if(::StringFind("XAU", _Symbol) != -1)
      {
         _value = 0.10;
      }
      return _value;
   }
//+------------------------------------------------------------------+
//| adds a new order to ur trades array                              |
//+------------------------------------------------------------------+
   bool placeTrade(const int index, const int type)
   {
// increase array size
      if(!this.Increase(trades)) return false;

      static STradeInfo newTrade;
      newTrade.reset();

      newTrade.trend_of_trade = type;
      newTrade.entry_price = ::iClose(_Symbol, PERIOD_CURRENT, index);
      newTrade.time_open   = ::iTime(_Symbol, PERIOD_CURRENT, index);
      newTrade.in_progress = true;

      static long _ticket = 1;

      newTrade.ticket = _ticket;
      _ticket++;

// set last item of list as value
      trades[this.count() - 1] = newTrade;

      return true;
   }
//+------------------------------------------------------------------+
//| returns the current profit                                       |
//+------------------------------------------------------------------+
   double profit(const int shift, const ENUM_CHART_STRATEGY strategy)
   {
      const int _count = this.count();
      double _profit = 0.0;
      const datetime currentTime = ::iTime(_Symbol, PERIOD_CURRENT, shift);

      switch(strategy)
      {
      case CHART_STRATEGY_TOTAL:
         // Sum all trades
         for(int i = 0; i < _count; i++)
         {
            _profit += this.trades[i].profit_pips;
         }
         break;

      case CHART_STRATEGY_SINGLE:
         // Only current trade (last trade)
         if(_count > 0)
         {
            _profit = this.trades[_count - 1].profit_pips;
         }
         break;

      case CHART_STRATEGY_DAILY:
         // Only trades opened today
      {
         MqlDateTime currentDT, tradeDT;
         ::TimeToStruct(currentTime, currentDT);

         for(int i = 0; i < _count; i++)
         {
            ::TimeToStruct(this.trades[i].time_open, tradeDT);
            if(tradeDT.year == currentDT.year &&
                  tradeDT.mon == currentDT.mon &&
                  tradeDT.day == currentDT.day)
            {
               _profit += this.trades[i].profit_pips;
            }
         }
         break;
      }

      case CHART_STRATEGY_WEEKLY:
         // Only trades opened this week
      {
         // Calculate start of current week (Monday)
         MqlDateTime currentDT;
         ::TimeToStruct(currentTime, currentDT);

         // Get day of week (0=Sunday, 1=Monday, etc.)
         int dayOfWeek = currentDT.day_of_week;
         if(dayOfWeek == 0) dayOfWeek = 7; // Make Sunday = 7

         // Calculate seconds to subtract to get to Monday 00:00:00
         int daysToMonday = dayOfWeek - 1;
         datetime weekStart = currentTime - (daysToMonday * 86400); // 86400 seconds in a day

         // Set to start of day
         MqlDateTime weekStartDT;
         ::TimeToStruct(weekStart, weekStartDT);
         weekStartDT.hour = 0;
         weekStartDT.min = 0;
         weekStartDT.sec = 0;
         weekStart = ::StructToTime(weekStartDT);

         for(int i = 0; i < _count; i++)
         {
            if(this.trades[i].time_open >= weekStart)
            {
               _profit += this.trades[i].profit_pips;
            }
         }
         break;
      }

      case CHART_STRATEGY_MONTHLY:
         // Only trades opened this month
      {
         MqlDateTime currentDT, tradeDT;
         ::TimeToStruct(currentTime, currentDT);

         for(int i = 0; i < _count; i++)
         {
            ::TimeToStruct(this.trades[i].time_open, tradeDT);
            if(tradeDT.year == currentDT.year &&
                  tradeDT.mon == currentDT.mon)
            {
               _profit += this.trades[i].profit_pips;
            }
         }
         break;
      }
      default:
         break;
      };

      return _profit;
   }
//+------------------------------------------------------------------+
//| remove a trade based on the index                                |
//+------------------------------------------------------------------+
   bool removeTradeIndex(const int index)
   {
      const int _count = this.count();
      for(int i = 0; i < _count; i++)
      {
         if(i == index)
         {
            for(int j = i; j < _count - 1; j++)
            {
               this.trades[j] = this.trades[j + 1];
            }
         }
      }
      return this.Decrease(trades);
   }
//+------------------------------------------------------------------+
//| remove a trade based on its ticket                               |
//+------------------------------------------------------------------+
   bool removeTradeTicket(const long ticket)
   {
      const int _count = this.count();
      for(int i = 0; i < _count; i++)
      {
         if(this.trades[i].ticket == ticket)
         {
            for(int j = i; j < _count - 1; j++)
            {
               trades[j] = trades[j + 1];
            }
         }
      }
      return this.Decrease(trades);
   }
//+------------------------------------------------------------------+
//| reset trades array                                               |
//+------------------------------------------------------------------+
   void resetTrades()
   {
      ::ZeroMemory(this.trades);
      ::ArrayResize(this.trades, 0);
   }
//+------------------------------------------------------------------+
//| update the pip count of current order and on-chart comment       |
//+------------------------------------------------------------------+
   void update(const int currentCandle)
   {
      static STradeInfo _info;
      _info.reset();
      if(!this.currentTradeGet(_info)) return;
      if(!_info.in_progress) return;
      const double _close = ::iClose(_Symbol, PERIOD_CURRENT, currentCandle);
      if(_info.trend_of_trade == BUY)
      {
         _info.profit_pips = (_close - _info.entry_price) / this.pipValue();
      }
      else if(_info.trend_of_trade == SELL)
      {
         _info.profit_pips = (_info.entry_price - _close) / this.pipValue();
      }
      else
      {
         ::Print("Unexpected order type...");
         return;
      }
      if(DEBUG && currentCandle == 0)
      {
         ::Comment(
            "entry: " + doubleToString(_info.entry_price, _Digits) + ", " +
            "close: " + doubleToString(_close, _Digits) + ", " +
            "profit: " + doubleToString(_info.profit_pips) + " pips, " +
            "drawdown: " + doubleToString(_info.drawdown_pips) + " pips");
      }
      switch(inpCloseStrategy)
      {
      case CLOSE_ON_TP:
         if(_info.profit_pips >= inpCloseTakeProfit)
         {
            this.closeCurrentTrade(currentCandle);
         }
         break;
      default:
         break;
      };

//---drawdown
      if(_info.profit_pips < _info.drawdown_pips)
      {
         _info.drawdown_pips = _info.profit_pips;
      }

//---update 'er
      this.currentTradeUpdate(_info);
   }
protected:
   STradeInfo trades[];
private:
};
//+------------------------------------------------------------------+
//| class for pritning params                                        |
//+------------------------------------------------------------------+
class MqlParamStringer
{
public:
   static string stringify(const MqlParam &param)
   {
      switch(param.type)
      {
      case TYPE_BOOL:
      case TYPE_CHAR:
      case TYPE_UCHAR:
      case TYPE_SHORT:
      case TYPE_USHORT:
      case TYPE_DATETIME:
      case TYPE_COLOR:
      case TYPE_INT:
      case TYPE_UINT:
      case TYPE_LONG:
      case TYPE_ULONG:
         return ::IntegerToString(param.integer_value);
      case TYPE_FLOAT:
      case TYPE_DOUBLE:
         return (string)(float)param.double_value;
      case TYPE_STRING:
         return param.string_value;
      }
      return NULL;
   }

   static string stringify(const MqlParam &params[])
   {
      string result = "";
      const int p = ::ArraySize(params);
      for(int i = 0; i < p; ++i)
      {
         result += stringify(params[i]) + (i < p - 1 ? "," : "");
      }
      return result;
   }
};
//---globals
CIndicator indi;
CMentalTrader *mTrader;
int handle = INVALID_HANDLE;
double bufferBuy[], bufferSell[];
double bufferProfit[], bufferDrawdown[];
bool initSuccess = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- set
   mTrader = new CMentalTrader();
//--- acquire
#ifdef __MQL5__
//buffeys
   string inputParams[];
   const int paramCount = ::StringSplit(inpIndicatorParams, ',', inputParams);

// Trim whitespace from all parameters
   for(int i = 0; i < paramCount; i++)
   {
      ::StringTrimLeft(inputParams[i]);
      ::StringTrimRight(inputParams[i]);
   }

   switch(paramCount)
   {
   case 0:
      switch(inpIndicatorType)
      {
      case INDICATOR_ICUSTOM:
         handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5");
         break;
      case INDICATOR_IMA:
         ::Alert("MA Period must be provided!");
         return INIT_FAILED;
      default:
         break;
      };
      break;
   case 1:
      switch(inpIndicatorType)
      {
      case INDICATOR_ICUSTOM:
      {
         const ENUM_DATATYPE _type = inputType(inputParams[0]);
         switch(_type)
         {
         case TYPE_BOOL:
         {
            const bool _choice = ::StringFind(inputParams[0], "rue") != -1;
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _choice);
            break;
         }
         case TYPE_INT:
         {
            const int _value = (int)::StringToInteger(inputParams[0]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _value);
            break;
         }
         case TYPE_DOUBLE:
         {
            const double _value = ::StringToDouble(inputParams[0]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _value);
            break;
         }
         case TYPE_DATETIME:
         {
            const datetime _value = ::StringToTime(inputParams[0]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _value);
            break;
         }
         case TYPE_COLOR:
         {
            const color _value = (color)::StringToInteger(inputParams[0]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _value);
            break;
         }
         default: // TYPE_STRING
         {
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0]);
            break;
         }
         }
         break;
      }
      case INDICATOR_IMA:
         if(inputType(inputParams[0]) != TYPE_INT)
         {
            ::Alert("MA Period must be provided and be an integer!");
            return INIT_FAILED;
         }
         handle = ::iMA(_Symbol, PERIOD_CURRENT, (int)::StringToInteger(inputParams[0]), 0, MODE_EMA, PRICE_CLOSE);
      default:
         break;
      };
      break;
   case 2:
      switch(inpIndicatorType)
      {
      case INDICATOR_ICUSTOM:
      {
         const ENUM_DATATYPE _type1 = inputType(inputParams[0]);
         const ENUM_DATATYPE _type2 = inputType(inputParams[1]);

         // Convert first parameter
         if(_type1 == TYPE_BOOL)
         {
            const bool _val1 = ::StringFind(inputParams[0], "rue") != -1;
            // Convert second parameter
            if(_type2 == TYPE_BOOL)
            {
               const bool _val2 = ::StringFind(inputParams[1], "rue") != -1;
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_INT)
            {
               const int _val2 = (int)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DOUBLE)
            {
               const double _val2 = ::StringToDouble(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DATETIME)
            {
               const datetime _val2 = ::StringToTime(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_COLOR)
            {
               const color _val2 = (color)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else
            {
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, inputParams[1]);
            }
         }
         else if(_type1 == TYPE_INT)
         {
            const int _val1 = (int)::StringToInteger(inputParams[0]);
            if(_type2 == TYPE_BOOL)
            {
               const bool _val2 = ::StringFind(inputParams[1], "rue") != -1;
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_INT)
            {
               const int _val2 = (int)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DOUBLE)
            {
               const double _val2 = ::StringToDouble(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DATETIME)
            {
               const datetime _val2 = ::StringToTime(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_COLOR)
            {
               const color _val2 = (color)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else
            {
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, inputParams[1]);
            }
         }
         else if(_type1 == TYPE_DOUBLE)
         {
            const double _val1 = ::StringToDouble(inputParams[0]);
            if(_type2 == TYPE_BOOL)
            {
               const bool _val2 = ::StringFind(inputParams[1], "rue") != -1;
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_INT)
            {
               const int _val2 = (int)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DOUBLE)
            {
               const double _val2 = ::StringToDouble(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DATETIME)
            {
               const datetime _val2 = ::StringToTime(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_COLOR)
            {
               const color _val2 = (color)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else
            {
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, inputParams[1]);
            }
         }
         else if(_type1 == TYPE_DATETIME)
         {
            const datetime _val1 = ::StringToTime(inputParams[0]);
            if(_type2 == TYPE_BOOL)
            {
               const bool _val2 = ::StringFind(inputParams[1], "rue") != -1;
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_INT)
            {
               const int _val2 = (int)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DOUBLE)
            {
               const double _val2 = ::StringToDouble(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DATETIME)
            {
               const datetime _val2 = ::StringToTime(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_COLOR)
            {
               const color _val2 = (color)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else
            {
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, inputParams[1]);
            }
         }
         else if(_type1 == TYPE_COLOR)
         {
            const color _val1 = (color)::StringToInteger(inputParams[0]);
            if(_type2 == TYPE_BOOL)
            {
               const bool _val2 = ::StringFind(inputParams[1], "rue") != -1;
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_INT)
            {
               const int _val2 = (int)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DOUBLE)
            {
               const double _val2 = ::StringToDouble(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_DATETIME)
            {
               const datetime _val2 = ::StringToTime(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else if(_type2 == TYPE_COLOR)
            {
               const color _val2 = (color)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, _val2);
            }
            else
            {
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _val1, inputParams[1]);
            }
         }
         else // TYPE_STRING
         {
            if(_type2 == TYPE_BOOL)
            {
               const bool _val2 = ::StringFind(inputParams[1], "rue") != -1;
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0], _val2);
            }
            else if(_type2 == TYPE_INT)
            {
               const int _val2 = (int)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0], _val2);
            }
            else if(_type2 == TYPE_DOUBLE)
            {
               const double _val2 = ::StringToDouble(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0], _val2);
            }
            else if(_type2 == TYPE_DATETIME)
            {
               const datetime _val2 = ::StringToTime(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0], _val2);
            }
            else if(_type2 == TYPE_COLOR)
            {
               const color _val2 = (color)::StringToInteger(inputParams[1]);
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0], _val2);
            }
            else
            {
               handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0], inputParams[1]);
            }
         }
         break;
      }
      case INDICATOR_IMA:
         ::Print("Moving Average indicator only supports 1 parameter.");
         return INIT_FAILED;
      default:
         break;
      };
      break;
   case 3:
      switch(inpIndicatorType)
      {
      case INDICATOR_ICUSTOM:
      {
         // Determine types for all 3 parameters
         const ENUM_DATATYPE _type1 = inputType(inputParams[0]);
         const ENUM_DATATYPE _type2 = inputType(inputParams[1]);
         const ENUM_DATATYPE _type3 = inputType(inputParams[2]);

         // helper macro
#define CONVERT_PARAM(idx, typeVar) \
(typeVar == TYPE_BOOL ? (bool)(::StringFind(inputParams[idx], "rue") != -1) : \
 typeVar == TYPE_INT ? (int)::StringToInteger(inputParams[idx]) : \
 typeVar == TYPE_DOUBLE ? ::StringToDouble(inputParams[idx]) : \
 typeVar == TYPE_DATETIME ? ::StringToTime(inputParams[idx]) : \
 typeVar == TYPE_COLOR ? (color)::StringToInteger(inputParams[idx]) : inputParams[idx])

         // Convert all parameters based on their types
         if(_type1 == TYPE_BOOL && _type2 == TYPE_BOOL && _type3 == TYPE_BOOL)
         {
            const bool _v1 = ::StringFind(inputParams[0], "rue") != -1;
            const bool _v2 = ::StringFind(inputParams[1], "rue") != -1;
            const bool _v3 = ::StringFind(inputParams[2], "rue") != -1;
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _v1, _v2, _v3);
         }
         else if(_type1 == TYPE_INT && _type2 == TYPE_INT && _type3 == TYPE_INT)
         {
            const int _v1 = (int)::StringToInteger(inputParams[0]);
            const int _v2 = (int)::StringToInteger(inputParams[1]);
            const int _v3 = (int)::StringToInteger(inputParams[2]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _v1, _v2, _v3);
         }
         else if(_type1 == TYPE_DOUBLE && _type2 == TYPE_DOUBLE && _type3 == TYPE_DOUBLE)
         {
            const double _v1 = ::StringToDouble(inputParams[0]);
            const double _v2 = ::StringToDouble(inputParams[1]);
            const double _v3 = ::StringToDouble(inputParams[2]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _v1, _v2, _v3);
         }
         else if(_type1 == TYPE_STRING && _type2 == TYPE_STRING && _type3 == TYPE_STRING)
         {
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", inputParams[0], inputParams[1], inputParams[2]);
         }
         // Mixed types - INT, INT, DOUBLE (common pattern)
         else if(_type1 == TYPE_INT && _type2 == TYPE_INT && _type3 == TYPE_DOUBLE)
         {
            const int _v1 = (int)::StringToInteger(inputParams[0]);
            const int _v2 = (int)::StringToInteger(inputParams[1]);
            const double _v3 = ::StringToDouble(inputParams[2]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _v1, _v2, _v3);
         }
         // Mixed types - INT, DOUBLE, INT
         else if(_type1 == TYPE_INT && _type2 == TYPE_DOUBLE && _type3 == TYPE_INT)
         {
            const int _v1 = (int)::StringToInteger(inputParams[0]);
            const double _v2 = ::StringToDouble(inputParams[1]);
            const int _v3 = (int)::StringToInteger(inputParams[2]);
            handle = ::iCustom(_Symbol, PERIOD_CURRENT, "\\Indicators\\" + inpIndicatorName + ".ex5", _v1, _v2, _v3);
         }
         // For other mixed type combinations, use MqlParam array
         else
         {
            MqlParam params[3];

            // Set parameter 1
            if(_type1 == TYPE_BOOL)
            {
               params[0].type = TYPE_BOOL;
               params[0].integer_value = ::StringFind(inputParams[0], "rue") != -1;
            }
            else if(_type1 == TYPE_INT)
            {
               params[0].type = TYPE_INT;
               params[0].integer_value = ::StringToInteger(inputParams[0]);
            }
            else if(_type1 == TYPE_DOUBLE)
            {
               params[0].type = TYPE_DOUBLE;
               params[0].double_value = ::StringToDouble(inputParams[0]);
            }
            else if(_type1 == TYPE_DATETIME)
            {
               params[0].type = TYPE_DATETIME;
               params[0].integer_value = ::StringToTime(inputParams[0]);
            }
            else if(_type1 == TYPE_COLOR)
            {
               params[0].type = TYPE_COLOR;
               params[0].integer_value = ::StringToInteger(inputParams[0]);
            }
            else
            {
               params[0].type = TYPE_STRING;
               params[0].string_value = inputParams[0];
            }

            // Set parameter 2
            if(_type2 == TYPE_BOOL)
            {
               params[1].type = TYPE_BOOL;
               params[1].integer_value = ::StringFind(inputParams[1], "rue") != -1;
            }
            else if(_type2 == TYPE_INT)
            {
               params[1].type = TYPE_INT;
               params[1].integer_value = ::StringToInteger(inputParams[1]);
            }
            else if(_type2 == TYPE_DOUBLE)
            {
               params[1].type = TYPE_DOUBLE;
               params[1].double_value = ::StringToDouble(inputParams[1]);
            }
            else if(_type2 == TYPE_DATETIME)
            {
               params[1].type = TYPE_DATETIME;
               params[1].integer_value = ::StringToTime(inputParams[1]);
            }
            else if(_type2 == TYPE_COLOR)
            {
               params[1].type = TYPE_COLOR;
               params[1].integer_value = ::StringToInteger(inputParams[1]);
            }
            else
            {
               params[1].type = TYPE_STRING;
               params[1].string_value = inputParams[1];
            }

            // Set parameter 3
            if(_type3 == TYPE_BOOL)
            {
               params[2].type = TYPE_BOOL;
               params[2].integer_value = ::StringFind(inputParams[2], "rue") != -1;
            }
            else if(_type3 == TYPE_INT)
            {
               params[2].type = TYPE_INT;
               params[2].integer_value = ::StringToInteger(inputParams[2]);
            }
            else if(_type3 == TYPE_DOUBLE)
            {
               params[2].type = TYPE_DOUBLE;
               params[2].double_value = ::StringToDouble(inputParams[2]);
            }
            else if(_type3 == TYPE_DATETIME)
            {
               params[2].type = TYPE_DATETIME;
               params[2].integer_value = ::StringToTime(inputParams[2]);
            }
            else if(_type3 == TYPE_COLOR)
            {
               params[2].type = TYPE_COLOR;
               params[2].integer_value = ::StringToInteger(inputParams[2]);
            }
            else
            {
               params[2].type = TYPE_STRING;
               params[2].string_value = inputParams[2];
            }

            // Pass the entire MqlParam array to iCustom
            handle = ::IndicatorCreate(_Symbol, PERIOD_CURRENT, IND_CUSTOM, 3, params);
         }

#undef CONVERT_PARAM
         break;
      }
      case INDICATOR_IMA:
         ::Print("Moving Average indicator only supports 1 parameter.");
         return INIT_FAILED;
      default:
         break;
      };
      break;
   default:
      ::Print("Too many parameters... only up to 3 parameters are allowed currently.");
      break;
   };
   if(handle == INVALID_HANDLE)
   {
      if(inpIndicatorType == INDICATOR_ICUSTOM)
      {
         ::Print("Failed to acquire \"" + inpIndicatorName + ".ex5\"");
      }
      else
      {
         ::Print("Failed to acquire Moving average indicator..");
      }
      return INIT_FAILED;
   }
   if(DEBUG)
   {
//--- read the parameters applied by the indicator
      ENUM_INDICATOR indicatorType;
      MqlParam params[];
      ::IndicatorParameters(handle, indicatorType, params);
      ::Print("Parameters: " + MqlParamStringer::stringify(params));
   }
#endif
//--- indicator buffers mapping
   if(!indi.createBuffer("Profit", DRAW_LINE, STYLE_SOLID, inpProfitColor, 3, 0, bufferProfit)) return INIT_FAILED;
   if(!indi.createBuffer("Drawdown", DRAW_LINE, STYLE_SOLID, inpDrawdownColor, 3, 1, bufferDrawdown)) return INIT_FAILED;
//--- return success
   initSuccess = true;
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
//--- check
   if(!initSuccess) return rates_total;
//--- set limit
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ::ArraySetAsSeries(bufferProfit, true);
      ::ArraySetAsSeries(bufferDrawdown, true);
      ::ArrayInitialize(bufferProfit, 0.0);
      ::ArrayInitialize(bufferDrawdown, 0.0);
   }
   else limit++;
   limit = ::MathMin(limit, MAX_CANDLES);
//--- copy buffer
   if(!copyBuffer(inpBuyEntryBuffer, limit + 3, bufferBuy))
   {
      ::Alert("Failed to load buy buffer value from \"" + inpIndicatorName + ".ex5\"");
      return rates_total;
   }
   if(!copyBuffer(inpSellEntryBuffer, limit + 3, bufferSell))
   {
      ::Alert("Failed to load sell buffer value from \"" + inpIndicatorName + ".ex5\"");
      return rates_total;
   }
//--- loop
   int i = limit - 1;
   while(i >= 0)
   {
      switch(inpChartStrategy)
      {
      case CHART_STRATEGY_DAILY:
      {
         const datetime daily = ::iTime(_Symbol, PERIOD_D1, i);
         drawVerticalLine("-Indicator-Stats-daily-" + string(daily), 0, daily, 1, clrWhite);
         break;
      }
      case CHART_STRATEGY_WEEKLY:
      {
         const datetime weekly = ::iTime(_Symbol, PERIOD_W1, i);
         drawVerticalLine("-Indicator-Stats-weekly-" + string(weekly), 0, weekly, 1, clrWhite);
         break;
      }
      case CHART_STRATEGY_MONTHLY:
      {
         const datetime monthly = ::iTime(_Symbol, PERIOD_MN1, i);
         drawVerticalLine("-Indicator-Stats-monthly-" + string(monthly), 0, monthly, 1, clrWhite);
         break;
      }
      default:
         break;
      };
      const int _entry = i + inpEntryCandle;
      const int _close = i + inpCloseCandle;
      //
      if(!mTrader.isOrderOpen())
      {
         switch(trend(_entry))
         {
         case TREND_BULLISH:
            mTrader.placeTrade(_entry, BUY);
            break;
         case TREND_BEARISH:
            mTrader.placeTrade(_entry, SELL);
            break;
         default:
            break;
         }
      }
      else
      {
         //--- update profit
         mTrader.update(i);

         //--- check for closing conditions (opposite signal) and place new trades
         switch(trend(_entry))
         {
         case TREND_BULLISH:
            if(inpCloseStrategy == CLOSE_ON_OPPOSITE)
            {
               mTrader.closeCurrentTrade(_close);
            }
            mTrader.placeTrade(_entry, BUY);
            break;
         case TREND_BEARISH:
            if(inpCloseStrategy == CLOSE_ON_OPPOSITE)
            {
               mTrader.closeCurrentTrade(_close);
            }
            mTrader.placeTrade(_entry, SELL);
            break;
         default:
            break;
         }
      }
      bufferProfit[i]   = mTrader.profit(i, inpChartStrategy);
      bufferDrawdown[i] = mTrader.drawdown(i, inpChartStrategy);
      i--;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
#ifdef __MQL5__
   ::IndicatorRelease(handle);
#endif
   indi.deletePointer(mTrader);
   ::ObjectsDeleteAll(0, "-Indicator");
   ::Comment("");
}
//+------------------------------------------------------------------+
//| fill the buffer with indicator data                              |
//+------------------------------------------------------------------+
bool copyBuffer(const int buffer_num, const int count, double&buffer_array[])
{
   ::ArraySetAsSeries(buffer_array, true);
#ifdef __MQL5__
   return ::CopyBuffer(handle, buffer_num, 0, count, buffer_array) == count;
#else
// MQL4 version - parse parameters and call iCustom directly
   string inputParams[];
   const int paramCount = ::StringSplit(inpIndicatorParams, ',', inputParams);

// Trim whitespace from all parameters
   for(int p = 0; p < paramCount; p++)
   {
      ::StringTrimLeft(inputParams[p]);
      ::StringTrimRight(inputParams[p]);
   }

   int i = 0;
   switch(paramCount)
   {
   case 0:
      while(i < count)
      {
         buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", buffer_num, i);
         i++;
      }
      break;
   case 1:
   {
      const ENUM_DATATYPE _type = inputType(inputParams[0]);
      if(_type == TYPE_BOOL)
      {
         const bool _val = ::StringFind(inputParams[0], "rue") != -1;
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _val, buffer_num, i);
            i++;
         }
      }
      else if(_type == TYPE_INT)
      {
         const int _val = (int)::StringToInteger(inputParams[0]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _val, buffer_num, i);
            i++;
         }
      }
      else if(_type == TYPE_DOUBLE)
      {
         const double _val = ::StringToDouble(inputParams[0]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _val, buffer_num, i);
            i++;
         }
      }
      else if(_type == TYPE_DATETIME)
      {
         const datetime _val = ::StringToTime(inputParams[0]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _val, buffer_num, i);
            i++;
         }
      }
      else if(_type == TYPE_COLOR)
      {
         const color _val = (color)::StringToInteger(inputParams[0]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _val, buffer_num, i);
            i++;
         }
      }
      else // TYPE_STRING
      {
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", inputParams[0], buffer_num, i);
            i++;
         }
      }
      break;
   }
   case 2:
   {
      const ENUM_DATATYPE _type1 = inputType(inputParams[0]);
      const ENUM_DATATYPE _type2 = inputType(inputParams[1]);

      // Convert parameters based on types (handle common combinations)
      if(_type1 == TYPE_INT && _type2 == TYPE_INT)
      {
         const int _v1 = (int)::StringToInteger(inputParams[0]);
         const int _v2 = (int)::StringToInteger(inputParams[1]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, buffer_num, i);
            i++;
         }
      }
      else if(_type1 == TYPE_INT && _type2 == TYPE_DOUBLE)
      {
         const int _v1 = (int)::StringToInteger(inputParams[0]);
         const double _v2 = ::StringToDouble(inputParams[1]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, buffer_num, i);
            i++;
         }
      }
      else if(_type1 == TYPE_DOUBLE && _type2 == TYPE_INT)
      {
         const double _v1 = ::StringToDouble(inputParams[0]);
         const int _v2 = (int)::StringToInteger(inputParams[1]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, buffer_num, i);
            i++;
         }
      }
      else if(_type1 == TYPE_DOUBLE && _type2 == TYPE_DOUBLE)
      {
         const double _v1 = ::StringToDouble(inputParams[0]);
         const double _v2 = ::StringToDouble(inputParams[1]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, buffer_num, i);
            i++;
         }
      }
      else if(_type1 == TYPE_STRING && _type2 == TYPE_INT)
      {
         const int _v2 = (int)::StringToInteger(inputParams[1]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", inputParams[0], _v2, buffer_num, i);
            i++;
         }
      }
      else if(_type1 == TYPE_STRING && _type2 == TYPE_DOUBLE)
      {
         const double _v2 = ::StringToDouble(inputParams[1]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", inputParams[0], _v2, buffer_num, i);
            i++;
         }
      }
      else // Default: treat both as strings
      {
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", inputParams[0], inputParams[1], buffer_num, i);
            i++;
         }
      }
      break;
   }
   case 3:
   {
      const ENUM_DATATYPE _type1 = inputType(inputParams[0]);
      const ENUM_DATATYPE _type2 = inputType(inputParams[1]);
      const ENUM_DATATYPE _type3 = inputType(inputParams[2]);

      // Handle most common pattern: INT, INT, INT
      if(_type1 == TYPE_INT && _type2 == TYPE_INT && _type3 == TYPE_INT)
      {
         const int _v1 = (int)::StringToInteger(inputParams[0]);
         const int _v2 = (int)::StringToInteger(inputParams[1]);
         const int _v3 = (int)::StringToInteger(inputParams[2]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, _v3, buffer_num, i);
            i++;
         }
      }
      // INT, INT, DOUBLE
      else if(_type1 == TYPE_INT && _type2 == TYPE_INT && _type3 == TYPE_DOUBLE)
      {
         const int _v1 = (int)::StringToInteger(inputParams[0]);
         const int _v2 = (int)::StringToInteger(inputParams[1]);
         const double _v3 = ::StringToDouble(inputParams[2]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, _v3, buffer_num, i);
            i++;
         }
      }
      // INT, DOUBLE, INT
      else if(_type1 == TYPE_INT && _type2 == TYPE_DOUBLE && _type3 == TYPE_INT)
      {
         const int _v1 = (int)::StringToInteger(inputParams[0]);
         const double _v2 = ::StringToDouble(inputParams[1]);
         const int _v3 = (int)::StringToInteger(inputParams[2]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, _v3, buffer_num, i);
            i++;
         }
      }
      // DOUBLE, DOUBLE, DOUBLE
      else if(_type1 == TYPE_DOUBLE && _type2 == TYPE_DOUBLE && _type3 == TYPE_DOUBLE)
      {
         const double _v1 = ::StringToDouble(inputParams[0]);
         const double _v2 = ::StringToDouble(inputParams[1]);
         const double _v3 = ::StringToDouble(inputParams[2]);
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", _v1, _v2, _v3, buffer_num, i);
            i++;
         }
      }
      else // Default: treat all as strings
      {
         while(i < count)
         {
            buffer_array[i] = ::iCustom(_Symbol, PERIOD_CURRENT, inpIndicatorName + ".ex4", inputParams[0], inputParams[1], inputParams[2], buffer_num, i);
            i++;
         }
      }
      break;
   }
   default:
      ::Print("MQL4: Too many parameters for iCustom call.");
      return false;
   }

   return true;
#endif
}
//+------------------------------------------------------------------+
//| convert a double into a string                                   |
//+------------------------------------------------------------------+
string doubleToString(const double value, const int digits = 2)
{
#ifdef __MQL5__
   return ::DoubleToString(value, digits);
#else
   return ::DoubleToStr(value, digits);
#endif
}
//+------------------------------------------------------------------+
//| draw a vertical line at a specific time                          |
//+------------------------------------------------------------------+
void drawVerticalLine(string object_name, double price, datetime time, int width, color color_type, int sub_window = 0)
{
   if(::ObjectFind(0, object_name) != 0)
   {
      ::ObjectCreate(0, object_name, OBJ_VLINE, sub_window, time, price);
      ::ObjectSetInteger(0, object_name, OBJPROP_COLOR, color_type);
      ::ObjectSetInteger(0, object_name, OBJPROP_STYLE, STYLE_SOLID);
      ::ObjectSetInteger(0, object_name, OBJPROP_WIDTH, width);
      ::ObjectSetInteger(0, object_name, OBJPROP_BACK, true);
      ::ObjectSetInteger(0, object_name, OBJPROP_SELECTABLE, false);
      ::ObjectSetInteger(0, object_name, OBJPROP_SELECTED, false);
      ::ObjectSetInteger(0, object_name, OBJPROP_HIDDEN, true);
      ::ObjectSetInteger(0, object_name, OBJPROP_ZORDER, 0);
   }
}
//+------------------------------------------------------------------+
//| check if the string is boolean                                   |
//+------------------------------------------------------------------+
bool isBool(const string str)
{
   string copy = str;
   int len = ::StringToLower(copy);
   return str == "true" ? true : str == "false" ? true : false;
}
//+------------------------------------------------------------------+
//| check if the string is a color                                   |
//+------------------------------------------------------------------+
bool isColor(const string str)
{
   return ::StringFind(str, "clr") != -1;
}
//+------------------------------------------------------------------+
//| check if the string is datetime                                  |
//+------------------------------------------------------------------+
bool isDatetime(const string str)
{
   return ::StringFind(str, "'") != -1;
}
//+------------------------------------------------------------------+
//| check if all values within the charArray are digits (0-9)        |
//+------------------------------------------------------------------+
bool isDigit(uchar&charArray[], const bool periodAllowed = false)
{
   string digitList = periodAllowed ? "0123456789." : "0123456789";
// all numerical values (0 - 9)
   const int range = ArraySize(charArray) - 1; // subtract one for the null
   int j = 0;
   string str = "";

   while(j < range)
   {
      str = ::CharToString(charArray[j]);
      if(::StringFind(digitList, str) == -1) return false;
      j++;
   }
   return true;
}
//+------------------------------------------------------------------+
//| returns the data type of the converted input                     |
//+------------------------------------------------------------------+
ENUM_DATATYPE inputType(const string inputParam)
{
   uchar charArray[];
   int   copied = StringToCharArray(inputParam, charArray);
   return
      isBool(inputParam) ? TYPE_BOOL :
      isColor(inputParam) ? TYPE_COLOR :
      isDigit(charArray, false) ? TYPE_INT :
      isDigit(charArray, true) ? TYPE_DOUBLE :
      isDatetime(inputParam) ? TYPE_DATETIME :
      TYPE_STRING;
}
//+------------------------------------------------------------------+
//| get the trend of the current bar                                 |
//+------------------------------------------------------------------+
ENUM_TREND trend(const int shift)
{
   switch(inpTradeStrategy)
   {
   case TRADE_STRATEGY_BUFFERS:
      switch(inpEntryStrategy)
      {
      case ENTRY_NOT_EMPTY_VALUE:
         if(bufferBuy[shift] != EMPTY_VALUE)
         {
            return TREND_BULLISH;
         }
         else if(bufferSell[shift] != EMPTY_VALUE)
         {
            return TREND_BEARISH;
         }
         break;
      case ENTRY_NOT_0:
         if(bufferBuy[shift] != 0)
         {
            return TREND_BULLISH;
         }
         else if(bufferSell[shift] != 0)
         {
            return TREND_BEARISH;
         }
         break;
      case ENTRY_NEITHER_EMPTY_VALUE_OR_0:
         if(bufferBuy[shift] != EMPTY_VALUE && bufferBuy[shift] != 0)
         {
            return TREND_BULLISH;
         }
         else if(bufferSell[shift] != EMPTY_VALUE && bufferSell[shift] != 0)
         {
            return TREND_BEARISH;
         }
         break;
      default:
         break;
      };
      return TREND_NEUTRAL;
   case TRADE_STRATEGY_PRICE_CROSS:
   {
      const double close = iClose(_Symbol, PERIOD_CURRENT, shift);
      const double close1 = iClose(_Symbol, PERIOD_CURRENT, shift + 1);
      //
      if(bufferBuy[shift] != EMPTY_VALUE && bufferBuy[shift] != 0 &&
            bufferBuy[shift + 1] != EMPTY_VALUE && bufferBuy[shift + 1] != 0)
      {
         if(bufferBuy[shift + 1] < close1 && bufferBuy[shift] > close)
         {
            return TREND_BULLISH;
         }
      }
      else if(bufferSell[shift] != EMPTY_VALUE && bufferSell[shift] != 0 &&
              bufferSell[shift + 1] != EMPTY_VALUE && bufferSell[shift + 1] != 0)
      {
         if(bufferSell[shift + 1] > close1 && bufferSell[shift] < close)
         {
            return TREND_BEARISH;
         }
      }
      return TREND_NEUTRAL;
   }
   default:
      return TREND_NEUTRAL;
   }
}
//+------------------------------------------------------------------+
