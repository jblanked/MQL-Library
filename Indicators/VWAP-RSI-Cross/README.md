### VWAP-RSI-Cross
A MetaTrader 4 and 5 indicator that displays two VWAPs in an RSI window.

input int inpRSIPeriod  = 9;     // RSI Period
input int inpFastPeriod = 9;     // VWAP Fast Period
input int inpSlowPeriod = 21;    // VWAP Slow Period
input int inpMaxCandles = 1000;  // Max Candles

Parameters:
- RSI Period: The period of the RSI
- VWAP Fast Period: The period for the faster VWAP
- VWAP Slow Period: The period for the slower VWAP
- Max Candles: The maximum number of candles for the indicator to calculate and draw

### Getting Started
To use this indicator:
1. Download the appropriate file (`.mq4` for MQL4 or `.mq5` for MQL5)
2. Compile it using the `MetaEditor` application
3. Place the compiled indicator in your `Indicators` folder