#include "String.mqh"
#include "ExpTradeSummary.mqh"

//+------------------------------------------------------------------+
//| запись оптимизации по символам                                   |
//+------------------------------------------------------------------+
struct TestCacheSymbolRecord : public ExpTradeSummary
{
//  wchar_t           symbol[32];
  STRING32           symbol;

#define TOSTRING3(A) #A + " = " + this.A[] + "\n"
  string ToString( void ) const
  {
    return(ExpTradeSummary::ToString() + TOSTRING3(symbol));
  }
#undef TOSTRING3
};