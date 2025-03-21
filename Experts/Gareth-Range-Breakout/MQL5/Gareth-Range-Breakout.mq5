//+------------------------------------------------------------------+
//|                                        Gareth-Range-Breakout.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.01"
#property strict

#define OBJECT_NAME "G-Range-Break"

#include <Trade/Trade.mqh>
CTrade trade;

enum enum_which_lotsize
{
   usepercentrisk = 1, // Risk per trade
   uselotsize = 2, // Lot size
};
//---- inputs
input string inpStartTime = "01:00";   // Start Time (HH:MM)
input string inpStopTime  = "15:00";   // Stop Time (HH:MM)
input double inpPipBuffer = 0.0;       // Pip Buffer
input bool   inpCloseRule = false;     // Close if Opposite Opened?
input double inp2ndTP     = 0.0;       // Second Trade TP if SL Hit
//---- days
input bool   inpMonday    = true;      // Trade on Mondays? (1)
input bool   inpTuesday   = true;      // Trade on Tuesday? (2)
input bool   inpWednesday = true;      // Trade on Wednesdays? (3)
input bool   inpThursday  = true;      // Trade on Thursdays? (4)
input bool   inpFriday    = true;      // Trade on Fridays? (5)
//---- draw
input color  inpZoneColor = clrYellow; // Zone Color
input int    inpZoneWidth = 2;         // Zone Width
//---- general
input enum_which_lotsize inpRiskChoice = uselotsize; // Risk Option
input double inpLotsize   = 0.10;      // Risk/Lot Size
input long   inpMagic     = 278911;    // Magic Number
input string inpComment   = "G-Range"; // Order Comment

enum _level
{
   Pips,   // Pips
   Percent // Percent of Range
};
input _level inpTPOption  = Pips;      // TP Option
input double inpTPValue   = 30.0;      // TP Value (if Pips: in pips; if Percent: percentage of range)
input _level inpSLOption  = Pips;      // SL Option
input double inpSLValue   = 10.0;      // SL Value (if Pips: in pips; if Percent: percentage of range)
//--- global
double initial_balance;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Draw the range zone at initialization
   draw_range();
   initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, OBJECT_NAME);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime check;
   const datetime time = iTime(_Symbol, PERIOD_M1, 0);
   if(!allow_day(time)) return;
   if(check == time) return;
   if(!market_open(time)) return;
   check = time;
   // Redraw today's range and (if conditions met) set new pending orders
   draw_range();
}

//+------------------------------------------------------------------+
bool allow_day(datetime current_time)
{
   MqlDateTime dt;
   TimeToStruct(current_time, dt);
   switch(dt.day)
   {
   case 1:
      return inpMonday;
   case 2:
      return inpTuesday;
   case 3:
      return inpWednesday;
   case 4:
      return inpThursday;
   case 5:
      return inpFriday;
   default:
      return false;
   }
}

