"""
Create a sample healthcare database for the Database workshop
This script creates an SQLite database with sample data matching the workshop examples
"""

import sqlite3
from datetime import datetime, timedelta
import random

# Connect to database (creates file if it doesn't exist)
conn = sqlite3.connect('healthcare.db')
cursor = conn.cursor()

# Drop tables if they exist (for clean slate)
cursor.execute('DROP TABLE IF EXISTS outpatient_visits')
cursor.execute('DROP TABLE IF EXISTS patients')
cursor.execute('DROP TABLE IF EXISTS providers')
cursor.execute('DROP TABLE IF EXISTS diagnoses')

# Create tables
cursor.execute('''
CREATE TABLE patients (
    patient_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    insurance_id TEXT
)
''')

cursor.execute('''
CREATE TABLE providers (
    provider_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    specialty TEXT NOT NULL
)
''')

cursor.execute('''
CREATE TABLE diagnoses (
    diagnosis_id INTEGER PRIMARY KEY,
    icd_code TEXT NOT NULL,
    description TEXT NOT NULL
)
''')

cursor.execute('''
CREATE TABLE outpatient_visits (
    visit_id INTEGER PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    provider_id INTEGER NOT NULL,
    diagnosis_id INTEGER NOT NULL,
    visit_date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(diagnosis_id)
)
''')

# Insert sample patients
patients_data = [
    (1, 'John Smith', '1975-03-15', 'INS001'),
    (2, 'Mary Johnson', '1982-07-22', 'INS002'),
    (3, 'Robert Williams', '1990-11-08', 'INS003'),
    (4, 'Patricia Brown', '1965-05-30', 'INS004'),
    (5, 'Michael Jones', '1978-09-12', 'INS005'),
    (6, 'Jennifer Garcia', '1988-02-17', 'INS006'),
    (7, 'William Miller', '1972-12-03', 'INS007'),
    (8, 'Elizabeth Davis', '1995-06-25', None),
    (9, 'David Rodriguez', '1980-04-18', 'INS009'),
    (10, 'Sarah Martinez', '1992-08-09', 'INS010'),
]

cursor.executemany(
    'INSERT INTO patients (patient_id, name, date_of_birth, insurance_id) VALUES (?, ?, ?, ?)',
    patients_data
)

# Insert sample providers
providers_data = [
    (1, 'Dr. Emily Chen', 'Cardiology'),
    (2, 'Dr. James Wilson', 'Neurology'),
    (3, 'Dr. Sarah Thompson', 'Family Medicine'),
    (4, 'Dr. Michael Anderson', 'Orthopedics'),
    (5, 'Dr. Lisa Rodriguez', 'Cardiology'),
    (6, 'Dr. Robert Lee', 'Neurology'),
    (7, 'Dr. Amanda White', 'Family Medicine'),
]

cursor.executemany(
    'INSERT INTO providers (provider_id, name, specialty) VALUES (?, ?, ?)',
    providers_data
)

# Insert sample diagnoses
diagnoses_data = [
    (1, 'I10', 'Essential (primary) hypertension'),
    (2, 'E11.9', 'Type 2 diabetes mellitus without complications'),
    (3, 'J06.9', 'Acute upper respiratory infection, unspecified'),
    (4, 'M54.5', 'Low back pain'),
    (5, 'I25.10', 'Atherosclerotic heart disease'),
    (6, 'G43.909', 'Migraine, unspecified, not intractable'),
    (7, 'J45.20', 'Mild intermittent asthma, uncomplicated'),
    (8, 'K21.9', 'Gastro-esophageal reflux disease without esophagitis'),
    (9, 'M17.9', 'Osteoarthritis of knee, unspecified'),
    (10, 'F41.1', 'Generalized anxiety disorder'),
]

cursor.executemany(
    'INSERT INTO diagnoses (diagnosis_id, icd_code, description) VALUES (?, ?, ?)',
    diagnoses_data
)

# Insert sample outpatient visits
# Generate visits over the past 6 months
visits_data = []
visit_id = 1
base_date = datetime.now() - timedelta(days=180)

for patient_id in range(1, 11):
    # Each patient has 1-4 visits
    num_visits = random.randint(1, 4)
    for _ in range(num_visits):
        days_offset = random.randint(0, 180)
        visit_date = (base_date + timedelta(days=days_offset)).strftime('%Y-%m-%d')
        provider_id = random.randint(1, 7)
        diagnosis_id = random.randint(1, 10)
        
        visits_data.append((visit_id, patient_id, provider_id, diagnosis_id, visit_date))
        visit_id += 1

cursor.executemany(
    'INSERT INTO outpatient_visits (visit_id, patient_id, provider_id, diagnosis_id, visit_date) VALUES (?, ?, ?, ?, ?)',
    visits_data
)

# Create indexes for better query performance
cursor.execute('CREATE INDEX idx_patients_name ON patients(name)')
cursor.execute('CREATE INDEX idx_visits_date ON outpatient_visits(visit_date)')
cursor.execute('CREATE INDEX idx_visits_patient ON outpatient_visits(patient_id)')
cursor.execute('CREATE INDEX idx_visits_provider ON outpatient_visits(provider_id)')

# Commit changes
conn.commit()

# Display summary
print("Healthcare database created successfully!")
print("\nDatabase Summary:")
print(f"- Patients: {len(patients_data)}")
print(f"- Providers: {len(providers_data)}")
print(f"- Diagnoses: {len(diagnoses_data)}")
print(f"- Outpatient Visits: {len(visits_data)}")

# Example queries
print("\n" + "="*50)
print("Example Queries:")
print("="*50)

print("\n1. All patients:")
cursor.execute("SELECT * FROM patients LIMIT 5")
for row in cursor.fetchall():
    print(f"   {row}")

print("\n2. Visits with patient and provider names:")
cursor.execute("""
    SELECT p.name as patient_name, v.visit_date, pr.name as provider_name, d.description
    FROM patients p
    INNER JOIN outpatient_visits v ON p.patient_id = v.patient_id
    INNER JOIN providers pr ON v.provider_id = pr.provider_id
    INNER JOIN diagnoses d ON v.diagnosis_id = d.diagnosis_id
    LIMIT 5
""")
for row in cursor.fetchall():
    print(f"   {row}")

print("\n3. Visit count by provider specialty:")
cursor.execute("""
    SELECT pr.specialty, COUNT(*) as visit_count
    FROM providers pr
    INNER JOIN outpatient_visits v ON pr.provider_id = v.provider_id
    GROUP BY pr.specialty
    ORDER BY visit_count DESC
""")
for row in cursor.fetchall():
    print(f"   {row}")

# Close connection
conn.close()

print("\nDatabase file: healthcare.db")
print("You can now use this database for workshop examples!")
