#!/usr/bin/env pwsh

# Development startup script for Acquisition App with Neon Local
# This script starts the application in development mode with Neon Local

Write-Host "🚀 Starting Acquisition App in Development Mode" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Check if .env.development exists
if (!(Test-Path ".env.development")) {
    Write-Host "❌ Error: .env.development file not found!" -ForegroundColor Red
    Write-Host "   Please copy .env.development from the template and update with your Neon credentials." -ForegroundColor Red
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
    Write-Host "   Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Create .neon_local directory if it doesn't exist
if (!(Test-Path ".neon_local")) {
    New-Item -ItemType Directory -Name ".neon_local" | Out-Null
}

# Add .neon_local to .gitignore if not already present
if (Test-Path ".gitignore") {
    $gitignoreContent = Get-Content ".gitignore" -ErrorAction SilentlyContinue
    if ($gitignoreContent -notcontains ".neon_local/") {
        Add-Content ".gitignore" ".neon_local/"
        Write-Host "✅ Added .neon_local/ to .gitignore" -ForegroundColor Green
    }
} else {
    ".neon_local/" | Out-File ".gitignore"
    Write-Host "✅ Created .gitignore and added .neon_local/" -ForegroundColor Green
}

Write-Host "📦 Building and starting development containers..." -ForegroundColor Yellow
Write-Host "   - Neon Local proxy will create an ephemeral database branch" -ForegroundColor Yellow
Write-Host "   - Application will run with hot reload enabled" -ForegroundColor Yellow
Write-Host ""

# Run migrations with Drizzle
Write-Host "📜 Applying latest schema with Drizzle..." -ForegroundColor Blue
npm run db:migrate

# Wait for the database to be ready
Write-Host "⏳ Waiting for the database to be ready..." -ForegroundColor Blue
docker compose exec neon-local psql -U neon -d neondb -c 'SELECT 1'

# Start development environment with project name for isolation
docker compose -p acquisitions-dev -f docker-compose.dev.yml up --build

Write-Host ""
Write-Host "🎉 Development environment started successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 APPLICATION LINKS:" -ForegroundColor Cyan
Write-Host "   📱 Main App: http://localhost:3001" -ForegroundColor Green
Write-Host "   ❤️  Health Check: http://localhost:3001/health" -ForegroundColor Green
Write-Host "   🗄️  Database Admin: http://localhost:8080" -ForegroundColor Green
Write-Host ""
Write-Host "🗄️  DATABASE CONNECTION:" -ForegroundColor Cyan
Write-Host "   Direct: postgres://neon:npg@localhost:5432/neondb" -ForegroundColor Green
Write-Host ""
Write-Host "⏹️  To stop: Press Ctrl+C or run 'docker compose down'" -ForegroundColor Yellow
