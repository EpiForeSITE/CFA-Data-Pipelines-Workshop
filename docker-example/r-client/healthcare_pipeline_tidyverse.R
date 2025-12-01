#!/usr/bin/env Rscript
# R Client for Healthcare Data Pipeline (Tidyverse Style)
# Uses dbplyr, rows_upsert, and logger for modern R data science workflow

# Load required libraries
library(httr)
library(jsonlite)
library(DBI)
library(RPostgres)
library(dplyr)
library(tidyr)
library(dbplyr)
library(logger)

# Configuration
API_URL <- "http://localhost:8000"
DB_HOST <- "localhost"
DB_PORT <- 5432
DB_NAME <- "healthcare"
DB_USER <- "healthuser"
DB_PASSWORD <- "healthpass"

# Setup logging
log_threshold(INFO)
log_info("Starting Healthcare Data Pipeline (Tidyverse Edition)")

# ==============================================================================
# PART 1: Fetch data from Plumber API (Tidyverse Style)
# ==============================================================================

log_info("=== Fetching Patient Data from API ===")

# 1. Health check with better error handling
check_api_health <- function() {
  log_debug("Checking API health...")
  
  health_response <- GET(paste0(API_URL, "/health"))
  
  if (status_code(health_response) == 200) {
    health_data <- content(health_response)
    log_info("✓ API is healthy (Version: {health_data$version[[1]]})")
    return(TRUE)
  } else {
    log_error("API health check failed with status: {status_code(health_response)}")
    return(FALSE)
  }
}

if (!check_api_health()) {
  stop("Cannot proceed without healthy API")
}

# 2. Get all patients using tidyverse approach
get_patients_from_api <- function() {
  log_info("Getting all patients from API...")
  
  patients_response <- GET(paste0(API_URL, "/patients"))
  stop_for_status(patients_response)
  
  patients <- content(patients_response) %>%
    bind_rows() %>%
    mutate(
      date_of_birth = as.Date(date_of_birth),
      source = "api"
    )
  
  log_info("Retrieved {nrow(patients)} patients from API")
  return(patients)
}

patients_api <- get_patients_from_api()

# Preview data
log_info("Sample of patient data:")
patients_api %>%
  select(patient_id, name, insurance_id) %>%
  head(3) %>%
  print()

# 3. Get specific patient with error handling
get_patient_by_id <- function(id) {
  log_debug("Fetching patient {id} from API...")
  
  patient_response <- GET(paste0(API_URL, "/patients/", id))
  
  if (status_code(patient_response) == 200) {
    patient <- content(patient_response) %>% 
      bind_rows() %>%
      mutate(date_of_birth = as.Date(date_of_birth))
    log_info("✓ Retrieved patient {id}: {patient$name}")
    return(patient)
  } else {
    log_warn("Could not retrieve patient {id}")
    return(tibble())
  }
}

patient_1001 <- get_patient_by_id(1001)

# 4. Get patients by insurance with functional approach
get_patients_by_insurance <- function(insurance_id) {
  log_debug("Fetching patients with insurance {insurance_id}...")
  
  insurance_response <- GET(paste0(API_URL, "/patients/insurance/", insurance_id))
  stop_for_status(insurance_response)
  
  patients <- content(insurance_response) %>% 
    bind_rows() %>%
    mutate(date_of_birth = as.Date(date_of_birth))
  
  log_info("Found {nrow(patients)} patients with {insurance_id} insurance")
  return(patients)
}

ins001_patients <- get_patients_by_insurance("INS001")

# 5. Get statistics with better formatting
get_patient_stats <- function() {
  log_debug("Fetching patient statistics...")
  
  stats_response <- GET(paste0(API_URL, "/stats"))
  stop_for_status(stats_response)
  
  stats <- content(stats_response)
  
  log_info("Patient Statistics:")
  log_info("  Total patients: {stats$total_patients[[1]]}")
  log_info("  Average age: {round(stats$avg_age[[1]], 1)} years")
  
  return(stats)
}

patient_stats <- get_patient_stats()

# ==============================================================================
# PART 2: Connect to Database with dbplyr
# ==============================================================================

log_info("=== Connecting to PostgreSQL Database ===")

