#include "String.mqh"

#define UINT64 ulong
#define INT64 datetime
#define UINT uint

//+------------------------------------------------------------------+
//| Структура торгового ордера                                       |
//+------------------------------------------------------------------+
struct TradeOrder
{
private:
  ENUM_ORDER_REASON ReasonToInteger( const ENUM_ORDER_REASON Reason ) const
  {
    int Res = 1;

    switch (Reason)
    {
    case ORDER_REASON_SL:
      Res = 3;

      break;
    case ORDER_REASON_TP:
      Res = 4;

      break;
    }

    return((ENUM_ORDER_REASON)Res);
  }

  ENUM_ORDER_REASON IntegerToReason( const int Reason ) const
  {
    ENUM_ORDER_REASON Res = ORDER_REASON_CLIENT;

    switch (Reason)
    {
    case 3:
      Res = ORDER_REASON_SL;

      break;
    case 4:
      Res = ORDER_REASON_TP;

      break;
    }

    return((ENUM_ORDER_REASON)Res);
  }

public:
  UINT64            order;                   // уникальный идентификатор ордера
//  wchar_t           symbol[32];              // символ по которому выставлен ордер
  STRING32          symbol;                  // символ по которому выставлен ордер
  INT64             time_setup;              // время приёма ордера от клиента в систему
  INT64             time_done;               // время снятия завки
  ENUM_ORDER_TYPE   type;                    // тип ордера
  ENUM_ORDER_REASON type_reason;             // причина формирования ордера
  double            price_order;             // цена ордера
  double            price_trigger;           // цена исполнения ордера
  double            price_sl;                // цена SL в ордере
  double            price_tp;                // цена TP в ордере
  UINT64            volume_initial;          // начальный объём заявки
  UINT64            volume_current;          // текущий объём заявки
//  wchar_t           comment[32];             // комментарий к ордеру
  STRING32          comment;                 // комментарий к ордеру
  ENUM_ORDER_STATE  state;                   // текущее состояние ордера
  UINT              digits;                  // количество знаков у торгового символа
  double            contract_size;           // размер контракта

