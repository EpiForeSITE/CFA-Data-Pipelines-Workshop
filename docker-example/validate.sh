#!/usr/bin/env bash
# Validation script to test the Docker environment
# Run this to verify all components are working correctly

echo "========================================"
echo "Docker Healthcare Pipeline Validation"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ERRORS=0

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Docker
echo "1. Checking Docker..."
if command_exists docker; then
    echo -e "${GREEN}✓ Docker is installed${NC}"
    docker --version
else
    echo -e "${RED}✗ Docker is not installed${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check Docker Compose
echo "2. Checking Docker Compose..."
if command_exists docker-compose; then
    echo -e "${GREEN}✓ Docker Compose is installed${NC}"
    docker-compose --version
else
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check if containers are running
echo "3. Checking containers..."
if docker-compose ps | grep -q "healthcare_api.*Up"; then
    echo -e "${GREEN}✓ API container is running${NC}"
else
    echo -e "${RED}✗ API container is not running${NC}"
    echo "  Run: docker-compose up -d"
    ERRORS=$((ERRORS + 1))
fi

if docker-compose ps | grep -q "healthcare_db.*Up"; then
    echo -e "${GREEN}✓ Database container is running${NC}"
else
    echo -e "${RED}✗ Database container is not running${NC}"
    echo "  Run: docker-compose up -d"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test API health endpoint
echo "4. Testing API health endpoint..."
if command_exists curl; then
    API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
    if [ "$API_RESPONSE" = "200" ]; then
        echo -e "${GREEN}✓ API health check passed${NC}"
        curl -s http://localhost:8000/health | head -n 5
    else
        echo -e "${RED}✗ API health check failed (HTTP $API_RESPONSE)${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ curl not found, skipping API test${NC}"
fi
echo ""

# Test API patients endpoint
echo "5. Testing API patients endpoint..."
if command_exists curl; then
    PATIENTS_RESPONSE=$(curl -s http://localhost:8000/patients)
    PATIENT_COUNT=$(echo "$PATIENTS_RESPONSE" | grep -o "patient_id" | wc -l)
    if [ "$PATIENT_COUNT" -ge 10 ]; then
        echo -e "${GREEN}✓ API returns patient data ($PATIENT_COUNT patients)${NC}"
    else
        echo -e "${RED}✗ API patient data incomplete${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ curl not found, skipping patient test${NC}"
fi
echo ""

# Test database connectivity (if psql is installed)
echo "6. Testing database connectivity..."
if command_exists psql; then
    PGPASSWORD=healthpass psql -h localhost -p 5432 -U healthuser -d healthcare -c "SELECT COUNT(*) FROM visits;" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        VISIT_COUNT=$(PGPASSWORD=healthpass psql -h localhost -p 5432 -U healthuser -d healthcare -t -c "SELECT COUNT(*) FROM visits;" | tr -d ' ')
        echo -e "${GREEN}✓ Database connection successful ($VISIT_COUNT visits)${NC}"
    else
        echo -e "${RED}✗ Database connection failed${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠ psql not found, using docker exec instead${NC}"
    VISIT_COUNT=$(docker-compose exec -T database psql -U healthuser -d healthcare -t -c "SELECT COUNT(*) FROM visits;" | tr -d ' ')
    if [ ! -z "$VISIT_COUNT" ]; then
        echo -e "${GREEN}✓ Database connection successful ($VISIT_COUNT visits)${NC}"
    else
        echo -e "${RED}✗ Database connection failed${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi
echo ""

# Check R installation (if needed)
echo "7. Checking R environment..."
if command_exists Rscript; then
    echo -e "${GREEN}✓ R is installed${NC}"
    Rscript --version 2>&1 | head -n 1
    
    # Check for required packages
    echo "  Checking R packages..."
    Rscript -e "if (!require('httr', quietly=TRUE)) cat('Missing: httr\n')" 2>&1 | grep -q "Missing"
    if [ $? -ne 0 ]; then
        echo -e "  ${GREEN}✓ httr installed${NC}"
    else
        echo -e "  ${YELLOW}⚠ httr not installed${NC}"
    fi
else
    echo -e "${YELLOW}⚠ R is not installed (optional for R client)${NC}"
fi
echo ""

# Check Python installation (if needed)
echo "8. Checking Python environment..."
if command_exists python || command_exists python3; then
    PYTHON_CMD=$(command_exists python3 && echo "python3" || echo "python")
    echo -e "${GREEN}✓ Python is installed${NC}"
    $PYTHON_CMD --version
    
    # Check for required packages
    echo "  Checking Python packages..."
    $PYTHON_CMD -c "import requests" 2>/dev/null && echo -e "  ${GREEN}✓ requests installed${NC}" || echo -e "  ${YELLOW}⚠ requests not installed${NC}"
    $PYTHON_CMD -c "import pandas" 2>/dev/null && echo -e "  ${GREEN}✓ pandas installed${NC}" || echo -e "  ${YELLOW}⚠ pandas not installed${NC}"
    $PYTHON_CMD -c "import psycopg2" 2>/dev/null && echo -e "  ${GREEN}✓ psycopg2 installed${NC}" || echo -e "  ${YELLOW}⚠ psycopg2 not installed${NC}"
else
    echo -e "${YELLOW}⚠ Python is not installed (optional for Python client)${NC}"
fi
echo ""

# Summary
echo "========================================"
echo "Validation Summary"
echo "========================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You're ready to run the pipeline:"
    echo "  R:      Rscript r-client/healthcare_pipeline.R"
    echo "  Python: python python-client/healthcare_pipeline.py"
else
    echo -e "${RED}✗ $ERRORS check(s) failed${NC}"
    echo ""
    echo "Please address the issues above before running the pipeline."
    exit 1
fi
echo ""
