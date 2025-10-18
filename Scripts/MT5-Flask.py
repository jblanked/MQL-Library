# Copyright 2024-2025,JBlanked LLC
# https://www.jblanked.com/trading-tools/

import os
import sys
import subprocess
import MetaTrader5 as mt5
import flask

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

def Ask(symbol: str) -> float:
    """Returns the ask price of the request asset"""
    symbol_info = mt5.symbol_info(symbol)
    if not symbol_info:
        print(f"Failed to fetch symbol data for {symbol}")
        return 0.0
    return symbol_info.ask


def Bid(symbol: str) -> float:
    """Returns the bid price of the request asset"""
    symbol_info = mt5.symbol_info(symbol)
    if not symbol_info:
        print(f"Failed to fetch symbol data for {symbol}")
        return 0.0
    return symbol_info.bid


if __name__ == "__main__":
    '''Run the script'''
    
    # establish connection to the MetaTrader 5 terminal
    if not mt5.initialize():
        print("initialize() failed, error code =",mt5.last_error())
        quit()
    
    # setup virtual enviornment and install requirement
    setup_venv("venv")
    install_package("flask")
    
    app = flask.Flask(__name__)

    # example: http://127.0.0.1:5000/ask/EURUSD/
    @app.route("/ask/<symbol>/")
    def get_ask():
        price = Ask("EURUSD")
        return str(price)

    # example: http://127.0.0.1:5000/bid/EURUSD/
    @app.route("/bid/<symbol>/")
    def get_bid(symbol):
        price = Bid(symbol)
        return str(price)
    
    # run the flask server
    app.run(debug=False)

    # shut down connection to the MetaTrader 5 terminal
    mt5.shutdown()
