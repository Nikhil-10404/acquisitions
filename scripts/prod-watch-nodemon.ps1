#!/usr/bin/env pwsh

Write-Host "Starting Enhanced Production Hot Reload with Nodemon..." -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

# Basic checks
if (!(Test-Path ".env.production")) {
    Write-Host "ERROR: .env.production not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Installing nodemon if not present..." -ForegroundColor Yellow
npm install

Write-Host "Cleaning up existing containers..." -ForegroundColor Yellow
docker compose -p acquisitions-watch-improved -f docker-compose.watch-improved.yml down 2>$null

Write-Host "" 
Write-Host "APPLICATION READY:" -ForegroundColor Cyan
Write-Host "  Main App: http://localhost:3000" -ForegroundColor Green
Write-Host "  Health: http://localhost:3000/health" -ForegroundColor Green
Write-Host ""
Write-Host "ENHANCED HOT RELOAD ACTIVE - Edit src/ files to see changes!" -ForegroundColor Magenta
Write-Host "Using nodemon with polling for Windows compatibility!" -ForegroundColor Magenta
Write-Host "Press Ctrl+C to stop..." -ForegroundColor Yellow
Write-Host ""

# Start with enhanced hot reload using nodemon
docker compose -p acquisitions-watch-improved -f docker-compose.watch-improved.yml up --build