#!/usr/bin/env pwsh

# Docker cleanup script to resolve network and container conflicts
# Usage: powershell -ExecutionPolicy Bypass -File ./scripts/cleanup.ps1

Write-Host "🧹 Docker Cleanup Script" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# Stop all running containers for this project
Write-Host "🛑 Stopping all acquisition containers..." -ForegroundColor Yellow
$containers = @("acquisitions-app-prod", "acquisitions-app-dev", "acquisitions-app-watch", "acquisitions-neon-local", "acquisitions-adminer")

foreach ($container in $containers) {
    $existing = docker ps -a -q --filter "name=$container" 2>$null
    if ($existing) {
        Write-Host "   Stopping $container..." -ForegroundColor Yellow
        docker stop $container *> $null
        Write-Host "   Removing $container..." -ForegroundColor Yellow  
        docker rm $container *> $null
        Write-Host "   ✅ $container cleaned up" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  $container not found (already clean)" -ForegroundColor Gray
    }
}

Write-Host ""

# Stop all compose environments
Write-Host "🐳 Stopping all Docker Compose environments..." -ForegroundColor Yellow
docker compose -p acquisitions-dev -f docker-compose.dev.yml down *> $null
docker compose -p acquisitions-prod -f docker-compose.prod.yml down *> $null
docker compose -p acquisitions-watch -f docker-compose.watch.yml down *> $null
Write-Host "   ✅ All compose environments stopped" -ForegroundColor Green

Write-Host ""

# Remove conflicting networks
Write-Host "🌐 Cleaning up networks..." -ForegroundColor Yellow
$networks = docker network ls --filter "name=acquisitions" -q 2>$null
if ($networks) {
    foreach ($network in $networks) {
        $networkName = docker network inspect $network --format "{{.Name}}" 2>$null
        if ($networkName) {
            Write-Host "   Removing network: $networkName..." -ForegroundColor Yellow
            docker network rm $network *> $null
            Write-Host "   ✅ Network $networkName removed" -ForegroundColor Green
        }
    }
} else {
    Write-Host "   ℹ️  No acquisition networks found" -ForegroundColor Gray
}

Write-Host ""

# Optional: Clean up unused Docker resources
Write-Host "🗑️  Removing unused Docker resources..." -ForegroundColor Yellow
Write-Host "   Pruning unused networks..." -ForegroundColor Gray
docker network prune -f *> $null
Write-Host "   ✅ Unused networks pruned" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Cleanup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 You can now safely run:" -ForegroundColor Cyan
Write-Host "   npm run dev:docker    (Development mode)" -ForegroundColor Green
Write-Host "   npm run prod:docker   (Production mode)" -ForegroundColor Green
Write-Host "   npm run prod:watch    (Production with hot reload)" -ForegroundColor Green
Write-Host ""