CREATE DATABASE IF NOT EXISTS hospital_intelligence;
USE hospital_intelligence;
DROP DATABASE hospital_intelligence;

DROP TABLE IF EXISTS patient_records;
CREATE TABLE patient_records (
    patient_id INT NOT NULL,
    name VARCHAR(150),
    age TINYINT UNSIGNED,
    gender VARCHAR(20),
    blood_type VARCHAR(10),
    medical_condition VARCHAR(50),
    date_of_admission DATE,
    doctor VARCHAR(150),
    hospital VARCHAR(255),
    insurance_provider VARCHAR(100),
    billing_amount DECIMAL(12,2),
    room_number SMALLINT UNSIGNED,
    admission_type VARCHAR(30),
    discharge_date DATE,
    medication VARCHAR(100),
    test_results VARCHAR(30),
    age_group VARCHAR(50),
    admission_year SMALLINT,
    admission_month VARCHAR(20),
    admission_day VARCHAR(20),
    admission_quarter VARCHAR(5),
    length_of_stay SMALLINT,
    length_of_stay_category VARCHAR(30),
    age_band VARCHAR(20),
    admission_month_number TINYINT,
    admission_season VARCHAR(20),
    admission_day_type VARCHAR(20),
    billing_category VARCHAR(20),
    billable_days SMALLINT,
    billing_per_day DECIMAL(12,2),
    insurance_type VARCHAR(30),
    long_stay_flag VARCHAR(5),
    high_billing_flag VARCHAR(5),
    analytical_risk_segment VARCHAR(50),
    patient_outcome_label VARCHAR(50),
    stay_cost_intensity VARCHAR(30),

    PRIMARY KEY (patient_id)
);
DESCRIBE patient_records;
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_schema = 'hospital_intelligence'
  AND table_name = 'patient_records';
  
select count(*) as total_rows from patient_records;

SELECT *
FROM patient_records
LIMIT 10;

SELECT
    MIN(date_of_admission) AS earliest_admission,
    MAX(date_of_admission) AS latest_admission
FROM patient_records;

SELECT COUNT(*) AS total_records
FROM patient_records;

-- Duplicate patient IDs
SELECT
    patient_id,
    COUNT(*) AS occurrence_count
FROM patient_records
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- Missing critical values
SELECT
    SUM(patient_id IS NULL) AS missing_patient_id,
    SUM(age IS NULL) AS missing_age,
    SUM(date_of_admission IS NULL) AS missing_admission_date,
    SUM(discharge_date IS NULL) AS missing_discharge_date,
    SUM(billing_amount IS NULL) AS missing_billing,
    SUM(test_results IS NULL) AS missing_test_results
FROM patient_records;

-- Invalid ages
SELECT COUNT(*) AS invalid_age_records
FROM patient_records
WHERE age < 0
   OR age > 120;
   
-- Negative billing
SELECT COUNT(*) AS negative_billing_records
FROM patient_records
WHERE billing_amount < 0;

-- Negative length of stay
SELECT COUNT(*) AS invalid_stay_records
FROM patient_records
WHERE length_of_stay < 0;

-- Admission after discharge
SELECT COUNT(*) AS invalid_date_records
FROM patient_records
WHERE date_of_admission > discharge_date;

-- Category inspection
SELECT DISTINCT gender
FROM patient_records;

SELECT DISTINCT admission_type
FROM patient_records;

SELECT DISTINCT test_results
FROM patient_records;

SELECT DISTINCT medical_condition
FROM patient_records;

-- Executive overview
SELECT
    COUNT(*) AS total_patient_records,
    COUNT(DISTINCT hospital) AS total_hospitals,
    COUNT(DISTINCT doctor) AS total_doctors,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing,
    ROUND(AVG(length_of_stay), 2) AS average_length_of_stay,
    ROUND(AVG(billing_per_day), 2) AS average_billing_per_day
FROM patient_records;

