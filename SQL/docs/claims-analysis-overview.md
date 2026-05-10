# Claims Data Analysis

## Objective
Analyze insurance claims to identify billing patterns, measure denial rates, and optimize revenue cycle management.

## Dataset
File: `SQL/data/claims_data.csv` (30 claims)

| Field | Description |
|-------|-------------|
| claim_id | Unique claim identifier |
| patient_id | Link to patient record |
| service_date | Date of service |
| procedure_code | CPT billing code |
| diagnosis_code | ICD-10 code |
| claim_amount | Billed charge |
| paid_amount | Amount reimbursed |
| denial_reason | Reason for denial |
| claim_status | Paid / Denied / Pending |
| payer_type | Medicare / Medicaid / Commercial |
| provider_npi | National Provider Identifier |
| place_of_service | Office / Hospital / ER |

## Key Analysis Areas
1. Claims Volume and Revenue
2. Denial Rate Analysis
3. Denial Reason Distribution
4. High-Cost Patients
5. Procedure Code Utilization
6. Monthly Trends

## Key Insights
- Medicare has the highest claim volume
- Denial rate varies significantly by place of service
- Top denial reason: "Not medically necessary" (documentation gaps)
- High-cost claims cluster in cardiology and neurology
- Readmitted patients generate significantly higher total claim costs

## Future Improvements
- Add claim lag analysis
- Build denial prediction ML model
- Add prior authorization tracking
- Include appeals and overturn rates
- Add fraud detection rules
