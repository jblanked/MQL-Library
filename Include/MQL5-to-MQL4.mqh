//+------------------------------------------------------------------+
//|                                                 MQL5-to-MQL4.mqh |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property strict

//--- last updated: October 10th, 2025
//--- add this to MQl4/Include

#ifdef __MQL4__

enum ENUM_POSITION_TYPE
{
   POSITION_TYPE_BUY, // Buy
   POSITION_TYPE_SELL // Sell
};

enum ENUM_POSITION_PROPERTY_INTEGER
{
   POSITION_TICKET,           // Position ticket.
   POSITION_TIME,             // Position open time
   POSITION_TIME_MSC,         // Position opening time in milliseconds since 01.01.1970
   POSITION_TIME_UPDATE,      // Position changing time
   POSITION_TIME_UPDATE_MSC,  // Position changing time in milliseconds since 01.01.1970
   POSITION_TYPE,             // Position type
   POSITION_MAGIC,            // Position magic number
   POSITION_IDENTIFIER,       // Position identifier is a unique number assigned to each re-opened position. It does not change throughout its life cycle and corresponds to the ticket of an order used to open a position.
   POSITION_REASON            // The reason for opening a position
};

enum ENUM_POSITION_PROPERTY_DOUBLE
{
   POSITION_VOLUME,        // Position volume
   POSITION_PRICE_OPEN,    // Position open price
   POSITION_SL,            // Stop Loss level of opened position
   POSITION_TP,            // Take Profit level of opened position
   POSITION_PRICE_CURRENT, // Current price of the position symbol
   POSITION_SWAP,          // Cumulative swap
   POSITION_PROFIT         // Current profit
};

enum ENUM_POSITION_PROPERTY_STRING
{
   POSITION_SYMBOL,     // Symbol of the position
   POSITION_COMMENT,    // Position comment
   POSITION_EXTERNAL_ID // Position identifier in an external trading system (on the Exchange)
};

enum ENUM_POSITION_REASON
{
   POSITION_REASON_CLIENT, // The position was opened as a result of activation of an order placed from a desktop terminal
   POSITION_REASON_MOBILE, // The position was opened as a result of activation of an order placed from a mobile application
   POSITION_REASON_WEB,    // The position was opened as a result of activation of an order placed from the web platform
   POSITION_REASON_EXPERT  // The position was opened as a result of activation of an order placed from an MQL5 program, i.e. an Expert Advisor or a script
};

enum ENUM_TRADE_TRANSACTION_TYPE
{
   TRADE_TRANSACTION_ORDER_ADD,      // Adding a new open order.
   TRADE_TRANSACTION_ORDER_UPDATE,   // Updating an open order.
   TRADE_TRANSACTION_ORDER_DELETE,   // Removing an order from the list of the open ones.
   TRADE_TRANSACTION_DEAL_ADD,       // Adding a deal to the history
   TRADE_TRANSACTION_DEAL_UPDATE,    // Updating a deal in the history.
   TRADE_TRANSACTION_DEAL_DELETE,    // Deleting a deal from the history.
   TRADE_TRANSACTION_HISTORY_ADD,    // Adding an order to the history as a result of execution or cancellation.
   TRADE_TRANSACTION_HISTORY_UPDATE, // Changing an order located in the orders history.
   TRADE_TRANSACTION_HISTORY_DELETE, // Deleting an order from the orders history.
   TRADE_TRANSACTION_POSITION,       // Changing a position not related to a deal execution.
   TRADE_TRANSACTION_REQUEST         // Notification of the fact that a trade request has been processed by a server and processing result has been received
};

enum ENUM_ORDER_STATE
{
   ORDER_STATE_STARTED,       // Order checked, but not yet accepted by broker
   ORDER_STATE_PLACED,        // Order accepted
   ORDER_STATE_CANCELED,      // Order canceled by client
   ORDER_STATE_PARTIAL,       // Order partially executed
   ORDER_STATE_FILLED,        // Order fully executed
   ORDER_STATE_REJECTED,      // Order rejected
   ORDER_STATE_EXPIRED,       // Order expired
   ORDER_STATE_REQUEST_ADD,   // Order is being registered (placing to the trading system)
   ORDER_STATE_REQUEST_MODIFY,// Order is being modified (changing its parameters)
   ORDER_STATE_REQUEST_CANCEL // Order is being deleted (deleting from the trading system)
};

