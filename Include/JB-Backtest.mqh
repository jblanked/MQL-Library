//+------------------------------------------------------------------+
//|                                                  JB-Backtest.mqh |
//|                                     Copyright 2024-2026,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2026,JBlanked"
#property link      "https://www.jblanked.com/"
#property description "Extension of FXSaber's MTTester"
#property strict

#include "fxsaber\MultiTester\MTTester.mqh"                // https://www.mql5.com/ru/code/26132
#include "fxsaber\SingleTesterCache\SingleTesterCache.mqh" // https://www.mql5.com/ru/code/27611

#import "shell32.dll"
int ShellExecuteW(int hWnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

/*
   Features:
      - automatically creates .ini and .set files
      - simplifies the creation of settings
      - returns results
*/

struct testerInputs
{
   string            expertName;
   string            symbol;
   ENUM_TIMEFRAMES   timeFrame;
   int               optimization;
   int               model;
   datetime          fromDate;
   datetime          toDate;
   int               forwardMode;
   double            deposit;
   string            currency;
   int               profitInPips;
   long              leverage;
   int               executionMode;
   int               optimizationCriterion;
   int               visual;
};

//+------------------------------------------------------------------+
//| Backtest class                                                   |
//+------------------------------------------------------------------+
class CBacktest
{
protected:
   string            m_settings;
   string            s_settings;
   testerInputs      i_settings;

public:
   CBacktest(const string expertName, const string symbol, const ENUM_TIMEFRAMES timeFrame);
   CBacktest(const testerInputs & inputs);

   template <typename T>
   void              addSetting(const string inputVariable, T tempValue);
   bool              ask(
      const bool openFolder = false,
      const string message = "Would you like to run a backtest of your current settings? (Note: Not recommended on a VPS)",
      const string title = "Alert"
   );
   bool              closeOtherCharts(void);
   string            doubleToString(const double doubleValue, const int digits = 2);
   datetime          endDate(void);
   datetime          monthCurrent(void);
   void              openFolder(void);
   string            run(const bool openFolder = false, const bool removeTool = false);
   void              save(void);
   string            timeCurrent(void);
   string            timeframeSuffix(const ENUM_TIMEFRAMES timeframe);

private:
   int               fileHandle;
   string            iniFileName;
   string            setFileName;

   testerInputs      check(const testerInputs & inputs);
   template <typename T>
   bool              isEmpty(const T & value);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBacktest::CBacktest(const string expertName, const string symbol, const ENUM_TIMEFRAMES timeFrame)
{

   this.iniFileName = "backtest\\" + expertName + "-" +
                      symbol + "-" +
                      this.timeframeSuffix(timeFrame) + "-" +
                      this.timeCurrent() +
                      ".ini";

   this.setFileName = "backtest\\" + expertName + "-" +
                      symbol + "-" +
                      this.timeframeSuffix(timeFrame) + "-" +
                      this.timeCurrent() +
                      ".set";

   this.s_settings = "";
   this.m_settings = "[Tester]\n" +
                     "Expert=" + expertName + "\n" +
                     "Symbol=" + symbol + "\n" +
                     "Period=" + this.timeframeSuffix(timeFrame) + "\n" +
                     "Optimization=0\n" +
                     "Model=0\n" + // 0 — "Every tick", 1 — "1 minute OHLC", 2 — "Open price only", 3 — "Math calculations", 4 — "Every tick based on real ticks"
                     "FromDate=" + TimeToString(this.monthCurrent(), TIME_DATE) + "\n" +
                     "ToDate=" + TimeToString(TimeCurrent(), TIME_DATE) + "\n" +
                     "ForwardMode=0\n" +
                     "Deposit=" + this.doubleToString(AccountInfoDouble(ACCOUNT_BALANCE)) + "\n" +
                     "Currency=" + AccountInfoString(ACCOUNT_CURRENCY) + "\n" +
                     "ProfitInPips=0\n" +
                     "Leverage=" + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)) + "\n" +
                     "ExecutionMode=27\n" +
                     "OptimizationCriterion=3\n" +
                     "Visual=0\n";

   this.i_settings.currency               = AccountInfoString(ACCOUNT_CURRENCY);
   this.i_settings.deposit                = AccountInfoDouble(ACCOUNT_BALANCE);
   this.i_settings.executionMode          = 27;
   this.i_settings.expertName             = expertName;
   this.i_settings.forwardMode            = false;
   this.i_settings.fromDate               = this.monthCurrent();
   this.i_settings.leverage               = AccountInfoInteger(ACCOUNT_LEVERAGE);
   this.i_settings.model                  = 0;
   this.i_settings.optimization           = false;
   this.i_settings.optimizationCriterion  = 3;
   this.i_settings.profitInPips           = false;
   this.i_settings.symbol                 = symbol;
   this.i_settings.timeFrame              = timeFrame;
   this.i_settings.toDate                 = (datetime)TimeToString(TimeCurrent(), TIME_DATE);
   this.i_settings.visual                 = false;
}

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBacktest::CBacktest(const testerInputs & inputs)
{
   this.i_settings = this.check(inputs);

   this.iniFileName = "backtest\\" + i_settings.expertName + "-" +
                      i_settings.symbol + "-" +
                      this.timeframeSuffix(i_settings.timeFrame) + "-" +
                      this.timeCurrent() +
                      ".ini";

   this.setFileName = "backtest\\" + i_settings.expertName + "-" +
                      i_settings.symbol + "-" +
                      this.timeframeSuffix(i_settings.timeFrame) + "-" +
                      this.timeCurrent() +
                      ".set";

   this.s_settings = "";
   this.m_settings = "[Tester]\n" +
                     "Expert=" + this.i_settings.expertName + "\n" +
                     "Symbol=" + this.i_settings.symbol + "\n" +
                     "Period=" + this.timeframeSuffix(this.i_settings.timeFrame) + "\n" +
                     "Optimization=" + string(this.i_settings.optimization) + "\n" +
                     "Model=" + string(this.i_settings.model) + "\n" +
                     "FromDate=" + TimeToString(this.i_settings.fromDate, TIME_DATE) + "\n" +
                     "ToDate=" + TimeToString(this.i_settings.toDate, TIME_DATE) + "\n" +
                     "ForwardMode=" + string(this.i_settings.forwardMode) + "\n" +
                     "Deposit=" + this.doubleToString(this.i_settings.deposit) + "\n" +
                     "Currency=" + this.i_settings.currency + "\n" +
                     "ProfitInPips=" + string(this.i_settings.profitInPips) + "\n" +
                     "Leverage=" + IntegerToString(this.i_settings.leverage) + "\n" +
                     "ExecutionMode=" + string(this.i_settings.executionMode) + "\n" +
                     "OptimizationCriterion=" + string(this.i_settings.optimizationCriterion) + "\n" +
                     "Visual=" + string(this.i_settings.visual) + "\n";
}

