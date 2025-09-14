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

# Run docker compose up - build and detach
$up = Start-Process -FilePath "docker" -ArgumentList @("compose", "-f", $composeFile, "up", "--build", "-d") -NoNewWindow -PassThru -Wait
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
}

Write-Host ""
Write-Host "[COMPLETE] Production environment started!" -ForegroundColor Green
Write-Host "   Application (containerized) should be available on the port configured in your docker-compose.prod.yml" -ForegroundColor Green
Write-Host "   To view logs: docker logs -f [container-name] (or use the service name from docker-compose.prod.yml)" -ForegroundColor Green
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "   View logs: docker compose -f docker-compose.prod.yml logs -f" -ForegroundColor Yellow
Write-Host "   Stop app: docker compose -f docker-compose.prod.yml down" -ForegroundColor Yellow
Write-Host ""