enum ENUM_DEAL_TYPE
{
   DEAL_TYPE_BUY,                      // Buy
   DEAL_TYPE_SELL,                     // Sell
   DEAL_TYPE_BALANCE,                  // Balance
   DEAL_TYPE_CREDIT,                   // Credit
   DEAL_TYPE_CHARGE,                   // Additional Charge
   DEAL_TYPE_CORRECTION,               // Correction
   DEAL_TYPE_BONUS,                    // Bonus
   DEAL_TYPE_COMMISSION,               // Additional commission
   DEAL_TYPE_COMMISSION_DAILY,         // Daily commission
   DEAL_TYPE_COMMISSION_MONTHLY,       // Monthly commission
   DEAL_TYPE_COMMISSION_AGENT_DAILY,   // Daily agent commission
   DEAL_TYPE_COMMISSION_AGENT_MONTHLY, // Monthly agent commission
   DEAL_TYPE_INTEREST,                 // Interest rate
   DEAL_TYPE_BUY_CANCELED,             // Canceled buy deal
   DEAL_TYPE_SELL_CANCELED,            // Canceled sell deal
   DEAL_DIVIDEND,                      // Dividend operations
   DEAL_DIVIDEND_FRANKED,              // Franked (non-taxable) dividend operations
   DEAL_TAX                            // Tax charges
};

enum ENUM_DEAL_PROPERTY_STRING
{
   DEAL_SYMBOL,      // Deal symbol
   DEAL_COMMENT,     // Deal comment
   DEAL_EXTERNAL_ID  // Deal identifier in an external trading system (on the Exchange)
};

enum ENUM_DEAL_PROPERTY_DOUBLE
{
   DEAL_VOLUME,     // Deal volume
   DEAL_PRICE,      // Deal price
   DEAL_COMMISSION, // Deal commission
   DEAL_SWAP,       // Cumulative swap on close
   DEAL_PROFIT,     // Deal profit
   DEAL_FEE,        // Fee for making a deal charged immediately after performing a deal
   DEAL_SL,         // Stop Loss level
   DEAL_TP          // Take Profit level
};

enum ENUM_DEAL_PROPERTY_INTEGER
{
   DEAL_TICKET,     // Deal ticket. Unique number assigned to each deal
   DEAL_ORDER,      // Deal order number
   DEAL_TIME,       // Deal time
   DEAL_TIME_MSC,   // The time of a deal execution in milliseconds since 01.01.1970
   DEAL_TYPE,       // Deal type
   DEAL_ENTRY,      // Deal entry - entry in, entry out, reverse
   DEAL_MAGIC,      // Deal magic number
   DEAL_REASON,     // The reason or source for deal execution
   DEAL_POSITION_ID // DEAL_POSITION_ID
};

enum ENUM_DEAL_ENTRY
{
   DEAL_ENTRY_IN,    // Entry in
   DEAL_ENTRY_OUT,   // Entry out
   DEAL_ENTRY_INOUT, // Reverse
   DEAL_ENTRY_OUT_BY // Close a position by an opposite one
};

enum ENUM_DEAL_REASON
{
   DEAL_REASON_CLIENT,           // The deal was executed as a result of activation of an order placed from a desktop terminal
   DEAL_REASON_MOBILE,           // The deal was executed as a result of activation of an order placed from a mobile application
   DEAL_REASON_WEB,              // The deal was executed as a result of activation of an order placed from the web platform
   DEAL_REASON_EXPERT,           // The deal was executed as a result of activation of an order placed from an MQL5 program, i.e. an Expert Advisor or a script
   DEAL_REASON_SL,               // The deal was executed as a result of Stop Loss activation
   DEAL_REASON_TP,               // The deal was executed as a result of Take Profit activation
   DEAL_REASON_SO,               // The deal was executed as a result of the Stop Out event
   DEAL_REASON_ROLLOVER,         // The deal was executed due to a rollover
   DEAL_REASON_VMARGIN,          // The deal was executed after charging the variation margin
   DEAL_REASON_SPLIT,            // The deal was executed after the split (price reduction) of an instrument, which had an open position during split announcement
   DEAL_REASON_CORPORATE_ACTION  // The deal was executed as a result of a corporate action: merging or renaming a security, transferring a client to another account, etc.
};

