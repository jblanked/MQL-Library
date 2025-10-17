# Copyright 2024-2025,JBlanked LLC
# https://www.jblanked.com/trading-tools/

import os
import sys
import subprocess
from datetime import datetime
import MetaTrader5 as mt5

# timeframe constants
PERIOD_M1: int = mt5.TIMEFRAME_M1
PERIOD_M5: int = mt5.TIMEFRAME_M5
PERIOD_M15: int = mt5.TIMEFRAME_M15
PERIOD_M30: int = mt5.TIMEFRAME_M30
PERIOD_H1: int = mt5.TIMEFRAME_H1
PERIOD_H4: int = mt5.TIMEFRAME_H4
PERIOD_D1: int = mt5.TIMEFRAME_D1
PERIOD_W1: int = mt5.TIMEFRAME_W1
PERIOD_MN1: int = mt5.TIMEFRAME_MN1

class MqlRates:
   '''MQlRates class that mimics the MQL5 struct'''
   
   def __init__(self, close: float = 0.0, high: float = 0.0, low: float = 0.0, open: float = 0.0, time: datetime = None, volume: float = 0.0):
       '''Init MqlRates object'''
       self.close: float = close # close price
       self.high: float = high # high price
       self.low: float = low # low price
       self.open: float = open # open price
       self.time: datetime = time # time in UTC
       self.volume: float = volume # tick volume
   
   def __del__(self):
       '''Clean up resources on delete'''
       self.close = 0.0 
       self.high = 0.0 
       self.low = 0.0 
       self.open = 0.0
       self.time = None 
       self.volume = 0.0 
       
   def __str__(self):
       '''Stringify if printing'''
       return f"Time: {self.time}, Close: {self.close}, Open: {self.open}, High: {self.high}, Low: {self.low}, Volume: {self.volume}"

def Ask(symbol: str) -> float:
    '''Returns the ask price of the request asset'''
    symbol_info = mt5.symbol_info(symbol)
    if not symbol_info:
        print(f"Failed to fetch symbol data for {symbol}")
        return 0.0
    return symbol_info.ask

def Bid(symbol: str) -> float:
    '''Returns the bid price of the request asset'''
    symbol_info = mt5.symbol_info(symbol)
    if not symbol_info:
        print(f"Failed to fetch symbol data for {symbol}")
        return 0.0
    return symbol_info.bid

def Digits(symbol: str) -> int:
    '''Returns the digits of the request asset'''
    symbol_info = mt5.symbol_info(symbol)
    if not symbol_info:
        print(f"Failed to fetch symbol data for {symbol}")
        return 0
    return symbol_info.digits

def CopyRates(symbol: str, timeframe: int, start_position: int, count: int) -> list[MqlRates]:
    '''Return a list of rates'''
    timezone = None
    
    try:
        import pytz
        timezone = pytz.timezone("Etc/UTC")
    except ImportError as e:
        pass
        
    rates: list = mt5.copy_rates_from_pos(symbol, timeframe, start_position, count)
    mql_rates: list[MqlRates] = []
    for rate in rates:
        _rate: MqlRates = MqlRates()
        _rate.volume = rate[5]
        _rate.close = rate[4]
        _rate.low = rate[3]
        _rate.high = rate[2]
        _rate.open = rate[1]
        _rate.time = rate[0] if not timezone else datetime.fromtimestamp(rate[0], tz=timezone)
        mql_rates.append(_rate)
        
    mql_rates.reverse()
    
    return mql_rates
    
def iClose(symbol: str, timeframe: int, shift: int) -> float:
    '''Returns the close value of the selected symbol, timeframe, and shift'''
    rates: list = mt5.copy_rates_from_pos(symbol, timeframe, shift, 1)
    if rates:
        return rates[0][4]
    return 0.0

def iHigh(symbol: str, timeframe: int, shift: int) -> float:
    '''Returns the high value of the selected symbol, timeframe, and shift'''
    rates: list = mt5.copy_rates_from_pos(symbol, timeframe, shift, 1)
    if rates:
        return rates[0][2]
    return 0.0

def iLow(symbol: str, timeframe: int, shift: int) -> float:
    '''Returns the low value of the selected symbol, timeframe, and shift'''
    rates: list = mt5.copy_rates_from_pos(symbol, timeframe, shift, 1)
    if rates:
        return rates[0][3]
    return 0.0

