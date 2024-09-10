//+------------------------------------------------------------------+
//|                                                       JB-TDI.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
//---
class CTDI
  {
public:
   //--- indicator buffers
   double            Buffer1[]; // 7 MA
   double            Buffer2[]; // 2 MA
   double            Buffer3[]; // 34 MA
   double            Buffer4[]; // Upper Band
   double            Buffer5[]; // Mid Band
   double            Buffer6[]; // Bottom Band

                     CTDI::CTDI(
      const string symbol,
      const ENUM_TIMEFRAMES timeframe,
      const int rsiPeriod = 8,
      const ENUM_APPLIED_PRICE rsiAppliedPrice = PRICE_CLOSE,
      const int maPeriod1 = 7,
      const ENUM_MA_METHOD maMethod1 = MODE_SMA,
      const int maPeriod2 = 2,
      const ENUM_MA_METHOD maMethod2 = MODE_SMA,
      const int maPeriod3 = 34,
      const ENUM_MA_METHOD maMethod3 = MODE_SMA,
      const int bandsPeriod = 34,
      const double bandsDeviation = 1.619
   )
     {
      this.m_symbol = symbol;
      this.m_timeframe = timeframe;
      this.m_rsiPeriod = rsiPeriod;
      this.m_rsiAppliedPrice = rsiAppliedPrice;
      this.m_maPeriod1 = maPeriod1;
      this.m_maMethod1 = maMethod1;
      this.m_maPeriod2 = maPeriod2;
      this.m_maMethod2 = maMethod2;
      this.m_maPeriod3 = maPeriod3;
      this.m_maMethod3 = maMethod3;
      this.m_bandsPeriod = bandsPeriod;
      this.m_bandsDeviation = bandsDeviation;

      this.init();
     }

   void              run(const int limit)
     {
      if(!this.isSetAsSeries)
        {
         this.setAsSeries(limit);
        }

#ifdef __MQL5__
      CopyBuffer(this.maHandle1, 0, 0, limit, this.Buffer1);
      CopyBuffer(this.maHandle2, 0, 0, limit, this.Buffer2);
      CopyBuffer(this.maHandle3, 0, 0, limit, this.Buffer3);
      CopyBuffer(this.bbHandle, 0, 0, limit, this.Buffer4);
      CopyBuffer(this.bbHandle, 1, 0, limit, this.Buffer5);
      CopyBuffer(this.bbHandle, 2, 0, limit, this.Buffer6);
#else
      // copy buffer mql4
      for(int r = 0; r < limit; r++)
        {
         this.maArray1[r] = ::iRSI(this.m_symbol, this.m_timeframe, this.m_rsiPeriod, this.m_rsiAppliedPrice, r); // temp rsi data
        }

      for(int cb = 0; cb < limit; cb++)
        {
         this.Buffer1[cb] = iMAOnArray(this.maArray1, 0, this.m_maPeriod1, 0, this.m_maMethod1, cb);
         this.Buffer2[cb] = iMAOnArray(this.maArray1, 0, this.m_maPeriod2, 0, this.m_maMethod2, cb);
         this.Buffer3[cb] = iMAOnArray(this.maArray1, 0, this.m_maPeriod3, 0, this.m_maMethod3, cb);
         this.Buffer4[cb] = iBandsOnArray(this.maArray1, 0, this.m_bandsPeriod, this.m_bandsDeviation, 0, MODE_UPPER, cb);
         this.Buffer5[cb] = iBandsOnArray(this.maArray1, 0, this.m_bandsPeriod, this.m_bandsDeviation, 0, MODE_MAIN, cb);
         this.Buffer6[cb] = iBandsOnArray(this.maArray1, 0, this.m_bandsPeriod, this.m_bandsDeviation, 0, MODE_LOWER, cb);
        }
#endif
     }

protected:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_rsiPeriod;
   int               m_rsiAppliedPrice;
   int               m_maPeriod1;
   ENUM_MA_METHOD    m_maMethod1;
   int               m_maPeriod2;
   ENUM_MA_METHOD    m_maMethod2;
   int               m_maPeriod3;
   ENUM_MA_METHOD    m_maMethod3;
   int               m_bandsPeriod;
   double            m_bandsDeviation;

private:
   bool              isSetAsSeries;

   //--- arrays for prices
   double            maArray1[], maArray2[], maArray3[], bbArrayUp[], bbArrayMid[], bbArrayDn[];

   //--- handles for MT5 indicator loading
   int               maHandle1, maHandle2, maHandle3, bbHandle, rsiHandle;

   void              setAsSeries(int bars)
     {
      ::ArrayInitialize(Buffer1, EMPTY_VALUE);
      ::ArrayInitialize(Buffer2, EMPTY_VALUE);
      ::ArrayInitialize(Buffer3, EMPTY_VALUE);
      ::ArrayInitialize(Buffer4, EMPTY_VALUE);
      ::ArrayInitialize(Buffer5, EMPTY_VALUE);
      ::ArrayInitialize(Buffer6, EMPTY_VALUE);

      ::ArrayInitialize(maArray1, EMPTY_VALUE);
      ::ArrayInitialize(maArray2, EMPTY_VALUE);
      ::ArrayInitialize(maArray3, EMPTY_VALUE);
      ::ArrayInitialize(bbArrayUp, EMPTY_VALUE);
      ::ArrayInitialize(bbArrayMid, EMPTY_VALUE);
      ::ArrayInitialize(bbArrayDn, EMPTY_VALUE);

      ::ArraySetAsSeries(Buffer1, true);
      ::ArraySetAsSeries(Buffer2, true);
      ::ArraySetAsSeries(Buffer3, true);
      ::ArraySetAsSeries(Buffer4, true);
      ::ArraySetAsSeries(Buffer5, true);
      ::ArraySetAsSeries(Buffer6, true);

      ::ArraySetAsSeries(maArray1, true);
      ::ArraySetAsSeries(maArray2, true);
      ::ArraySetAsSeries(maArray3, true);
      ::ArraySetAsSeries(bbArrayUp, true);
      ::ArraySetAsSeries(bbArrayMid, true);
      ::ArraySetAsSeries(bbArrayDn, true);

      ::ArrayResize(Buffer1, bars);
      ::ArrayResize(Buffer2, bars);
      ::ArrayResize(Buffer3, bars);
      ::ArrayResize(Buffer4, bars);
      ::ArrayResize(Buffer5, bars);
      ::ArrayResize(Buffer6, bars);

      ::ArrayResize(maArray1, bars);
      ::ArrayResize(maArray2, bars);
      ::ArrayResize(maArray3, bars);
      ::ArrayResize(bbArrayUp, bars);
      ::ArrayResize(bbArrayMid, bars);
      ::ArrayResize(bbArrayDn, bars);
     }

   bool              init(void)
     {
#ifdef __MQL5__
      rsiHandle = ::iRSI(this.m_symbol, this.m_timeframe, this.m_rsiPeriod, this.m_rsiAppliedPrice);
      maHandle1 = ::iMA(this.m_symbol, this.m_timeframe, this.m_maPeriod1, 0, this.m_maMethod1, this.rsiHandle);
      maHandle2 = ::iMA(this.m_symbol, this.m_timeframe, this.m_maPeriod2, 0, this.m_maMethod2, this.rsiHandle);
      maHandle3 = ::iMA(this.m_symbol, this.m_timeframe, this.m_maPeriod3, 0, this.m_maMethod3, this.rsiHandle);
      bbHandle  = ::iBands(this.m_symbol, this.m_timeframe, this.m_bandsPeriod, 0, this.m_bandsDeviation, this.rsiHandle);

      return
         this.isNotInvalid(maHandle1) && this.isNotInvalid(maHandle2) &&
         this.isNotInvalid(maHandle3) && this.isNotInvalid(bbHandle) &&
         this.isNotInvalid(rsiHandle);
#endif
      return true;
     }

   bool              isNotInvalid(int handle)
     {
      return handle != INVALID_HANDLE;
     }

  };
//+------------------------------------------------------------------+
