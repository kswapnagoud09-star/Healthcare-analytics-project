-- Healthcare Analytics Project
-- Script: 05_create_tables.sql
-- Purpose: DDL for all project tables

DROP TABLE IF EXISTS claims;
DROP TABLE IF EXISTS hedis_member_measures;
DROP TABLE IF EXISTS hedis_measures;
DROP TABLE IF EXISTS patients;

-- TABLE: patients
CREATE TABLE patients (
    patient_id          INT             PRIMARY KEY,
    age                 INT             NOT NULL CHECK (age BETWEEN 0 AND 120),
    gender              CHAR(1)         NOT NULL CHECK (gender IN ('M', 'F')),
    diagnosis           VARCHAR(100)    NOT NULL,
    readmitted          VARCHAR(3)      NOT NULL CHECK (readmitted IN ('Yes', 'No')),
    length_of_stay      INT             NOT NULL CHECK (length_of_stay >= 0),
    admission_date      DATE,
    discharge_date      DATE,
    payer_type          VARCHAR(50),
    attending_physician VARCHAR(100),
    department          VARCHAR(100),
    icu_flag            VARCHAR(3)      CHECK (icu_flag IN ('Yes', 'No')),
    comorbidity_count   INT             DEFAULT 0 CHECK (comorbidity_count >= 0),
    CONSTRAINT chk_dates CHECK (discharge_date >= admission_date)
);

COMMENT ON TABLE patients IS 'Patient admissions and demographics for readmission analysis';

-- TABLE: claims
CREATE TABLE claims (
    claim_id            VARCHAR(10)     PRIMARY KEY,
    patient_id          INT             REFERENCES patients(patient_id),
    service_date        DATE            NOT NULL,
    procedure_code      VARCHAR(10)     NOT NULL,
    diagnosis_code      VARCHAR(10)     NOT NULL,
    claim_amount        DECIMAL(10,2)   NOT NULL CHECK (claim_amount >= 0),
    paid_amount         DECIMAL(10,2)   NOT NULL CHECK (paid_amount >= 0),
    denial_reason       VARCHAR(200),
    claim_status        VARCHAR(10)     NOT NULL CHECK (claim_status IN ('Paid', 'Denied', 'Pending')),
    payer_type          VARCHAR(50),
    provider_npi        VARCHAR(10),
    place_of_service    VARCHAR(50)
);

COMMENT ON TABLE claims IS 'Insurance claims data for billing and denial analysis';

-- TABLE: hedis_measures
CREATE TABLE hedis_measures (
    measure_id          VARCHAR(10)     PRIMARY KEY,
    measure_name        VARCHAR(200)    NOT NULL,
    measure_short       VARCHAR(20)     NOT NULL,
    numerator_criteria  VARCHAR(500),
    denominator_criteria VARCHAR(500),
    target_rate         DECIMAL(4,2)    CHECK (target_rate BETWEEN 0 AND 1),
    measurement_year    INT
);

-- TABLE: hedis_member_measures
CREATE TABLE hedis_member_measures (
    id                  SERIAL          PRIMARY KEY,
    patient_id          INT             REFERENCES patients(patient_id),
    measure_id          VARCHAR(10)     REFERENCES hedis_measures(measure_id),
    in_denominator      BOOLEAN         NOT NULL DEFAULT FALSE,
    in_numerator        BOOLEAN         NOT NULL DEFAULT FALSE,
    measurement_year    INT             NOT NULL,
    last_service_date   DATE,
    exclusion_flag      BOOLEAN         DEFAULT FALSE,
    exclusion_reason    VARCHAR(200)
);

-- Indexes for performance
CREATE INDEX idx_patients_diagnosis    ON patients (diagnosis);
CREATE INDEX idx_patients_readmitted   ON patients (readmitted);
CREATE INDEX idx_patients_payer        ON patients (payer_type);
CREATE INDEX idx_claims_patient        ON claims (patient_id);
CREATE INDEX idx_claims_status         ON claims (claim_status);
CREATE INDEX idx_claims_payer          ON claims (payer_type);
CREATE INDEX idx_hedis_member_patient  ON hedis_member_measures (patient_id);
CREATE INDEX idx_hedis_member_measure  ON hedis_member_measures (measure_id);

SELECT 'All tables created successfully.' AS status;