//+------------------------------------------------------------------+
//| Add an input to the testing config                               |
//+------------------------------------------------------------------+
template <typename T>
void              CBacktest::addSetting(const string inputVariable, T tempValue)
{
   static bool inputsAdded = false;
   if(inputsAdded)
   {
      this.m_settings += "\n[TesterInputs]";
      inputsAdded = true;
   }

   MTTESTER::SetValue(this.m_settings, inputVariable, (string)tempValue);
   MTTESTER::SetValue(this.s_settings, inputVariable, (string)tempValue);
}

//+------------------------------------------------------------------+
//| Ask the user if they want to backtest, and backtest if so        |
//+------------------------------------------------------------------+
bool              CBacktest::ask(
   const bool openFolder = false,
   const string message = "Would you like to run a backtest of your current settings? (Note: Not recommended on a VPS)",
   const string title = "Alert"
)
{
   if(MessageBox(message, title, MB_YESNO | MB_ICONQUESTION) == 6)
   {
      Print(this.run(openFolder, false));
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Get fully set testerInputs struct                                |
//+------------------------------------------------------------------+
testerInputs      CBacktest::check(const testerInputs & inputs)
{
   testerInputs temp;

   temp.expertName            = inputs.expertName; // cant be empty
   temp.symbol                = this.isEmpty(inputs.symbol) ? _Symbol :  inputs.symbol;
   temp.timeFrame             = this.isEmpty(inputs.timeFrame) ? PERIOD_CURRENT : inputs.timeFrame;
   temp.optimization          = this.isEmpty(inputs.optimization) ? false : inputs.optimization;
   temp.model                 = this.isEmpty(inputs.model) ? 0 : inputs.model;
   temp.fromDate              = this.isEmpty(inputs.fromDate) ? this.monthCurrent() : inputs.fromDate;
   temp.toDate                = this.isEmpty(inputs.toDate) ? (datetime)TimeToString(TimeCurrent(), TIME_DATE) : inputs.toDate;
   temp.forwardMode           = this.isEmpty(inputs.forwardMode) ? false : inputs.forwardMode;
   temp.deposit               = this.isEmpty(inputs.deposit) ? AccountInfoDouble(ACCOUNT_BALANCE) : inputs.deposit;
   temp.currency              = this.isEmpty(inputs.currency) ? AccountInfoString(ACCOUNT_CURRENCY) :  inputs.currency;
   temp.profitInPips          = this.isEmpty(inputs.profitInPips) ? false : inputs.profitInPips;
   temp.leverage              = this.isEmpty(inputs.leverage) ? AccountInfoInteger(ACCOUNT_LEVERAGE) : inputs.leverage;
   temp.executionMode         = this.isEmpty(inputs.executionMode) ? 27 : inputs.executionMode;
   temp.optimizationCriterion = this.isEmpty(inputs.optimizationCriterion) ? 3 : inputs.optimizationCriterion;
   temp.visual                = this.isEmpty(inputs.visual) ? false : inputs.visual;
   return temp;
}

//+------------------------------------------------------------------+
//| Close all charts except the current                              |
//+------------------------------------------------------------------+
bool              CBacktest::closeOtherCharts(void)
{
   bool Res = false;
   for(long Chart = ::ChartFirst(); Chart != -1; Chart = ::ChartNext(Chart))
   {
      if(Chart != ::ChartID())
         Res |= ::ChartClose(Chart);
   }
   return Res;
}

//+------------------------------------------------------------------+
//| Convert a double to string                                       |
//+------------------------------------------------------------------+
string            CBacktest::doubleToString(const double doubleValue, const int digits = 2)
{
   const string tempDouble = string(doubleValue) + "00000000";
   const int periodLocation = StringFind(tempDouble, ".");
   return StringSubstr(tempDouble, 0, periodLocation) + StringSubstr(tempDouble, periodLocation, digits + 1);
}

//+------------------------------------------------------------------+
//| Get the end date from the strategy tester                        |
//+------------------------------------------------------------------+
datetime          CBacktest::endDate(void)
{
   return (MTTESTER::GetSettings(this.m_settings) ? (datetime)MTTESTER::GetValue(this.m_settings, "ToDate") : 0);
}

//+------------------------------------------------------------------+
//| Get the date of the current month                                |
//+------------------------------------------------------------------+
datetime          CBacktest::monthCurrent(void)
{
   return iTime(_Symbol, PERIOD_MN1, 0);
}

//+------------------------------------------------------------------+
//| Check if a value is empty                                        |
//+------------------------------------------------------------------+
template <typename T>
bool              CBacktest::isEmpty(const T & value)
{
   return value == NULL || (string)value == "" || (int)value == 0 || (double)value == EMPTY_VALUE;
}

//+------------------------------------------------------------------+
//| Open a folder                                                    |
//+------------------------------------------------------------------+
void              CBacktest::openFolder(void)
{
   ShellExecuteW(
      0,
      "open",
      "cmd.exe",
      "/c start " + TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + "backtest",
      NULL,
      0
   );
}

//+------------------------------------------------------------------+
//| Run strategy tester and return the results                       |
//+------------------------------------------------------------------+
string              CBacktest::run(const bool openFolder = false, const bool removeTool = false)
{
   MTTESTER::SetSettings2(this.m_settings);
   this.save();
   MTTESTER::ClickStart();

   while(!MTTESTER::IsReady() && !IsStopped())
   {
      Sleep(100);
   }

   uchar Bytes2[];
   string res = "";
   if (MTTESTER::GetLastTstCache(Bytes2) != -1) // If it was possible to read the last cache record of a single run
   {
      const SINGLETESTERCACHE SingleTesterCache(Bytes2); // Drive it into the corresponding object.

      const string FileName = "Report.htm";
      uchar Array[];
      res = SingleTesterCache.Summary.ToString();
      if (!(StringToCharArray(res, Array) > 0) || !FileSave(FileName, Array))
      {
         Print("Failed to save report to " + TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + FileName);
      }
   }

   if(openFolder)
   {
      this.openFolder();
   }

   if(removeTool)
   {
      ExpertRemove();
   }

   return res;
}

//+------------------------------------------------------------------+
//| Save the .ini/.set settings based on current set                 |
//+------------------------------------------------------------------+
void              CBacktest::save(void)
{
   this.fileHandle = FileOpen(this.iniFileName, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
   FileWriteString(this.fileHandle, this.m_settings);
   FileClose(this.fileHandle);

   this.fileHandle = FileOpen(this.setFileName, FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
   FileWriteString(this.fileHandle, this.s_settings);
   FileClose(this.fileHandle);
}

//+------------------------------------------------------------------+
//| Get the current time as a string                                 |
//+------------------------------------------------------------------+
string            CBacktest::timeCurrent(void)
{
   string editedTime = TimeToString(TimeCurrent(), TIME_DATE);
   StringReplace(editedTime, ".", "-");
   StringReplace(editedTime, ":", "-");
   StringReplace(editedTime, " ", "-");
   StringReplace(editedTime, "  ", "-");
   return editedTime;
}

//+------------------------------------------------------------------+
//| Get the suffix of a timeframe                                    |
//+------------------------------------------------------------------+
string            CBacktest::timeframeSuffix(const ENUM_TIMEFRAMES timeframe)
{
   const string timeframeEdit = EnumToString(timeframe);
// return last 3 characters
   return StringSubstr(timeframeEdit, StringLen(timeframeEdit) - 3, StringLen(timeframeEdit) - 1);
}
//+------------------------------------------------------------------+