  bool Set( const ulong Ticket )
  {
    const bool Res = (::HistoryOrderGetInteger(Ticket, ORDER_TICKET) == Ticket);

    if (Res)
    {
      this.order = Ticket;                                                                                                     // уникальный идентификатор ордера

      string Str = ::HistoryOrderGetString(Ticket, ORDER_SYMBOL);
      this.symbol = Str;                                                                                                       // символ по которому выставлен ордер

      this.contract_size = ::SymbolInfoDouble(Str, SYMBOL_TRADE_CONTRACT_SIZE);                                                // размер контракта
      this.digits = (UINT)::SymbolInfoInteger(Str, SYMBOL_DIGITS);                                                             // количество знаков у торгового символа

      Str = ::HistoryOrderGetString(Ticket, ORDER_COMMENT);
      this.comment = Str;                                                                                                      // комментарий к ордеру

      this.time_setup = (INT64)::HistoryOrderGetInteger(Ticket, ORDER_TIME_SETUP);                                             // время приёма ордера от клиента в систему
      this.time_done = (INT64)::HistoryOrderGetInteger(Ticket, ORDER_TIME_DONE);                                               // время снятия завки

      this.type = (ENUM_ORDER_TYPE)::HistoryOrderGetInteger(Ticket, ORDER_TYPE);                                               // тип ордера
      this.type_reason = this.ReasonToInteger((ENUM_ORDER_REASON)::HistoryOrderGetInteger(Ticket, ORDER_REASON));              // причина формирования ордера
      this.state = (ENUM_ORDER_STATE)::HistoryOrderGetInteger(Ticket, ORDER_STATE);                                            // текущее состояние ордера

      this.price_order = ::HistoryOrderGetDouble(Ticket, ORDER_PRICE_OPEN);                                                    // цена ордера
      this.price_trigger = 0;                                                                                                  // цена исполнения ордера
      this.price_sl = ::HistoryOrderGetDouble(Ticket, ORDER_SL);                                                               // цена SL в ордере
      this.price_tp = ::HistoryOrderGetDouble(Ticket, ORDER_TP);                                                               // цена TP в ордере

      this.volume_initial = (UINT64)(::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_INITIAL) * this.contract_size * 1000 + 0.1); // начальный объём заявки
      this.volume_current = (UINT64)(::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_CURRENT) * this.contract_size * 1000 + 0.1); // текущий объём заявки
    }

    return(Res);
  }

  long GetProperty( const ENUM_ORDER_PROPERTY_INTEGER Property ) const
  {
    long Res = 0;

    switch (Property)
    {
      case ORDER_TICKET:
        Res = (long)this.order;

        break;
      case ORDER_TIME_SETUP:
        Res = this.time_setup;

        break;
      case ORDER_TYPE:
        Res = this.type;

        break;
      case ORDER_STATE:
        Res = this.state;

        break;
      case ORDER_TIME_DONE:
        Res = this.time_done;

        break;
      case ORDER_TIME_SETUP_MSC:
        Res = (long)this.time_setup * 1000;

        break;
      case ORDER_TIME_DONE_MSC:
        Res = (long)this.time_done * 1000;

        break;
      case ORDER_REASON:
        Res = this.IntegerToReason(this.type_reason);

        break;
      case ORDER_POSITION_ID:
        Res = (long)this.order;

        break;
    }

    return(Res);
  }

  double GetProperty( const ENUM_ORDER_PROPERTY_DOUBLE Property ) const
  {
    double Res = 0;

    switch (Property)
    {
      case ORDER_VOLUME_INITIAL:
        Res = (double)this.volume_initial / (this.contract_size ? this.contract_size * 1000 : 1e8);

        break;
      case ORDER_VOLUME_CURRENT:
        Res = (double)this.volume_current / (this.contract_size ? this.contract_size * 1000 : 1e8);

        break;
      case ORDER_PRICE_OPEN:
        Res = this.price_order;

        break;
      case ORDER_SL:
        Res = this.price_sl;

        break;
      case ORDER_TP:
        Res = this.price_tp;

        break;
    }

    return(Res);
  }

  string GetProperty( const ENUM_ORDER_PROPERTY_STRING Property ) const
  {
    string Res = NULL;

    switch (Property)
    {
      case ORDER_SYMBOL:
        Res = this.symbol[];

        break;
      case ORDER_COMMENT:
        Res = this.comment[];

        break;
    }

    return(Res);
  }

#define TOSTRING(A) #A + " = " + (string)(this.A) + "\n"
#define TOSTRING2(A) #A + " = " + ::EnumToString(this.A) + " (" + (string)(this.A) + ")\n"
#define TOSTRING3(A) #A + " = " + this.A[] + "\n"

  string ToString( void ) const
  {
    return(
           TOSTRING(order) +                   // уникальный идентификатор ордера
           TOSTRING3(symbol) +                 // символ по которому выставлен ордер
           TOSTRING(time_setup) +              // время приёма ордера от клиента в систему
           TOSTRING(time_done) +               // время снятия завки
           TOSTRING2(type) +                   // тип ордера
           TOSTRING2(type_reason) +            // причина формирования ордера
           TOSTRING(price_order) +             // цена ордера
           TOSTRING(price_trigger) +           // цена исполнения ордера
           TOSTRING(price_sl) +                // цена SL в ордере
           TOSTRING(price_tp) +                // цена TP в ордере
           TOSTRING(volume_initial) +          // начальный объём заявки
           TOSTRING(volume_current) +          // текущий объём заявки
           TOSTRING3(comment) +                // комментарий к ордеру
           TOSTRING2(state) +                  // текущее состояние ордера
           TOSTRING(digits) +                  // количество знаков у торгового символа
           TOSTRING(contract_size)             // размер контракта
          );
  }

#undef TOSTRING3
#undef TOSTRING2
#undef TOSTRING
};

#undef UINT
#undef INT64
#undef UINT64