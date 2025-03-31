//+------------------------------------------------------------------+
//|                                                    JB-ZigZag.mqh |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property description "Modification of the infamous ZigZag indicator, optimized by JBlanked"
#property strict
class CZigZag
{
public:
   double            ZigZagBuffer[];
   double            HH[], LH[], HL[], LL[];
   //
                     CZigZag(
      string symbol,
      ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT,
      bool draw = false,
      int depth = 5,
      int deviation = 0,
      int backstep = 0,
      int max_count = 500,
      int recount = 50
   ) :               m_symbol(symbol), m_timeframe(timeframe), m_depth(depth),
                     m_deviation(deviation), m_backstep(backstep), m_max_count(max_count),
                     m_recount(recount), m_draw(draw), is_set(false),
                     tag("CZigZag(" + string(depth) + "," + string(deviation) + "," + string(backstep) + ")")
   {
      // nothing to do for now
   };

                    ~CZigZag()
   {
      if(this.m_draw) ObjectsDeleteAll(0, this.tag);
   }

   void              run(int limit);
protected:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_depth;
   int               m_deviation;
   int               m_backstep;
   int               m_max_count;
   int               m_recount;
   bool              m_draw;
private:
   double            HighMapBuffer[];
   double            LowMapBuffer[];
   double            previousHigh;
   double            previousLow;
   bool              is_set;
   int               arr_size;
   string            tag;
   //
   void              drawLabel(int shift, bool high);
   bool              objectSetText(string name, string text, int font_size, string font = "", color text_color = clrNONE);
   void              removeLabel(int shift);
   void              set_as_series();
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZigZag::drawLabel(int shift, bool high)
{
   string status = "";

   if(high)
   {
      double currentHigh = HighMapBuffer[shift];

//--- find the previous high
      for (int i = shift + 1; i < shift + this.m_max_count; i++)
      {
         if(i >= arr_size) continue;
         if (HighMapBuffer[i] != EMPTY_VALUE && ZigZagBuffer[i] != EMPTY_VALUE)
         {
            previousHigh = HighMapBuffer[i];
            break;
         }
      }

      double position = HighMapBuffer[shift] + (2 * Point());

      if(this.m_draw) ObjectCreate(0, tag + (string)iTime(this.m_symbol, this.m_timeframe, shift), OBJ_TEXT, 0, iTime(this.m_symbol, this.m_timeframe, shift), position);

      if(currentHigh > previousHigh)
      {
         HH[shift] = iHigh(this.m_symbol, this.m_timeframe, shift);
         if(this.m_draw) this.objectSetText(tag + (string)iTime(this.m_symbol, this.m_timeframe, shift), "HH  ", 7, "Arial Black", clrYellow);
      }
      else if(currentHigh < previousHigh)
      {
         LH[shift] = iHigh(this.m_symbol, this.m_timeframe, shift);
         if(this.m_draw) this.objectSetText(tag + (string)iTime(this.m_symbol, this.m_timeframe, shift), "LH  ", 6, "Arial Black", clrLime);
      }
      else
      {
         HH[shift] = EMPTY_VALUE;
         LH[shift] = EMPTY_VALUE;
      }
   }
   else
   {
      double currentLow = LowMapBuffer[shift];

//--- find the previous Low
      for (int i = shift + 1; i < shift + this.m_max_count; i++)
      {
         if(i >= arr_size) continue;
         if (LowMapBuffer[i] != EMPTY_VALUE && ZigZagBuffer[i] != EMPTY_VALUE)
         {
            previousLow = LowMapBuffer[i];
            break;
         }
      }

      double position = LowMapBuffer[shift] - (2 / 2 * Point());

      if(this.m_draw) ObjectCreate(0, tag + (string)iTime(this.m_symbol, this.m_timeframe, shift), OBJ_TEXT, 0, iTime(this.m_symbol, this.m_timeframe, shift), position);

      if(currentLow > previousLow)
      {
         HL[shift] = iLow(this.m_symbol, this.m_timeframe, shift);
         if(this.m_draw) this.objectSetText(tag + (string)iTime(this.m_symbol, this.m_timeframe, shift), "HL  ", 6, "Arial Black", clrRed);
      }
      else if(currentLow < previousLow)
      {
         LL[shift] = iLow(this.m_symbol, this.m_timeframe, shift);
         if(this.m_draw) this.objectSetText(tag + (string)iTime(this.m_symbol, this.m_timeframe, shift), "LL  ", 7, "Arial Black", clrYellow);
      }
      else
      {
         HL[shift] = EMPTY_VALUE;
         LL[shift] = EMPTY_VALUE;
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZigZag::objectSetText(string name, string text, int font_size, string font = "", color text_color = clrNONE)
{
   int tmpObjType = (int)ObjectGetInteger(0, name, OBJPROP_TYPE);
   if(tmpObjType != OBJ_LABEL && tmpObjType != OBJ_TEXT) return(false);
   if(StringLen(text) > 0 && font_size > 0)
   {
      if(ObjectSetString(0, name, OBJPROP_TEXT, text) && ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size))
      {
         if((StringLen(font) > 0) && ObjectSetString(0, name, OBJPROP_FONT, font) == false) return(false);
         if(ObjectSetInteger(0, name, OBJPROP_COLOR, text_color) == false) return(false);
         return(true);
      }
   }
   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZigZag::removeLabel(int shift)
{
   HH[shift] = EMPTY_VALUE;
   HL[shift] = EMPTY_VALUE;
   LH[shift] = EMPTY_VALUE;
   LL[shift] = EMPTY_VALUE;
   if(this.m_draw) ObjectDelete(0, tag + (string)iTime(this.m_symbol, this.m_timeframe, shift));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZigZag::run(int limit)
{
   if(!this.is_set) this.set_as_series();

   if((limit - 1) >= this.arr_size) return;

//--- refresh values
   for (int i = (this.m_max_count - 1); i >= 0; i--)
   {
      if(i >= this.arr_size) continue;
      ZigZagBuffer[i] = EMPTY_VALUE;
      HH[i]           = EMPTY_VALUE;
      LH[i]           = EMPTY_VALUE;
      HL[i]           = EMPTY_VALUE;
      LL[i]           = EMPTY_VALUE;
   }

// Temporary variables for tracking extremes.
   double lastlow = EMPTY_VALUE, lasthigh = EMPTY_VALUE;
   int lastlowpos = 0, lasthighpos = 0;
   double curlow = EMPTY_VALUE, curhigh = EMPTY_VALUE;
   int whatlookfor = 0; // 0: initial; 1: looking for trough (low); -1: looking for peak (high)
   double val, res;
   int back;

// --- Recalculate the map buffers using original extreme-value logic.
   for(int shift = limit - 1; shift >= 0; shift--)
   {
      if(shift >= this.arr_size) continue;
      // LOW processing using iLow() and iLowest()
      val = iLow(this.m_symbol, this.m_timeframe, iLowest(this.m_symbol, this.m_timeframe, MODE_LOW, this.m_depth, shift));
      if(val == lastlow)
         val = EMPTY_VALUE;
      else
      {
         lastlow = val;
         if((iLow(this.m_symbol, this.m_timeframe, shift) - val) > (this.m_deviation * Point()))
            val = EMPTY_VALUE;
         else
         {
            for(back = 1; back <= this.m_backstep; back++)
            {
               if(shift + back >= this.arr_size) continue;
               res = LowMapBuffer[shift + back];
               if((res != EMPTY_VALUE) && (res > val))
                  LowMapBuffer[shift + back] = EMPTY_VALUE;
            }
         }
      }
      if(iLow(this.m_symbol, this.m_timeframe, shift) == val)
         LowMapBuffer[shift] = val;
      else
         LowMapBuffer[shift] = EMPTY_VALUE;

      // HIGH processing using iHigh() and iHighest()
      val = iHigh(this.m_symbol, this.m_timeframe, iHighest(this.m_symbol, this.m_timeframe, MODE_HIGH, this.m_depth, shift));
      if(val == lasthigh)
         val = EMPTY_VALUE;
      else
      {
         lasthigh = val;
         if((val - iHigh(this.m_symbol, this.m_timeframe, shift)) > (this.m_deviation * Point()))
            val = EMPTY_VALUE;
         else
         {
            for(back = 1; back <= this.m_backstep; back++)
            {
               if(shift + back >= this.arr_size) continue;
               res = HighMapBuffer[shift + back];
               if((res != EMPTY_VALUE) && (res < val))
                  HighMapBuffer[shift + back] = EMPTY_VALUE;
            }
         }
      }
      if(iHigh(this.m_symbol, this.m_timeframe, shift) == val)
         HighMapBuffer[shift] = val;
      else
         HighMapBuffer[shift] = EMPTY_VALUE;
   }

// --- Establish initial condition for final zigzag processing.
   if(LowMapBuffer[limit] != EMPTY_VALUE)
   {
      curlow = LowMapBuffer[limit];
      whatlookfor = 1;
   }
   else if(HighMapBuffer[limit] != EMPTY_VALUE)
   {
      curhigh = HighMapBuffer[limit];
      whatlookfor = -1;
   }
   else
   {
      // If both buffers are empty at 'limit', scan upward.
      for(int shift = limit; shift >= 0; shift--)
      {
         if(shift >= this.arr_size) continue;
         if(LowMapBuffer[shift] != EMPTY_VALUE)
         {
            curlow = LowMapBuffer[shift];
            whatlookfor = 1;
            break;
         }
         if(HighMapBuffer[shift] != EMPTY_VALUE)
         {
            curhigh = HighMapBuffer[shift];
            whatlookfor = -1;
            break;
         }
      }
   }

// --- Final zigzag "cutting" and label drawing loop (original logic preserved, using EMPTY_VALUE).
   for(int shift = limit - 1; shift >= 0; shift--)
   {
      if(shift >= this.arr_size) continue;
      res = EMPTY_VALUE;
      switch(whatlookfor)
      {
      case 0: // Initial state: choose the first valid point.
         if(lastlow == EMPTY_VALUE && lasthigh == EMPTY_VALUE)
         {
            if(HighMapBuffer[shift] != EMPTY_VALUE)
            {
               lasthigh = iHigh(this.m_symbol, this.m_timeframe, shift);
               lasthighpos = shift;
               whatlookfor = -1;
               ZigZagBuffer[shift] = lasthigh;
               this.drawLabel(shift, true);
               res = lasthigh;
            }
            if(LowMapBuffer[shift] != EMPTY_VALUE)
            {
               lastlow = iLow(this.m_symbol, this.m_timeframe, shift);
               lastlowpos = shift;
               whatlookfor = 1;
               ZigZagBuffer[shift] = lastlow;
               this.drawLabel(shift, false);
               res = lastlow;
            }
         }
         break;

      case 1: // Looking for a trough (low): check for a lower low.
         if(LowMapBuffer[shift] != EMPTY_VALUE && LowMapBuffer[shift] < lastlow && HighMapBuffer[shift] == EMPTY_VALUE)
         {
            ZigZagBuffer[lastlowpos] = EMPTY_VALUE;
            this.removeLabel(lastlowpos);
            lastlowpos = shift;
            lastlow = LowMapBuffer[shift];
            ZigZagBuffer[shift] = lastlow;
            this.drawLabel(shift, false);
            res = lastlow;
         }
         if(HighMapBuffer[shift] != EMPTY_VALUE && LowMapBuffer[shift] == EMPTY_VALUE)
         {
            lasthigh = HighMapBuffer[shift];
            lasthighpos = shift;
            ZigZagBuffer[shift] = lasthigh;
            this.drawLabel(shift, true);
            whatlookfor = -1;
            res = lasthigh;
         }
         break;

      case -1: // Looking for a peak (high): check for a higher high.
         if(HighMapBuffer[shift] != EMPTY_VALUE && HighMapBuffer[shift] > lasthigh && LowMapBuffer[shift] == EMPTY_VALUE)
         {
            ZigZagBuffer[lasthighpos] = EMPTY_VALUE;
            this.removeLabel(lasthighpos);
            lasthighpos = shift;
            lasthigh = HighMapBuffer[shift];
            ZigZagBuffer[shift] = lasthigh;
            this.drawLabel(shift, true);
            res = lasthigh;
         }
         if(LowMapBuffer[shift] != EMPTY_VALUE && HighMapBuffer[shift] == EMPTY_VALUE)
         {
            lastlow = LowMapBuffer[shift];
            lastlowpos = shift;
            ZigZagBuffer[shift] = lastlow;
            this.drawLabel(shift, false);
            whatlookfor = 1;
            res = lastlow;
         }
         break;
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZigZag::set_as_series(void)
{
   const int maxi = MathMin(Bars(this.m_symbol, this.m_timeframe) - this.m_depth, this.m_max_count) + 3;

   ArrayInitialize(ZigZagBuffer, EMPTY_VALUE);
   ArrayInitialize(HH, EMPTY_VALUE);
   ArrayInitialize(LH, EMPTY_VALUE);
   ArrayInitialize(HL, EMPTY_VALUE);
   ArrayInitialize(LL, EMPTY_VALUE);
   ArrayInitialize(HighMapBuffer, EMPTY_VALUE);
   ArrayInitialize(LowMapBuffer, EMPTY_VALUE);

   ArraySetAsSeries(ZigZagBuffer, true);
   ArraySetAsSeries(HH, true);
   ArraySetAsSeries(LH, true);
   ArraySetAsSeries(HL, true);
   ArraySetAsSeries(LL, true);
   ArraySetAsSeries(HighMapBuffer, true);
   ArraySetAsSeries(LowMapBuffer, true);

   arr_size = ArrayResize(ZigZagBuffer, maxi);
   ArrayResize(HH, maxi);
   ArrayResize(LH, maxi);
   ArrayResize(HL, maxi);
   ArrayResize(LL, maxi);
   ArrayResize(HighMapBuffer, maxi);
   ArrayResize(LowMapBuffer, maxi);

   this.is_set = arr_size != -1;
}
//+------------------------------------------------------------------+
