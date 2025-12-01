#!/usr/bin/env Rscript
# R Client for Healthcare Data Pipeline
# Pulls data from both the Plumber API and PostgreSQL database

# Load required libraries
library(httr)
library(jsonlite)
library(DBI)
library(RPostgres)
library(dplyr)
library(tidyr)

# Configuration
API_URL <- "http://localhost:8000"
DB_HOST <- "localhost"
DB_PORT <- 5432
DB_NAME <- "healthcare"
DB_USER <- "healthuser"
DB_PASSWORD <- "healthpass"

# ==============================================================================
# PART 1: Fetch data from Plumber API
# ==============================================================================

cat("\n=== Fetching Patient Data from API ===\n")

# 1. Health check
health_response <- GET(paste0(API_URL, "/health"))
if (status_code(health_response) == 200) {
  health_data <- content(health_response)
  cat("✓ API is healthy\n")
  cat("  Version:", health_data$version[[1]], "\n")
} else {
  stop("API health check failed!")
}

# 2. Get all patients
cat("\n--- Getting all patients from API ---\n")
patients_response <- GET(paste0(API_URL, "/patients"))
stop_for_status(patients_response)
patients_api <- content(patients_response) %>%
  bind_rows() %>%
  mutate(date_of_birth = as.Date(date_of_birth))

cat("Total patients from API:", nrow(patients_api), "\n")
print(head(patients_api, 3))

# 3. Get specific patient by ID
cat("\n--- Getting patient 1001 from API ---\n")
patient_response <- GET(paste0(API_URL, "/patients/1001"))
stop_for_status(patient_response)
patient_1001 <- content(patient_response) %>% bind_rows()
print(patient_1001)

# 4. Get patients by insurance
cat("\n--- Getting patients with INS001 insurance ---\n")
insurance_response <- GET(paste0(API_URL, "/patients/insurance/INS001"))
stop_for_status(insurance_response)
insurance_patients <- content(insurance_response) %>% bind_rows()
cat("Patients with INS001:", nrow(insurance_patients), "\n")

# 5. Get statistics
cat("\n--- Getting patient statistics from API ---\n")
stats_response <- GET(paste0(API_URL, "/stats"))
stop_for_status(stats_response)
stats <- content(stats_response)
cat("Total patients:", stats$total_patients[[1]], "\n")
cat("Average age:", stats$avg_age[[1]], "years\n")

# ==============================================================================
# PART 2: Fetch data from PostgreSQL Database
# ==============================================================================

cat("\n\n=== Fetching Healthcare Data from PostgreSQL ===\n")

# Connect to PostgreSQL
tryCatch({
  con <- dbConnect(
    RPostgres::Postgres(),
    host = DB_HOST,
    port = DB_PORT,
    dbname = DB_NAME,
    user = DB_USER,
    password = DB_PASSWORD
  )
  cat("✓ Connected to PostgreSQL database\n")
}, error = function(e) {
  stop("Failed to connect to database: ", e$message)
})

# 1. Get all visits
cat("\n--- Querying visits table ---\n")
visits <- dbGetQuery(con, "
  SELECT
    visit_id,
    patient_id,
    visit_date,
    provider_name,
    diagnosis_code
  FROM visits
  ORDER BY visit_date DESC
  LIMIT 5
")
cat("Recent visits (showing 5):\n")
print(visits)

# 2. Get prescriptions for a specific patient
cat("\n--- Querying prescriptions for patient 1002 ---\n")
prescriptions <- dbGetQuery(con, "
  SELECT
    p.prescription_id,
    p.patient_id,
    p.medication_name,
    p.dosage,
    p.frequency,
    p.start_date,
    v.visit_date
  FROM prescriptions p
  LEFT JOIN visits v ON p.visit_id = v.visit_id
  WHERE p.patient_id = 1002
  ORDER BY p.start_date DESC
")
cat("Prescriptions for patient 1002:\n")
print(prescriptions)

# 3. Get lab results with patient info
cat("\n--- Joining lab results with visit information ---\n")
lab_results <- dbGetQuery(con, "
  SELECT
    l.patient_id,
    l.test_name,
    l.test_value,
    l.test_unit,
    l.normal_range,
    l.test_date,
    v.provider_name
  FROM lab_results l
  LEFT JOIN visits v ON l.visit_id = v.visit_id
  WHERE l.patient_id IN (1001, 1002)
  ORDER BY l.test_date DESC
")
cat("Lab results for patients 1001 and 1002:\n")
print(lab_results)

# 4. Complex query: Patient visit summary
cat("\n--- Creating patient visit summary ---\n")
visit_summary <- dbGetQuery(con, "
  SELECT
    v.patient_id,
    COUNT(DISTINCT v.visit_id) as total_visits,
    COUNT(DISTINCT p.prescription_id) as total_prescriptions,
    COUNT(DISTINCT l.lab_id) as total_lab_tests,
    MIN(v.visit_date) as first_visit,
    MAX(v.visit_date) as last_visit
  FROM visits v
  LEFT JOIN prescriptions p ON v.visit_id = p.visit_id
  LEFT JOIN lab_results l ON v.visit_id = l.visit_id
  GROUP BY v.patient_id
  ORDER BY total_visits DESC
")
cat("Patient visit summary:\n")
print(visit_summary)

# ==============================================================================
# PART 3: Combine API and Database Data
# ==============================================================================

cat("\n\n=== Combining API Patient Data with Database Visit Data ===\n")

# Join patient info from API with visit summary from database
combined_data <- patients_api %>%
  left_join(visit_summary, by = "patient_id") %>%
  mutate(
    total_visits = replace_na(total_visits, 0),
    total_prescriptions = replace_na(total_prescriptions, 0),
    total_lab_tests = replace_na(total_lab_tests, 0)
  )

cat("\nCombined patient and visit data:\n")
print(combined_data)

# Calculate some statistics
cat("\n--- Summary Statistics ---\n")
cat("Patients with visits:", sum(combined_data$total_visits > 0), "/", nrow(combined_data), "\n")
cat("Average visits per patient:", round(mean(combined_data$total_visits), 2), "\n")
cat("Average prescriptions per patient:", round(mean(combined_data$total_prescriptions), 2), "\n")

# ==============================================================================
# PART 4: Write combined data back to database (optional)
# ==============================================================================

cat("\n\n=== Writing combined data to database ===\n")

# Create a new table with combined data
dbWriteTable(
  con,
  "patient_summary",
  combined_data,
  overwrite = TRUE
)
cat("✓ Created 'patient_summary' table in database\n")

# Verify the write
row_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM patient_summary")
cat("Rows in patient_summary:", as.integer(row_count$count), "\n")

# ==============================================================================
# Cleanup
# ==============================================================================

dbDisconnect(con)
cat("\n✓ Disconnected from database\n")
cat("\n=== Pipeline Complete ===\n")
