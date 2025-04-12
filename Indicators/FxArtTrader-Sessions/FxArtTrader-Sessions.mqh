//+------------------------------------------------------------------+
//|                                         FxArtTrader-Sessions.mqh |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
//---- definitions
#define TAG "FxArtTraderSessions"
//---- includes
#include <chart-draw.mqh>   // from https://github.com/jblanked/MQL-Library/blob/main/Include/Chart-Draw.mqh
#include <jb-zigzag.mqh>    // from https://github.com/jblanked/MQL-Library/tree/main/Indicators/ZigZag-HH-LL
//---- enums
enum ENUM_FX_ART_SESSION
{
   NewYork,
   London,
   Asian,
   NewYork2,
   LondonLunch
};
enum ENUM_FX_ART_ZIGZAG_LABEL
{
   HH,
   HL,
   LL,
   LH
};
enum ENUM_FX_ART_TREND
{
   Bullish,
   Bearish,
   Neutral
};
//---- structs
struct FX_ART_SESSION_TIME
{
   string            asianOpen;          // Asian
   string            asianEnd;           // Asian
   string            londonOpen;         // London
   string            londonEnd;          // London
   string            newYork1Open;       // New York AM
   string            newYork1End;        // New York AM
   string            newYork2Open;       // New York PM or London Close
   string            newYork2End;        // New York PM or London Close
   string            londonLunchOpen;    // London Lunch Start
   string            londonLunchEnd;     // London Lunch End
};
struct FX_ART_PATTERN
{
   ENUM_FX_ART_ZIGZAG_LABEL labels[5];  // holds the last 5 zigzag labels
   int                      candles[5]; // holds the last 5 zigzag candles
   double                   prices[5];  // holds the last 5 zigzag prices (HH,ll,etc)
   ENUM_FX_ART_TREND        trend;      // holds the trend of the current pattern
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFxArtTradeSession
{
public:
   double buy[], sell[]; // Buffers
   ~CFxArtTradeSession()
   {
      if(CheckPointer(this.zz) == POINTER_DYNAMIC)
      {
         delete this.zz;
         this.zz = NULL;
      }
   }
   CFxArtTradeSession(
      string symbol,
      ENUM_TIMEFRAMES timeframe,
      int   depth         = 5,                 // Depth
      int   deviation     = 0,                 // Deviation
      int   backstep      = 0,                 // Backstep
      int   candleLimit   = 5000,              // Candle Limit
      bool  drawOnChart   = false,             // Allow Drawing?
      color asianColor    = clrLightSteelBlue, // Asian Zone Color
      color londonColor   = clrLightGreen,     // London Zone Color
      color london2Color  = clrGoldenrod,      // London Lunch Zone Color
      color newYorkColor  = clrLightBlue,      // New York 1 Color
      color newYork2Color = clrCoral           // New York 2 Color
   ) :   m_symbol(symbol), m_timeframe(timeframe),
      m_deviation(deviation), m_backstep(backstep),
      m_limit(MathMax(candleLimit, Bars(symbol, timeframe))),
      m_drawOnChart(drawOnChart), m_asianColor(asianColor),
      m_londonColor(londonColor), m_london2Color(london2Color),
      m_newYorkColor(newYorkColor), m_newYork2Color(newYork2Color),
      asianTrend(Neutral), forexPair(isForexPair())
   {
      zz = new CZigZag(symbol, timeframe, drawOnChart, depth, deviation, backstep, this.m_limit, 3);
      qm.trend = Neutral;
      if(forexPair) // Forex
      {
         kz.asianOpen       = "03:00"; // 20:00 EST - Asian
         kz.asianEnd        = "07:00"; // 00:00 EST
         kz.londonOpen      = "09:00"; // 02:00 EST - London
         kz.londonEnd       = "12:00"; // 05:00 EST
         kz.londonLunchOpen = "12:00"; // 05:00 EST - London Lunch
         kz.londonLunchEnd  = "14:00"; // 07:00 EST
         kz.newYork1Open    = "14:00"; // 07:00 EST - New York AM
         kz.newYork1End     = "17:00"; // 10:00 EST
         kz.newYork2Open    = "17:00"; // 10:00 EST - London Close
         kz.newYork2End     = "19:00"; // 12:00 EST
      }
      else // Indices
      {
         kz.asianOpen       = "03:00"; // 20:00 EST - Asian
         kz.asianEnd        = "07:00"; // 00:00 EST
         kz.londonOpen      = "09:00"; // 02:00 EST - London
         kz.londonEnd       = "12:00"; // 05:00 EST
         kz.londonLunchOpen = "12:00"; // 05:00 EST - London Lunch
         kz.londonLunchEnd  = "14:00"; // 07:00 EST
         kz.newYork1Open    = "15:30"; // 08:30 EST - New York AM
         kz.newYork1End     = "18:00"; // 11:00 EST
         kz.newYork2Open    = "20:30"; // 13:30 EST - New York PM
         kz.newYork2End     = "23:00"; // 16:00 EST
      }
   }
   void run(int limit);
protected:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_depth;
   int               m_deviation;
   int               m_backstep;
   int               m_limit;
   CZigZag           *zigzag;
private:
   bool                 m_drawOnChart;
   color                m_asianColor;
   color                m_londonColor;
   color                m_london2Color;
   color                m_newYorkColor;
   color                m_newYork2Color;
   bool                 is_set;
   bool                 forexPair;
   FX_ART_SESSION_TIME  kz; // Session struct
   FX_ART_PATTERN       qm; // Pattern struct
   CZigZag              *zz; // from jb-zigzag
   ENUM_FX_ART_TREND    asianTrend;
   //
   void                 set();
   bool                 isForexPair();
   void                 getSessionHighLow(datetime sessionStart, datetime sessionEnd, double &sessionHigh, double &sessionLow);
   void                 drawAsianLevels(datetime open, double low, datetime end, double high, string str_addon);
   void                 drawText(CChartDraw &draw, string tag, string text, datetime time, double price, bool shift);
   void                 drawSession(ENUM_FX_ART_SESSION session, datetime time1, double price1, datetime time2, double price2, string str_addon, datetime today);
};
//+------------------------------------------------------------------+
//| run: processes the OnCalculate (main) logic                      |
//+------------------------------------------------------------------+
void CFxArtTradeSession::run(int limit)
{
   if(!this.is_set) set();
   zz.run(limit);
   const datetime today = iTime(this.m_symbol, PERIOD_D1, 0);
   string last_processed_day = ""; // Track daily sessions already processed
   int daily_shift = 0;
   datetime current, asian_open, asian_end, london_open, london_end, ny_open, ny_end, ny_open_2, ny_end_2, lunch_open, lunch_end;
   string daily_str;
   double price1, price2, asian_low, asian_high;
   const int arr_size = ArraySize(zz.HH);
   int shift;
   bool broke_today = false;

// Process each candle from oldest (limit-1) to most recent (0)
   for(int x = limit - 1; x >= 0; x--)
   {
      current = iTime(this.m_symbol, this.m_timeframe, x);

      // Reset pattern for current outer candle
      shift = 0;
      // Build the pattern by scanning forward from the current candle
      for (int i = x; i < limit && shift < 5; i++)
      {
         if(i >= arr_size)
            continue;

         if(zz.HH[i] != EMPTY_VALUE)
         {
            qm.labels[shift]  = HH;
            qm.candles[shift] = i;
            qm.prices[shift]  = zz.HH[i];
            shift++;
            continue;
         }
         else if(zz.HL[i] != EMPTY_VALUE)
         {
            qm.labels[shift]  = HL;
            qm.candles[shift] = i;
            qm.prices[shift]  = zz.HL[i];
            shift++;
            continue;
         }
         else if(zz.LL[i] != EMPTY_VALUE)
         {
            qm.labels[shift]  = LL;
            qm.candles[shift] = i;
            qm.prices[shift]  = zz.LL[i];
            shift++;
            continue;
         }
         else if(zz.LH[i] != EMPTY_VALUE)
         {
            qm.labels[shift]  = LH;
            qm.candles[shift] = i;
            qm.prices[shift]  = zz.LH[i];
            shift++;
            continue;
         }
      }

      // Only determine trend if exactly 5 pattern points have been found
      qm.trend = Neutral;
      if(shift == 5)
      {
         if(qm.labels[0] == HL &&
               qm.labels[1] == HH &&
               qm.labels[2] == LL &&
               (qm.labels[3] == HH || qm.labels[3] == LH) &&
               (qm.labels[4] == HL || qm.labels[4] == LL)
           )
            qm.trend = Bullish;
         else if(qm.labels[0] == LH &&
                 qm.labels[1] == LL &&
                 qm.labels[2] == HH &&
                 (qm.labels[3] == HL || qm.labels[3] == LL) &&
                 (qm.labels[4] == LH || qm.labels[4] == HH)
                )
            qm.trend = Bearish;
      }

      // Determine daily bar shift and set up session boundaries
      daily_shift = iBarShift(this.m_symbol, PERIOD_D1, current);
      if(daily_shift < 0) continue;

      daily_str = TimeToString(iTime(this.m_symbol, PERIOD_D1, daily_shift), TIME_DATE);
      asian_open  = StringToTime(daily_str + " " + kz.asianOpen);
      asian_end   = StringToTime(daily_str + " " + kz.asianEnd);
      this.getSessionHighLow(asian_open, asian_end, price1, price2);
      if(price1 > price2)
      {
         asian_low  = price2;
         asian_high = price1;
      }
      else
      {
         asian_low  = price1;
         asian_high = price2;
      }

      // Trend operations: check for Asian session break after London Open
      if(!broke_today && current >= StringToTime(daily_str + " " + kz.londonOpen))
      {
         const double high_price = iHigh(this.m_symbol, this.m_timeframe, x + 1);
         const double low_price  = iLow(this.m_symbol, this.m_timeframe, x + 1);
         if(high_price > asian_high)
         {
            broke_today = true;
            asianTrend = Bearish;
         }
         else if(low_price < asian_low)
         {
            broke_today = true;
            asianTrend = Bullish;
         }
      }
      if(current < StringToTime(daily_str + " " + kz.londonOpen))
      {
         broke_today = false;
         asianTrend = Neutral;
      }

      // Arrow operations:
      // Draw arrow only if we have a complete pattern and the relative candle shift is valid (greater than 0)
      if(asianTrend == Bullish && qm.trend == Bullish && shift == 5 && qm.prices[2] < asian_low) // middle must be lower than asian low
      {
         if(qm.candles[0] > 0) // Prevent negative index
         {
            const int candle = qm.candles[0] - 1;
            buy[candle] = iLow(this.m_symbol, this.m_timeframe, candle);
         }
      }
      if(asianTrend == Bearish && qm.trend == Bearish && shift == 5 && qm.prices[2] > asian_high) // middle must be higher than asian high
      {
         if(qm.candles[0] > 0)
         {
            const int candle = qm.candles[0] - 1;
            sell[candle] = iHigh(this.m_symbol, this.m_timeframe, candle);
         }
      }

      // Process each day only once (except today) for handling sessions
      if(x > 0 && daily_str == last_processed_day) continue;
      last_processed_day = daily_str;

      // Define additional session boundaries and draw session zones
      london_open = StringToTime(daily_str + " " + kz.londonOpen);
      london_end  = StringToTime(daily_str + " " + kz.londonEnd);
      ny_open     = StringToTime(daily_str + " " + kz.newYork1Open);
      ny_end      = StringToTime(daily_str + " " + kz.newYork1End);
      ny_open_2   = StringToTime(daily_str + " " + kz.newYork2Open);
      ny_end_2    = StringToTime(daily_str + " " + kz.newYork2End);
      lunch_open  = StringToTime(daily_str + " " + kz.londonLunchOpen);
      lunch_end   = StringToTime(daily_str + " " + kz.londonLunchEnd);

      this.drawSession(Asian, asian_open, price1, asian_end, price2, daily_str, today);
      this.drawAsianLevels(asian_open, asian_low, StringToTime(daily_str + " " + "23:50"), asian_high, daily_str);
      this.getSessionHighLow(london_open, london_end, price1, price2);
      this.drawSession(London, london_open, price1, london_end, price2, daily_str, today);
      this.getSessionHighLow(lunch_open, lunch_end, price1, price2);
      this.drawSession(LondonLunch, lunch_open, price1, lunch_end, price2, daily_str, today);
      this.getSessionHighLow(ny_open, ny_end, price1, price2);
      this.drawSession(NewYork, ny_open, price1, ny_end, price2, daily_str, today);
      this.getSessionHighLow(ny_open_2, ny_end_2, price1, price2);
      this.drawSession(NewYork2, ny_open_2, price1, ny_end_2, price2, daily_str, today);
   }
}
//+------------------------------------------------------------------+
//| set: initializes the arrays                                      |
//+------------------------------------------------------------------+
void CFxArtTradeSession::set(void)
{
   ArrayInitialize(buy, EMPTY_VALUE);
   ArrayInitialize(sell, EMPTY_VALUE);
   ArraySetAsSeries(buy, true);
   ArraySetAsSeries(sell, true);
   ArrayResize(buy, this.m_limit + 1);
   ArrayResize(sell, this.m_limit + 1);
   this.is_set = true;
}
//+------------------------------------------------------------------+
//| returns true if "vs" is within the symbol's description          |
//+------------------------------------------------------------------+
bool CFxArtTradeSession::isForexPair()
{
// e.g. Euro vs US Dollar
   return StringFind(SymbolInfoString(this.m_symbol, SYMBOL_DESCRIPTION), "vs") != -1;
}
//+------------------------------------------------------------------+
//| Get session high and low from M1 timeframe                       |
//+------------------------------------------------------------------+
void CFxArtTradeSession::getSessionHighLow(datetime sessionStart, datetime sessionEnd, double &sessionHigh, double &sessionLow)
{
   int shift1 = iBarShift(this.m_symbol, PERIOD_M1, sessionStart);
   int shift2 = iBarShift(this.m_symbol, PERIOD_M1, sessionEnd);
   if(shift1 < 0)
      shift1 = 0;
   if(shift2 < 0)
      shift2 = 0;

// Determine the proper range regardless of the order of sessionStart and sessionEnd
   int start = MathMin(shift1, shift2); // use the more recent bar as the start
   int count = MathAbs(shift1 - shift2) + 1;

// If for some reason count is non-positive, use the single bar value
   if(count <= 0)
   {
      sessionHigh = iHigh(this.m_symbol, PERIOD_M1, shift1);
      sessionLow  = iLow(this.m_symbol, PERIOD_M1, shift1);
      return;
   }

   int highestIndex = iHighest(this.m_symbol, PERIOD_M1, MODE_HIGH, count, start);
   int lowestIndex  = iLowest(this.m_symbol, PERIOD_M1, MODE_LOW, count, start);
   sessionHigh = iHigh(this.m_symbol, PERIOD_M1, highestIndex);
   sessionLow  = iLow(this.m_symbol, PERIOD_M1, lowestIndex);
}
//+------------------------------------------------------------------+
//| plots asian low/high                                             |
//+------------------------------------------------------------------+
void CFxArtTradeSession::drawAsianLevels(datetime open, double low, datetime end, double high, string str_addon)
{
   CChartDraw draw; // from Chart-Draw.mqh
   const string tag = TAG + str_addon;
   draw.Chart_Trend_Line(tag + "asianHighLevel", open, high, end, high, 2, this.m_asianColor);
   draw.Chart_Trend_Line(tag + "asianLowLevel", open, low, end, low, 2, this.m_asianColor);
}
//+------------------------------------------------------------------+
//| Draw text                                                        |
//+------------------------------------------------------------------+
void CFxArtTradeSession::drawText(CChartDraw &draw, string tag, string text, datetime time, double price, bool shift)
{
   draw.ChartText(tag, text, "Arial", 8, clrWhite, time, price, shift ? ANCHOR_LEFT_LOWER : ANCHOR_LOWER);
}
//+------------------------------------------------------------------+
//| Draw session function                                            |
//+------------------------------------------------------------------+
void CFxArtTradeSession::drawSession(ENUM_FX_ART_SESSION session, datetime time1, double price1, datetime time2, double price2, string str_addon, datetime today)
{
   CChartDraw draw; // from Chart-Draw.mqh
   const string tag = TAG + str_addon;
   const bool title_shift = time2 > today;
   const datetime time_mid = title_shift ? time1 : (time1 + time2) / 2;
   const double price = MathMax(price1, price2);
   switch(session)
   {
   case Asian:
      drawText(draw, tag + "_AsianText_", "Asian", time_mid, price, title_shift);
      draw.Chart_Zone(tag + "_AsianZone_", time1, price1, time2, price2, this.m_asianColor, 1);
      break;
   case London:
      drawText(draw, tag + "_LondonText_", "London", time_mid, price, title_shift);
      draw.Chart_Zone(tag + "_LondonZone_", time1, price1, time2, price2, this.m_londonColor, 1);
      break;
   case NewYork:
      drawText(draw, tag + "_NewYorkText_", "New York AM", time_mid, price, title_shift);
      draw.Chart_Zone(tag + "_NewYorkZone_", time1, price1, time2, price2, this.m_newYorkColor, 1);
      break;
   case NewYork2:
      drawText(draw, tag + "_NewYork2Text_", forexPair ? "London Close" : "New York PM", time_mid, price, title_shift);
      draw.Chart_Zone(tag + "_NewYork2Zone_", time1, price1, time2, price2, this.m_newYork2Color, 1);
      break;
   case LondonLunch:
      drawText(draw, tag + "_LondonLunchText_", "London Lunch", time_mid, price, title_shift);
      draw.Chart_Zone(tag + "_LondonLunchZone_", time1, price1, time2, price2, this.m_london2Color, 1);
      break;
   }
}
//+------------------------------------------------------------------+