-- Patients by gender
SELECT
    gender,
    COUNT(*) AS total_patients,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS patient_percentage
FROM patient_records
GROUP BY gender
ORDER BY total_patients DESC;

-- Patients by age group
SELECT
    age_group,
    COUNT(*) AS total_patients
FROM patient_records
GROUP BY age_group
ORDER BY total_patients DESC;

-- Medical-condition distribution
SELECT
    medical_condition,
    COUNT(*) AS total_patients,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS patient_percentage
FROM patient_records
GROUP BY medical_condition
ORDER BY total_patients DESC;

-- Admissions by type
SELECT
    admission_type,
    COUNT(*) AS total_admissions,
    ROUND(AVG(length_of_stay), 2) AS average_stay,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY admission_type
ORDER BY total_admissions DESC;

-- Financial analysis

-- Total billing by medical condition
SELECT
    medical_condition,
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY medical_condition
ORDER BY total_billing DESC;

-- Billing by insurance provider
SELECT
    insurance_provider,
    COUNT(*) AS total_claims,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY insurance_provider
ORDER BY total_billing DESC;

-- Government versus private insurance
SELECT
    insurance_type,
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY insurance_type
ORDER BY total_billing DESC;

-- Billing categories
SELECT
    billing_category,
    COUNT(*) AS patient_count,
    ROUND(MIN(billing_amount), 2) AS minimum_billing,
    ROUND(MAX(billing_amount), 2) AS maximum_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY billing_category;

-- High-billing patients
SELECT
    patient_id,
    name,
    age,
    medical_condition,
    admission_type,
    insurance_provider,
    billing_amount,
    length_of_stay
FROM patient_records
WHERE high_billing_flag = 'Yes'
ORDER BY billing_amount DESC
LIMIT 20;

-- Most expensive patient records
SELECT
    patient_id,
    name,
    hospital,
    medical_condition,
    billing_amount,
    length_of_stay,
    billing_per_day
FROM patient_records
ORDER BY billing_amount DESC
LIMIT 10;

-- Hospitals with the highest total billing
SELECT
    hospital,
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing,
    ROUND(AVG(length_of_stay), 2) AS average_stay
FROM patient_records
GROUP BY hospital
HAVING COUNT(*) >= 2
ORDER BY total_billing DESC
LIMIT 20;

-- Hospitals with highest average billing
SELECT
    hospital,
    COUNT(*) AS total_patients,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY hospital
HAVING COUNT(*) >= 2
ORDER BY average_billing DESC
LIMIT 20;

-- Hospitals with longest average stay
SELECT
    hospital,
    COUNT(*) AS total_patients,
    ROUND(AVG(length_of_stay), 2) AS average_length_of_stay
FROM patient_records
GROUP BY hospital
HAVING COUNT(*) >= 2
ORDER BY average_length_of_stay DESC
LIMIT 20;

-- Hospital performance scorecard
SELECT
    hospital,
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing,
    ROUND(AVG(length_of_stay), 2) AS average_stay,
    ROUND(AVG(billing_per_day), 2) AS average_billing_per_day,
    SUM(long_stay_flag = 'Yes') AS long_stay_patients,
    SUM(high_billing_flag = 'Yes') AS high_billing_patients
FROM patient_records
GROUP BY hospital
HAVING COUNT(*) >= 2
ORDER BY total_billing DESC
LIMIT 25;

-- Stay-category distribution
SELECT
    length_of_stay_category,
    COUNT(*) AS total_patients,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY length_of_stay_category
ORDER BY total_patients DESC;

-- Average stay by condition
SELECT
    medical_condition,
    COUNT(*) AS total_patients,
    ROUND(AVG(length_of_stay), 2) AS average_stay,
    MIN(length_of_stay) AS minimum_stay,
    MAX(length_of_stay) AS maximum_stay
FROM patient_records
GROUP BY medical_condition
ORDER BY average_stay DESC;

-- Long-stay patients by medical condition
SELECT
    medical_condition,
    COUNT(*) AS long_stay_patients
