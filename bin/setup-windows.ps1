# Windows-specific setup script with psycopg2 workaround
Write-Host "**************************************************" -ForegroundColor Green
Write-Host " Setting up TDD/BDD Final Project Environment (Windows)" -ForegroundColor Green
Write-Host "**************************************************" -ForegroundColor Green

Write-Host "*** Checking Python installation..." -ForegroundColor Yellow
$pythonVersion = python --version 2>$null
Write-Host "Python version: $pythonVersion" -ForegroundColor Green

Write-Host "*** Creating virtual environment..." -ForegroundColor Yellow
python -m venv venv

Write-Host "*** Activating virtual environment..." -ForegroundColor Yellow
& "venv\Scripts\Activate.ps1"

Write-Host "*** Upgrading pip and wheel..." -ForegroundColor Yellow
python -m pip install --upgrade pip wheel setuptools

Write-Host "*** Installing PostgreSQL adapter for Windows..." -ForegroundColor Yellow
# Try psycopg2-binary first, fallback to alternatives if it fails
$psycopgInstalled = $false
try {
    pip install psycopg2-binary --only-binary=psycopg2-binary --no-cache-dir
    $psycopgInstalled = $true
    Write-Host "psycopg2-binary installed successfully" -ForegroundColor Green
} catch {
    Write-Host "psycopg2-binary failed, trying alternative..." -ForegroundColor Yellow
    try {
        pip install psycopg2cffi
        $psycopgInstalled = $true
        Write-Host "psycopg2cffi installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Installing pg8000 as PostgreSQL adapter..." -ForegroundColor Yellow
        pip install pg8000
        $psycopgInstalled = $true
    }
}

Write-Host "*** Installing other dependencies..." -ForegroundColor Yellow
pip install flask flask-restx flask-sqlalchemy python-dotenv gunicorn
pip install pytest pytest-cov pytest-flask factory-boy faker
pip install behave selenium requests

Write-Host "*** Setting up environment file..." -ForegroundColor Yellow
if (Test-Path "dot-env-example") {
    Copy-Item "dot-env-example" ".env"
    Write-Host ".env file created" -ForegroundColor Green
} else {
    Write-Host "dot-env-example not found, skipping .env creation" -ForegroundColor Yellow
}

Write-Host "*** Checking Docker..." -ForegroundColor Yellow
try {
    $dockerInfo = docker info 2>$null
    if ($dockerInfo) {
        Write-Host "Docker is running" -ForegroundColor Green
        if (Test-Path "Makefile") {
            Write-Host "*** Starting PostgreSQL container..." -ForegroundColor Yellow
            make db
            docker ps --filter "name=postgres"
        } else {
            Write-Host "Makefile not found, skipping database setup" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    }
} catch {
    Write-Host "Docker not found. Please install Docker Desktop." -ForegroundColor Red
}

Write-Host "**************************************************" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "**************************************************" -ForegroundColor Green
Write-Host "To activate the virtual environment:" -ForegroundColor Cyan
Write-Host "  venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue"