# Data Dictionary

## patients table

| Column | Data Type | Description | Example Values |
|--------|-----------|-------------|----------------|
| patient_id | INTEGER | Unique patient identifier | 1, 2, 3 |
| age | INTEGER | Patient age at admission | 45, 67, 72 |
| gender | VARCHAR(1) | Patient gender (M/F) | M, F |
| diagnosis | VARCHAR(100) | Primary diagnosis | Diabetes, Heart Disease |
| readmitted | VARCHAR(3) | 30-day readmission flag | Yes, No |
| length_of_stay | INTEGER | Days in hospital | 2, 5, 11 |
| admission_date | DATE | Date of admission | 2024-01-05 |
| discharge_date | DATE | Date of discharge | 2024-01-10 |
| payer_type | VARCHAR(50) | Insurance payer type | Medicare, Medicaid, Commercial |
| attending_physician | VARCHAR(100) | Name of attending physician | Dr. Smith |
| department | VARCHAR(100) | Hospital department | Cardiology, Internal Medicine |
| icu_flag | VARCHAR(3) | ICU stay indicator | Yes, No |
| comorbidity_count | INTEGER | Number of comorbid conditions | 0, 1, 2, 3, 4 |

## claims table

| Column | Data Type | Description | Example Values |
|--------|-----------|-------------|----------------|
| claim_id | VARCHAR(10) | Unique claim identifier | CLM001 |
| patient_id | INTEGER | Foreign key to patients | 1, 5, 22 |
| service_date | DATE | Date of service | 2024-01-10 |
| procedure_code | VARCHAR(10) | CPT procedure code | 99213, 93458 |
| diagnosis_code | VARCHAR(10) | ICD-10 diagnosis code | E11.9, I25.10 |
| claim_amount | DECIMAL(10,2) | Total billed amount | 350.00, 2400.00 |
| paid_amount | DECIMAL(10,2) | Amount actually paid | 280.00, 0.00 |
| denial_reason | VARCHAR(200) | Reason for denial | Not medically necessary |
| claim_status | VARCHAR(10) | Claim status | Paid, Denied |
| payer_type | VARCHAR(50) | Insurance payer type | Medicare, Medicaid |
| provider_npi | VARCHAR(10) | National Provider Identifier | 1234567890 |
| place_of_service | VARCHAR(50) | Where service was rendered | Office, Inpatient Hospital |

## Common ICD-10 Codes Used

| ICD-10 Code | Diagnosis |
|-------------|-----------|
| E11.9 | Type 2 Diabetes without complications |
| E11.65 | Type 2 Diabetes with hyperglycemia |
| I10 | Essential (primary) hypertension |
| I25.10 | Atherosclerotic heart disease |
| J44.1 | COPD with acute exacerbation |
| J45.20 | Mild intermittent asthma |
| J18.9 | Pneumonia, unspecified organism |
| I63.9 | Cerebral infarction (Stroke) |
| N39.0 | Urinary tract infection |
| K37 | Unspecified appendicitis |

## Common CPT Codes Used

| CPT Code | Procedure |
|----------|-----------|
| 99211 | Office visit, level 1 |
| 99212 | Office visit, level 2 |
| 99213 | Office visit, level 3 |
| 99214 | Office visit, level 4 |
| 99223 | Initial inpatient hospital care |
| 93306 | Echocardiogram |
| 93458 | Cardiac catheterization |
| 94060 | Bronchodilation spirometry |
| 94640 | Nebulizer treatment |
| 71046 | Chest X-ray, 2 views |
| 70553 | Brain MRI with contrast |
| 44950 | Appendectomy |