FROM patient_records
WHERE long_stay_flag = 'Yes'
GROUP BY medical_condition
ORDER BY long_stay_patients DESC;

-- Extended-stay patient details
SELECT
    patient_id,
    name,
    age,
    medical_condition,
    admission_type,
    hospital,
    length_of_stay,
    billing_amount
FROM patient_records
WHERE length_of_stay_category = 'Extended Stay'
ORDER BY length_of_stay DESC, billing_amount DESC
LIMIT 20;

-- Admissions by year
SELECT
    admission_year,
    COUNT(*) AS total_admissions,
    ROUND(SUM(billing_amount), 2) AS total_billing
FROM patient_records
GROUP BY admission_year
ORDER BY admission_year;

-- Admissions by month
SELECT
    admission_month_number,
    admission_month,
    COUNT(*) AS total_admissions,
    ROUND(SUM(billing_amount), 2) AS total_billing
FROM patient_records
GROUP BY
    admission_month_number,
    admission_month
ORDER BY admission_month_number;

-- Admissions by quarter
SELECT
    admission_quarter,
    COUNT(*) AS total_admissions,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY admission_quarter
ORDER BY admission_quarter;

-- Weekday versus weekend
SELECT
    admission_day_type,
    COUNT(*) AS total_admissions,
    ROUND(AVG(length_of_stay), 2) AS average_stay,
    ROUND(AVG(billing_amount), 2) AS average_billing
FROM patient_records
GROUP BY admission_day_type;

-- Admissions by season
SELECT
    admission_season,
    COUNT(*) AS total_admissions,
    ROUND(SUM(billing_amount), 2) AS total_billing
FROM patient_records
GROUP BY admission_season
ORDER BY total_admissions DESC;

-- Test-results analysis
SELECT
    test_results,
    COUNT(*) AS total_patients,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS result_percentage
FROM patient_records
GROUP BY test_results
ORDER BY total_patients DESC;

-- Test results by condition
SELECT
    medical_condition,
    test_results,
    COUNT(*) AS patient_count
FROM patient_records
GROUP BY
    medical_condition,
    test_results
ORDER BY
    medical_condition,
    patient_count DESC;
    
-- Abnormal-result patients by admission type
SELECT
    admission_type,
    COUNT(*) AS abnormal_result_count
FROM patient_records
WHERE test_results = 'Abnormal'
GROUP BY admission_type
ORDER BY abnormal_result_count DESC;

-- Analytical-risk distribution
SELECT 
    analytical_risk_segment,
    COUNT(*) AS total_patients,
    ROUND(AVG(age), 2) AS average_age,
    ROUND(AVG(billing_amount), 2) AS average_billing,
    ROUND(AVG(length_of_stay), 2) AS average_stay
FROM
    patient_records
GROUP BY analytical_risk_segment
ORDER BY total_patients DESC;

-- Rank medical conditions by total billing
WITH condition_billing AS (
    SELECT
        medical_condition,
        COUNT(*) AS total_patients,
        SUM(billing_amount) AS total_billing
    FROM patient_records
    GROUP BY medical_condition
)

SELECT
    medical_condition,
    total_patients,
    ROUND(total_billing, 2) AS total_billing,
    DENSE_RANK() OVER (
        ORDER BY total_billing DESC
    ) AS billing_rank
FROM condition_billing;

-- Rank insurance providers
SELECT
    insurance_provider,
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    DENSE_RANK() OVER (
        ORDER BY SUM(billing_amount) DESC
    ) AS provider_rank
FROM patient_records
GROUP BY insurance_provider;

-- Year-over-year admission growth
WITH yearly_data AS (
    SELECT
        admission_year,
        COUNT(*) AS total_admissions
    FROM patient_records
    GROUP BY admission_year
),

growth_data AS (
    SELECT
        admission_year,
        total_admissions,
        LAG(total_admissions) OVER (
            ORDER BY admission_year
        ) AS previous_year_admissions
    FROM yearly_data
)

