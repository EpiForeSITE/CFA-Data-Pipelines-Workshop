#!/usr/bin/env pwsh
# Build and Deploy Script for Quarto Website
# This script builds the site locally and pushes it to GitHub Pages

Write-Host "🚀 Building Quarto website..." -ForegroundColor Green

# Step 1: Build the healthcare database
Write-Host "📊 Creating healthcare database..." -ForegroundColor Yellow
Set-Location exercises
python 03-healthcare-database.py
Set-Location ..

# Step 2: Clean previous build
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
if (Test-Path "_site") {
    Remove-Item "_site" -Recurse -Force
}

# Step 3: Render the site
Write-Host "🔨 Rendering Quarto site..." -ForegroundColor Yellow
quarto render

# Step 4: Check if build was successful
if (-not (Test-Path "_site/index.html")) {
    Write-Host "❌ Build failed - no index.html found!" -ForegroundColor Red
    exit 1
}

# Step 5: Add and commit the built site
Write-Host "📝 Committing built site..." -ForegroundColor Yellow
git add .
git add _site/ --force  # Force add even though it might be in gitignore
git commit -m "build: update website with latest content

- Built locally with Quarto $(quarto --version)
- Includes latest slide updates
- Healthcare database generated
- Ready for GitHub Pages"

# Step 6: Push to GitHub
Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Website should be available at: https://epiforesite.github.io/CFA-Data-Pipelines-Workshop/" -ForegroundColor Cyan