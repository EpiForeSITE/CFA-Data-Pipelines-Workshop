# Docker Healthcare Pipeline - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Docker Compose Network                          │
│                        (healthcare_network bridge)                       │
│                                                                          │
│  ┌────────────────────────────────┐  ┌──────────────────────────────┐  │
│  │     Container: healthcare_api  │  │  Container: healthcare_db     │  │
│  │                                │  │                               │  │
│  │  ┌──────────────────────────┐  │  │  ┌────────────────────────┐  │  │
│  │  │   R Plumber REST API     │  │  │  │  PostgreSQL 16         │  │  │
│  │  │                          │  │  │  │                        │  │  │
│  │  │  Endpoints:              │  │  │  │  Tables:               │  │  │
│  │  │  • GET  /health          │  │  │  │  • visits              │  │  │
│  │  │  • GET  /patients        │  │  │  │  • prescriptions       │  │  │
│  │  │  • GET  /patients/:id    │  │  │  │  • lab_results         │  │  │
│  │  │  • GET  /patients/       │  │  │  │                        │  │  │
│  │  │         insurance/:id    │  │  │  │  Data:                 │  │  │
│  │  │  • GET  /stats           │  │  │  │  • 12 visits           │  │  │
│  │  │  • POST /patients        │  │  │  │  • 7 prescriptions     │  │  │
│  │  │                          │  │  │  │  • 12 lab results      │  │  │
│  │  │  Data:                   │  │  │  │                        │  │  │
│  │  │  • 10 patient records    │  │  │  │  Volume:               │  │  │
│  │  │  • CSV-based storage     │  │  │  │  postgres_data:/var/   │  │  │
│  │  │                          │  │  │  │    lib/postgresql/data │  │  │
│  │  └──────────────────────────┘  │  │  └────────────────────────┘  │  │
│  │                                │  │                               │  │
│  │  Port: 8000 → Host:8000        │  │  Port: 5432 → Host:5432      │  │
│  │  Health: /health endpoint      │  │  Health: pg_isready          │  │
│  └────────────────────────────────┘  └──────────────────────────────┘  │
│              ▲                                      ▲                   │
└──────────────┼──────────────────────────────────────┼───────────────────┘
               │                                      │
               │ HTTP Requests                        │ PostgreSQL Protocol
               │ (httr / requests)                    │ (DBI / psycopg2)
               │                                      │
┌──────────────┴──────────────────┬───────────────────┴─────────────────┐
│                                 │                                     │
│  ┌───────────────────────────┐  │  ┌───────────────────────────────┐  │
│  │    R Client Pipeline      │  │  │   Python Client Pipeline      │  │
│  │  (r-client/ folder)       │  │  │  (python-client/ folder)      │  │
│  │                           │  │  │                               │  │
│  │  Libraries:               │  │  │  Libraries:                   │  │
│  │  • httr (API calls)       │  │  │  • requests (API calls)       │  │
│  │  • jsonlite (JSON)        │  │  │  • pandas (DataFrames)        │  │
│  │  • DBI (DB interface)     │  │  │  • psycopg2 (PostgreSQL)      │  │
│  │  • RPostgres (driver)     │  │  │  • sqlalchemy (ORM)           │  │
│  │  • dplyr (data manip)     │  │  │                               │  │
│  │                           │  │  │                               │  │
│  │  Process:                 │  │  │  Process:                     │  │
│  │  1. Fetch from API        │  │  │  1. Fetch from API            │  │
│  │  2. Query database        │  │  │  2. Query database            │  │
│  │  3. Combine datasets      │  │  │  3. Combine datasets          │  │
│  │  4. Write to DB           │  │  │  4. Write to DB               │  │
│  │                           │  │  │  5. Test POST endpoint        │  │
│  └───────────────────────────┘  │  └───────────────────────────────┘  │
│                                 │                                     │
│  Output: patient_summary table  │  Output: patient_summary table      │
└─────────────────────────────────┴─────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────────┐
│  Start Pipeline │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  STEP 1: Extract from API               │
│  • GET /patients (all patient data)     │
│  • GET /patients/1001 (single patient)  │
│  • GET /patients/insurance/INS001       │
│  • GET /stats (aggregations)            │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  STEP 2: Extract from Database          │
│  • SELECT FROM visits                   │
│  • SELECT FROM prescriptions            │
│  • SELECT FROM lab_results              │
│  • JOIN operations for summaries        │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  STEP 3: Transform & Combine            │
│  • Convert data types                   │
│  • Join API patients with DB visits     │
│  • Calculate aggregations               │
│  • Handle missing values (fillna)       │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  STEP 4: Load (Write to Database)       │
│  • CREATE TABLE patient_summary         │
│  • INSERT combined data                 │
│  • Verify write operation               │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  End Pipeline   │
│  (Success!)     │
└─────────────────┘
```

## Container Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                     docker-compose up -d                         │
└────────────────────────┬────────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
         ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│  Build API Image    │         │  Build DB Image     │
│  (from Dockerfile)  │         │  (from Dockerfile)  │
└────────┬────────────┘         └────────┬────────────┘
         │                               │
         ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│  Start API          │         │  Start PostgreSQL   │
│  Container          │         │  Container          │
└────────┬────────────┘         └────────┬────────────┘
         │                               │
         ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│  Load plumber.R     │         │  Run init.sql       │
│  Load patients.csv  │         │  Create tables      │
│                     │         │  Insert sample data │
└────────┬────────────┘         └────────┬────────────┘
         │                               │
         ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│  Health Check:      │         │  Health Check:      │
│  GET /health        │         │  pg_isready         │
│  (wait for healthy) │         │  (wait for healthy) │
└────────┬────────────┘         └────────┬────────────┘
         │                               │
         └───────────────┬───────────────┘
                         │
                         ▼
                 ┌───────────────┐
                 │  Ready for    │
                 │  Client       │
                 │  Connections! │
                 └───────────────┘
```

## Network Communication

```
Host Machine (localhost)
│
├─ Port 8000 ──────────────► Container: healthcare_api
│                             Network: healthcare_network
│                             Internal IP: 172.x.x.2
│
└─ Port 5432 ──────────────► Container: healthcare_db
                              Network: healthcare_network
                              Internal IP: 172.x.x.3

Containers can communicate using:
• Service names (api, database)
• Internal IPs (172.x.x.x)

Clients connect using:
• localhost:8000 (API)
• localhost:5432 (Database)
```

## Volume Persistence

```
Docker Host
│
├─ Named Volume: postgres_data
│  └─ Mapped to: /var/lib/postgresql/data (in container)
│     └─ Contains: PostgreSQL database files
│        • Tables, indexes, data
│        • Transaction logs
│        • Configuration
│
└─ Benefits:
   • Data persists across container restarts
   • Data survives container removal
   • Can be backed up independently
   • Shared between container recreations
```

## Security Considerations

```
┌─────────────────────────────────────────────────────────────┐
│  Credentials Management                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ❌ NEVER in code:                                           │
│     password = "healthpass"  # BAD!                          │
│                                                              │
│  ✅ Use environment variables:                               │
│     password = os.getenv("DB_PASSWORD")  # GOOD!             │
│     password = Sys.getenv("DB_PASSWORD")  # GOOD!            │
│                                                              │
│  ✅ Use .env file (not committed to git):                    │
│     POSTGRES_PASSWORD=healthpass                             │
│                                                              │
│  ✅ In docker-compose.yml:                                   │
│     environment:                                             │
│       POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```
