# Docker Healthcare Data Pipeline Example

A complete, hands-on example demonstrating how to build data pipelines that pull from multiple sources using Docker containers. This example uses real-world healthcare data scenarios with both an API and a database.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Environment                       │
│                                                              │
│  ┌──────────────────┐         ┌─────────────────────┐      │
│  │  R Plumber API   │         │  PostgreSQL DB      │      │
│  │  (Port 8000)     │         │  (Port 5432)        │      │
│  │                  │         │                     │      │
│  │  Patient Data    │         │  Visits             │      │
│  │  Demographics    │         │  Prescriptions      │      │
│  │  Insurance Info  │         │  Lab Results        │      │
│  └────────┬─────────┘         └──────────┬──────────┘      │
│           │                              │                  │
└───────────┼──────────────────────────────┼──────────────────┘
            │                              │
            │                              │
    ┌───────▼──────────┐          ┌────────▼─────────┐
    │                  │          │                  │
    │   R Client       │          │  Python Client   │
    │   Pipeline       │          │  Pipeline        │
    │                  │          │                  │
    └──────────────────┘          └──────────────────┘
            │                              │
            └──────────┬───────────────────┘
                       │
                 Combined Data
              (Patient + Visit Summary)
```

## 📦 What's Included

### 1. **R Plumber API Container** (`api/`)
- RESTful API serving patient demographic data
- Endpoints for patient lookup, filtering by insurance, statistics
- Built with R Plumber framework
- Sample data: 10 patients with various insurance types

### 2. **PostgreSQL Database Container** (`database/`)
- Healthcare database with visits, prescriptions, and lab results
- Pre-populated with realistic sample data
- Relational schema with foreign keys
- 12 visits, 7 prescriptions, 12 lab results

### 3. **R Client** (`r-client/`)
- Pulls data from both API and database
- Combines datasets using dplyr
- Demonstrates httr for API calls and DBI/RPostgres for database
- Writes combined data back to database

### 4. **Python Client** (`python-client/`)
- Equivalent functionality to R client
- Uses requests for API calls and pandas/psycopg2 for database
- Shows POST endpoint usage (creating new patient)
- Demonstrates data merging and transformation

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** installed and running
- **R** (version 4.0+) with packages: `httr`, `jsonlite`, `DBI`, `RPostgres`, `dplyr`
- **Python** (version 3.8+) with packages in `python-client/requirements.txt`

### Step 1: Start the Docker Containers

```bash
# Navigate to the docker-example directory
cd docker-example

# Build and start both containers
docker-compose up -d --build

# Verify containers are running
docker-compose ps
```

You should see:
```
NAME                IMAGE                    STATUS
healthcare_api      docker-example-api       Up (healthy)
healthcare_db       docker-example-database  Up (healthy)
```

### Step 2: Verify the Services

**Test the API:**
```bash
# Windows PowerShell
Invoke-WebRequest -Uri http://localhost:8000/health | Select-Object -ExpandProperty Content

# Or use curl (Git Bash, WSL, or curl for Windows)
curl http://localhost:8000/health
```

**Test the Database:**
```bash
# Using psql (if installed)
psql -h localhost -p 5432 -U healthuser -d healthcare -c "SELECT COUNT(*) FROM visits;"
# Password: healthpass
```

### Step 3: Run the R Client

```bash
# Install R packages (one-time setup)
Rscript r-client/install_packages.R

# Run the pipeline
Rscript r-client/healthcare_pipeline.R
```

### Step 4: Run the Python Client

```bash
# Install Python packages (one-time setup)
pip install -r python-client/requirements.txt

