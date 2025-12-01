# Healthcare API with R Plumber
library(plumber)
library(jsonlite)
library(dplyr)

# Load patient data
patients_data <- read.csv("patients_data.csv", stringsAsFactors = FALSE)
patients_data$date_of_birth <- as.Date(patients_data$date_of_birth)

#* @apiTitle Healthcare Patient API
#* @apiDescription API for accessing patient information
#* @apiVersion 1.0.0

#* Health check endpoint
#* @get /health
function() {
  list(
    status = "healthy",
    timestamp = Sys.time(),
    version = "1.0.0"
  )
}

#* Get all patients
#* @get /patients
#* @serializer json
function() {
  patients_data
}

#* Get patient by ID
#* @param id:int Patient ID
#* @get /patients/<id>
#* @serializer json
function(id) {
  id <- as.integer(id)
  patient <- patients_data %>%
    filter(patient_id == id)
  
  if (nrow(patient) == 0) {
    stop("Patient not found")
  }
  
  patient
}

#* Get patients by insurance type
#* @param insurance_id Insurance ID (e.g., INS001, SELF_PAY)
#* @get /patients/insurance/<insurance_id>
#* @serializer json
function(insurance_id) {
  patients <- patients_data %>%
    filter(insurance_id == !!insurance_id)
  
  if (nrow(patients) == 0) {
    return(list(message = "No patients found with this insurance"))
  }
  
  patients
}

#* Get patient statistics
#* @get /stats
#* @serializer json
function() {
  list(
    total_patients = nrow(patients_data),
    insurance_breakdown = patients_data %>%
      group_by(insurance_id) %>%
      summarise(count = n(), .groups = "drop") %>%
      as.list(),
    avg_age = round(mean(as.numeric(Sys.Date() - patients_data$date_of_birth) / 365.25), 1)
  )
}

#* Create new patient (POST endpoint)
#* @param patient_id:int Patient ID
#* @param name:character Patient name
#* @param date_of_birth:character Date of birth (YYYY-MM-DD)
#* @param insurance_id:character Insurance ID
#* @post /patients
#* @serializer json
function(patient_id, name, date_of_birth, insurance_id = "SELF_PAY") {
  new_patient <- data.frame(
    patient_id = as.integer(patient_id),
    name = name,
    date_of_birth = as.Date(date_of_birth),
    insurance_id = insurance_id,
    stringsAsFactors = FALSE
  )
  
  # Check if patient already exists
  if (any(patients_data$patient_id == new_patient$patient_id)) {
    stop("Patient ID already exists")
  }
  
  # Add to data (note: this is in-memory, resets on container restart)
  patients_data <<- rbind(patients_data, new_patient)
  
  list(
    message = "Patient created successfully",
    patient = new_patient
  )
}

# Error handling is now managed by plumber's default error handlers
