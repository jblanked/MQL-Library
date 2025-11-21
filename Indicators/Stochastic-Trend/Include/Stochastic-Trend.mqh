//+------------------------------------------------------------------+
//|                                             Stochastic-Trend.mqh |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property strict
//---enums
enum ENUM_STO_LINE
{
   ENUM_MAIN_LINE = 0,   // Main Line
   ENUM_SIGNAL_LINE = 1, // Signal Line
};
//+------------------------------------------------------------------+
//| Class for the Stochatic Trend strategy                           |
//+------------------------------------------------------------------+
class CStochasticTrend
{
public:
   double bufferStochM[]; // 0
   double bufferStochS[]; // 1
   double bufferBuy[];    // 2
   double bufferSell[];   // 3
   double bufferMaFast[]; // 4
   double bufferMaSlow[]; // 5
   //
   CStochasticTrend(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT,
      const double buyLevel = 15.00,
      const double sellLevel = 85.00,
      const int maPeriodFast = 21,
      const int maPeriodSlow = 53,
      const int stochKPeriod = 14,
      const int stochDPeriod = 3,
      const int stochSPeriod = 3,
      const bool priceFilter = true
   );
   ~CStochasticTrend();
   bool memcpy(const int buffer_index, double&buffer[]);
   void run(const int count);
   bool set();
   int signal(const int index);
protected:
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   double m_buy_level;
   double m_sell_level;
   bool m_price_filter;
private:
   int CopyBuffer(int indicator_handle, int buffer_num, int start_pos, int count, double&double_array[], string indicator_name);
   bool fill(const int count);
   bool isEmpty(double val);
   int tradingSignal(const int shift);
   //
   int handleStochastic;
   int handleEMAFast;
   int handleEMASlow;
   //
   int stochPeriodK;
   int stochPeriodD;
   int stochPeriodS;
   int fastMaPeriod;
   int slowMaPeriod;
   //
   bool isSetAsSeries;
   bool isResized;
   //
   MqlRates rates[];
};
//+------------------------------------------------------------------+
//| Initialize the class                                             |
//+------------------------------------------------------------------+
CStochasticTrend::CStochasticTrend(
   const string symbol,
   const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT,
   const double buyLevel = 15.00,
   const double sellLevel = 85.00,
   const int maPeriodFast = 21,
   const int maPeriodSlow = 53,
   const int stochKPeriod = 14,
   const int stochDPeriod = 3,
   const int stochSPeriod = 3,
   const bool priceFilter = true)
   :
   m_symbol(symbol), m_timeframe(timeframe),
   m_buy_level(buyLevel), m_sell_level(sellLevel),
   stochPeriodK(stochKPeriod), stochPeriodD(stochDPeriod), stochPeriodS(stochSPeriod),
   fastMaPeriod(maPeriodFast), slowMaPeriod(maPeriodSlow),
   m_price_filter(priceFilter)

