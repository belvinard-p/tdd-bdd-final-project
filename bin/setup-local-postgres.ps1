# PowerShell setup script for Windows with local PostgreSQL
Write-Host "**************************************************" -ForegroundColor Green
Write-Host " Setting up TDD/BDD Final Project Environment (Local PostgreSQL)" -ForegroundColor Green
Write-Host "**************************************************" -ForegroundColor Green

Write-Host "*** Checking Python installation..." -ForegroundColor Yellow
$pythonVersion = python --version 2>$null
Write-Host "Python version: $pythonVersion" -ForegroundColor Green

Write-Host "*** Creating virtual environment..." -ForegroundColor Yellow
python -m venv venv

Write-Host "*** Activating virtual environment..." -ForegroundColor Yellow
& "venv\Scripts\Activate.ps1"

Write-Host "*** Upgrading pip and setuptools..." -ForegroundColor Yellow
python -m pip install --upgrade pip wheel setuptools

Write-Host "*** Installing PostgreSQL adapter..." -ForegroundColor Yellow
# Since you have local PostgreSQL, psycopg2 should work better
pip install psycopg2
if ($LASTEXITCODE -ne 0) {
    Write-Host "Trying psycopg2-binary..." -ForegroundColor Yellow
    pip install psycopg2-binary
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
    Write-Host "dot-env-example not found, creating basic .env..." -ForegroundColor Yellow
    @"
DATABASE_URI=postgresql://postgres:password@localhost:5432/postgres
FLASK_APP=service:app
FLASK_DEBUG=True
"@ | Out-File -FilePath ".env" -Encoding UTF8
}

Write-Host "*** Checking PostgreSQL connection..." -ForegroundColor Yellow
try {
    psql --version | Out-Null
    Write-Host "PostgreSQL client found" -ForegroundColor Green
    Write-Host "Make sure PostgreSQL service is running" -ForegroundColor Yellow
} catch {
    Write-Host "PostgreSQL client not found in PATH" -ForegroundColor Yellow
    Write-Host "Make sure PostgreSQL is installed and running" -ForegroundColor Yellow
}

Write-Host "**************************************************" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "**************************************************" -ForegroundColor Green
Write-Host ""
Write-Host "Virtual environment: venv\Scripts\Activate.ps1" -ForegroundColor Cyan
Write-Host "Update .env file with your PostgreSQL credentials" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to continue"