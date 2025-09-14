#!/usr/bin/env pwsh

Write-Host "Starting Production Hot Reload..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Basic checks
if (!(Test-Path ".env.production")) {
    Write-Host "ERROR: .env.production not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Cleaning up existing containers..." -ForegroundColor Yellow
docker compose -p acquisitions-watch -f docker-compose.watch.yml down 2>$null

Write-Host "" 
Write-Host "APPLICATION READY:" -ForegroundColor Cyan
Write-Host "  Main App: http://localhost:3000" -ForegroundColor Green
Write-Host "  Health: http://localhost:3000/health" -ForegroundColor Green
Write-Host ""
Write-Host "HOT RELOAD ACTIVE - Edit src/ files to see changes!" -ForegroundColor Magenta
Write-Host "Press Ctrl+C to stop..." -ForegroundColor Yellow
Write-Host ""

# Start with hot reload
docker compose -p acquisitions-watch -f docker-compose.watch.yml up --build