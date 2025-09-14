#!/usr/bin/env pwsh

# Production startup script with Watch functionality
# This script starts the application in production mode with hot reload using docker-compose watch
# Usage: powershell -ExecutionPolicy Bypass -File ./scripts/prod-watch.ps1

Write-Host "[PROD-WATCH] Starting Acquisition App in Production Mode with Hot Reload" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Green

# Check if .env.production exists
if (!(Test-Path ".env.production")) {
    Write-Host "[ERROR] .env.production file not found!" -ForegroundColor Red
    Write-Host "   Please create .env.production with your production environment variables." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
} catch {
    Write-Host "[ERROR] Docker is not running!" -ForegroundColor Red
    Write-Host "   Please start Docker and try again." -ForegroundColor Red
    exit 1
}

# Check Docker Compose version (watch requires v2.22+)
$composeVersion = docker compose version --short 2>$null
if ([string]::IsNullOrEmpty($composeVersion)) {
    Write-Host "[WARNING] Could not detect Docker Compose version." -ForegroundColor Yellow
    Write-Host "   Docker Compose Watch requires v2.22 or higher." -ForegroundColor Yellow
} else {
    Write-Host "[INFO] Docker Compose version: $composeVersion" -ForegroundColor Blue
}

Write-Host "[BUILD] Building and starting production containers with watch mode..." -ForegroundColor Yellow
Write-Host "   - Using Neon Cloud Database (without local proxy)" -ForegroundColor Yellow
Write-Host "   - Running in production mode with HOT RELOAD enabled" -ForegroundColor Yellow
Write-Host "   - File changes will be synced automatically" -ForegroundColor Yellow
Write-Host ""

# Bring up production compose with watch
Write-Host "[DOCKER] Starting docker compose with watch mode..." -ForegroundColor Blue
$composeFile = "docker-compose.prod.yml"

if (!(Test-Path $composeFile)) {
    Write-Host "[ERROR] $composeFile not found in project root!" -ForegroundColor Red
    Write-Host "   Make sure docker-compose.prod.yml exists and try again." -ForegroundColor Red
    exit 1
}

# Stop any existing containers first
Write-Host "[CLEANUP] Stopping any existing containers..." -ForegroundColor Blue
docker compose -f $composeFile down *> $null

# Start with watch mode (this runs in foreground)
Write-Host "[WATCH] Starting containers with file watching enabled..." -ForegroundColor Green
Write-Host "   🔥 Hot reload is now ENABLED for production!" -ForegroundColor Green
Write-Host "   📁 Watching: ./src/ for code changes" -ForegroundColor Green  
Write-Host "   📦 Watching: ./package.json for dependency changes" -ForegroundColor Green
Write-Host "   🐳 Watching: ./Dockerfile for image changes" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 APPLICATION READY:" -ForegroundColor Cyan
Write-Host "   📱 Main App: http://localhost:3000" -ForegroundColor Green
Write-Host "   ❤️  Health Check: http://localhost:3000/health" -ForegroundColor Green
Write-Host ""
Write-Host "🔥 HOT RELOAD ACTIVE - Your changes will be synced automatically!" -ForegroundColor Magenta
Write-Host "📋 Container logs will appear below..." -ForegroundColor Cyan
Write-Host ""
Write-Host "⏹️  Press Ctrl+C to stop watch mode..." -ForegroundColor Yellow
Write-Host ""

# Run docker compose watch (this will run in foreground and show logs)
docker compose -f $composeFile watch

Write-Host ""
Write-Host "[STOPPED] Watch mode stopped." -ForegroundColor Yellow
Write-Host "   To restart: npm run prod:watch" -ForegroundColor Yellow