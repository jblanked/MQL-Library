//+------------------------------------------------------------------+
//|                                                  JB-Backtest.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#property description "Extension of FXSaber's MTTester"

/*
   Features:
      - automatically creates .ini and .set files
      - simplifies the creation of settings
*/

// Import ShellExecuteW from shell32.dll
#import "shell32.dll"
int ShellExecuteW(int hWnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
#import

//#include <fxsaber\MultiTester\MultiTester.mqh>  auto tester
#include <fxsaber\MultiTester\MTTester.mqh> // https://www.mql5.com/ru/code/26132

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
//|                                                                  |
//+------------------------------------------------------------------+
class CBacktest
  {
protected:
   string            m_settings;
   string            s_settings;
   testerInputs      i_settings;
public:
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

      this.inputsAdded = false;
      this.s_settings = "";
      this.m_settings= "[Tester]\n" +
                       "Expert=" + expertName + "\n" +
                       "Symbol=" + symbol + "\n" +
                       "Period=" + this.timeframeSuffix(timeFrame) + "\n" +
                       "Optimization=0\n" +
                       "Model=0\n" +
                       "FromDate=2024.01.01\n" +
                       "ToDate=" + TimeToString(TimeCurrent(),TIME_DATE) + "\n" +
                       "ForwardMode=0\n" +
                       "Deposit=" + this.doubleToString(AccountInfoDouble(ACCOUNT_BALANCE)) + "\n" +
                       "Currency=" + AccountInfoString(ACCOUNT_CURRENCY) + "\n" +
                       "ProfitInPips=0\n" +
                       "Leverage=" + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)) + "\n" +
                       "ExecutionMode=27\n" +
                       "OptimizationCriterion=3\n" +
                       "Visual=0";

      this.i_settings.currency               = AccountInfoString(ACCOUNT_CURRENCY);
      this.i_settings.deposit                = AccountInfoDouble(ACCOUNT_BALANCE);
      this.i_settings.executionMode          = 27;
      this.i_settings.expertName             = expertName;
      this.i_settings.forwardMode            = 0;
      this.i_settings.fromDate               = D'2024.01.01';
      this.i_settings.leverage               = AccountInfoInteger(ACCOUNT_LEVERAGE);
      this.i_settings.model                  = 0;
      this.i_settings.optimization           = 0;
      this.i_settings.optimizationCriterion  = 3;
      this.i_settings.profitInPips           = 0;
      this.i_settings.symbol                 = symbol;
      this.i_settings.timeFrame              = timeFrame;
      this.i_settings.toDate                 = (datetime)TimeToString(TimeCurrent(),TIME_DATE);
      this.i_settings.visual                 = 0;
     }
                     CBacktest::CBacktest(const testerInputs & inputs)
     {

      this.inputsAdded = false;

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
      this.m_settings= "[Tester]\n" +
                       "Expert=" + this.i_settings.expertName + "\n" +
                       "Symbol=" + this.i_settings.symbol + "\n" +
                       "Period=" + this.timeframeSuffix(this.i_settings.timeFrame) + "\n" +
                       "Optimization=" + string(this.i_settings.optimization) + "\n" +
                       "Model=" + string(this.i_settings.model) + "\n" +
                       "FromDate=" + TimeToString(this.i_settings.fromDate,TIME_DATE) + "\n" +
                       "ToDate=" + TimeToString(this.i_settings.toDate,TIME_DATE) + "\n" +
                       "ForwardMode=" + string(this.i_settings.forwardMode) + "\n" +
                       "Deposit=" + this.doubleToString(this.i_settings.deposit) + "\n" +
                       "Currency=" + this.i_settings.currency + "\n" +
                       "ProfitInPips=" + string(this.i_settings.profitInPips) + "\n" +
                       "Leverage=" + IntegerToString(this.i_settings.leverage) + "\n" +
                       "ExecutionMode=" + string(this.i_settings.executionMode) + "\n" +
                       "OptimizationCriterion=" + string(this.i_settings.optimizationCriterion) + "\n" +
                       "Visual=" + string(this.i_settings.visual);
     }

   template <typename T>
   void              addSetting(const string inputVariable, T tempValue)
     {
      if(!this.inputsAdded)
        {
         this.m_settings += "\n[TesterInputs]";
         this.inputsAdded = true;
        }

      MTTESTER::SetValue(this.m_settings,inputVariable,(string)tempValue);
      MTTESTER::SetValue(this.s_settings,inputVariable,(string)tempValue);

     }

   bool              ask(
      const bool openFolder = false,
      const string message = "Would you like to run a backtest of your current settings? (Note: Not recommended on a VPS)",
      const string title = "Alert"
   )
     {
      if(MessageBox(message, title, MB_YESNO | MB_ICONQUESTION) == 6)
        {
         this.run(openFolder, false);
         return true;
        }
      return false;
     }

   bool              closeOtherCharts(void)
     {
      bool Res=false;
      for(long Chart = ::ChartFirst(); Chart != -1; Chart = ::ChartNext(Chart))
        {
         if(Chart != ::ChartID())
            Res |= ::ChartClose(Chart);
        }
      return Res;
     }

   string            doubleToString(const double doubleValue, const int digits=2)
     {
      const string tempDouble = string(doubleValue) + "00000000";
      const int periodLocation = StringFind(tempDouble,".");
      return StringSubstr(tempDouble,0,periodLocation) + StringSubstr(tempDouble,periodLocation,digits+1);
     }

   datetime          endDate(void)
     {
      return (MTTESTER::GetSettings(this.m_settings) ? (datetime)MTTESTER::GetValue(this.m_settings, "ToDate") : 0);
     }

   void              openFolder(void)
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

   void              run(const bool openFolder = false, const bool removeTool = false)
     {
      // set settings to be tested
      MTTESTER::SetSettings2(this.m_settings);

      // save ini and set files
      this.save();

      // run the test
      MTTESTER::ClickStart();

      // sleep after test done
      while(!MTTESTER::IsReady() && !IsStopped())
        {
         Sleep(100);
        }

      // open folder
      if(openFolder)
        {
         this.openFolder();
        }

      // remove script
      if(removeTool)
        {
         ExpertRemove();
        }

     }

   void              save(void)
     {
      this.fileHandle = FileOpen(this.iniFileName,FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
      FileWriteString(this.fileHandle,this.m_settings);
      FileClose(this.fileHandle);

      this.fileHandle = FileOpen(this.setFileName,FILE_READ | FILE_REWRITE | FILE_WRITE | FILE_COMMON | FILE_BIN);
      FileWriteString(this.fileHandle,this.s_settings);
      FileClose(this.fileHandle);
     }

   string            timeCurrent(void)
     {
      string editedTime = TimeToString(TimeCurrent(),TIME_DATE);
      StringReplace(editedTime,".","-");
      StringReplace(editedTime,":","-");
      StringReplace(editedTime," ","-");
      StringReplace(editedTime,"  ","-");
      return editedTime;
     }

   string            timeframeSuffix(const ENUM_TIMEFRAMES timeframe)
     {
      if(timeframe == PERIOD_CURRENT)
        {
         return "M30";
        }
      const string timeframeEdit = EnumToString(timeframe);
      // return last 3 characters
      return StringSubstr(timeframeEdit, StringLen(timeframeEdit)-3,StringLen(timeframeEdit)-1);
     };

private:
   int               fileHandle;
   bool              inputsAdded;
   string            iniFileName;
   string            setFileName;

   testerInputs      check(const testerInputs & inputs)
     {
      testerInputs temp;

      temp.expertName            = inputs.expertName; // cant be empty
      temp.symbol                = this.isEmpty(inputs.symbol) ? _Symbol :  inputs.symbol;
      temp.timeFrame             = this.isEmpty(inputs.timeFrame) ? PERIOD_CURRENT : inputs.timeFrame;
      temp.optimization          = this.isEmpty(inputs.optimization) ? 0 : inputs.optimization;
      temp.model                 = this.isEmpty(inputs.model) ? 0 : inputs.model;
      temp.fromDate              = this.isEmpty(inputs.fromDate) ? D'2024.01.01' : inputs.fromDate;
      temp.toDate                = this.isEmpty(inputs.toDate) ? (datetime)TimeToString(TimeCurrent(),TIME_DATE) : inputs.toDate;
      temp.forwardMode           = this.isEmpty(inputs.forwardMode) ? 0 : inputs.forwardMode;
      temp.deposit               = this.isEmpty(inputs.deposit) ? AccountInfoDouble(ACCOUNT_BALANCE) : inputs.deposit;
      temp.currency              = this.isEmpty(inputs.currency) ? AccountInfoString(ACCOUNT_CURRENCY) :  inputs.currency;
      temp.profitInPips          = this.isEmpty(inputs.profitInPips) ? 0 : inputs.profitInPips;
      temp.leverage              = this.isEmpty(inputs.leverage) ? AccountInfoInteger(ACCOUNT_LEVERAGE) : inputs.leverage;
      temp.executionMode         = this.isEmpty(inputs.executionMode) ? 27 : inputs.executionMode;
      temp.optimizationCriterion = this.isEmpty(inputs.optimizationCriterion) ? 3 : inputs.optimizationCriterion;
      temp.visual                = this.isEmpty(inputs.visual) ? 0 : inputs.visual;
      return temp;
     }

   template <typename T>
   bool              isEmpty(const T & value)
     {
      return value == NULL || (string)value == "" || (int)value == 0 || (double)value == EMPTY_VALUE;
     }

  };
//+------------------------------------------------------------------+
