#define __int64 datetime

//+------------------------------------------------------------------+
//| Структура для графика тестирования                               |
//+------------------------------------------------------------------+
struct TesterTradeState
{
//  __int64           datetime;            // текущее тестовое время
  __int64           time;                // текущее тестовое время
  double            balance;             // текущий баланс
  double            equity;              // текущий equity
  double            value;               // текущее рассчитанное значение нагрузки на депозит

#define TOSTRING(A) #A + " = " + (string)(this.A) + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(time) +                // текущее тестовое время
           TOSTRING(balance) +             // текущий баланс
           TOSTRING(equity) +              // текущий equity
           TOSTRING(value)                 // текущее рассчитанное значение нагрузки на депозит
          );
  }

#undef TOSTRING
};

#undef __int64