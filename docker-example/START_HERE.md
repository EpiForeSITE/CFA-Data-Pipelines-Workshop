# 🐳 Start Here - Docker Healthcare Pipeline Example

Welcome! This folder contains a **complete, working example** of a data pipeline using Docker containers.

## 🎯 What This Is

A hands-on example demonstrating:
- ✅ R Plumber REST API in a Docker container
- ✅ PostgreSQL database in a Docker container  
- ✅ R client that pulls from both sources
- ✅ Python client that pulls from both sources
- ✅ Real healthcare data scenarios

## 📖 Where to Start

### 1️⃣ **New to Docker?** Start here:
👉 Read **[README.md](README.md)** - Complete setup guide with explanations

### 2️⃣ **Just want to run it?** Quick start:
👉 Read **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Essential commands only

### 3️⃣ **Want to understand the architecture?** 
👉 Read **[ARCHITECTURE.md](ARCHITECTURE.md)** - Visual diagrams and data flow

### 4️⃣ **Need a file overview?**
👉 Read **[FILE_SUMMARY.md](FILE_SUMMARY.md)** - What each file does

## ⚡ Super Quick Start (3 Commands)

```bash
# 1. Start the containers
docker-compose up -d --build

# 2. Run the pipeline (choose R or Python)
Rscript r-client/healthcare_pipeline.R
# OR
python python-client/healthcare_pipeline.py

# 3. Stop when done
docker-compose down
```

## 📂 What's Inside

```
docker-example/
├── 📖 README.md              ← Start here if new to this
├── 📖 QUICK_REFERENCE.md     ← Commands cheat sheet
├── 📖 ARCHITECTURE.md        ← Visual diagrams
├── 📖 FILE_SUMMARY.md        ← File-by-file breakdown
├── 🐳 docker-compose.yml     ← Runs both containers
├── 📂 api/                   ← R Plumber API code
├── 📂 database/              ← PostgreSQL setup
├── 📂 r-client/              ← R pipeline script
└── 📂 python-client/         ← Python pipeline script
```

## 🎓 Learning Objectives

By working through this example, you'll learn:

1. **Docker Basics**
   - Building custom images
   - Multi-container applications
   - Container networking
   - Volume persistence

2. **API Integration**  
   - Creating REST APIs with R Plumber
   - Making HTTP GET/POST requests
   - Handling JSON data

3. **Database Operations**
   - PostgreSQL in Docker
   - SQL queries and joins
   - Connecting from R and Python

4. **Data Pipelines**
   - Extracting from multiple sources
   - Combining datasets
   - Writing to databases
   - Error handling

## ✅ Prerequisites

- **Docker Desktop** installed and running
- **R** (optional, for R client)
- **Python** (optional, for Python client)

## 🆘 Help & Troubleshooting

1. **Containers won't start?**
   ```bash
   docker-compose logs
   ```

2. **Need to verify everything works?**
   ```bash
   # Windows
   .\validate.ps1
   
   # Linux/Mac
   ./validate.sh
   ```

3. **Want to start fresh?**
   ```bash
   docker-compose down -v
   docker-compose up -d --build
   ```

## 📊 What You'll Build

```
API Container          Database Container
(Patient Data)         (Visit/Lab Data)
     │                        │
     │                        │
     └────────┬───────────────┘
              │
         Your Pipeline
              │
      Combined Patient + 
       Visit Summary
```

## 🚀 Next Steps After Completion

1. ✅ Run both R and Python versions - compare the code
2. ✅ Modify the API - add a new endpoint
3. ✅ Add a database table - extend the schema
4. ✅ Enhance the pipeline - add data validation
5. ✅ Deploy to production - add authentication, monitoring

## 💡 Pro Tips

- Use `docker-compose logs -f` to watch container output in real-time
- The API data is **in-memory** (resets on restart)
- The database data **persists** in a Docker volume
- Both pipelines do the same thing - learn from the differences!

## 📚 Integration with Workshop

This example brings together **all 4 workshop sessions**:

| Session | Concepts Applied |
|---------|------------------|
| 1 | Environment setup, git, package management |
| 2 | REST APIs, HTTP requests, authentication |
| 3 | Database connections, SQL, upserts |
| 4 | Data cleaning, pipeline integration |

## 🎉 Ready to Start?

1. Open **[README.md](README.md)** for the full guide
2. Or jump right in with the Quick Start above

**Happy Pipeline Building! 🚀**

---

Questions? See the main [workshop repository](https://github.com/EpiForeSITE/CFA-Data-Pipelines-Workshop) or ask in the discussion board.
