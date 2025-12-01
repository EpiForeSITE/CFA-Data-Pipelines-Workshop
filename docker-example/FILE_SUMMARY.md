# Docker Example - Complete File Listing

## 📁 Project Structure

```
docker-example/
│
├── 📄 README.md                    # Main documentation
├── 📄 QUICK_REFERENCE.md           # Command cheat sheet
├── 📄 ARCHITECTURE.md              # Visual diagrams
├── 📄 docker-compose.yml           # Container orchestration
├── 📄 .env.example                 # Environment template
├── 📄 .gitignore                   # Git ignore rules
├── 📜 validate.sh                  # Linux/Mac validation script
├── 📜 validate.ps1                 # Windows validation script
│
├── 📂 api/                         # R Plumber API Container
│   ├── 📄 Dockerfile               # Container build instructions
│   ├── 📜 plumber.R                # API endpoint definitions
│   └── 📊 patients_data.csv        # Sample patient data (10 records)
│
├── 📂 database/                    # PostgreSQL Database Container
│   ├── 📄 Dockerfile               # Container build instructions
│   └── 📜 init.sql                 # Database schema + sample data
│
├── 📂 r-client/                    # R Pipeline Client
│   ├── 📜 healthcare_pipeline.R    # Main pipeline script
│   └── 📜 install_packages.R       # Package installation helper
│
└── 📂 python-client/               # Python Pipeline Client
    ├── 🐍 healthcare_pipeline.py   # Main pipeline script
    └── 📄 requirements.txt         # Python dependencies
```

## 📋 File Purposes

### Root Directory

| File | Purpose |
|------|---------|
| `README.md` | Complete setup guide, architecture overview, troubleshooting |
| `QUICK_REFERENCE.md` | Quick command reference for common operations |
| `ARCHITECTURE.md` | Visual diagrams of system architecture and data flow |
| `docker-compose.yml` | Defines both containers, networking, volumes |
| `.env.example` | Template for environment variables |
| `.gitignore` | Prevents committing sensitive files |
| `validate.sh` | Linux/Mac script to verify setup |
| `validate.ps1` | Windows PowerShell script to verify setup |

### api/ Directory

| File | Lines | Purpose |
|------|-------|---------|
| `Dockerfile` | 21 | Builds R container with Plumber |
| `plumber.R` | 115 | REST API with 6 endpoints |
| `patients_data.csv` | 11 | 10 patient records (header + data) |

**API Endpoints:**
- `GET /health` - Health check
- `GET /patients` - List all patients
- `GET /patients/{id}` - Get single patient
- `GET /patients/insurance/{id}` - Filter by insurance
- `GET /stats` - Statistics
- `POST /patients` - Create patient

### database/ Directory

| File | Lines | Purpose |
|------|-------|---------|
| `Dockerfile` | 12 | Builds PostgreSQL container |
| `init.sql` | 150+ | Creates 3 tables + sample data |

**Database Tables:**
- `visits` - 12 healthcare visit records
- `prescriptions` - 7 medication prescriptions
- `lab_results` - 12 laboratory test results

### r-client/ Directory

| File | Lines | Purpose |
|------|-------|---------|
| `healthcare_pipeline.R` | 200+ | Full ETL pipeline in R |
| `install_packages.R` | 10 | Installs required R packages |

**Pipeline Steps:**
1. Fetch from API (httr)
2. Query database (DBI/RPostgres)
3. Combine data (dplyr)
4. Write back to database

### python-client/ Directory

| File | Lines | Purpose |
|------|-------|---------|
| `healthcare_pipeline.py` | 230+ | Full ETL pipeline in Python |
| `requirements.txt` | 4 | Python package dependencies |

**Pipeline Steps:**
1. Fetch from API (requests)
2. Query database (psycopg2/SQLAlchemy)
3. Combine data (pandas)
4. Write back to database
5. Test POST endpoint

## 🚀 Getting Started (3 Steps)

### Step 1: Start Containers
```bash
docker-compose up -d --build
```

### Step 2: Verify Setup
```bash
# Windows
.\validate.ps1

# Linux/Mac
./validate.sh
```

