#include "TesterSettings.mqh"

TESTER_SETTINGS TesterSettings;

bool IsRun( void )
{
  const long Chart_ID = ChartID();
  const string Name = ChartGetString(Chart_ID, CHART_EXPERT_NAME);

  bool Res = false;

  for (long chartID = ChartFirst();
       (chartID != -1) && !((chartID != Chart_ID) && (Res = (ChartGetString(chartID, CHART_EXPERT_NAME) == Name)));
       chartID = ChartNext(chartID))
    ;

  return(Res);
}

int OnInit()
{
  bool Res = IsStopped() || MQLInfoInteger(MQL_TESTER) || IsRun() || !EventSetTimer(1);

  if (!Res)
  {
    if (TesterSettings.GetSize())
    {
      const string Str = "Проверьте даты интервала тестирования!!!\\n\n" +
                         "С предыдущего запуска осталось незавершенных заданий - " + (string)TesterSettings.GetSize() + "\n" +
                         TesterSettings.ToString(0) + "\n...\n" + TesterSettings.ToString(TesterSettings.GetSize() - 1) + "\n" +
                         "Продолжить с момента прерывания (YES),\nначать новое задание (NO),\nвыйти (CANCEL)?";

      switch(MessageBox(Str, __FILE__, MB_YESNOCANCEL))
      {
      case IDNO:
        TesterSettings.Free();

        SetTesterSettings();

        break;
      case IDCANCEL:
        TesterSettings.Free();

        break;
      }
    }
    else
      SetTesterSettings();

    if (!(Res = !TesterSettings.GetSize()))
      OnTimer();
  }

  return(Res ? INIT_FAILED : INIT_SUCCEEDED);
}

string LengthToString( const datetime Length )
{
  const int Days = (int)(Length / (24 * 3600));

  return(((Days) ? (string)Days + "d ": "") + ::TimeToString(Length, TIME_SECONDS));
}

#define MACROS_TIME (" Time = " + LengthToString(TimeLocal() - StartTime))

void OnTimer()
{
  static const int Size = TesterSettings.GetSize();
  static bool IsRun = false;
  static int Pos = 0;
  static datetime StartTime = 0;
  static bool Init = false;
  static int Attempts = 0;
  static int Errors = 0;

  if (!Size || IsStopped())
  {
    EventKillTimer();
    ExpertRemove();
  }
  else if (MTTESTER::IsReady())
  {
    if (IsRun)
    {
      TesterSettings.Deinit(Pos - 1);

      Alert(TesterSettings.ToString(Pos - 1) + " - Done." + MACROS_TIME);
      Attempts = 0;

      if (Pos == Size)
      {
        TesterSettings.Finish();
        Alert("Finish." + (Errors ? " Errors = " + (string)Errors: NULL));

//        EventKillTimer(); // https://www.mql5.com/ru/forum/324536/page39#comment_13990833
          ExpertRemove();
      }
      else if (IsRun = (Init = TesterSettings.Init(Pos)) && TesterSettings.Run(Pos))
      {
        Alert(TesterSettings.ToString(Pos++) + " - Start.");

        StartTime = TimeLocal();
      }
      else
      {
        Errors++;
        Attempts++;
        Comment("Waiting " + TesterSettings.ToString(Pos) + "... - Error (" + (string)Attempts + ").");
        Alert("Waiting " + TesterSettings.ToString(Pos) + "... - Error (" + (string)Attempts + ").");

        if (!Init && (++Pos == Size))
        {
          TesterSettings.Finish();
          Alert("Finish." + (Errors ? " Errors = " + (string)Errors: NULL));

//          EventKillTimer(); // https://www.mql5.com/ru/forum/324536/page39#comment_13990833
          ExpertRemove();
        }
      }
    }
    else if (IsRun = (Init || (Init = TesterSettings.Init(Pos))) && TesterSettings.Run(Pos))
    {
      Alert(TesterSettings.ToString(Pos++) + " - Start.");

      StartTime = TimeLocal();
    }
    else
    {
      Errors++;
      Attempts++;
      Comment("Waiting " + TesterSettings.ToString(Pos) + "... - Error (" + (string)Attempts + ").");
      Alert("Waiting " + TesterSettings.ToString(Pos) + "... - Error (" + (string)Attempts + ").");

      if (IsRun = (Attempts >= 5)) // Если достигили предела неудачных попыток, переключаемся на следующее задание.
        Pos++;

      if (!Init && (++Pos == Size))
      {
        TesterSettings.Finish();
        Alert("Finish." + (Errors ? " Errors = " + (string)Errors: NULL));

//          EventKillTimer(); // https://www.mql5.com/ru/forum/324536/page39#comment_13990833
        ExpertRemove();
      }
    }
  }
  else
    Comment("Waiting " + (Pos ? TesterSettings.ToString(Pos - 1) + "..." + MACROS_TIME : "Tester...") +
            "\nNext Step: " + (Pos < Size ? TesterSettings.ToString(Pos) : "Finish"));
}

#undef MACROS_TIME

void OnDeinit( const int Reason )
{
  Comment("");

  // https://www.mql5.com/ru/forum/170952/page169#comment_15531309
  if (Reason == REASON_CLOSE)
    MessageBox("Terminal is being closed!");
}

// Чтобы исключить случайное написание этих функций.
void OnTick() {}
void OnBookEvent( const string& ) {}
void OnChartEvent( const int, const long&, const double&, const string& ) {}