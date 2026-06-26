input int inAmount = 4; // Столько ищем сетов ( > 1)
input int inMinMaxTrades = 100; // Если верхняя граница количества сделок меньше этого значения - игнорим

#include <fxsaber\MultiTester\MTTester.mqh> // https://www.mql5.com/ru/code/26132
#include <fxsaber\TesterCache\TesterCache.mqh> // https://www.mql5.com/ru/code/26223

class TASK
{
private:
  static int inMinTrades; // Минимальное количество трейдов (позиций).
  static int inMaxTrades; // Максимальное количество трейдов (позиций).

  static int Count;
  static int Trades;

  static string StringBetween( string &Str, const string StrBegin, const string StrEnd = NULL )
  {
    string Res = NULL;
    int PosBegin = ::StringFind(Str, StrBegin);

    if ((PosBegin >= 0) || (StrBegin == NULL))
    {
      PosBegin = (PosBegin >= 0) ? PosBegin + ::StringLen(StrBegin) : 0;

      const int PosEnd = ::StringFind(Str, StrEnd, PosBegin);

      if (PosEnd != PosBegin)
        Res = ::StringSubstr(Str, PosBegin, (PosEnd >= 0) ? PosEnd - PosBegin : -1);

      Str = (PosEnd >= 0) ? ::StringSubstr(Str, PosEnd + ::StringLen(StrEnd)) : NULL;

      if (Str == "")
        Str = NULL;
    }

    return((Res == "") ? NULL : Res);
  }

  template <typename T>
  static bool CheckInput( const string Name, T &Value )
  {
    string Str;

    bool Res = MTTESTER::GetSettings(Str);

    if (Res)
    {
      Str = StringBetween(Str, "[TesterInputs]\r\n");

      if (Res = (::StringFind(Str, Name) >= 0))
        Value = (T)TASK::StringBetween(Str, Name + "=", "\r\n");
      else
        ::Alert("input " + Name + " - not found!");
    }

    return(Res);
  }

  static bool CheckInputsMinMax( const bool Replace = false )
  {
    int Value;
    bool Res = Replace ? TASK::CheckInput("inMinTrades", TASK::inMinTrades) && TASK::CheckInput("inMaxTrades", TASK::inMaxTrades)
                       : TASK::CheckInput("inMinTrades", Value) && TASK::CheckInput("inMaxTrades", Value);

    if (Res && ((inMaxTrades <= inMinTrades) || (inMaxTrades < ::inMinMaxTrades)))
    {
    #define TOSTRING(A) #A + " = " + (string)(A)
      ::Alert(TOSTRING(inMinTrades));

      ::Alert(TOSTRING(inMaxTrades));
    #undef TOSTRING

      Res = false;
    }

    return(Res);
  }

  template <typename T>
  static int GetMaxFitnessPos( const TESTERCACHE<T> &Cache )
  {
    int Pos = 0;
    double MaxFitness = -DBL_MAX;

    for (int i = Cache.GetAmount() - 1; i >= 0; i--)
      if (Cache[i].TesterStatistics(STAT_CUSTOM_ONTESTER) > MaxFitness)
      {
        MaxFitness = Cache[i].TesterStatistics(STAT_CUSTOM_ONTESTER);

        Pos = i;
      }

    return(Pos);
  }

  template <typename T>
  static string GetPath( const TESTERCACHE<T> &Cache )
  {
    return(__FILE__ + "\\" + Cache.Header.expert_name[] + "\\" +
           ::TimeToString(Cache.Header.date_from, TIME_DATE) + "-" +
           ::TimeToString(Cache.Header.date_to, TIME_DATE) + "\\" + Cache.Header.symbol[] + "\\");
  }

  static void GetInterval( int &Begin, int &End, const int iTrades, int Num, const int Amount = 4,
                           const double MinOpen = 0.5, const double MaxOpen = 1.1,
                           const double StepKoef = 0.8, const double MaxKoef = 3 )
  {
    const double Step = (MaxOpen - MinOpen) / (Amount - 1);
    const double Tmp = (MinOpen + Num * Step) * iTrades;

    Begin = (int)Tmp;
    End = (int)((Num < Amount - 1) ? Tmp + StepKoef * Step * iTrades : iTrades * MaxKoef);

    if (Num > Amount)
      Alert("Error!!!");

    return;
  }