### Step 3: Run Pipeline
```bash
# R version
Rscript r-client/healthcare_pipeline.R

# Python version
python python-client/healthcare_pipeline.py
```

## 📊 What Gets Created

### During Container Startup
1. **API Container** (`healthcare_api`)
   - Loads 10 patient records into memory
   - Starts REST API on port 8000
   - Serves HTTP requests

2. **Database Container** (`healthcare_db`)
   - Creates PostgreSQL database
   - Creates 3 tables (visits, prescriptions, lab_results)
   - Inserts 31 total records
   - Listens on port 5432

### During Pipeline Execution
1. **API Data Fetched**
   - 10 patients from `/patients` endpoint
   - Converted to DataFrame/tibble

2. **Database Data Queried**
   - Visit summary aggregated
   - Prescription counts calculated
   - Lab result counts calculated

3. **Combined Dataset Created**
   - Patient demographics (from API)
   - Visit statistics (from database)
   - Merged on `patient_id`

4. **New Table Written**
   - `patient_summary` table created
   - 10 rows written
   - Contains combined data

## 🔍 Data Relationships

```
Patients (API)           Visits (DB)
└─ patient_id ──────────┬─ patient_id
                        │
                        ├─ Prescriptions (DB)
                        │  └─ visit_id → visit_id
                        │
                        └─ Lab Results (DB)
                           └─ visit_id → visit_id
```

## 💾 Data Volumes

| Item | Count | Storage |
|------|-------|---------|
| Patients (API) | 10 | In-memory CSV |
| Visits (DB) | 12 | PostgreSQL volume |
| Prescriptions (DB) | 7 | PostgreSQL volume |
| Lab Results (DB) | 12 | PostgreSQL volume |
| **Total Records** | **41** | **~50 KB** |

## 🎓 Learning Path

1. **Beginner:** Run both pipelines, compare outputs
2. **Intermediate:** Modify API endpoints, add new queries
3. **Advanced:** Add authentication, implement caching, add monitoring

## 🛠️ Customization Ideas

- Add more API endpoints (PUT, DELETE)
- Implement authentication (API keys, JWT)
- Add data validation (pandera, validate)
- Create scheduled jobs (cron, APScheduler)
- Add monitoring (Prometheus metrics)
- Implement caching (Redis)
- Add logging aggregation (ELK stack)
- Create web dashboard (Shiny, Streamlit)

## 📚 Technologies Used

| Technology | Version | Purpose |
|------------|---------|---------|
| Docker | Latest | Containerization |
| Docker Compose | Latest | Multi-container orchestration |
| PostgreSQL | 16 | Relational database |
| R | 4.5.1 | Programming language |
| Plumber | Latest | R REST API framework |
| Python | 3.8+ | Programming language |
| httr | Latest | R HTTP client |
| requests | Latest | Python HTTP client |
| DBI/RPostgres | Latest | R database interface |
| psycopg2 | Latest | Python PostgreSQL driver |
| dplyr | Latest | R data manipulation |
| pandas | Latest | Python data manipulation |

## ⏱️ Expected Execution Times

| Task | Duration |
|------|----------|
| Initial build | 3-5 minutes |
| Container startup | 20-30 seconds |
| Health check ready | 10-20 seconds |
| R pipeline execution | 5-10 seconds |
| Python pipeline execution | 5-10 seconds |

## 📈 Resource Usage

| Container | CPU | Memory | Disk |
|-----------|-----|--------|------|
| healthcare_api | <5% | ~200 MB | ~500 MB |
| healthcare_db | <5% | ~100 MB | ~100 MB |
| **Total** | **<10%** | **~300 MB** | **~600 MB** |

## 🎯 Workshop Alignment

This example integrates concepts from all 4 workshop sessions:

- ✅ **Session 1:** Git, environments, package management
- ✅ **Session 2:** REST APIs, HTTP requests, JSON parsing
- ✅ **Session 3:** Database connections, SQL queries, upserts
- ✅ **Session 4:** Data cleaning, pipeline integration, error handling

## 🤝 Credits

Created for the **CFA Data Pipelines Workshop** by the ForeSITE team.

---

**Questions?** See `README.md` or open an issue in the workshop repository.
