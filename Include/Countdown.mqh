//+------------------------------------------------------------------+
//|                                                    Countdown.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"

class CCountdown
{
   private:
   
      string time;
      datetime dif;
      int diff;
      string finalS;
      string dtD;
      string dtM;
      
      MqlDateTime tm;
      MqlDateTime now;
      MqlDateTime tmD;
   
   
   public:
   
      CCountdown::CCountdown(void) // constructor
      {
      time = "00:00:00";
      dif = 0;
      finalS = "";
      dtM = "";
      dtD = "";
      }
      
      CCountdown::~CCountdown(void) // deconstructor
      {
      time = "00:00:00";
      dif = 0;
      finalS = "";
      dtM = "";
      dtD = "";
      }
      
      string datetimeToDay(const datetime destinationTime)
      {
         TimeToStruct(destinationTime,tmD);
         
         switch(tmD.day)
         {
            case 1:
            case 21:
            case 31:
               dtD = "st";
               break;
            
            case 2:
            case 22:
               dtD = "nd";
               break;
            
            case 3:
            case 23:
               dtD = "rd";
               break;
            
            default:
               dtD = "th";
               break;
         }
         
         switch(tmD.mon)
         {
            case 1: dtM = "January"; break;
            case 2: dtM = "February"; break;
            case 3: dtM = "March"; break;
            case 4: dtM = "April"; break;
            case 5: dtM = "May"; break;
            case 6: dtM = "June"; break;
            case 7: dtM = "July"; break;
            case 8: dtM = "August"; break;
            case 9: dtM = "September"; break;
            case 10: dtM = "October"; break;
            case 11: dtM = "November"; break;
            case 12: dtM = "December"; break;
         }
         
         return dtM + " " + string(tmD.day) + dtD;
         
         
      }
   
      string timer(const datetime destinationTime)
      {
         time = "00:00:00";
         
         if(TimeCurrent()>destinationTime) return time;
         
         TimeToStruct(destinationTime,tm);
         TimeToStruct(TimeCurrent(),now);
         
         finalS = TimeToString(destinationTime-TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
         
         diff = tm.day - now.day;
         
         switch(diff)
         {
            case 0:
               time = finalS;
               break;
            
            case 1:
               if(tm.hour-now.hour<=0) time = finalS;
               else time = string(int(StringSubstr(finalS,0,2)) + (24)) + StringSubstr(finalS,2,(StringLen(finalS)-2));
               break;
            
            default:
               if(tm.hour-now.hour<=0) time = string(int(StringSubstr(finalS,0,2)) + (24*(diff-1))) + StringSubstr(finalS,2,(StringLen(finalS)-2));
               else time = string(int(StringSubstr(finalS,0,2)) + (24*diff)) + StringSubstr(finalS,2,(StringLen(finalS)-2)); 
               break;
         }
         
         return time;
      }
   
};