//+------------------------------------------------------------------+
//| Draw range and place new orders (once per day after stop time)   |
//+------------------------------------------------------------------+
void draw_range()
{
   const datetime start_time = stringToTime(inpStartTime);
   const datetime stop_time  = stringToTime(inpStopTime);
   const int index_1 = iBarShift(_Symbol, PERIOD_M1, start_time);
   const int index_2 = iBarShift(_Symbol, PERIOD_M1, stop_time);
   const int range = MathAbs(index_1 - index_2);
   const int index_high = iHighest(_Symbol, PERIOD_M1, MODE_HIGH, range, index_2);
   const int index_low  = iLowest(_Symbol, PERIOD_M1, MODE_LOW, range, index_2);
   const datetime time_1 = iTime(_Symbol, PERIOD_M1, index_high);
   const datetime time_2 = iTime(_Symbol, PERIOD_M1, index_low);
   const double price_1 = iHigh(_Symbol, PERIOD_M1, index_high);
   const double price_2 = iLow(_Symbol, PERIOD_M1, index_low);

   // Calculate the actual range value (price difference)
   double range_value = MathAbs(price_1 - price_2);

   // Draw or update the range rectangle
   if(ObjectFind(0, OBJECT_NAME) < 0)
   {
      if(!ObjectCreate(0, OBJECT_NAME, OBJ_RECTANGLE, 0, time_1, price_1, time_2, price_2))
      {
         Print("Failed to create zone " + OBJECT_NAME);
         return;
      }
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_COLOR, inpZoneColor);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_WIDTH, inpZoneWidth);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_BACK, true);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_FILL, true);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_ZORDER, 10);
   }
   else
   {
      ObjectSetDouble(0, OBJECT_NAME, OBJPROP_PRICE, 0, price_1);
      ObjectSetDouble(0, OBJECT_NAME, OBJPROP_PRICE, 1, price_2);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_TIME, 0, time_1);
      ObjectSetInteger(0, OBJECT_NAME, OBJPROP_TIME, 1, time_2);
   }

   // Only place pending orders if current time is AFTER the user-defined stop time
   if(TimeCurrent() < stop_time)
      return;
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   // Only place new orders once per day
   int currentDate = dt.year * 10000 + dt.mon * 100 + dt.day;
   static int lastOrderDate = 0;
   if(currentDate == lastOrderDate)
      return;

   // Remove any existing orders (from a previous day)
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
      {
         trade.OrderDelete(ticket);
      }
   }

   // Calculate pip value and adjustment
   const double pipv = Point() * 10;
   const double pip_adjustment = inpPipBuffer * pipv;

   // BUY STOP order
   const double buy_price = price_1 + pip_adjustment;
   double buy_st_ls, buy_tp_ls;
   if(inpSLOption == Pips)
      buy_st_ls = buy_price - inpSLValue * pipv;
   else  // Percent option for SL
      buy_st_ls = buy_price - (inpSLValue / 100.0 * range_value);
   if(inpTPOption == Pips)
      buy_tp_ls = buy_price + inpTPValue * pipv;
   else  // Percent option for TP
      buy_tp_ls = buy_price + (inpTPValue / 100.0 * range_value);
   double buy_sl_pips = MathAbs(buy_price - buy_st_ls) / pipv;
   if(!trade.BuyStop(get_lot(buy_sl_pips), buy_price, _Symbol, buy_st_ls, buy_tp_ls))
      Print("Failed to place buy stop for " + _Symbol + " at " + (string)buy_price);

   // SELL STOP order
   const double sell_price = price_2 - pip_adjustment;
   double sell_st_ls, sell_tp_ls;
   if(inpSLOption == Pips)
      sell_st_ls = sell_price + inpSLValue * pipv;
   else  // Percent option for SL
      sell_st_ls = sell_price + (inpSLValue / 100.0 * range_value);
   if(inpTPOption == Pips)
      sell_tp_ls = sell_price - inpTPValue * pipv;
   else  // Percent option for TP
      sell_tp_ls = sell_price - (inpTPValue / 100.0 * range_value);
   double sell_sl_pips = MathAbs(sell_price - sell_st_ls) / pipv;
   if(!trade.SellStop(get_lot(sell_sl_pips), sell_price, _Symbol, sell_st_ls, sell_tp_ls))
      Print("Failed to place sell stop for " + _Symbol + " at " + (string)sell_price);

   // Mark that orders have been placed for today
   lastOrderDate = currentDate;
}

//+------------------------------------------------------------------+
datetime stringToTime(const string time, const datetime timeCurrent = 0)
{
   MqlDateTime day;
   if((timeCurrent == 0) || (StringToTime(time) >= iTime(_Symbol, PERIOD_D1, 0)))
      TimeCurrent(day);
   else if(timeCurrent != 0)
      TimeToStruct(timeCurrent, day);
   else
      TimeToStruct(StringToTime(time), day);

   const int hour = (int)StringToInteger(StringSubstr(time, 0, 2));
   const int minute = (int)StringToInteger(StringSubstr(time, 3, 2));
   const int second = (int)StringToInteger(StringSubstr(time, 6, 2));

   day.hour = hour;
   day.min = minute;
   day.sec = second;
   return StructToTime(day);
}

