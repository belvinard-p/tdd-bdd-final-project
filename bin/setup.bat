@echo off
echo **************************************************
echo  Setting up TDD/BDD Final Project Environment
echo **************************************************

echo *** Checking if Python is installed...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed or not in PATH
    echo Please install Python 3.9+ from https://python.org
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo *** Checking Python version...
python --version

echo *** Creating a Python virtual environment
python -m venv venv

echo *** Activating virtual environment and installing dependencies...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip wheel
pip install -r requirements.txt

echo *** Establishing .env file
copy dot-env-example .env

echo *** Starting the Postgres Docker container...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not installed or not running
    echo Please install Docker Desktop from https://docker.com
    pause
    exit /b 1
)

make db

echo *** Checking the Postgres Docker container...
docker ps

echo **************************************************
echo  TDD/BDD Final Project Environment Setup Complete
echo **************************************************
echo.
echo Virtual environment created in 'venv' folder
echo To activate it, run: venv\Scripts\activate.bat
echo.
pause