# Connect to PostgreSQL with better error handling
connect_to_database <- function() {
  log_debug("Attempting database connection...")
  
  tryCatch({
    con <- dbConnect(
      RPostgres::Postgres(),
      host = DB_HOST,
      port = DB_PORT,
      dbname = DB_NAME,
      user = DB_USER,
      password = DB_PASSWORD
    )
    log_info("✓ Connected to PostgreSQL database")
    return(con)
  }, error = function(e) {
    log_error("Failed to connect to database: {e$message}")
    stop("Database connection failed")
  })
}

con <- connect_to_database()

# Create dbplyr table references
visits_tbl <- tbl(con, "visits")
prescriptions_tbl <- tbl(con, "prescriptions")
lab_results_tbl <- tbl(con, "lab_results")

log_info("✓ Created dbplyr table references")

# ==============================================================================
# PART 3: Query data using dbplyr (Lazy Evaluation)
# ==============================================================================

log_info("=== Querying Healthcare Data with dbplyr ===")

# 1. Get recent visits using dbplyr
log_info("Getting recent visits...")
recent_visits <- visits_tbl %>%
  select(visit_id, patient_id, visit_date, provider_name, diagnosis_code) %>%
  arrange(desc(visit_date)) %>%
  head(5) %>%
  collect()

log_info("Recent visits (showing {nrow(recent_visits)}):")
recent_visits %>% print()

# 2. Get prescriptions for patient 1002 using dbplyr joins
log_info("Getting prescriptions for patient 1002...")
patient_prescriptions <- prescriptions_tbl %>%
  filter(patient_id == 1002) %>%
  left_join(visits_tbl, by = "visit_id") %>%
  select(
    prescription_id,
    patient_id = patient_id.x,
    medication_name,
    dosage,
    frequency,
    start_date,
    visit_date
  ) %>%
  arrange(desc(start_date)) %>%
  collect()

log_info("Found {nrow(patient_prescriptions)} prescriptions for patient 1002")
patient_prescriptions %>% print()

# 3. Complex join: Lab results with visit info using dbplyr
log_info("Joining lab results with visit information...")
lab_with_visits <- lab_results_tbl %>%
  filter(patient_id %in% c(1001, 1002)) %>%
  left_join(visits_tbl, by = "visit_id") %>%
  select(
    patient_id = patient_id.x,
    test_name,
    test_value,
    test_unit,
    normal_range,
    test_date,
    provider_name
  ) %>%
  arrange(desc(test_date)) %>%
  collect()

log_info("Retrieved {nrow(lab_with_visits)} lab results for patients 1001 and 1002")
lab_with_visits %>% print()

