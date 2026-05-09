# HEDIS Metrics Analysis

## Objective
Calculate NCQA HEDIS quality measures from patient data, identify gaps in care, and support quality improvement.

## Measures Analyzed

| Measure | Code | Target |
|---------|------|--------|
| Controlling High Blood Pressure | CBP | 60% |
| Comprehensive Diabetes Care - HbA1c Testing | CDC | 85% |
| Comprehensive Diabetes Care - HbA1c Control | CDC | 55% |
| Plan All-Cause Readmissions | PCR | <=10% |
| Breast Cancer Screening | BCS | 70% |
| Medication Management for Asthma | MMA | 75% |

## Methodology
Each HEDIS measure:
1. **Denominator** - eligible population
2. **Exclusions** - members excluded (hospice, etc.)
3. **Numerator** - who received the required service
4. **Rate** = Numerator / (Denominator - Exclusions)

## Key Insights
- CBP is typically the hardest measure to meet due to medication adherence challenges
- PCR is an inverse measure: lower rate = better performance
- Diabetic patients represent the largest HEDIS-eligible population
- Gaps in care are most pronounced in the Medicare population

## Related Files
- `SQL/data/hedis_measures.csv` - HEDIS measure reference
- `SQL/queries/02_hedis_metrics.sql` - SQL HEDIS queries
- `SQL/python/hedis_calculator.py` - Python HEDIS engine
