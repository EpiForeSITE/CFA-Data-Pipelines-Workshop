#!/usr/bin/env python3
"""
Python Client for Healthcare Data Pipeline
Pulls data from both the Plumber API and PostgreSQL database
"""

import requests
import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import json

# Configuration
API_URL = "http://localhost:8000"
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'healthcare',
    'user': 'healthuser',
    'password': 'healthpass'
}

# ==============================================================================
# PART 1: Fetch data from Plumber API
# ==============================================================================

print("\n=== Fetching Patient Data from API ===")

# 1. Health check
print("\n--- Checking API health ---")
health_response = requests.get(f"{API_URL}/health")
if health_response.status_code == 200:
    health_data = health_response.json()
    print(f"✓ API is healthy")
    print(f"  Version: {health_data['version']}")
else:
    raise Exception("API health check failed!")

# 2. Get all patients
print("\n--- Getting all patients from API ---")
patients_response = requests.get(f"{API_URL}/patients")
patients_response.raise_for_status()
patients_api = pd.DataFrame(patients_response.json())
patients_api['date_of_birth'] = pd.to_datetime(patients_api['date_of_birth'])
print(f"Total patients from API: {len(patients_api)}")
print(patients_api.head(3))

# 3. Get specific patient by ID
print("\n--- Getting patient 1001 from API ---")
patient_response = requests.get(f"{API_URL}/patients/1001")
patient_response.raise_for_status()
patient_1001 = pd.DataFrame(patient_response.json())
print(patient_1001)

# 4. Get patients by insurance
print("\n--- Getting patients with INS001 insurance ---")
insurance_response = requests.get(f"{API_URL}/patients/insurance/INS001")
insurance_response.raise_for_status()
insurance_patients = pd.DataFrame(insurance_response.json())
print(f"Patients with INS001: {len(insurance_patients)}")

# 5. Get statistics
print("\n--- Getting patient statistics from API ---")
stats_response = requests.get(f"{API_URL}/stats")
stats_response.raise_for_status()
stats = stats_response.json()
print(f"Total patients: {stats['total_patients']}")
print(f"Average age: {stats['avg_age']} years")

# ==============================================================================
# PART 2: Fetch data from PostgreSQL Database
# ==============================================================================

print("\n\n=== Fetching Healthcare Data from PostgreSQL ===")

# Connect to PostgreSQL
try:
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    print("✓ Connected to PostgreSQL database")
except Exception as e:
    raise Exception(f"Failed to connect to database: {e}")

# Also create SQLAlchemy engine for pandas
engine = create_engine(
    f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@"
    f"{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

# 1. Get all visits
print("\n--- Querying visits table ---")
visits_query = """
    SELECT 
        visit_id, 
        patient_id, 
        visit_date, 
        provider_name, 
        diagnosis_code
    FROM visits
    ORDER BY visit_date DESC
    LIMIT 5
"""
visits = pd.read_sql_query(visits_query, engine)
print("Recent visits (showing 5):")
print(visits)

# 2. Get prescriptions for a specific patient
print("\n--- Querying prescriptions for patient 1002 ---")
prescriptions_query = """
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
"""
prescriptions = pd.read_sql_query(prescriptions_query, engine)
print("Prescriptions for patient 1002:")
print(prescriptions)

# 3. Get lab results with patient info
print("\n--- Joining lab results with visit information ---")
lab_results_query = """
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
"""
lab_results = pd.read_sql_query(lab_results_query, engine)
print("Lab results for patients 1001 and 1002:")
print(lab_results)

# 4. Complex query: Patient visit summary
print("\n--- Creating patient visit summary ---")
visit_summary_query = """
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
"""
visit_summary = pd.read_sql_query(visit_summary_query, engine)
print("Patient visit summary:")
print(visit_summary)

# ==============================================================================
# PART 3: Combine API and Database Data
# ==============================================================================

print("\n\n=== Combining API Patient Data with Database Visit Data ===")

# Join patient info from API with visit summary from database
combined_data = patients_api.merge(
    visit_summary, 
    on='patient_id', 
    how='left'
)

# Fill NaN values with 0 for visit counts
combined_data['total_visits'] = combined_data['total_visits'].fillna(0).astype(int)
combined_data['total_prescriptions'] = combined_data['total_prescriptions'].fillna(0).astype(int)
combined_data['total_lab_tests'] = combined_data['total_lab_tests'].fillna(0).astype(int)

print("\nCombined patient and visit data:")
print(combined_data)

# Calculate some statistics
print("\n--- Summary Statistics ---")
print(f"Patients with visits: {(combined_data['total_visits'] > 0).sum()}/{len(combined_data)}")
print(f"Average visits per patient: {combined_data['total_visits'].mean():.2f}")
print(f"Average prescriptions per patient: {combined_data['total_prescriptions'].mean():.2f}")

# ==============================================================================
# PART 4: Write combined data back to database (optional)
# ==============================================================================

print("\n\n=== Writing combined data to database ===")

# Write to database using pandas
combined_data.to_sql(
    'patient_summary', 
    engine, 
    if_exists='replace', 
    index=False
)
print("✓ Created 'patient_summary' table in database")

# Verify the write
verify_query = "SELECT COUNT(*) as count FROM patient_summary"
row_count = pd.read_sql_query(verify_query, engine)
print(f"Rows in patient_summary: {row_count['count'].iloc[0]}")

# ==============================================================================
# PART 5: Demonstration of POST endpoint (creating new patient via API)
# ==============================================================================

print("\n\n=== Testing POST endpoint (creating new patient) ===")

new_patient = {
    'patient_id': 1011,
    'name': 'Test Patient',
    'date_of_birth': '1995-06-15',
    'insurance_id': 'INS002'
}

try:
    create_response = requests.post(
        f"{API_URL}/patients",
        json=new_patient
    )
    if create_response.status_code == 200:
        result = create_response.json()
        print(f"✓ Created new patient: {result['patient']['name']}")
        
        # Verify by fetching the patient
        verify_response = requests.get(f"{API_URL}/patients/1011")
        if verify_response.status_code == 200:
            print("✓ Verified: Patient was created successfully")
            print(pd.DataFrame(verify_response.json()))
    else:
        print(f"Note: Patient might already exist (this is expected on re-runs)")
except Exception as e:
    print(f"Note: {e} (this is expected if patient already exists)")

# ==============================================================================
# Cleanup
# ==============================================================================

cursor.close()
conn.close()
engine.dispose()
print("\n✓ Disconnected from database")
print("\n=== Pipeline Complete ===\n")