# 4. Patient visit summary using dbplyr aggregations
log_info("Creating patient visit summary...")
visit_summary_db <- visits_tbl %>%
  left_join(prescriptions_tbl, by = "visit_id") %>%
  left_join(lab_results_tbl, by = "visit_id") %>%
  group_by(patient_id.x) %>%
  summarise(
    total_visits = n_distinct(visit_id),
    total_prescriptions = n_distinct(prescription_id),
    total_lab_tests = n_distinct(lab_id),
    first_visit = min(visit_date, na.rm = TRUE),
    last_visit = max(visit_date, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(patient_id = patient_id.x) %>%
  arrange(desc(total_visits)) %>%
  collect()

log_info("Patient visit summary:")
visit_summary_db %>% print()

# ==============================================================================
# PART 4: Combine API and Database Data (Tidyverse Style)
# ==============================================================================

log_info("=== Combining API Patient Data with Database Visit Data ===")

# Join using tidyverse approach with better handling of missing values
combined_data <- patients_api %>%
  left_join(visit_summary_db, by = "patient_id") %>%
  mutate(
    across(c(total_visits, total_prescriptions, total_lab_tests), ~ replace_na(.x, 0)),
    has_visits = total_visits > 0,
    visit_frequency = case_when(
      total_visits == 0 ~ "No visits",
      total_visits == 1 ~ "Single visit",
      total_visits <= 3 ~ "Few visits",
      TRUE ~ "Frequent visitor"
    )
  ) %>%
  arrange(desc(total_visits))

log_info("Combined patient and visit data:")
combined_data %>%
  select(patient_id, name, insurance_id, total_visits, visit_frequency) %>%
  print()

# Calculate summary statistics using tidyverse
summary_stats <- combined_data %>%
  summarise(
    total_patients = n(),
    patients_with_visits = sum(has_visits),
    avg_visits = round(mean(total_visits), 2),
    avg_prescriptions = round(mean(total_prescriptions), 2),
    avg_lab_tests = round(mean(total_lab_tests), 2)
  )

log_info("Summary Statistics:")
log_info("  Total patients: {summary_stats$total_patients}")
log_info("  Patients with visits: {summary_stats$patients_with_visits}/{summary_stats$total_patients}")
log_info("  Average visits per patient: {summary_stats$avg_visits}")
log_info("  Average prescriptions per patient: {summary_stats$avg_prescriptions}")
log_info("  Average lab tests per patient: {summary_stats$avg_lab_tests}")

# ==============================================================================
# PART 5: Write data using rows_upsert (Modern Tidyverse Approach)
# ==============================================================================

log_info("=== Writing combined data using rows_upsert ===")

# Prepare data for upsert
upsert_data <- combined_data %>%
  select(-source) %>%
  mutate(
    last_updated = Sys.time(),
    data_source = "api_db_combined"
  )

# Check if table exists, if not create it
if (!dbExistsTable(con, "patient_summary_tidyverse")) {
  log_info("Creating new patient_summary_tidyverse table...")
  
  # Create table with initial data
  dbWriteTable(con, "patient_summary_tidyverse", upsert_data, overwrite = TRUE)
  log_info("✓ Created patient_summary_tidyverse table with {nrow(upsert_data)} rows")
} else {
  log_info("Table exists, performing upsert operation...")
  
  # Get existing table as a tibble for rows_upsert
  existing_data <- tbl(con, "patient_summary_tidyverse") %>% collect()
  
  # Perform upsert - this updates existing records and inserts new ones
  updated_data <- existing_data %>%
    rows_upsert(upsert_data, by = "patient_id")
  
  # Write back to database
  dbWriteTable(con, "patient_summary_tidyverse", updated_data, overwrite = TRUE)
  log_info("✓ Upserted {nrow(updated_data)} rows to patient_summary_tidyverse")
}

# Verify the write operation
verification_query <- tbl(con, "patient_summary_tidyverse") %>%
  summarise(
    row_count = n(),
    last_update = max(last_updated, na.rm = TRUE)
  ) %>%
  collect()

log_info("Verification: {verification_query$row_count} rows in patient_summary_tidyverse")
log_info("Last updated: {verification_query$last_update}")

# ==============================================================================
# PART 6: Advanced Analytics with dbplyr
# ==============================================================================

log_info("=== Advanced Analytics ===")

# Create a complex analytical query using dbplyr
insurance_analysis <- tbl(con, "patient_summary_tidyverse") %>%
  group_by(insurance_id) %>%
  summarise(
    patient_count = n(),
    avg_visits = round(mean(total_visits, na.rm = TRUE), 2),
    avg_prescriptions = round(mean(total_prescriptions, na.rm = TRUE), 2),
    total_visits = sum(total_visits, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(patient_count)) %>%
  collect()

log_info("Insurance Analysis:")
insurance_analysis %>% print()

# Find high-utilization patients using dbplyr
high_utilization <- tbl(con, "patient_summary_tidyverse") %>%
  filter(total_visits >= 2 | total_prescriptions >= 2) %>%
  select(patient_id, name, insurance_id, total_visits, total_prescriptions, visit_frequency) %>%
  arrange(desc(total_visits)) %>%
  collect()

if (nrow(high_utilization) > 0) {
  log_info("High-utilization patients ({nrow(high_utilization)} found):")
  high_utilization %>% print()
} else {
  log_info("No high-utilization patients found")
}

# ==============================================================================
# Cleanup with logging
# ==============================================================================

log_info("=== Pipeline Cleanup ===")

# Disconnect from database
dbDisconnect(con)
log_info("✓ Disconnected from database")

log_info("=== Tidyverse Healthcare Pipeline Complete ===")
log_info("Successfully processed {nrow(patients_api)} patients with modern R workflow")