//+------------------------------------------------------------------+
bool market_open(datetime current_time)
{
   return current_time >= stringToTime("01:00") &&
          current_time < stringToTime("23:50");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Division(double numerator, double denominator)
{

   return denominator == 0 ? 0 : numerator / denominator;
}

//+------------------------------------------------------------------+
double GetRisk(enum_which_lotsize which_risk, double percentRisk, double stopLosss, double lotsizeee)
{

   if(which_risk == usepercentrisk)
   {

      double accEquity = AccountInfoDouble(ACCOUNT_EQUITY);  // account balance

      double decimalRisk = percentRisk / 100;   // turn user input into risk %

      double accountRisk = accEquity * decimalRisk; // define total risk

      double pip_value = Point() * 10;

      double tickValue = (SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
      string acccount_company = AccountInfoString(ACCOUNT_COMPANY); // acount company

      double max_lotsize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE); // contract size

      if(((acccount_company == "Hankotrade LLC") || (acccount_company == "FTMO S.R.O.") || (acccount_company == "E8 Funding Ltd") ) && pip_value == 1)

      {
         tickValue = tickValue * 100;
      }

      if((_Symbol == "US30.mini") || (_Symbol == "NAS100.mini"))
      {
         tickValue = tickValue * 100 ;
      }


      if((acccount_company == "Traders Global Group Incorporated") && pip_value == 1)

      {
         tickValue = tickValue * 10 ;
      }

      double maxLossInQuoteCurr = accountRisk / tickValue;


      double quoteDivision = Division(maxLossInQuoteCurr, (stopLosss * pip_value));
      //double GetRisk = NormalizeDouble(maxLossInQuoteCurr /(stopLosss * GetPipValue())/lotSizes,2);
      double starting_riskk = NormalizeDouble(Division(quoteDivision, max_lotsize), 2);
      double GetRisk = starting_riskk * tickValue;


      if((_Symbol == "US30") || (_Symbol == "NAS100") || (_Symbol == "SPX500") || (_Symbol == "JPN225") || (_Symbol == "UK100") ||
            (_Symbol == "FRA40") || (_Symbol == "ESP35") || (_Symbol == "US30.mini") || (_Symbol == "NAS100.mini") || (_Symbol == "BTCUSD") || (_Symbol == "ETHUSD") ||
            (_Symbol == "LTCUSD") || (_Symbol == "BNBUSD") ||

            (_Symbol == "U30USD.HKT") || (_Symbol == "NASUSD.HKT") || (_Symbol == "SPXUSD.HKT") || (_Symbol == "225JPY.HKT") || (_Symbol == "100GBP.HKT") ||
            (_Symbol == "F40EUR.HKT") || (_Symbol == "E35EUR.HKT") ||

            (_Symbol == "US100.cash") || (_Symbol == "US30.cash") || (_Symbol == "US100") ||

            (_Symbol == "US30.e8") || (_Symbol == "US100.e8") || (_Symbol == "US500.e8") || (_Symbol == "GER40.e8") || (_Symbol == "EU50.e8")  || (_Symbol == "XAUUSD") || (_Symbol == "XAGUSD")


        )
      {
         double final_lotsize = NormalizeDouble((GetRisk * tickValue), 2);

         if(final_lotsize < 0.01)
         {
            return 0.01;
         }
         return final_lotsize;
      }


      if((_Symbol == "USDJPY") || (_Symbol == "CADJPY") || (_Symbol == "EURJPY") || (_Symbol == "AUDJPY") || (_Symbol == "NZDJPY")  || (_Symbol == "CHFJPY")  || (_Symbol == "GBPJPY"))
      {
         double final_lotsize =  NormalizeDouble((GetRisk * 10), 2);

         if(final_lotsize < 0.01)
         {
            return 0.01;
         }
         return final_lotsize;
      }

      else
      {

         double final_lotsize = NormalizeDouble((GetRisk  / 10), 2);
         if(final_lotsize < 0.01)
         {
            return 0.01;
         }
         return final_lotsize;
      }

   }

   if(which_risk == uselotsize)
   {
      double GetRisk = NormalizeDouble(lotsizeee, 2);
      return GetRisk;
   }


   return lotsizeee;
}
//+------------------------------------------------------------------+
double get_lot(double sl)
{
   return
      GetRisk(inpRiskChoice, inpLotsize, sl, inpLotsize);
}
//+------------------------------------------------------------------+