def iOpen(symbol: str, timeframe: int, shift: int) -> float:
    '''Returns the open value of the selected symbol, timeframe, and shift'''
    rates: list = mt5.copy_rates_from_pos(symbol, timeframe, shift, 1)
    if rates:
        return rates[0][1]
    return 0.0

def iTime(symbol: str, timeframe: int, shift: int) -> datetime:
    '''Returns the time value of the selected symbol, timeframe, and shift'''
    # set time zone to UTC
    timezone = None
    try:
        import pytz
        timezone = pytz.timezone("Etc/UTC")
    except ImportError as e:
        pass
    rates: list = mt5.copy_rates_from_pos(symbol, timeframe, shift, 1)
    if rates:
        return rates[0][0] if not timezone else datetime.fromtimestamp(rates[0][0], tz=timezone)
    return None
    
def Pip(symbol: str) -> float:
    '''Returns the point value of the request asset'''
    symbol_info = mt5.symbol_info(symbol)
    
    if not symbol_info:
        print(f"Failed to fetch symbol data for {symbol}")
        return 0.0
        
    point: int = symbol_info.point
    digits: int = symbol_info.digits
    
    if digits == 0:
        return point * 10.0
    if digits >= 4:
        return 0.0001 # currency pairs
    if digits == 3 or "oil" in symbol.lower():
        return 0.01 # JPY pairs
    if "xau" in symbol.lower():
        return 0.10 # gold
    
    if symbol.lower() in ["nas100", "us100", "ustec100", "spx500", "us30"]:
        return 1 # indices/crypto
    
    return point * 10.0 # default
    
def Point(symbol: str) -> float:
    '''Returns the point value of the request asset'''
    symbol_info = mt5.symbol_info(symbol)
    if not symbol_info:
        print(f"Failed to fetch symbol data for {symbol}")
        return 0.0
    return symbol_info.point

def setup_venv(environment_name: str) -> str:
    '''Setup virtual environment and return its path'''
    
    # Create venv in user's AppData/Local directory to avoid permission issues
    user_data_dir = os.path.join(os.environ.get('LOCALAPPDATA', os.path.expanduser('~')), 'MT5_Python')
    os.makedirs(user_data_dir, exist_ok=True)
    
    venv_path = os.path.join(user_data_dir, environment_name)
    
    # Check if venv already exists
    if os.path.exists(venv_path):
        return venv_path
    
    # Create the environment
    try:
        print(f"Creating virtual environment at: {venv_path}")
        subprocess.check_call(
            [sys.executable, "-m", "venv", venv_path]
        )
        print(f"Virtual environment created successfully.")
        return venv_path
    except subprocess.CalledProcessError as e:
        print(f"Error setting up virtual environment: {e}")
        return None
    except Exception as e:
        print(f"Unexpected error setting up virtual environment: {e}")
        return None

def get_venv_python(venv_path: str) -> str:
    '''Get the path to the Python executable in the virtual environment'''
    if sys.platform == "win32":
        return os.path.join(venv_path, "Scripts", "python.exe")
    else:
        return os.path.join(venv_path, "bin", "python")

def install_package(package_name: str, venv_python: str = None) -> bool:
    """Installs a Python package using pip."""
    import time
    
    python_executable = venv_python if venv_python else sys.executable
    
    try:
        # Check if package is already installed
        try:
            __import__(package_name)
            if package_name in sys.modules:
                return True
        except ImportError:
            pass
        
        current = time.time()
        subprocess.check_call(
            [python_executable, "-m", "pip", "install", "--upgrade", package_name]
        )
        now = time.time()
        time_passed = str(now - current)[:4]
        print(f"{package_name} installed successfully in {time_passed} seconds!!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error installing {package_name}: {e}")
        return False
        

if __name__ == "__main__":
    '''Run the script'''
    
    # establish connection to the MetaTrader 5 terminal
    if not mt5.initialize():
        print("initialize() failed, error code =",mt5.last_error())
        quit()
    
    # setup virtual enviornment and install requirement
    setup_venv("venv")
    install_package("pytz")
   
    # example: copy and print rates
    rates = CopyRates("EURUSD", PERIOD_D1, 0, 3)
    for rate in rates:
        print(rate)
   
    # shut down connection to the MetaTrader 5 terminal
    mt5.shutdown()
