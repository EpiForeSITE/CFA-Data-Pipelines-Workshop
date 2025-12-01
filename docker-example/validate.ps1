# Validation script for Windows PowerShell
# Run this to verify all components are working correctly

Write-Host "========================================"
Write-Host "Docker Healthcare Pipeline Validation"
Write-Host "========================================"
Write-Host ""

$ErrorCount = 0

# Function to test command exists
function Test-Command {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# 1. Check Docker
Write-Host "1. Checking Docker..."
if (Test-Command docker) {
    Write-Host "[OK] Docker is installed" -ForegroundColor Green
    docker --version
} else {
    Write-Host "[ERROR] Docker is not installed" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# 2. Check Docker Compose
Write-Host "2. Checking Docker Compose..."
if (Test-Command docker-compose) {
    Write-Host "[OK] Docker Compose is installed" -ForegroundColor Green
    docker-compose --version
} else {
    Write-Host "[ERROR] Docker Compose is not installed" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# 3. Check containers
Write-Host "3. Checking containers..."
try {
    $containers = docker-compose ps 2>$null
    if ($containers -match "healthcare_api.*Up") {
        Write-Host "[OK] API container is running" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] API container is not running" -ForegroundColor Red
        Write-Host "  Run: docker-compose up -d"
        $ErrorCount++
    }

    if ($containers -match "healthcare_db.*Up") {
        Write-Host "[OK] Database container is running" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Database container is not running" -ForegroundColor Red
        Write-Host "  Run: docker-compose up -d"
        $ErrorCount++
    }
} catch {
    Write-Host "[ERROR] Cannot check containers (docker-compose not available or no containers)" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# 4. Test API health
Write-Host "4. Testing API health endpoint..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] API health check passed" -ForegroundColor Green
        $healthData = $response.Content | ConvertFrom-Json
        Write-Host "  Status: $($healthData.status), Version: $($healthData.version)"
    }
} catch {
    Write-Host "[ERROR] API health check failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# 5. Test API patients endpoint
Write-Host "5. Testing API patients endpoint..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/patients" -UseBasicParsing -TimeoutSec 10
    $patients = $response.Content | ConvertFrom-Json
    if ($patients.Count -ge 10) {
        Write-Host "[OK] API returns patient data ($($patients.Count) patients)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] API patient data incomplete" -ForegroundColor Red
        $ErrorCount++
    }
} catch {
    Write-Host "[ERROR] API patient test failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# 6. Test database
Write-Host "6. Testing database connectivity..."
try {
    $visitCount = docker-compose exec -T database psql -U healthuser -d healthcare -t -c "SELECT COUNT(*) FROM visits;" 2>$null
    if ($visitCount) {
        $visitCount = $visitCount.Trim()
        Write-Host "[OK] Database connection successful ($visitCount visits)" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Database connection failed" -ForegroundColor Red
        $ErrorCount++
    }
} catch {
    Write-Host "[ERROR] Database connection failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}
Write-Host ""

# 7. Check R
Write-Host "7. Checking R environment..."
if (Test-Command Rscript) {
    Write-Host "[OK] R is installed" -ForegroundColor Green
    $rVersion = Rscript --version 2>&1 | Select-Object -First 1
    Write-Host "  $rVersion"
    
    Write-Host "  Checking R packages..."
    $packages = @('httr', 'jsonlite', 'DBI', 'RPostgres', 'dplyr')
    foreach ($pkg in $packages) {
        try {
            $result = Rscript -e "if (require('$pkg', quietly=TRUE)) cat('installed') else cat('missing')" 2>$null
            if ($result -match 'installed') {
                Write-Host "    [OK] $pkg installed" -ForegroundColor Green
            } else {
                Write-Host "    [WARN] $pkg not installed" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "    [WARN] $pkg not installed" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[WARN] R is not installed (optional for R client)" -ForegroundColor Yellow
}
Write-Host ""

# 8. Check Python
Write-Host "8. Checking Python environment..."
if (Test-Command python) {
    Write-Host "[OK] Python is installed" -ForegroundColor Green
    python --version
    
    Write-Host "  Checking Python packages..."
    $packages = @('requests', 'pandas', 'psycopg2', 'sqlalchemy')
    foreach ($pkg in $packages) {
        try {
            python -c "import $pkg" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    [OK] $pkg installed" -ForegroundColor Green
            } else {
                Write-Host "    [WARN] $pkg not installed" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "    [WARN] $pkg not installed" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[WARN] Python is not installed (optional for Python client)" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "========================================"
Write-Host "Validation Summary"
Write-Host "========================================"
if ($ErrorCount -eq 0) {
    Write-Host "[SUCCESS] All checks passed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You are ready to run the pipeline:"
    Write-Host "  R:      Rscript r-client/healthcare_pipeline.R"
    Write-Host "  Python: python python-client/healthcare_pipeline.py"
} else {
    Write-Host "[FAILED] $ErrorCount check(s) failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please address the issues above before running the pipeline."
    exit 1
}
Write-Host ""