SELECT
    admission_year,
    total_admissions,
    previous_year_admissions,
    ROUND(
        (
            total_admissions -
            previous_year_admissions
        ) * 100.0 /
        NULLIF(previous_year_admissions, 0),
        2
    ) AS year_over_year_growth_percentage
FROM growth_data;

-- Condition contribution to billing
WITH billing_summary AS (
    SELECT
        medical_condition,
        SUM(billing_amount) AS condition_billing
    FROM patient_records
    GROUP BY medical_condition
)

SELECT
    medical_condition,
    ROUND(condition_billing, 2) AS total_billing,
    ROUND(
        condition_billing * 100.0 /
        SUM(condition_billing) OVER (),
        2
    ) AS billing_contribution_percentage
FROM billing_summary
ORDER BY condition_billing DESC;

-- Patient billing compared with condition average
SELECT
    patient_id,
    name,
    medical_condition,
    billing_amount,
    ROUND(
        AVG(billing_amount) OVER (
            PARTITION BY medical_condition
        ),
        2
    ) AS condition_average_billing,
    ROUND(
        billing_amount -
        AVG(billing_amount) OVER (
            PARTITION BY medical_condition
        ),
        2
    ) AS difference_from_condition_average
FROM patient_records
ORDER BY difference_from_condition_average DESC
LIMIT 20;

-- Executive summary view

CREATE OR REPLACE VIEW vw_executive_summary AS
SELECT
    COUNT(*) AS total_patient_records,
    COUNT(DISTINCT hospital) AS total_hospitals,
    COUNT(DISTINCT doctor) AS total_doctors,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing,
    ROUND(AVG(length_of_stay), 2) AS average_length_of_stay,
    ROUND(AVG(billing_per_day), 2) AS average_billing_per_day,
    SUM(test_results = 'Abnormal') AS abnormal_result_count,
    SUM(long_stay_flag = 'Yes') AS long_stay_count,
    SUM(high_billing_flag = 'Yes') AS high_billing_count
FROM patient_records;

-- Medical-condition view
CREATE OR REPLACE VIEW vw_condition_performance AS
SELECT
    medical_condition,
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing,
    ROUND(AVG(length_of_stay), 2) AS average_length_of_stay,
    ROUND(AVG(billing_per_day), 2) AS average_billing_per_day,
    SUM(test_results = 'Abnormal') AS abnormal_result_count
FROM patient_records
GROUP BY medical_condition;

-- Insurance view
CREATE OR REPLACE VIEW vw_insurance_performance AS
SELECT
    insurance_provider,
    insurance_type,
    COUNT(*) AS total_patients,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(billing_amount), 2) AS average_billing,
    ROUND(AVG(length_of_stay), 2) AS average_length_of_stay
FROM patient_records
GROUP BY
    insurance_provider,
    insurance_type;
    
-- Monthly trend view
CREATE OR REPLACE VIEW vw_monthly_admission_trend AS
SELECT
    admission_year,
    admission_month_number,
    admission_month,
    COUNT(*) AS total_admissions,
    ROUND(SUM(billing_amount), 2) AS total_billing,
    ROUND(AVG(length_of_stay), 2) AS average_length_of_stay
FROM patient_records
GROUP BY
    admission_year,
    admission_month_number,
    admission_month;
    
SHOW FULL TABLES
WHERE Table_type = 'VIEW';

-- Create indexes
CREATE INDEX idx_medical_condition
ON patient_records(medical_condition);

CREATE INDEX idx_admission_date
ON patient_records(date_of_admission);

CREATE INDEX idx_admission_year
ON patient_records(admission_year);

CREATE INDEX idx_insurance_provider
ON patient_records(insurance_provider);

CREATE INDEX idx_test_results
ON patient_records(test_results);

CREATE INDEX idx_admission_type
ON patient_records(admission_type);

SHOW INDEXES FROM patient_records;