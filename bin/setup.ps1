# PowerShell setup script for Windows
Write-Host "**************************************************" -ForegroundColor Green
Write-Host " Setting up TDD/BDD Final Project Environment" -ForegroundColor Green
Write-Host "**************************************************" -ForegroundColor Green

Write-Host "*** Checking if Python is installed..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>$null
    Write-Host "*** Python version: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.9+ from https://python.org" -ForegroundColor Red
    Write-Host "Make sure to check 'Add Python to PATH' during installation" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "*** Creating a Python virtual environment" -ForegroundColor Yellow
python -m venv venv

Write-Host "*** Activating virtual environment and installing dependencies..." -ForegroundColor Yellow
& "venv\Scripts\Activate.ps1"
python -m pip install --upgrade pip wheel

Write-Host "*** Installing PostgreSQL adapter for Windows..." -ForegroundColor Yellow
$psycopgInstalled = $false

# Try psycopg2 first (works with local PostgreSQL)
try {
    pip install psycopg2 --no-cache-dir
    $psycopgInstalled = $true
    Write-Host "psycopg2 installed successfully" -ForegroundColor Green
} catch {
    Write-Host "psycopg2 failed, trying psycopg2-binary..." -ForegroundColor Yellow
    try {
        pip install psycopg2-binary --only-binary=psycopg2-binary --no-cache-dir
        $psycopgInstalled = $true
        Write-Host "psycopg2-binary installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Installing alternative PostgreSQL adapter..." -ForegroundColor Yellow
        pip install pg8000
        $psycopgInstalled = $true
        Write-Host "pg8000 installed as PostgreSQL adapter" -ForegroundColor Green
    }
}

Write-Host "*** Installing remaining dependencies..." -ForegroundColor Yellow
pip install flask flask-restx flask-sqlalchemy python-dotenv gunicorn
pip install pytest pytest-cov pytest-flask factory-boy faker
pip install behave selenium requests

Write-Host "*** Establishing .env file" -ForegroundColor Yellow
if (Test-Path "dot-env-example") {
    Copy-Item "dot-env-example" ".env"
    Write-Host ".env file created from template" -ForegroundColor Green
} else {
    Write-Host "Creating basic .env file..." -ForegroundColor Yellow
    @"
DATABASE_URI=postgresql://postgres:password@localhost:5432/postgres
FLASK_APP=service:app
FLASK_DEBUG=True
"@ | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "Basic .env file created" -ForegroundColor Green
}

Write-Host "*** Checking database options..." -ForegroundColor Yellow

# Check for local PostgreSQL first
$localPostgres = $false
try {
    psql --version | Out-Null
    $localPostgres = $true
    Write-Host "Local PostgreSQL found" -ForegroundColor Green
} catch {
    Write-Host "Local PostgreSQL not found in PATH" -ForegroundColor Yellow
}

# Check Docker as fallback
$dockerRunning = $false
try {
    $dockerInfo = docker info 2>$null
    if ($dockerInfo) {
        $dockerRunning = $true
        Write-Host "Docker is running" -ForegroundColor Green
    }
} catch {
    Write-Host "Docker not available" -ForegroundColor Yellow
}

if ($localPostgres) {
    Write-Host "*** Using local PostgreSQL installation" -ForegroundColor Green
    Write-Host "Make sure PostgreSQL service is running" -ForegroundColor Yellow
    Write-Host "Update .env file with your PostgreSQL credentials" -ForegroundColor Yellow
} elseif ($dockerRunning) {
    try {
        Write-Host "*** Starting PostgreSQL Docker container..." -ForegroundColor Yellow
        if (Test-Path "Makefile") {
            make db
            docker ps --filter "name=postgres"
        } else {
            Write-Host "Makefile not found, skipping Docker setup" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error starting Docker container" -ForegroundColor Red
    }
} else {
    Write-Host "*** No database found" -ForegroundColor Red
    Write-Host "Please either:" -ForegroundColor Yellow
    Write-Host "  1. Install PostgreSQL locally, or" -ForegroundColor Yellow
    Write-Host "  2. Install Docker Desktop" -ForegroundColor Yellow
}

Write-Host "**************************************************" -ForegroundColor Green
Write-Host " TDD/BDD Final Project Environment Setup Complete" -ForegroundColor Green
Write-Host "**************************************************" -ForegroundColor Green
Write-Host ""
Write-Host "Virtual environment: venv\Scripts\Activate.ps1" -ForegroundColor Cyan
if ($localPostgres) {
    Write-Host "Database: Local PostgreSQL (update .env with your credentials)" -ForegroundColor Cyan
} elseif ($dockerRunning) {
    Write-Host "Database: Docker PostgreSQL container" -ForegroundColor Cyan
} else {
    Write-Host "Database: Not configured - install PostgreSQL or Docker" -ForegroundColor Yellow
}
Write-Host ""
Read-Host "Press Enter to continue"