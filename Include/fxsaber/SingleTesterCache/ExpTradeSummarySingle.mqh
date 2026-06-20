#include "String.mqh"

//+------------------------------------------------------------------+
//| Структура для статистики торговли                                |
//+------------------------------------------------------------------+
struct ExpTradeSummarySingle
{
public:
  int               Offset1[10];
  int               bars;
  int               ticks;
  STRING32          symbol;
  double            initial_deposit;     // начальный депозит
  double            withdrawal;          // снято средств
  double            profit;              // общая прибыль (+)
  double            grossprofit;         // общий плюс
  double            grossloss;           // общий минус
  double            maxprofit;           // максимально прибыльная сделка
  double            minprofit;           // максимально убыточная сделка
  double            conprofitmax;        // прибыль максимальной последовательности прибыльных сделок
  double            maxconprofit;        // максимальная прибыль среди последовательностей
  double            conlossmax;          // убыток максимальной последовательности убыточных сделок
  double            maxconloss;          // максимальный убыток среди последовательностей
  double            balance_min;         // минимальное значение баланса (для расчёта абсолютной просадки)
  double            maxdrawdown;         // максимальная просадка по балансу
  double            drawdownpercent;     // отношение максимальной просадки по балансу к её пику
  double            reldrawdown;         // максимальная относительная просадка по балансу в деньгах
  double            reldrawdownpercent;  // максимальная относительная просадка по балансу в процентах
  double            equity_min;          // минимальное значение equity (для расчёта абсолютной просадки по equity)
  double            maxdrawdown_e;       // максимальная просадка по equity
  double            drawdownpercent_e;   // отношение максимальной просадки по equity к её пику (+)
  double            reldrawdown_e;       // максимальная относительная просадка по equity в деньгах
  double            reldrawdownpercnt_e; // максимальная относительная просадка по equity в процентах
  double            expected_payoff;     // матожидание выигрыша (+)
  double            profit_factor;       // показатель прибыльности (+)
  double            recovery_factor;     // фактор восстановления (+)
  double            sharpe_ratio;        // коэффициент Шарпа (+)
  double            margin_level;        // минимальный уровень маржи
  double            custom_fitness;      // пользовательский фитнесс - результат OnTester (+)
  int               deals;               // общее количество сделок
  int               trades;              // количество сделок out/inout
  int               profittrades;        // количество прибыльных
  int               losstrades;          // количество убыточных
  int               shorttrades;         // количество шортов
  int               longtrades;          // количество лонгов
  int               winshorttrades;      // количество прибыльных шортов
  int               winlongtrades;       // количество прибыльных лонгов
  int               conprofitmax_trades; // максимальная последовательность прибыльных сделок
  int               maxconprofit_trades; // последовательность максимальной прибыли
  int               conlossmax_trades;   // максимальная последовательность убыточных сделок
  int               maxconloss_trades;   // последовательность максимального убытка
  int               avgconwinners;       // среднее количество последовательных прибыльных сделок
  int               avgconloosers;       // среднее количество последовательных убыточных сделок

#define TOSTRING(A) #A + " = " + (string)(A) + "\n"
#define TOSTRING3(A) #A + " = " + this.A[] + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(bars) +
           TOSTRING(ticks) +
           TOSTRING3(symbol) +
           TOSTRING(initial_deposit) +      // начальный депозит
           TOSTRING(withdrawal) +           // снято средств
           TOSTRING(profit) +               // общая прибыль (+)
           TOSTRING(grossprofit) +          // общий плюс
           TOSTRING(grossloss) +            // общий минус
           TOSTRING(maxprofit) +            // максимально прибыльная сделка
           TOSTRING(minprofit) +            // максимально убыточная сделка
           TOSTRING(conprofitmax) +         // прибыль максимальной последовательности прибыльных сделок
           TOSTRING(maxconprofit) +         // максимальная прибыль среди последовательностей
           TOSTRING(conlossmax) +           // убыток максимальной последовательности убыточных сделок
           TOSTRING(maxconloss) +           // максимальный убыток среди последовательностей
           TOSTRING(balance_min) +          // минимальное значение баланса (для расчёта абсолютной просадки)
           TOSTRING(maxdrawdown) +          // максимальная просадка по балансу
           TOSTRING(drawdownpercent) +      // отношение максимальной просадки по балансу к её пику
           TOSTRING(reldrawdown) +          // максимальная относительная просадка по балансу в деньгах
           TOSTRING(reldrawdownpercent) +   // максимальная относительная просадка по балансу в процентах
           TOSTRING(equity_min) +           // минимальное значение equity (для расчёта абсолютной просадки по equity)
           TOSTRING(maxdrawdown_e) +        // максимальная просадка по equity
           TOSTRING(drawdownpercent_e) +    // отношение максимальной просадки по equity к её пику (+)
           TOSTRING(reldrawdown_e) +        // максимальная относительная просадка по equity в деньгах
           TOSTRING(reldrawdownpercnt_e) +  // максимальная относительная просадка по equity в процентах
           TOSTRING(expected_payoff) +      // матожидание выигрыша (+)
           TOSTRING(profit_factor) +        // показатель прибыльности (+)
           TOSTRING(recovery_factor) +      // фактор восстановления (+)
           TOSTRING(sharpe_ratio) +         // коэффициент Шарпа (+)
           TOSTRING(margin_level) +         // минимальный уровень маржи
           TOSTRING(custom_fitness) +       // пользовательский фитнесс - результат OnTester (+)
           TOSTRING(deals) +                // общее количество сделок
           TOSTRING(trades) +               // количество сделок out/inout
           TOSTRING(profittrades) +         // количество прибыльных
           TOSTRING(losstrades) +           // количество убыточных
           TOSTRING(shorttrades) +          // количество шортов
           TOSTRING(longtrades) +           // количество лонгов
           TOSTRING(winshorttrades) +       // количество прибыльных шортов
           TOSTRING(winlongtrades) +        // количество прибыльных лонгов
           TOSTRING(conprofitmax_trades) +  // максимальная последовательность прибыльных сделок
           TOSTRING(maxconprofit_trades) +  // последовательность максимальной прибыли
           TOSTRING(conlossmax_trades) +    // максимальная последовательность убыточных сделок
           TOSTRING(maxconloss_trades) +    // последовательность максимального убытка
           TOSTRING(avgconwinners) +        // среднее количество последовательных прибыльных сделок
           TOSTRING(avgconloosers)          // среднее количество последовательных убыточных сделок
          );
  }

