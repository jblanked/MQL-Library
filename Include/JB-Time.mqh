//+------------------------------------------------------------------+
//|                                                      JB-Time.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
enum ENUM_TIME_INCREMENT
{
   ENUM_YEAR = 0, // Year
   ENUM_MONTH = 1, // Month
   ENUM_DAY = 2, // Day
   ENUM_HOUR = 3, // Hours
   ENUM_MINUTE = 4, // Minutes
   ENUM_SECOND = 5 // Seconds
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTime
{
public:
   bool              allowTime(const bool usetimer, const string startTime, const string stopTime, datetime timeCurrent = 0);
   bool              allowTime(const bool usetimer, const datetime startTime, const datetime stopTime, datetime timeCurrent = 0);
   int               amountOfDays(const int whichMonth, const int whichYear);
   datetime          changeTime(const datetime initialTime, const int incrementBy, const ENUM_TIME_INCREMENT timeChange = ENUM_MONTH);


   datetime          day(const datetime date, const string timeHoursMinutes)
   {
      return StringToTime(TimeToString(date, TIME_DATE) + " " + timeHoursMinutes);
   };

   bool              dayAllowed(bool sunday, bool monday, bool tuesday, bool wednesday, bool thursday, bool friday, datetime timeCurrent = 0)
   {
      timeCurrent = timeCurrent == 0 ? TimeCurrent() : timeCurrent;
      MqlDateTime tm;
      TimeToStruct(timeCurrent, tm);

      switch(tm.day_of_week)
      {
      case 0:
         return sunday ? true : false;
      case 1:
         return monday ? true : false;
      case 2:
         return tuesday ? true : false;
      case 3:
         return wednesday ? true : false;
      case 4:
         return thursday ? true : false;
      case 5:
         return friday ? true : false;

      default:
         return false;
      }
   }

   // if not using the MQL calendar then use winterOffset = 4, otherwise use winterOffset = 3
   datetime          GMT(const datetime servertime, const ushort winterOffset = 4, const ushort summerOffset = 3);

   bool              isMarketOpen(string symbol = NULL, datetime timeCurrent = 0)
   {
      symbol      = symbol == NULL ? _Symbol : symbol;
      timeCurrent = timeCurrent == 0 ? TimeCurrent() : timeCurrent;

      MqlDateTime tm;
      TimeToStruct(timeCurrent, tm);

      switch(tm.day_of_week)
      {
      case 1:
      case 2:
      case 3:
      case 4:
         return true;

      case 5:
         // if time is 23:55:00 or higher its closed
         if(tm.hour == 23 && tm.min >= 55)
         {
            return false;
         }
         else
         {
            return true;
         }

      default:
         return false;
      };

   }

   bool              isTester(void)
   {
      return bool(MQLInfoInteger(MQL_OPTIMIZATION)) || bool(MQLInfoInteger(MQL_TESTER));
   }

   datetime          stringToTime(const string time, const datetime timeCurrent = 0);
   ENUM_TIMEFRAMES   periodCurrentToTimeframe(const ENUM_TIMEFRAMES periodCurrent)
   {
      return periodCurrent == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)Period() : periodCurrent;
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CTime::amountOfDays(const int whichMonth, const int whichYear)
{
   switch(whichMonth)
   {
   case 2:
      return whichYear % 4 == 0 ? 28 : 29;

   case 1:
   case 3:
   case 5:
   case 7:
   case 8:
   case 10:
   case 12:
      return 31;

   case 4:
   case 6:
   case 9:
   case 11:
      return 30;
   }

   return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CTime::stringToTime(const string time, const datetime timeCurrent = 0) // replaces MQL5's StringToTime function'
{
   MqlDateTime day; // define today as a datetime object

   if((timeCurrent == 0) || (StringToTime(time) >= iTime(_Symbol, PERIOD_D1, 0)))
   {
      TimeCurrent(day); // grab the current date's info
   }

   else if(timeCurrent != 0)
   {
      TimeToStruct(timeCurrent, day);
   }

   else
   {
      TimeToStruct(StringToTime(time), day);
   }


   const int hour = (int)StringToInteger(StringSubstr(time, 0, 2)); // set hour as an integer
   const int minute = (int)StringToInteger(StringSubstr(time, 3, 2)); // set minutes as an integer
   const int second = (int)StringToInteger(StringSubstr(time, 6, 2)); // set seconds as an integer

   day.hour = hour; // set the hour to today's hours
   day.min = minute; // set the minutes to today's minutes
   day.sec = second; // set seconds to today's seconds

   return StructToTime(day); // return user input's time as the hour, minutes, and seconds set to 0
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTime::allowTime(const bool usetimer, const string startTime, const string stopTime, datetime timeCurrent = 0)
{
   timeCurrent = timeCurrent == 0 ? TimeCurrent() : timeCurrent;
   return
      timeCurrent >= this.stringToTime(startTime, timeCurrent) &&
      timeCurrent < this.stringToTime(stopTime, timeCurrent);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTime::allowTime(const bool usetimer, const datetime startTime, const datetime stopTime, datetime timeCurrent = 0)
{
   timeCurrent = timeCurrent == 0 ? TimeCurrent() : timeCurrent;
   return !usetimer ? true : usetimer && timeCurrent >= startTime && timeCurrent <= stopTime ? true : false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CTime::changeTime(const datetime initialTime, const int incrementBy, const ENUM_TIME_INCREMENT timeChange = ENUM_MONTH)
{
   datetime newTime = initialTime;

   switch(timeChange)
   {
   case ENUM_YEAR:
      newTime = initialTime + (incrementBy * (PeriodSeconds(PERIOD_D1) * 365));
      break;

   case ENUM_MONTH:
      newTime = initialTime + (incrementBy * PeriodSeconds(PERIOD_MN1));
      break;

   case ENUM_DAY:
      newTime = initialTime + (incrementBy * PeriodSeconds(PERIOD_D1));
      break;

   case ENUM_HOUR:
      newTime = initialTime + (incrementBy * PeriodSeconds(PERIOD_H1));
      break;

   case ENUM_MINUTE:
      newTime = initialTime + (incrementBy * PeriodSeconds(PERIOD_M1));
      break;

   case ENUM_SECOND:
      newTime = initialTime + incrementBy;
      break;

   default:
      newTime = initialTime + (incrementBy * PeriodSeconds(PERIOD_M1));
      break;
   }

   return newTime;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CTime::GMT(const datetime servertime, const ushort winterOffset = 4, const ushort summerOffset = 3)
{

// Determine if the server time is during DST
   const bool isDst = (servertime >= D'2022.03.13 02:00:00' && servertime < D'2022.11.06 02:00:00') ||
                      (servertime >= D'2023.03.12 02:00:00' && servertime < D'2023.11.05 02:00:00') ||
                      (servertime >= D'2024.03.10 02:00:00' && servertime < D'2024.11.03 02:00:00');

// Convert server time to GMT based on whether it's DST or standard time
   if(isDst)
   {
      return servertime - summerOffset * 3600;
   }
   else
   {
      return servertime - winterOffset * 3600;
   }
}
//+------------------------------------------------------------------+
