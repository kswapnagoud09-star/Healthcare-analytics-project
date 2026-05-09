-- Healthcare Analytics Project
-- Script: 03_claims_analysis.sql
-- Purpose: Insurance Claims Data Analysis

-- ========== SECTION 1: FINANCIAL OVERVIEW ==========

-- Total claims summary
SELECT 
    COUNT(*) AS total_claims,
    SUM(claim_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    SUM(claim_amount - paid_amount) AS total_unpaid,
    ROUND(SUM(paid_amount) * 100.0 / NULLIF(SUM(claim_amount), 0), 2) AS payment_rate_pct
FROM claims;

-- Claims by status
SELECT 
    claim_status,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_claims
FROM claims
GROUP BY claim_status ORDER BY claim_count DESC;

-- Financial summary by payer
SELECT 
    payer_type,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    ROUND(AVG(claim_amount), 2) AS avg_claim_amount,
    ROUND(SUM(paid_amount) * 100.0 / NULLIF(SUM(claim_amount), 0), 2) AS payment_rate_pct
FROM claims
GROUP BY payer_type ORDER BY total_billed DESC;

-- ========== SECTION 2: DENIAL ANALYSIS ==========

-- Denial rate overall
SELECT 
    COUNT(*) AS total_claims,
    COUNT(*) FILTER (WHERE claim_status = 'Denied') AS denied_claims,
    ROUND(COUNT(*) FILTER (WHERE claim_status = 'Denied') * 100.0 / COUNT(*), 2) AS denial_rate_pct,
    SUM(claim_amount) FILTER (WHERE claim_status = 'Denied') AS denied_amount
FROM claims;

-- Denial reasons
SELECT 
    denial_reason,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS billed_amount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_denials
FROM claims WHERE claim_status = 'Denied'
GROUP BY denial_reason ORDER BY claim_count DESC;

-- Denial rate by payer
SELECT 
    payer_type,
    COUNT(*) AS total_claims,
    COUNT(*) FILTER (WHERE claim_status = 'Denied') AS denied_claims,
    ROUND(COUNT(*) FILTER (WHERE claim_status = 'Denied') * 100.0 / COUNT(*), 2) AS denial_rate_pct
FROM claims
GROUP BY payer_type ORDER BY denial_rate_pct DESC;

-- Top denied procedure codes
SELECT 
    procedure_code,
    COUNT(*) AS denial_count,
    SUM(claim_amount) AS denied_amount
FROM claims WHERE claim_status = 'Denied'
GROUP BY procedure_code ORDER BY denial_count DESC;

-- ========== SECTION 3: PROCEDURE CODE ANALYSIS ==========

-- Volume and revenue by procedure code
SELECT 
    procedure_code,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    ROUND(AVG(claim_amount), 2) AS avg_claim,
    ROUND(SUM(paid_amount) * 100.0 / NULLIF(SUM(claim_amount), 0), 2) AS payment_rate_pct
FROM claims
GROUP BY procedure_code ORDER BY total_billed DESC;

-- Place of service analysis
SELECT 
    place_of_service,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_billed,
    ROUND(AVG(claim_amount), 2) AS avg_claim,
    ROUND(COUNT(*) FILTER (WHERE claim_status = 'Denied') * 100.0 / COUNT(*), 2) AS denial_rate_pct
FROM claims
GROUP BY place_of_service ORDER BY total_billed DESC;

-- ========== SECTION 4: PATIENT-LEVEL ANALYSIS ==========

-- High-cost patients
SELECT 
    c.patient_id, p.age, p.gender, p.diagnosis, p.payer_type,
    COUNT(c.claim_id) AS total_claims,
    SUM(c.claim_amount) AS total_billed,
    SUM(c.paid_amount) AS total_paid,
    p.readmitted
FROM claims c
JOIN patients p ON c.patient_id = p.patient_id
GROUP BY c.patient_id, p.age, p.gender, p.diagnosis, p.payer_type, p.readmitted
ORDER BY total_billed DESC LIMIT 20;

-- Patients with readmissions and high claim costs
SELECT 
    p.patient_id, p.diagnosis, p.readmitted, p.length_of_stay,
    SUM(c.claim_amount) AS total_claim_cost,
    p.comorbidity_count
FROM patients p
JOIN claims c ON p.patient_id = c.patient_id
WHERE p.readmitted = 'Yes'
GROUP BY p.patient_id, p.diagnosis, p.readmitted, p.length_of_stay, p.comorbidity_count
ORDER BY total_claim_cost DESC;

-- ========== SECTION 5: MONTHLY TRENDS ==========

SELECT 
    DATE_TRUNC('month', service_date) AS service_month,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    COUNT(*) FILTER (WHERE claim_status = 'Denied') AS denied_count,
    ROUND(COUNT(*) FILTER (WHERE claim_status = 'Denied') * 100.0 / COUNT(*), 2) AS denial_rate_pct
FROM claims
GROUP BY DATE_TRUNC('month', service_date)
ORDER BY service_month;