#undef TOSTRING3
#undef TOSTRING

  double TesterStatistics( const ENUM_STATISTICS Statistic_ID ) const
  {
    switch (Statistic_ID)
    {
      case STAT_INITIAL_DEPOSIT:
        return(this.initial_deposit);
      case STAT_WITHDRAWAL:
        return(this.withdrawal);
      case STAT_PROFIT:
        return(this.profit);
      case STAT_GROSS_PROFIT:
        return(this.grossprofit);
      case STAT_GROSS_LOSS:
        return(-this.grossloss);
      case STAT_MAX_PROFITTRADE:
        return(this.maxprofit);
      case STAT_MAX_LOSSTRADE:
        return(-this.minprofit);
      case STAT_CONPROFITMAX:
        return(this.maxconprofit);
      case STAT_CONPROFITMAX_TRADES:
        return(this.maxconprofit_trades);
      case STAT_MAX_CONWINS:
        return(this.conprofitmax);
      case STAT_MAX_CONPROFIT_TRADES:
        return(this.conprofitmax_trades);
      case STAT_CONLOSSMAX:
        return(-this.conlossmax);
      case STAT_CONLOSSMAX_TRADES:
        return(this.conlossmax_trades);
      case STAT_MAX_CONLOSSES:
        return(-this.maxconloss);
      case STAT_MAX_CONLOSS_TRADES:
        return(this.maxconloss_trades);
      case STAT_BALANCEMIN:
        return(this.balance_min);
      case STAT_BALANCE_DD:
        return(this.maxdrawdown);
      case STAT_BALANCEDD_PERCENT:
        return(this.drawdownpercent);
      case STAT_BALANCE_DDREL_PERCENT:
        return(this.reldrawdownpercent);
      case STAT_BALANCE_DD_RELATIVE:
        return(this.reldrawdown);
      case STAT_EQUITYMIN:
        return(this.equity_min);
      case STAT_EQUITY_DD:
        return(this.maxdrawdown_e);
      case STAT_EQUITYDD_PERCENT:
        return(this.drawdownpercent_e);
      case STAT_EQUITY_DDREL_PERCENT:
        return(this.reldrawdownpercnt_e);
      case STAT_EQUITY_DD_RELATIVE:
        return(this.reldrawdown_e);
      case STAT_EXPECTED_PAYOFF:
        return(this.expected_payoff);
      case STAT_PROFIT_FACTOR:
        return(this.profit_factor);
      case STAT_RECOVERY_FACTOR:
        return(this.recovery_factor);
      case STAT_SHARPE_RATIO:
        return(this.sharpe_ratio);
      case STAT_MIN_MARGINLEVEL:
        return(this.margin_level);
      case STAT_CUSTOM_ONTESTER:
        return(this.custom_fitness);
      case STAT_DEALS:
        return(this.deals);
      case STAT_TRADES:
        return(this.trades);
      case STAT_PROFIT_TRADES:
        return(this.profittrades);
      case STAT_LOSS_TRADES:
        return(this.losstrades);
      case STAT_SHORT_TRADES:
        return(this.shorttrades);
      case STAT_LONG_TRADES:
        return(this.longtrades);
      case STAT_PROFIT_SHORTTRADES:
        return(this.winshorttrades);
      case STAT_PROFIT_LONGTRADES:
        return(this.winlongtrades);
      case STAT_PROFITTRADES_AVGCON:
        return(this.avgconwinners);
      case STAT_LOSSTRADES_AVGCON:
        return(this.avgconloosers);
    }

    return(0);
  }
};