-- Healthcare Database Initialization Script
-- This script runs automatically when the container is first created

-- Create visits table
CREATE TABLE IF NOT EXISTS visits (
    visit_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    visit_date DATE NOT NULL,
    provider_name VARCHAR(100) NOT NULL,
    diagnosis_code VARCHAR(20),
    treatment_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create prescriptions table
CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    visit_id INTEGER REFERENCES visits(visit_id),
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create lab_results table
CREATE TABLE IF NOT EXISTS lab_results (
    lab_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    visit_id INTEGER REFERENCES visits(visit_id),
    test_name VARCHAR(100) NOT NULL,
    test_value DECIMAL(10, 2),
    test_unit VARCHAR(20),
    normal_range VARCHAR(50),
    test_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample visit data
INSERT INTO visits (patient_id, visit_date, provider_name, diagnosis_code, treatment_notes) VALUES
(1001, '2024-01-15', 'Dr. Emily Chen', 'J06.9', 'Patient presented with common cold symptoms. Advised rest and fluids.'),
(1001, '2024-03-22', 'Dr. Emily Chen', 'I10', 'Follow-up for hypertension. Blood pressure controlled.'),
(1002, '2024-01-20', 'Dr. Michael Roberts', 'E11.9', 'Diabetes management visit. A1C levels reviewed.'),
(1002, '2024-04-10', 'Dr. Michael Roberts', 'E11.9', 'Quarterly diabetes check. Adjusting insulin dosage.'),
(1003, '2024-02-05', 'Dr. Sarah Johnson', 'M54.5', 'Complaint of lower back pain. Physical therapy recommended.'),
(1004, '2024-02-14', 'Dr. Emily Chen', 'Z00.00', 'Annual physical examination. All vitals normal.'),
(1005, '2024-03-01', 'Dr. Michael Roberts', 'J45.909', 'Asthma exacerbation. Prescribed inhaler.'),
(1006, '2024-03-15', 'Dr. Sarah Johnson', 'Z23', 'Vaccination appointment. Flu shot administered.'),
(1007, '2024-04-01', 'Dr. Emily Chen', 'K21.9', 'GERD symptoms. Lifestyle modifications discussed.'),
(1008, '2024-04-12', 'Dr. Michael Roberts', 'R50.9', 'Fever of unknown origin. Ordered lab work.'),
(1009, '2024-04-20', 'Dr. Sarah Johnson', 'I10', 'New diagnosis of hypertension. Starting medication.'),
(1010, '2024-04-25', 'Dr. Emily Chen', 'Z12.31', 'Routine mammogram screening. Results pending.');

-- Insert sample prescription data
INSERT INTO prescriptions (patient_id, visit_id, medication_name, dosage, frequency, start_date, end_date) VALUES
(1001, 2, 'Lisinopril', '10mg', 'Once daily', '2024-03-22', NULL),
(1002, 3, 'Metformin', '500mg', 'Twice daily', '2024-01-20', NULL),
(1002, 4, 'Insulin Glargine', '20 units', 'Once daily at bedtime', '2024-04-10', NULL),
(1003, 5, 'Ibuprofen', '400mg', 'As needed for pain', '2024-02-05', '2024-03-05'),
(1005, 7, 'Albuterol Inhaler', '90mcg', 'As needed', '2024-03-01', NULL),
(1007, 9, 'Omeprazole', '20mg', 'Once daily before breakfast', '2024-04-01', NULL),
(1009, 11, 'Amlodipine', '5mg', 'Once daily', '2024-04-20', NULL);

-- Insert sample lab results
INSERT INTO lab_results (patient_id, visit_id, test_name, test_value, test_unit, normal_range, test_date) VALUES
(1001, 2, 'Blood Pressure Systolic', 128, 'mmHg', '90-120', '2024-03-22'),
(1001, 2, 'Blood Pressure Diastolic', 82, 'mmHg', '60-80', '2024-03-22'),
(1002, 3, 'HbA1c', 6.8, '%', '4.0-5.6', '2024-01-20'),
(1002, 3, 'Fasting Glucose', 142, 'mg/dL', '70-100', '2024-01-20'),
(1002, 4, 'HbA1c', 6.4, '%', '4.0-5.6', '2024-04-10'),
(1004, 6, 'Cholesterol Total', 185, 'mg/dL', '<200', '2024-02-14'),
(1004, 6, 'HDL Cholesterol', 58, 'mg/dL', '>40', '2024-02-14'),
(1004, 6, 'LDL Cholesterol', 110, 'mg/dL', '<100', '2024-02-14'),
(1008, 10, 'White Blood Cell Count', 12.5, 'K/uL', '4.5-11.0', '2024-04-12'),
(1008, 10, 'C-Reactive Protein', 8.2, 'mg/L', '<3.0', '2024-04-12'),
(1009, 11, 'Blood Pressure Systolic', 148, 'mmHg', '90-120', '2024-04-20'),
(1009, 11, 'Blood Pressure Diastolic', 94, 'mmHg', '60-80', '2024-04-20');

-- Create indexes for better query performance
CREATE INDEX idx_visits_patient_id ON visits(patient_id);
CREATE INDEX idx_visits_visit_date ON visits(visit_date);
CREATE INDEX idx_prescriptions_patient_id ON prescriptions(patient_id);
CREATE INDEX idx_lab_results_patient_id ON lab_results(patient_id);

-- Grant permissions (if needed for specific user)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO healthuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO healthuser;

-- Display summary
SELECT 'Database initialized successfully!' AS status;
SELECT COUNT(*) AS total_visits FROM visits;
SELECT COUNT(*) AS total_prescriptions FROM prescriptions;
SELECT COUNT(*) AS total_lab_results FROM lab_results;