# Run the pipeline
python python-client/healthcare_pipeline.py
```

## 📊 Data Schema

### API Data (Plumber)

**Patient Demographics:**
| Field | Type | Description |
|-------|------|-------------|
| patient_id | integer | Unique patient identifier |
| name | string | Patient full name |
| date_of_birth | date | Patient date of birth |
| insurance_id | string | Insurance provider ID |

### Database Tables (PostgreSQL)

**visits:**
| Field | Type | Description |
|-------|------|-------------|
| visit_id | serial | Primary key |
| patient_id | integer | Foreign key to patients |
| visit_date | date | Date of visit |
| provider_name | varchar | Healthcare provider |
| diagnosis_code | varchar | ICD-10 diagnosis code |
| treatment_notes | text | Visit notes |

**prescriptions:**
| Field | Type | Description |
|-------|------|-------------|
| prescription_id | serial | Primary key |
| patient_id | integer | Foreign key to patients |
| visit_id | integer | Foreign key to visits |
| medication_name | varchar | Medication name |
| dosage | varchar | Dosage information |
| frequency | varchar | How often to take |
| start_date | date | Prescription start date |
| end_date | date | Prescription end date (nullable) |

**lab_results:**
| Field | Type | Description |
|-------|------|-------------|
| lab_id | serial | Primary key |
| patient_id | integer | Foreign key to patients |
| visit_id | integer | Foreign key to visits |
| test_name | varchar | Name of lab test |
| test_value | decimal | Numeric result |
| test_unit | varchar | Unit of measurement |
| normal_range | varchar | Expected normal range |
| test_date | date | Date of test |

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/patients` | Get all patients |
| GET | `/patients/{id}` | Get patient by ID |
| GET | `/patients/insurance/{insurance_id}` | Filter by insurance |
| GET | `/stats` | Patient statistics |
| POST | `/patients` | Create new patient |

### Example API Calls

**Get all patients:**
```bash
curl http://localhost:8000/patients
```

**Get patient 1001:**
```bash
curl http://localhost:8000/patients/1001
```

**Get patients with specific insurance:**
```bash
curl http://localhost:8000/patients/insurance/INS001
```

**Create new patient:**
```bash
curl -X POST http://localhost:8000/patients \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": 1011,
    "name": "New Patient",
    "date_of_birth": "1990-01-01",
    "insurance_id": "INS001"
  }'
```

## 🎯 Learning Objectives

This example demonstrates:

1. **Docker Containerization:**
   - Building custom Docker images
   - Using docker-compose for multi-container orchestration
   - Container networking and port mapping
   - Health checks and restart policies

2. **API Integration:**
   - Building RESTful APIs with R Plumber
   - Making HTTP requests (GET, POST)
   - Handling JSON data
   - Error handling and status codes

3. **Database Operations:**
   - PostgreSQL container setup
   - Database initialization with SQL scripts
   - Querying with SQL
   - Connecting from R (DBI/RPostgres) and Python (psycopg2/SQLAlchemy)

4. **Data Pipeline Patterns:**
   - Extracting data from multiple sources
   - Transforming and combining datasets
   - Loading data back to databases
   - Idempotent operations (upserts)

5. **Cross-Language Compatibility:**
   - Same workflow in R and Python
   - Language-specific best practices
   - Similar results with different tools

## 🛠️ Troubleshooting

### Containers won't start

```bash
# Check logs
docker-compose logs api
docker-compose logs database

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

### Connection refused errors

```bash
# Wait for health checks to pass
docker-compose ps

# Check if ports are already in use
netstat -an | findstr "8000"
netstat -an | findstr "5432"
```

### Database connection fails

```bash
# Verify database is ready
docker-compose exec database pg_isready -U healthuser

# Check database logs
docker-compose logs database
```

### R packages won't install

```R
# Install from specific CRAN mirror
install.packages("RPostgres", repos = "https://cloud.r-project.org/")

# On Windows, you might need Rtools
# Download from: https://cran.r-project.org/bin/windows/Rtools/
```

### Python connection errors

```bash
# Verify psycopg2 is installed correctly
pip install psycopg2-binary --force-reinstall

# Test connection
python -c "import psycopg2; print('Success!')"
```

## 🧹 Cleanup

### Stop containers (keep data)
```bash
docker-compose stop
```

### Stop and remove containers (keep data volume)
```bash
docker-compose down
```

### Remove everything including data
```bash
docker-compose down -v
```

### Remove Docker images
```bash
docker-compose down --rmi all -v
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [R Plumber Documentation](https://www.rplumber.io/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [DBI Package](https://dbi.r-dbi.org/)
- [pandas Documentation](https://pandas.pydata.org/)
- [requests Documentation](https://requests.readthedocs.io/)

## 🎓 Workshop Integration

This example integrates concepts from all workshop sessions:

- **Session 1:** Environment setup, version control
- **Session 2:** API data acquisition (REST endpoints, authentication)
- **Session 3:** Database operations (connections, queries, upserts)
- **Session 4:** Data cleaning, pipeline integration, combining sources

Use this as a reference implementation for building your own data pipelines!

## 📝 License

This example is part of the CFA Data Pipelines Workshop. Feel free to use and modify for educational purposes.

## 🤝 Contributing

Found a bug or have a suggestion? Please open an issue in the main workshop repository.

---

**Happy Pipeline Building! 🚀**
