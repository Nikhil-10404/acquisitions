#!/usr/bin/env pwsh

# Production startup script for Acquisition App with Neon Cloud
# This script starts the application in production mode using docker-compose.prod.yml
# Usage: powershell -ExecutionPolicy Bypass -File ./scripts/prod.ps1

Write-Host "[PROD] Starting Acquisition App in Production Mode" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

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

Write-Host "[BUILD] Building and starting production containers..." -ForegroundColor Yellow
Write-Host "   - Using Neon Cloud Database (without local proxy)" -ForegroundColor Yellow
Write-Host "   - Running in optimized production mode" -ForegroundColor Yellow
Write-Host ""

# Bring up production compose in detached mode
Write-Host "[DOCKER] Bringing up docker compose (prod)..." -ForegroundColor Blue
$composeFile = "docker-compose.prod.yml"

if (!(Test-Path $composeFile)) {
    Write-Host "[ERROR] $composeFile not found in project root!" -ForegroundColor Red
    Write-Host "   Make sure docker-compose.prod.yml exists and try again." -ForegroundColor Red
    exit 1
}

# Run docker compose up - build and detach with project name for isolation
$up = Start-Process -FilePath "docker" -ArgumentList @("compose", "-p", "acquisitions-prod", "-f", $composeFile, "up", "--build", "-d") -NoNewWindow -PassThru -Wait
if ($up.ExitCode -ne 0) {
    Write-Host "[ERROR] docker compose up failed with exit code $($up.ExitCode)." -ForegroundColor Red
    exit $up.ExitCode
}

# Basic wait so services can start (tune if needed)
Write-Host "[WAIT] Waiting for containers to initialize..." -ForegroundColor Blue
Start-Sleep -Seconds 10

# Check if the container is running before attempting migrations
Write-Host "[CHECK] Checking if container is running..." -ForegroundColor Blue
$containerStatus = docker ps --filter "name=acquisitions-app-prod" --format "{{.Status}}" 2>$null
if ([string]::IsNullOrEmpty($containerStatus)) {
    Write-Host "[WARNING] Container acquisitions-app-prod is not running. Skipping migrations." -ForegroundColor Yellow
    Write-Host "   Check container status with: docker ps -a" -ForegroundColor Yellow
} else {
    Write-Host "[SUCCESS] Container is running: $containerStatus" -ForegroundColor Green
    
    # Run migrations with Drizzle inside the container (will use .env.production variables)
    Write-Host "[MIGRATE] Applying latest schema with Drizzle (docker exec npm run db:migrate)..." -ForegroundColor Blue
    $migrate = Start-Process -FilePath "docker" -ArgumentList @("exec", "acquisitions-app-prod", "npm", "run", "db:migrate") -NoNewWindow -PassThru -Wait
    if ($migrate.ExitCode -ne 0) {
        Write-Host "[WARNING] db:migrate exited with code $($migrate.ExitCode). Check logs for details." -ForegroundColor Yellow
        Write-Host "   You can re-run migrations manually: docker exec acquisitions-app-prod npm run db:migrate" -ForegroundColor Yellow
    } else {
        Write-Host "[SUCCESS] Migrations applied (or were already up to date)." -ForegroundColor Green
    }
    
    # Wait a moment for application to fully start
    Write-Host "[VERIFY] Waiting for application to be fully ready..." -ForegroundColor Blue
    Start-Sleep -Seconds 5
    
    # Test if application is accessible
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "[VERIFIED] Application is responding correctly!" -ForegroundColor Green
        }
    } catch {
        Write-Host "[WARNING] Application might still be starting up..." -ForegroundColor Yellow
        Write-Host "   If the links don't work immediately, wait a few more seconds." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[COMPLETE] Production environment started successfully!" -ForegroundColor Green
Write-Host "" 
Write-Host "🌐 APPLICATION LINKS:" -ForegroundColor Cyan
Write-Host "   📱 Main App: http://localhost:3000" -ForegroundColor Green
Write-Host "   ❤️  Health Check: http://localhost:3000/health" -ForegroundColor Green
Write-Host ""
Write-Host "📊 MONITORING:" -ForegroundColor Yellow
Write-Host "   View logs: docker logs -f acquisitions-app-prod" -ForegroundColor Yellow
Write-Host "   View compose logs: docker compose -p acquisitions-prod -f docker-compose.prod.yml logs -f" -ForegroundColor Yellow
Write-Host "   Container stats: docker stats acquisitions-app-prod" -ForegroundColor Yellow
Write-Host ""
Write-Host "🛑 MANAGEMENT:" -ForegroundColor Yellow
Write-Host "   Stop app: docker compose -p acquisitions-prod -f docker-compose.prod.yml down" -ForegroundColor Yellow
Write-Host "   Restart app: npm run prod:docker" -ForegroundColor Yellow
Write-Host ""
