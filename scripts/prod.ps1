#!/usr/bin/env pwsh

# Production startup script for Acquisition App with Neon Cloud
# This script starts the application in production mode using docker-compose.prod.yml
# Usage: powershell -ExecutionPolicy Bypass -File ./scripts/prod.ps1

Write-Host "🚀 Starting Acquisition App in Production Mode" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Check if .env.production exists
if (!(Test-Path ".env.production")) {
    Write-Host "❌ Error: .env.production file not found!" -ForegroundColor Red
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
    Write-Host "❌ Error: Docker is not running!" -ForegroundColor Red
    Write-Host "   Please start Docker and try again." -ForegroundColor Red
    exit 1
}

Write-Host "📦 Building and starting production containers..." -ForegroundColor Yellow
Write-Host "   - Using Neon Cloud Database (no local proxy)" -ForegroundColor Yellow
Write-Host "   - Running in optimized production mode" -ForegroundColor Yellow
Write-Host ""

# Bring up production compose in detached mode
Write-Host "⏳ Bringing up docker compose (prod)..." -ForegroundColor Blue
$composeFile = "docker-compose.prod.yml"

if (!(Test-Path $composeFile)) {
    Write-Host "❌ Error: $composeFile not found in project root!" -ForegroundColor Red
    Write-Host "   Make sure docker-compose.prod.yml exists and try again." -ForegroundColor Red
    exit 1
}

# Run docker compose up - build and detach
$up = Start-Process -FilePath "docker" -ArgumentList @("compose", "-f", $composeFile, "up", "--build", "-d") -NoNewWindow -PassThru -Wait
if ($up.ExitCode -ne 0) {
    Write-Host "❌ Error: docker compose up failed with exit code $($up.ExitCode)." -ForegroundColor Red
    exit $up.ExitCode
}

# Basic wait so services can start (tune if needed)
Write-Host "⏳ Waiting a few seconds for containers to initialize..." -ForegroundColor Blue
Start-Sleep -Seconds 5

# Run migrations with Drizzle (will use .env.production variables)
Write-Host "📜 Applying latest schema with Drizzle (npm run db:migrate)..." -ForegroundColor Blue
$npm = Start-Process -FilePath "npm" -ArgumentList @("run","db:migrate") -NoNewWindow -PassThru -Wait
if ($npm.ExitCode -ne 0) {
    Write-Host "⚠️ Warning: db:migrate exited with code $($npm.ExitCode). Check logs for details." -ForegroundColor Yellow
    Write-Host "   You can re-run migrations manually: npm run db:migrate" -ForegroundColor Yellow
} else {
    Write-Host "✅ Migrations applied (or were already up to date)." -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Production environment started!" -ForegroundColor Green
Write-Host "   Application (containerized) should be available on the port configured in your docker-compose.prod.yml" -ForegroundColor Green
Write-Host "   To view logs: docker logs -f <container-name> (or use the service name from docker-compose.prod.yml)" -ForegroundColor Green
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "   View logs: docker compose -f $composeFile logs -f" -ForegroundColor Yellow
Write-Host "   Stop app: docker compose -f $composeFile down" -ForegroundColor Yellow
Write-Host ""
