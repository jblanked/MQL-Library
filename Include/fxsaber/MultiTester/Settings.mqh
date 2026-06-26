#include "MTTester.mqh"
#include "String.mqh"

struct SETTINGS
{
private:
  static string ToString( const datetime time )
  {
    return(" " + (time ? ::TimeToString(time, TIME_DATE) : "TesterDate"));
  }

public:
  STRING128 ExpertName;
  STRING32 Symb;
  ENUM_TIMEFRAMES period;
  datetime BeginTime;
  datetime EndTime;

  void Set( const string sExpertName = NULL,
            const string sSymb = NULL,
            const ENUM_TIMEFRAMES ePeriod = PERIOD_CURRENT,
            const datetime dBeginTime = 0,
            const datetime dEndTime = 0 )
  {
    this.ExpertName = sExpertName;
    this.Symb = sSymb;
    this.period = ((ePeriod == PERIOD_CURRENT) ? ::_Period : ePeriod);

    this.BeginTime = dBeginTime;
    this.EndTime = dEndTime;

    return;
  }

  bool Run( const bool CloseNotChart = true ) const
  {
    if (CloseNotChart)
      MTTESTER::CloseNotChart();

    return(MTTESTER::Run(this.ExpertName[], this.Symb[], this.period, this.BeginTime, this.EndTime));
  }

  string ToString( void ) const
  {
    return(((this.ExpertName[] == NULL) ? "TesterExpertName" : this.ExpertName[]) + " " +
           ((this.Symb[] ==  NULL) ? "TesterSymbolName" : this.Symb[]) + " " +
           ::EnumToString(this.period) +
           SETTINGS::ToString(this.BeginTime) + " - " + SETTINGS::ToString(this.EndTime));
  }
};