{
   if(!this.set())
   {
      ::Print("Failed to setup required indicators");
      return;
   }
   else
   {
      // set defaults
      this.isSetAsSeries   = false;
   }
}
//+------------------------------------------------------------------+
//| De-initialize the class
//+------------------------------------------------------------------+
CStochasticTrend::~CStochasticTrend()
{

}
//+------------------------------------------------------------------+
//| MQL4 + MQL5 CopyBuffer implementation                            |
//+------------------------------------------------------------------+
int CStochasticTrend::CopyBuffer(int indicator_handle, int buffer_num, int start_pos, int count, double&double_array[], string indicator_name)
{
#ifdef __MQL5__
   return ::CopyBuffer(indicator_handle, buffer_num, start_pos, count, double_array);
#else
   const bool isStochasticM = ::StringFind(indicator_name, "Main") != -1;
   const bool isStochasticS = ::StringFind(indicator_name, "Sig")  != -1;
   const bool isMaFast      = ::StringFind(indicator_name, "Fast") != -1;
   const bool isMaSlow      = ::StringFind(indicator_name, "Slow") != -1;
   ::ArraySetAsSeries(double_array, true);
   int check = start_pos;
   int index = 0;
   while(check < count)
   {
      if(isStochasticM)
      {
         double_array[index] = ::iStochastic(this.m_symbol, this.m_timeframe, this.stochPeriodK, this.stochPeriodD, this.stochPeriodS, MODE_EMA, STO_CLOSECLOSE, ENUM_MAIN_LINE, check);
      }
      else if(isStochasticS)
      {
         double_array[index] = ::iStochastic(this.m_symbol, this.m_timeframe, this.stochPeriodK, this.stochPeriodD, this.stochPeriodS, MODE_EMA, STO_CLOSECLOSE, ENUM_SIGNAL_LINE, check);
      }
      else if(isMaFast)
      {
         double_array[index] = ::iMA(this.m_symbol, this.m_timeframe, this.fastMaPeriod, 0, MODE_EMA, PRICE_CLOSE, check);
      }
      else
      {
         double_array[index] = ::iMA(this.m_symbol, this.m_timeframe, this.slowMaPeriod, 0, MODE_EMA, PRICE_CLOSE, check);
      }
      check++;
      index++;
   }
   return check;
#endif
}
//+------------------------------------------------------------------+
//| Fill the buffers with indicator data                             |
//+------------------------------------------------------------------+
bool CStochasticTrend::fill(const int count)
{
   if(this.CopyBuffer(this.handleEMAFast, 0, 0, count, this.bufferMaFast, "Fast EMA") != count)
   {
      ::Print("Failed to fetch fast moving average indicator values");
      return false;
   }
   if(this.CopyBuffer(this.handleEMASlow, 0, 0, count, this.bufferMaSlow, "Slow EMA") != count)
   {
      ::Print("Failed to fetch slow moving average indicator values");
      return false;
   }
   if(this.CopyBuffer(this.handleStochastic, ENUM_MAIN_LINE, 0, count, this.bufferStochM, "Stochastic Main") != count)
   {
      ::Print("Failed to fetch stochastic main line indicator values");
      return false;
   }
   if(this.CopyBuffer(this.handleStochastic, ENUM_SIGNAL_LINE, 0, count, this.bufferStochS, "Stochastic Signal") != count)
   {
      ::Print("Failed to fetch stochastic signal line indicator values");
      return false;
   }
   ArraySetAsSeries(this.rates, true);
   return ::CopyRates(this.m_symbol, this.m_timeframe, 0, count, this.rates) == count;
}
//+------------------------------------------------------------------+
//| returns true if the value is empty or 0                          |
//+------------------------------------------------------------------+
bool CStochasticTrend::isEmpty(double val)
{
   return val == EMPTY_VALUE || val == 0;
}
//+------------------------------------------------------------------+
//| Copy indicator data to a buffer                                  |
//+------------------------------------------------------------------+
bool CStochasticTrend::memcpy(const int buffer_index, double&buffer[])
{
   switch(buffer_index)
   {
   case 0:
      return ArrayCopy(buffer, this.bufferStochM, 0, 0, WHOLE_ARRAY) != -1;
   case 1:
      return ArrayCopy(buffer, this.bufferStochS, 0, 0, WHOLE_ARRAY) != -1;
   case 2:
      return ArrayCopy(buffer, this.bufferBuy, 0, 0, WHOLE_ARRAY) != -1;
   case 3:
      return ArrayCopy(buffer, this.bufferSell, 0, 0, WHOLE_ARRAY) != -1;
   case 4:
      return ArrayCopy(buffer, this.bufferMaFast, 0, 0, WHOLE_ARRAY) != -1;
   case 5:
      return ArrayCopy(buffer, this.bufferMaSlow, 0, 0, WHOLE_ARRAY) != -1;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Run the algorithm                                                |
//+------------------------------------------------------------------+
void CStochasticTrend::run(const int count)
{
   if(!this.isSetAsSeries)
   {
      ::ArraySetAsSeries(this.bufferMaFast, true);
      ::ArraySetAsSeries(this.bufferMaSlow, true);
      ::ArraySetAsSeries(this.bufferStochM, true);
      ::ArraySetAsSeries(this.bufferStochS, true);
      ::ArraySetAsSeries(this.bufferBuy, true);
      ::ArraySetAsSeries(this.bufferSell, true);
      ::ArraySetAsSeries(this.rates, true);
      this.isSetAsSeries = true;
   }
   if(!this.isResized)
   {
      ::ArrayResize(this.bufferMaFast, count + 3);
      ::ArrayResize(this.bufferMaSlow, count + 3);
      ::ArrayResize(this.bufferStochM, count + 3);
      ::ArrayResize(this.bufferStochS, count + 3);
      ::ArrayResize(this.bufferBuy, count + 3);
      ::ArrayResize(this.bufferSell, count + 3);
      this.isResized = true;
   }

   this.fill(count + 3);
   int i = count;
   const int maxBars = ::Bars(this.m_symbol, this.m_timeframe);
   const int arrSize = ::ArraySize(this.bufferMaFast);
   while(i >= 0)
   {
      if(i + 2 >= maxBars || i + 2 >= arrSize - 1)
      {
         i--;
         continue;
      }

      this.bufferBuy[i] = EMPTY_VALUE;
      this.bufferSell[i] = EMPTY_VALUE;
      this.bufferBuy[i + 1] = EMPTY_VALUE;
      this.bufferSell[i + 1] = EMPTY_VALUE;

      switch(tradingSignal(i + 1))
      {
      case 1:
         this.bufferBuy[i + 1] = this.rates[i + 1].low;
         break;
      case -1:
         this.bufferSell[i + 1] = this.rates[i + 1].high;
         break;
      };

      i--;
   }
}
//+------------------------------------------------------------------+
//| Set indicator handles                                            |
//+------------------------------------------------------------------+
bool CStochasticTrend::set()
{
   ::TesterHideIndicators(true);
//--- configure
#ifdef __MQL5__
   this.handleStochastic = ::iStochastic(this.m_symbol, this.m_timeframe, this.stochPeriodK, this.stochPeriodD, this.stochPeriodS, MODE_EMA, STO_CLOSECLOSE);
   this.handleEMAFast    = ::iMA(this.m_symbol, this.m_timeframe, this.fastMaPeriod, 0, MODE_EMA, PRICE_CLOSE);
   this.handleEMASlow    = ::iMA(this.m_symbol, this.m_timeframe, this.slowMaPeriod, 0, MODE_EMA, PRICE_CLOSE);
//--- check
   if(this.handleStochastic == INVALID_HANDLE)
   {
      ::Alert("Failed to acquire Stochastic indicator");
      return false;
   }
   if(this.handleEMAFast == INVALID_HANDLE || this.handleEMASlow == INVALID_HANDLE)
   {
      ::Alert("Failed to acquire Moving Average indicator");
      return false;
   }
#endif
   return true;
}
//+------------------------------------------------------------------+
//| Return 1 for bullish, -1 for bearish, 0 for neutral: call run 1st|
//+------------------------------------------------------------------+
int CStochasticTrend::signal(const int index)
{
   return
      ArraySize(this.bufferBuy) > index && !this.isEmpty(this.bufferBuy[index]) ? 1 :
      ArraySize(this.bufferSell) > index && !this.isEmpty(this.bufferSell[index]) ? -1 :
      0;
}
//+------------------------------------------------------------------+
//| Check if there's a trading signal                                |
//+------------------------------------------------------------------+
int CStochasticTrend::tradingSignal(const int shift)
{
   if(ArraySize(this.bufferStochM) < shift + 2) return 0;
   if(ArraySize(this.bufferStochS) < shift + 2) return 0;
   if(ArraySize(this.bufferMaFast) < shift + 1) return 0;
   if(ArraySize(this.bufferMaSlow) < shift + 1) return 0;
   if(ArraySize(this.rates) < shift + 1) return 0;
   return
      this.bufferMaFast[shift] > this.bufferMaSlow[shift] &&
      this.bufferStochS[shift] < this.m_buy_level && this.bufferStochS[shift + 1] < this.m_buy_level &&
      this.bufferStochM[shift] < this.m_buy_level && this.bufferStochM[shift + 1] < this.m_buy_level &&
      this.bufferStochS[shift + 1] < this.bufferStochM[shift + 1] && this.bufferStochS[shift] > this.bufferStochM[shift] &&
      (!this.m_price_filter || this.rates[shift].close > this.bufferMaFast[shift])
      ?
      1
      :
      this.bufferMaFast[shift] < this.bufferMaSlow[shift] &&
      this.bufferStochS[shift] > this.m_sell_level && this.bufferStochS[shift + 1] > this.m_sell_level &&
      this.bufferStochM[shift] > this.m_sell_level && this.bufferStochM[shift + 1] > this.m_sell_level &&
      this.bufferStochS[shift + 1] > this.bufferStochM[shift + 1] && this.bufferStochS[shift] < this.bufferStochM[shift] &&
      (!this.m_price_filter || this.rates[shift].close < this.bufferMaFast[shift])
      ?
      -1
      :
      0;
}
//+------------------------------------------------------------------+