enum ENUM_ORDER_TYPE_TIME
{
   ORDER_TIME_GTC,           // Good till cancel order
   ORDER_TIME_DAY,           // Good till current trade day order
   ORDER_TIME_SPECIFIED,     // Good till expired order
   ORDER_TIME_SPECIFIED_DAY  // The order will be effective till 23:59:59 of the specified day. If this time is outside a trading session, the order expires in the nearest trading time.
};

enum ENUM_ORDER_REASON
{
   ORDER_REASON_CLIENT, // The order was placed from a desktop terminal
   ORDER_REASON_MOBILE, // The order was placed from a mobile application
   ORDER_REASON_WEB,    // The order was placed from a web platform
   ORDER_REASON_EXPERT, // The order was placed from an MQL5-program, i.e. by an Expert Advisor or a script
   ORDER_REASON_SL,     // The order was placed as a result of Stop Loss activation
   ORDER_REASON_TP,     // The order was placed as a result of Take Profit activation
   ORDER_REASON_SO      // The order was placed as a result of the Stop Out event
};

enum ENUM_TRADE_REQUEST_ACTIONS
{
   TRADE_ACTION_DEAL,    // Place a trade order for an immediate execution with the specified parameters (market order)
   TRADE_ACTION_PENDING, // Place a trade order for the execution under specified conditions (pending order)
   TRADE_ACTION_SLTP,    // Modify Stop Loss and Take Profit values of an opened position
   TRADE_ACTION_MODIFY,  // Modify the parameters of the order placed previously
   TRADE_ACTION_REMOVE,  // Delete the pending order placed previously
   TRADE_ACTION_CLOSE_BY // Close a position by an opposite one
};

enum ENUM_ORDER_TYPE_FILLING
{
   ORDER_FILLING_FOK,    // Fill or Kill: An order can be executed in the specified volume only.
   ORDER_FILLING_IOC,    // Immediate or Cancel: A trader agrees to execute a deal with the volume maximally available in the market within that indicated in the order.
   ORDER_FILLING_BOC,    // Passive (Book or Cancel): guarantees that the price of the placed order will be worse than the current market
   ORDER_FILLING_RETURN  // Return: In case of partial filling, an order with remaining volume is not canceled but processed further.
};

struct MqlTradeTransaction
{
   ulong                         deal;             // Deal ticket
   ulong                         order;            // Order ticket
   string                        symbol;           // Trade symbol name
   ENUM_TRADE_TRANSACTION_TYPE   type;             // Trade transaction type
   ENUM_ORDER_TYPE               order_type;       // Order type
   ENUM_ORDER_STATE              order_state;      // Order state
   ENUM_DEAL_TYPE                deal_type;        // Deal type
   ENUM_ORDER_TYPE_TIME          time_type;        // Order type by action period
   datetime                      time_expiration;  // Order expiration time
   double                        price;            // Price
   double                        price_trigger;    // Stop limit order activation price
   double                        price_sl;         // Stop Loss level
   double                        price_tp;         // Take Profit level
   double                        volume;           // Volume in lots
   ulong                         position;         // Position ticket
   ulong                         position_by;      // Ticket of an opposite position
};

struct MqlTradeRequest
{
   ENUM_TRADE_REQUEST_ACTIONS    action;           // Trade operation type
   ulong                         magic;            // Expert Advisor ID (magic number)
   ulong                         order;            // Order ticket
   string                        symbol;           // Trade symbol
   double                        volume;           // Requested volume for a deal in lots
   double                        price;            // Price
   double                        stoplimit;        // StopLimit level of the order
   double                        sl;               // Stop Loss level of the order
   double                        tp;               // Take Profit level of the order
   ulong                         deviation;        // Maximal possible deviation from the requested price
   ENUM_ORDER_TYPE               type;             // Order type
   ENUM_ORDER_TYPE_FILLING       type_filling;     // Order execution type
   ENUM_ORDER_TYPE_TIME          type_time;        // Order expiration type
   datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type)
   string                        comment;          // Order comment
   ulong                         position;         // Position ticket
   ulong                         position_by;      // The ticket of an opposite position
};

