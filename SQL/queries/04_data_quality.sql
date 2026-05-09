-- Healthcare Analytics Project
-- Script: 04_data_quality.sql
-- Purpose: Data Quality Validation

-- ========== SECTION 1: COMPLETENESS ==========

-- Null audit - patients
SELECT 
    'patients' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE patient_id IS NULL) AS null_patient_id,
    COUNT(*) FILTER (WHERE age IS NULL) AS null_age,
    COUNT(*) FILTER (WHERE gender IS NULL) AS null_gender,
    COUNT(*) FILTER (WHERE diagnosis IS NULL) AS null_diagnosis,
    COUNT(*) FILTER (WHERE readmitted IS NULL) AS null_readmitted,
    COUNT(*) FILTER (WHERE length_of_stay IS NULL) AS null_los,
    COUNT(*) FILTER (WHERE admission_date IS NULL) AS null_admission_date,
    COUNT(*) FILTER (WHERE discharge_date IS NULL) AS null_discharge_date,
    COUNT(*) FILTER (WHERE payer_type IS NULL) AS null_payer_type
FROM patients;

-- Null audit - claims
SELECT 
    'claims' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE claim_id IS NULL) AS null_claim_id,
    COUNT(*) FILTER (WHERE patient_id IS NULL) AS null_patient_id,
    COUNT(*) FILTER (WHERE service_date IS NULL) AS null_service_date,
    COUNT(*) FILTER (WHERE procedure_code IS NULL) AS null_procedure_code,
    COUNT(*) FILTER (WHERE claim_amount IS NULL) AS null_claim_amount,
    COUNT(*) FILTER (WHERE claim_status IS NULL) AS null_claim_status
FROM claims;

-- Completeness rate per column
SELECT column_name, non_null_count, total_count,
       ROUND(non_null_count * 100.0 / total_count, 2) AS completeness_pct
FROM (
    SELECT 'age' AS column_name, COUNT(age) AS non_null_count, COUNT(*) AS total_count FROM patients UNION ALL
    SELECT 'gender', COUNT(gender), COUNT(*) FROM patients UNION ALL
    SELECT 'diagnosis', COUNT(diagnosis), COUNT(*) FROM patients UNION ALL
    SELECT 'payer_type', COUNT(payer_type), COUNT(*) FROM patients UNION ALL
    SELECT 'admission_date', COUNT(admission_date), COUNT(*) FROM patients UNION ALL
    SELECT 'discharge_date', COUNT(discharge_date), COUNT(*) FROM patients
) t
ORDER BY completeness_pct ASC;

-- ========== SECTION 2: VALIDITY ==========

-- Invalid age
SELECT patient_id, age, 'Invalid age (out of range 0-120)' AS issue
FROM patients WHERE age < 0 OR age > 120;

-- Invalid gender
SELECT patient_id, gender, 'Invalid gender code' AS issue
FROM patients WHERE gender NOT IN ('M', 'F');

-- Discharge before admission
SELECT patient_id, admission_date, discharge_date, 'Discharge before admission' AS issue
FROM patients WHERE discharge_date < admission_date;

-- Negative LOS
SELECT patient_id, length_of_stay, 'Negative length of stay' AS issue
FROM patients WHERE length_of_stay < 0;

-- LOS vs date mismatch
SELECT patient_id, length_of_stay,
       EXTRACT(DAY FROM (discharge_date - admission_date)) AS calculated_los,
       ABS(length_of_stay - EXTRACT(DAY FROM (discharge_date - admission_date))) AS discrepancy
FROM patients
WHERE admission_date IS NOT NULL AND discharge_date IS NOT NULL
  AND ABS(length_of_stay - EXTRACT(DAY FROM (discharge_date - admission_date))) > 0;

-- Paid > billed
SELECT claim_id, claim_amount, paid_amount, 'Paid exceeds billed' AS issue
FROM claims WHERE paid_amount > claim_amount;

-- Denied with non-zero paid
SELECT claim_id, claim_status, paid_amount, 'Denied claim has payment' AS issue
FROM claims WHERE claim_status = 'Denied' AND paid_amount > 0;

-- ========== SECTION 3: UNIQUENESS ==========

-- Duplicate patient IDs
SELECT patient_id, COUNT(*) AS duplicate_count
FROM patients GROUP BY patient_id HAVING COUNT(*) > 1;

-- Duplicate claim IDs
SELECT claim_id, COUNT(*) AS duplicate_count
FROM claims GROUP BY claim_id HAVING COUNT(*) > 1;

-- Potential duplicate claims
SELECT patient_id, service_date, procedure_code, diagnosis_code,
       COUNT(*) AS claim_count, 'Potential duplicate claim' AS issue
FROM claims
GROUP BY patient_id, service_date, procedure_code, diagnosis_code
HAVING COUNT(*) > 1;

-- ========== SECTION 4: REFERENTIAL INTEGRITY ==========

-- Orphan claims
SELECT c.claim_id, c.patient_id, 'No matching patient' AS issue
FROM claims c LEFT JOIN patients p ON c.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

-- ========== SECTION 5: DQ SCORECARD ==========

SELECT
    'patients' AS table_name,
    COUNT(*) AS total_records,
    ROUND((SELECT AVG(c) FROM (
        SELECT COUNT(age)*100.0/COUNT(*) c FROM patients UNION ALL
        SELECT COUNT(gender)*100.0/COUNT(*) FROM patients UNION ALL
        SELECT COUNT(diagnosis)*100.0/COUNT(*) FROM patients UNION ALL
        SELECT COUNT(payer_type)*100.0/COUNT(*) FROM patients
    ) t), 2) AS avg_completeness_pct,
    (SELECT COUNT(*) FROM patients WHERE age < 0 OR age > 120) AS invalid_age,
    (SELECT COUNT(*) FROM patients WHERE gender NOT IN ('M','F')) AS invalid_gender,
    (SELECT COUNT(*) FROM (SELECT patient_id FROM patients GROUP BY patient_id HAVING COUNT(*) > 1) d) AS duplicates
FROM patients

UNION ALL

SELECT 'claims', COUNT(*),
    ROUND((SELECT AVG(c) FROM (
        SELECT COUNT(claim_id)*100.0/COUNT(*) c FROM claims UNION ALL
        SELECT COUNT(patient_id)*100.0/COUNT(*) FROM claims UNION ALL
        SELECT COUNT(procedure_code)*100.0/COUNT(*) FROM claims UNION ALL
        SELECT COUNT(claim_status)*100.0/COUNT(*) FROM claims
    ) t), 2),
    (SELECT COUNT(*) FROM claims WHERE paid_amount > claim_amount),
    (SELECT COUNT(*) FROM claims WHERE claim_status = 'Denied' AND paid_amount > 0),
    (SELECT COUNT(*) FROM (SELECT claim_id FROM claims GROUP BY claim_id HAVING COUNT(*) > 1) d)
FROM claims;
