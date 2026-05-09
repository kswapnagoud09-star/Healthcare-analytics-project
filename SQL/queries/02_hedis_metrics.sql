-- Healthcare Analytics Project
-- Script: 02_hedis_metrics.sql
-- Purpose: HEDIS Quality Measure Analysis

-- ========== SECTION 1: HEDIS MEASURE SUMMARY ==========

-- All HEDIS measures with targets
SELECT measure_id, measure_short, measure_name, target_rate,
       ROUND(target_rate * 100, 1) AS target_pct
FROM hedis_measures ORDER BY measure_short;

-- Denominator: Diabetes measures (CDC) - patients 18-75 with diabetes
SELECT patient_id, age, gender, payer_type,
       'Eligible for CDC measures' AS measure_eligibility
FROM patients
WHERE diagnosis ILIKE '%Diabetes%' AND age BETWEEN 18 AND 75;

-- Denominator: Hypertension measure (CBP) - patients 18-85
SELECT patient_id, age, gender, payer_type
FROM patients
WHERE diagnosis ILIKE '%Hypertension%' AND age BETWEEN 18 AND 85;

-- ========== SECTION 2: COMPLIANCE RATES ==========

-- Compliance rate per measure
SELECT 
    hm.measure_id, m.measure_name, m.measure_short, m.target_rate,
    COUNT(*) FILTER (WHERE hm.in_denominator = TRUE)  AS denominator,
    COUNT(*) FILTER (WHERE hm.in_numerator  = TRUE)   AS numerator,
    ROUND(COUNT(*) FILTER (WHERE hm.in_numerator = TRUE) * 1.0 /
          NULLIF(COUNT(*) FILTER (WHERE hm.in_denominator = TRUE), 0), 4) AS compliance_rate,
    ROUND(COUNT(*) FILTER (WHERE hm.in_numerator = TRUE) * 100.0 /
          NULLIF(COUNT(*) FILTER (WHERE hm.in_denominator = TRUE), 0), 2) AS compliance_pct,
    m.target_rate * 100 AS target_pct
FROM hedis_member_measures hm
JOIN hedis_measures m ON hm.measure_id = m.measure_id
WHERE hm.exclusion_flag = FALSE
GROUP BY hm.measure_id, m.measure_name, m.measure_short, m.target_rate
ORDER BY compliance_rate ASC;

-- Gap in care: Members in denominator but NOT numerator
SELECT 
    p.patient_id, p.age, p.gender, p.diagnosis, p.payer_type,
    m.measure_short, m.measure_name, 'Gap in Care' AS status
FROM hedis_member_measures hm
JOIN patients p       ON hm.patient_id = p.patient_id
JOIN hedis_measures m ON hm.measure_id = m.measure_id
WHERE hm.in_denominator = TRUE AND hm.in_numerator = FALSE AND hm.exclusion_flag = FALSE
ORDER BY m.measure_short, p.patient_id;

-- Performance vs target
SELECT 
    m.measure_short, m.measure_name,
    ROUND(m.target_rate * 100, 1) AS target_pct,
    ROUND(COUNT(*) FILTER (WHERE hm.in_numerator = TRUE) * 100.0 /
          NULLIF(COUNT(*) FILTER (WHERE hm.in_denominator = TRUE), 0), 2) AS actual_pct,
    CASE WHEN ROUND(COUNT(*) FILTER (WHERE hm.in_numerator = TRUE) * 100.0 /
          NULLIF(COUNT(*) FILTER (WHERE hm.in_denominator = TRUE), 0), 2) >= m.target_rate * 100
         THEN 'MET' ELSE 'NOT MET' END AS target_status
FROM hedis_member_measures hm
JOIN hedis_measures m ON hm.measure_id = m.measure_id
WHERE hm.exclusion_flag = FALSE
GROUP BY m.measure_short, m.measure_name, m.target_rate
ORDER BY target_status, m.measure_short;

-- ========== SECTION 3: DIABETES DEEP DIVE ==========

-- Diabetes patients by payer
SELECT 
    payer_type,
    COUNT(*) AS diabetic_members,
    ROUND(AVG(age), 1) AS avg_age,
    SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female_count,
    SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male_count
FROM patients
WHERE diagnosis ILIKE '%Diabetes%' AND age BETWEEN 18 AND 75
GROUP BY payer_type ORDER BY diabetic_members DESC;

-- Readmission overlap with HEDIS-eligible population
SELECT 
    diagnosis,
    COUNT(*) AS total,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmitted,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS readmission_pct,
    ROUND(AVG(comorbidity_count), 2) AS avg_comorbidities
FROM patients
WHERE diagnosis IN ('Diabetes','Hypertension','Heart Disease','COPD','Asthma')
GROUP BY diagnosis ORDER BY readmission_pct DESC;

-- ========== SECTION 4: PCR MEASURE ==========

-- PCR denominator: All inpatient discharges
SELECT COUNT(*) AS total_inpatient_discharges FROM patients WHERE discharge_date IS NOT NULL;

-- PCR numerator: Unplanned readmissions
SELECT 
    COUNT(*) AS unplanned_readmissions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients WHERE discharge_date IS NOT NULL), 2) AS readmission_rate_pct
FROM patients WHERE readmitted = 'Yes';

-- PCR by diagnosis
SELECT 
    diagnosis,
    COUNT(*) AS discharges,
    SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) AS readmissions,
    ROUND(SUM(CASE WHEN readmitted = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pcr_rate_pct,
    10.0 AS hedis_target_pct
FROM patients
GROUP BY diagnosis HAVING COUNT(*) >= 3
ORDER BY pcr_rate_pct DESC;
