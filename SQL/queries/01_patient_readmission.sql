-- Healthcare Analytics Project
-- Script: 01_patient_readmission.sql
-- Purpose: Patient Readmission Analysis

-- ========== SECTION 1: BASIC STATS ==========

-- Total patients
SELECT COUNT(*) AS total_patients FROM patients;

-- Readmission rates
SELECT 
    readmitted,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM patients
GROUP BY readmitted
ORDER BY readmitted DESC;

-- Average length of stay
SELECT 
    ROUND(AVG(length_of_stay), 2) AS avg_los,
    MIN(length_of_stay)           AS min_los,
    MAX(length_of_stay)           AS max_los,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY length_of_stay) AS median_los
FROM patients;

-- ========== SECTION 2: DIAGNOSIS ANALYSIS ==========

-- Readmission rate by diagnosis
SELECT 
    diagnosis,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted_count,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct,
    ROUND(AVG(length_of_stay), 2) AS avg_los
FROM patients
GROUP BY diagnosis
ORDER BY readmission_rate_pct DESC;

-- Average LOS by diagnosis
SELECT 
    diagnosis,
    ROUND(AVG(length_of_stay), 2) AS avg_los,
    MIN(length_of_stay)           AS min_los,
    MAX(length_of_stay)           AS max_los
FROM patients
GROUP BY diagnosis
ORDER BY avg_los DESC;

-- ========== SECTION 3: DEMOGRAPHICS ==========

-- Readmission by gender
SELECT 
    gender,
    COUNT(*) AS total,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM patients
GROUP BY gender;

-- Age group analysis
SELECT 
    CASE 
        WHEN age < 45  THEN '18-44'
        WHEN age < 60  THEN '45-59'
        WHEN age < 70  THEN '60-69'
        WHEN age < 80  THEN '70-79'
        ELSE '80+'
    END AS age_group,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted_count,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct,
    ROUND(AVG(length_of_stay), 2) AS avg_los
FROM patients
GROUP BY age_group
ORDER BY MIN(age);

-- ========== SECTION 4: PAYER & DEPARTMENT ==========

-- Readmission by payer type
SELECT 
    payer_type,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted_count,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct,
    ROUND(AVG(length_of_stay), 2) AS avg_los
FROM patients
GROUP BY payer_type
ORDER BY readmission_rate_pct DESC;

-- Department performance
SELECT 
    department,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted_count,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct,
    ROUND(AVG(length_of_stay), 2) AS avg_los,
    SUM(CASE WHEN icu_flag = 'Yes' THEN 1 ELSE 0 END) AS icu_cases
FROM patients
GROUP BY department
ORDER BY readmission_rate_pct DESC;

-- ========== SECTION 5: HIGH-RISK PATIENTS ==========

-- High-risk patients (LOS > 5 AND readmitted)
SELECT 
    patient_id, age, gender, diagnosis, length_of_stay,
    payer_type, department, icu_flag, comorbidity_count
FROM patients
WHERE length_of_stay > 5
  AND readmitted = 'Yes'
ORDER BY length_of_stay DESC, comorbidity_count DESC;

-- Composite risk score
SELECT 
    patient_id, age, gender, diagnosis, length_of_stay, comorbidity_count, readmitted,
    (
        CASE WHEN age >= 70              THEN 3 ELSE 0 END +
        CASE WHEN length_of_stay > 7    THEN 3 ELSE 0 END +
        CASE WHEN icu_flag = 'Yes'      THEN 2 ELSE 0 END +
        CASE WHEN comorbidity_count >= 3 THEN 2 ELSE 0 END +
        CASE WHEN payer_type = 'Medicare' THEN 1 ELSE 0 END
    ) AS risk_score,
    CASE 
        WHEN (CASE WHEN age >= 70 THEN 3 ELSE 0 END + CASE WHEN length_of_stay > 7 THEN 3 ELSE 0 END +
              CASE WHEN icu_flag = 'Yes' THEN 2 ELSE 0 END + CASE WHEN comorbidity_count >= 3 THEN 2 ELSE 0 END +
              CASE WHEN payer_type = 'Medicare' THEN 1 ELSE 0 END) >= 7 THEN 'HIGH'
        WHEN (CASE WHEN age >= 70 THEN 3 ELSE 0 END + CASE WHEN length_of_stay > 7 THEN 3 ELSE 0 END +
              CASE WHEN icu_flag = 'Yes' THEN 2 ELSE 0 END + CASE WHEN comorbidity_count >= 3 THEN 2 ELSE 0 END +
              CASE WHEN payer_type = 'Medicare' THEN 1 ELSE 0 END) >= 4 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_category
FROM patients
ORDER BY risk_score DESC;

-- Monthly readmission trend
SELECT 
    DATE_TRUNC('month', admission_date) AS month,
    COUNT(*) AS total_admissions,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmissions,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM patients
WHERE admission_date IS NOT NULL
GROUP BY DATE_TRUNC('month', admission_date)
ORDER BY month;

-- Physician performance
SELECT 
    attending_physician,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted_count,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_rate_pct,
    ROUND(AVG(length_of_stay), 2) AS avg_los
FROM patients
GROUP BY attending_physician
ORDER BY readmission_rate_pct DESC;
