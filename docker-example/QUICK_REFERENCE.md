# Quick Reference Guide

## 🚀 Essential Commands

### Docker Operations

```bash
# Start everything
docker-compose up -d

# Start with rebuild
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop everything
docker-compose down

# Restart a service
docker-compose restart api
docker-compose restart database

# View running containers
docker-compose ps

# Access container shell
docker-compose exec api /bin/bash
docker-compose exec database psql -U healthuser -d healthcare
```

### API Testing

```bash
# Health check
curl http://localhost:8000/health

# Get all patients
curl http://localhost:8000/patients

# Get specific patient
curl http://localhost:8000/patients/1001

# Get by insurance
curl http://localhost:8000/patients/insurance/INS001

# Get statistics
curl http://localhost:8000/stats

# Create patient (POST)
curl -X POST http://localhost:8000/patients \
  -H "Content-Type: application/json" \
  -d '{"patient_id": 1011, "name": "Test", "date_of_birth": "1990-01-01", "insurance_id": "INS001"}'
```

### Database Queries

```bash
# Connect to database
docker-compose exec database psql -U healthuser -d healthcare

# Or from host (if psql installed)
psql -h localhost -p 5432 -U healthuser -d healthcare
```

```sql
-- Common queries
SELECT COUNT(*) FROM visits;
SELECT COUNT(*) FROM prescriptions;
SELECT COUNT(*) FROM lab_results;

-- Get patient visit summary
SELECT 
    patient_id,
    COUNT(*) as visit_count,
    MIN(visit_date) as first_visit,
    MAX(visit_date) as last_visit
FROM visits
GROUP BY patient_id;

-- Get prescriptions by patient
SELECT * FROM prescriptions WHERE patient_id = 1002;

-- Get lab results with visit info
SELECT 
    l.test_name,
    l.test_value,
    l.test_unit,
    v.visit_date,
    v.provider_name
FROM lab_results l
JOIN visits v ON l.visit_id = v.visit_id
WHERE l.patient_id = 1001;
```

## 🔧 Configuration

### Environment Variables

Create `.env` file (copy from `.env.example`):
```env
POSTGRES_DB=healthcare
POSTGRES_USER=healthuser
POSTGRES_PASSWORD=healthpass
API_PORT=8000
DB_PORT=5432
```

### Connection Strings

**R (DBI):**
```r
con <- dbConnect(
  RPostgres::Postgres(),
  host = "localhost",
  port = 5432,
  dbname = "healthcare",
  user = "healthuser",
  password = "healthpass"
)
```

**Python (psycopg2):**
```python
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="healthcare",
    user="healthuser",
    password="healthpass"
)
```

**Python (SQLAlchemy):**
```python
engine = create_engine(
    "postgresql://healthuser:healthpass@localhost:5432/healthcare"
)
```

## 📊 Sample Data Overview

### Patients (API)
- 10 patients (IDs 1001-1010)
- 3 insurance types: INS001, INS002, INS003
- 2 self-pay patients

### Visits (Database)
- 12 visits across multiple patients
- Date range: Jan-Apr 2024
- 3 providers

### Prescriptions (Database)
- 7 prescriptions
- Various medications (Lisinopril, Metformin, etc.)

### Lab Results (Database)
- 12 lab tests
- Blood pressure, HbA1c, cholesterol, etc.

## 🐛 Common Issues

### Port Already in Use
```bash
# Change ports in docker-compose.yml
ports:
  - "8001:8000"  # API
  - "5433:5432"  # Database
```

### Container Won't Start
```bash
# Check logs
docker-compose logs database
docker-compose logs api

# Rebuild
docker-compose down
docker-compose up -d --build
```

### Can't Connect to Database
```bash
# Wait for health check
docker-compose ps

# Should show "Up (healthy)"
# If not, wait 10-20 seconds
```

### R Package Installation Fails
```r
# Try different CRAN mirror
install.packages("RPostgres", 
  repos = "https://cloud.r-project.org/")

# On Windows, install Rtools first
# https://cran.r-project.org/bin/windows/Rtools/
```

## 📁 Project Structure

```
docker-example/
├── api/                    # R Plumber API container
│   ├── Dockerfile
│   ├── plumber.R          # API endpoints
│   └── patients_data.csv  # Sample patient data
├── database/               # PostgreSQL container
│   ├── Dockerfile
│   └── init.sql           # Schema and sample data
├── r-client/               # R pipeline script
│   ├── healthcare_pipeline.R
│   └── install_packages.R
├── python-client/          # Python pipeline script
│   ├── healthcare_pipeline.py
│   └── requirements.txt
├── docker-compose.yml      # Orchestration config
├── .env.example           # Environment template
└── README.md              # Full documentation
```

## 🎯 Next Steps

1. **Modify the API:** Add new endpoints in `api/plumber.R`
2. **Add Tables:** Extend `database/init.sql` with new schemas
3. **Enhance Clients:** Add data validation, cleaning, transformation
4. **Authentication:** Add API keys or OAuth to the API
5. **Monitoring:** Add logging and metrics collection
6. **Testing:** Write unit tests for API endpoints and pipelines

## 💡 Tips

- Always check container health before running clients
- Use `docker-compose logs -f` to watch real-time logs
- The API data is in-memory (resets on restart)
- The database data persists in a Docker volume
- Both clients do the same thing - compare them to learn!
