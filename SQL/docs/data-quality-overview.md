# Data Quality & Validation

## Objective
Implement a comprehensive data quality framework for healthcare data.

## Data Quality Dimensions

| Dimension | Description | Checks |
|-----------|-------------|--------|
| Completeness | No required fields are null | NULL counts per column |
| Validity | Values within expected ranges | Age range, gender codes, date logic |
| Uniqueness | No duplicate records | Duplicate PKs, duplicate claims |
| Consistency | Consistent across fields | LOS matches date diff, paid <= billed |
| Referential Integrity | Foreign keys resolve | Orphan claims |

## Checks Implemented

### Patients Table
- NULL audit across all columns
- Completeness rate per column
- Age out of range (0-120)
- Invalid gender codes
- Discharge before admission date
- Negative length of stay
- LOS vs calculated date difference
- Duplicate patient_id

### Claims Table
- NULL audit across all columns
- Paid amount > billed amount
- Denied claim with paid amount > 0
- Orphan claims (no matching patient)
- Potential duplicate claims
- Duplicate claim_id

## Data Quality Scorecard
Run `SQL/queries/04_data_quality.sql` to generate the scorecard.

In real-world healthcare data, expect:
- 5-15% null rates on optional fields
- 1-3% of claims with validation errors
- ~5% duplicate encounter rate without deduplication

## Future Improvements
- Automated Python data profiling report
- Data lineage tracking
- HIPAA compliance checks (PHI field masking)
- dbt tests for pipeline validation