  // Выключает Оптимизацию ( и одиночный проход)
  static bool OptimizationStop( void )
  {
    return(!MTTESTER::IsReady() && MTTESTER::ClickStart(false));
  }

public:
  TASK()
  {
    if (!TASK::CheckInputsMinMax(true) || (::inAmount <= 1))
    {
    #define TOSTRING(A) #A + " = " + (string)(A)
      ::Alert(TOSTRING(inAmount));

      ::Alert(TOSTRING(inMinMaxTrades));
    #undef TOSTRING

      ::ExpertRemove();
    }
    else
      MTTESTER::SetSettings2("[Tester]\n" +
                             "Optimization=2\n" +
                             "ForwardMode=0\n" +
                             "OptimizationCriterion=6");
  }

  ~TASK()
  {
    TASK::OptimizationStop();

    if (MTTESTER::IsReady())
    {
      const string Str ="[Tester]\n" +
                        "Optimization=0\n" +
                        "[TesterInputs]" +
                        "\ninMinTrades=" + (string)TASK::inMinTrades +
                        "\ninMaxTrades=" + (string)TASK::inMaxTrades;

      MTTESTER::SetSettings2(Str);
    }
  }

  static bool InitBase( void )
  {
    TASK::Count = 0;
    TASK::Trades = 0;

    ::Print("Base Optimization... " + MTTESTER::GetSymbolName());

    const bool Res = TASK::CheckInputsMinMax();

    if (Res)
    {
      const string Str = "[TesterInputs]" +
                         "\ninMinTrades=" + (string)TASK::inMinTrades +
                         "\ninMaxTrades=" + (string)TASK::inMaxTrades;

      MTTESTER::SetSettings2(Str);
      ::Print(Str);
    }

    return(Res);
  }

  static bool DeinitBase( void )
  {
    uchar Bytes[];
    TESTERCACHE<ExpTradeSummary> Cache;         // Стандартная оптимизация

    const bool Res = MTTESTER::GetLastOptCache(Bytes) && Cache.Load(Bytes);

    if (Res)
    {
      ::Print(Cache.Header.ToString()); // Вывели основные данные оптимизационного кеша.

      const int Pos = TASK::GetMaxFitnessPos(Cache);
      ::Print(Cache[Pos].ToString());

      Cache.SaveSet(Pos, TASK::GetPath(Cache) + "Base.set");
      Cache.Save(TASK::GetPath(Cache) + "Base.opt");

      TASK::Trades = (int)Cache[Pos].TesterStatistics(STAT_TRADES);
    }
    else
      ::Alert(__FUNCSIG__ + ": MTTESTER::GetLastOptCache(Bytes) && Cache.Load(Bytes) = false");

    return(Res);
  }

  static bool InitSub( void )
  {
    ::Print("Sub Optimizaton " + (string)++TASK::Count + "... " + MTTESTER::GetSymbolName());

    bool Res = (TASK::Trades >= ::inMinMaxTrades);

    if (Res)
    {
      int Begin, End;

      TASK::GetInterval(Begin, End, TASK::Trades, TASK::Count - 1, ::inAmount);

      if (Res = ((End >= ::inMinMaxTrades) && (Begin < End)))
      {
        const string Str = "[TesterInputs]" +
                           "\ninMinTrades=" + (string)Begin +
                           "\ninMaxTrades=" + (string)End;

        MTTESTER::SetSettings2(Str);
        ::Print(Str);
      }
    }

    return(Res);
  }

  static bool DeinitSub( void )
  {
    uchar Bytes[];
    TESTERCACHE<ExpTradeSummary> Cache;         // Стандартная оптимизация

    const bool Res = MTTESTER::GetLastOptCache(Bytes) && Cache.Load(Bytes);

    if (Res)
    {
      const int Pos = TASK::GetMaxFitnessPos(Cache);
      ::Print(Cache[Pos].ToString());

      Cache.SaveSet(Pos, TASK::GetPath(Cache) + (string)TASK::Count + ".set");
      Cache.Save(TASK::GetPath(Cache) + (string)TASK::Count + ".opt");
    }
    else
      ::Alert(__FUNCSIG__ + ": MTTESTER::GetLastOptCache(Bytes) && Cache.Load(Bytes) = false");

    const string Str = "[TesterInputs]" +
                       "\ninMinTrades=" + (string)TASK::inMinTrades +
                       "\ninMaxTrades=" + (string)TASK::inMaxTrades;

    MTTESTER::SetSettings2(Str); // Нужно восстановить исходные значения к моменту, когда все закончится.

    return(Res);
  }
};

static int TASK::inMinTrades = 0; // Минимальное количество трейдов (позиций).
static int TASK::inMaxTrades = 0; // Максимальное количество трейдов (позиций).

static int TASK::Count = 0;
static int TASK::Trades = 0;

TASK Task; // https://www.mql5.com/ru/forum/170952/page148#comment_13878583