struct MqlTradeResult
{
   uint     retcode;          // Operation return code
   ulong    deal;             // Deal ticket, if it is performed
   ulong    order;            // Order ticket, if it is placed
   double   volume;           // Deal volume, confirmed by broker
   double   price;            // Deal price, confirmed by broker
   double   bid;              // Current Bid price
   double   ask;              // Current Ask price
   string   comment;          // Broker comment to operation (by default it is filled by description of trade server return code)
   uint     request_id;       // Request ID set by the terminal during the dispatch
   int      retcode_external; // Return code of an external trading system
};

struct MqlTradeCheckResult
{
   uint         retcode;             // Reply code
   double       balance;             // Balance after the execution of the deal
   double       equity;              // Equity after the execution of the deal
   double       profit;              // Floating profit
   double       margin;              // Margin requirements
   double       margin_free;         // Free margin
   double       margin_level;        // Margin level
   string       comment;             // Comment to the reply code (description of the error)
};

//+------------------------------------------------------------------+
//| Get the opened positions only (no pending orders)                |
//+------------------------------------------------------------------+
int PositionsTotal()
{
   int _count       = 0;
   int _currentType = -1;
   for(int i = OrdersTotal() - 1; i >= 0; i--) //count backwards
   {
      if(OrderSelect(i, SELECT_BY_POS)) // select the order
      {
         _currentType = OrderType();
         if(_currentType == OP_BUY || _currentType == OP_SELL)
         {
            _count++;
         }
      }
   }
   return _count;
}
//+----------------------------------------------------------------------+
//| Get the ticket of a selected position (used in a PositionsTotal loop)|
//+----------------------------------------------------------------------+
ulong PositionGetTicket(const int index)
{
   int _currentType = -1;
   for(int i = OrdersTotal() - 1; i >= 0; i--) //count backwards
   {
      if(OrderSelect(i, SELECT_BY_POS)) // select the order
      {
         _currentType = OrderType();
         if(_currentType == OP_BUY || _currentType == OP_SELL)
         {
            if(i == index) return (ulong)OrderTicket();
         }
      }
   }
   return 0;
}
//+----------------------------------------------------------------------+
//| Get the symbol of a selected position (used in a PositionsTotal loop)|
//+----------------------------------------------------------------------+
string PositionGetSymbol(const int index)
{
   int _currentType = -1;
   for(int i = OrdersTotal() - 1; i >= 0; i--) //count backwards
   {
      if(OrderSelect(i, SELECT_BY_POS)) // select the order
      {
         _currentType = OrderType();
         if(_currentType == OP_BUY || _currentType == OP_SELL)
         {
            if(i == index) return OrderSymbol();
         }
      }
   }
   return "";
}
//+------------------------------------------------------------------+
//| Get position values                                              |
//+------------------------------------------------------------------+
long  PositionGetInteger(ENUM_POSITION_PROPERTY_INTEGER  property_id)
{
   switch(property_id)
   {
   case POSITION_TICKET:
      return (long)OrderTicket();
   case POSITION_TIME:
      return (long)OrderOpenTime();
   case POSITION_TIME_MSC:  // not the same
      return (long)OrderGetInteger(ORDER_TIME_SETUP_MSC);
   case POSITION_TIME_UPDATE:  // not the same
      return (long)OrderOpenTime();
   case POSITION_TIME_UPDATE_MSC:
      return (long)int(OrderOpenTime()); // not the same
   case POSITION_TYPE:
   {
      const int _posType = OrderType();
      return
         (_posType == OP_BUY || _posType == ORDER_TYPE_BUY) ? POSITION_TYPE_BUY :
         (_posType == OP_SELL || _posType == ORDER_TYPE_SELL) ? POSITION_TYPE_SELL :
         -1;
   };
   case POSITION_MAGIC:
      return (long)OrderMagicNumber();
   case POSITION_IDENTIFIER:
      return (long)OrderTicket(); // not the same
   case POSITION_REASON:
      return POSITION_REASON_EXPERT; // not the same
   };
   return 0;
}
//+------------------------------------------------------------------+
//| Get history position values                                      |
//+------------------------------------------------------------------+
long HistoryDealGetInteger(ulong ticket_number, ENUM_DEAL_PROPERTY_INTEGER property_id)
{
   switch(property_id)
   {
   case DEAL_TICKET:
      return (long)OrderTicket();
   case DEAL_ORDER:
      return (long)OrderTicket();
   case DEAL_TIME:
      return (long)OrderOpenTime();
   case DEAL_TIME_MSC:  // not the same
      return (long)OrderGetInteger(ORDER_TIME_SETUP_MSC);
   case DEAL_TYPE:
   {
      const int _posType = OrderType();
      return
         (_posType == OP_BUY || _posType == ORDER_TYPE_BUY) ? DEAL_TYPE_BUY :
         (_posType == OP_SELL || _posType == ORDER_TYPE_SELL) ? DEAL_TYPE_SELL :
         -1;
   };
   case DEAL_MAGIC:
      return (long)OrderMagicNumber();
   case DEAL_POSITION_ID:
      return (long)OrderTicket(); // not the same
   case DEAL_REASON:
      return DEAL_REASON_EXPERT; // not the same
   };
   return 0;
}
//+------------------------------------------------------------------+
//| Get position values                                              |
//+------------------------------------------------------------------+
double PositionGetDouble(ENUM_POSITION_PROPERTY_DOUBLE  property_id)
{
   switch(property_id)
   {
   case POSITION_VOLUME:
      return OrderLots();
   case POSITION_PRICE_OPEN:
      return OrderOpenPrice();
   case POSITION_SL:
      return OrderStopLoss();
   case POSITION_TP:
      return OrderTakeProfit();
   case POSITION_PRICE_CURRENT:
      return OrderClosePrice();
   case POSITION_SWAP:
      return OrderSwap();
   case POSITION_PROFIT:
      return OrderProfit();
   };
   return 0.0;
}
//+------------------------------------------------------------------+
//| Get history position values                                      |
//+------------------------------------------------------------------+
double HistoryDealGetDouble(ulong ticket_number, ENUM_DEAL_PROPERTY_DOUBLE property_id)
{
   switch(property_id)
   {
   case DEAL_VOLUME:
      return OrderLots();
   case DEAL_PRICE:
      return OrderOpenPrice();
   case DEAL_COMMISSION:
      return OrderCommission();
   case DEAL_SWAP:
      return OrderSwap();
   case DEAL_PROFIT:
      return OrderProfit();
   case DEAL_FEE:
      return 0.0; // not implemented
   case DEAL_SL:
      return OrderStopLoss();
   case DEAL_TP:
      return OrderTakeProfit();
   };
   return 0.0;
}
//+------------------------------------------------------------------+
//| Get position values                                              |
//+------------------------------------------------------------------+
string  PositionGetString(ENUM_POSITION_PROPERTY_STRING property_id)
{
   switch(property_id)
   {
   case POSITION_SYMBOL:
      return OrderGetString(ORDER_SYMBOL);
   case POSITION_COMMENT:
      return OrderGetString(ORDER_COMMENT);
   case POSITION_EXTERNAL_ID:
      return "";
   };
   return "";
}
//+------------------------------------------------------------------+
//| Get history position values                                      |
//+------------------------------------------------------------------+
string HistoryDealGetString(ulong  ticket_number, ENUM_DEAL_PROPERTY_STRING  property_id)
{
   if(ticket_number == 0) return ""; // no need for ticket since already selected prior
   switch(property_id)
   {
   case DEAL_SYMBOL:
      return OrderGetString(ORDER_SYMBOL);
   case DEAL_COMMENT:
      return OrderGetString(ORDER_COMMENT);
   case DEAL_EXTERNAL_ID:
      return "";
   };
   return "";
}
//+------------------------------------------------------------------+
//| Select an order, MQL5 style                                      |
//+------------------------------------------------------------------+
bool OrderSelect(ulong ticket)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--) //count backwards
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderTicket() != (int)ticket) continue;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Select an order from history                                     |
//+------------------------------------------------------------------+
bool HistoryOrderSelect(ulong ticket)
{
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--) //count backwards
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderTicket() != (int)ticket) continue;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Select an order from history                                     |
//+------------------------------------------------------------------+
bool HistoryDealSelect(ulong ticket)
{
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--) //count backwards
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderTicket() != (int)ticket) continue;
      return true;
   }
   return false;
}
#endif

//+------------------------------------------------------------------+
