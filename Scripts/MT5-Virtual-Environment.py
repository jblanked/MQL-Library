# Copyright 2024-2025,JBlanked LLC
# https://www.jblanked.com/trading-tools/
# Demo showing how to install and activate a virtual environment and install python libraries on the fly

import MetaTrader5 as mt5
import os
import sys
import subprocess

def setup_venv(environment_name: str) -> str:
    '''Setup virtual environment and return its path'''
    
    # Create venv in user's AppData/Local directory to avoid permission issues
    user_data_dir = os.path.join(os.environ.get('LOCALAPPDATA', os.path.expanduser('~')), 'MT5_Python')
    os.makedirs(user_data_dir, exist_ok=True)
    
    venv_path = os.path.join(user_data_dir, environment_name)
    
    # Check if venv already exists
    if os.path.exists(venv_path):
        print(f"Virtual environment already exists at: {venv_path}")
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

def install_package(package_name: str, venv_python: str = None, debug: bool = True) -> bool:
    """Installs a Python package using pip."""
    import time
    
    python_executable = venv_python if venv_python else sys.executable
    
    try:
        # Check if package is already installed
        try:
            __import__(package_name)
            if package_name in sys.modules:
                print(f"{package_name} is already installed.")
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

def install_packages(venv_python: str = None) -> bool:
    '''Installs all required packages for MT5-Server.py'''
    package_list: list = [
        "pip",
        "requests",
    ]
    
    for name in package_list:
        if not install_package(name, venv_python):
            return False
    
    return True

def main() -> None:
    """Run the main function"""
    
    # Open MT5
    if not mt5.initialize():
        print("Failed to initialize MT5")
        quit()
    
    print("MT5 initialized successfully")
    
    # Setup venv in user-accessible location
    environment_name = "venv"
    venv_path = setup_venv(environment_name)
    
    if not venv_path:
        print("Failed to setup virtual environment")
        mt5.shutdown()
        quit()
    
    # Get venv Python executable path
    venv_python = get_venv_python(venv_path)
    
    # Check if venv Python exists
    if not os.path.exists(venv_python):
        print(f"Virtual environment Python not found at: {venv_python}")
        mt5.shutdown()
        quit()
    
    print(f"Using Python from virtual environment: {venv_python}")
    
    # Install packages in the virtual environment
    if not install_packages(venv_python):
        print("Failed to install required packages")
        mt5.shutdown()
        quit()
    
    print("All packages installed successfully!")
    print(f"Virtual environment location: {venv_path}")
    
    # Shut down connection to the MetaTrader 5 terminal
    mt5.shutdown()
    print("MT5 shutdown complete")

# Run the script
if __name__ == "__main__":
    main()