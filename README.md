# Healthcare Data Analytics Project Showcase

> A complete, production-ready portfolio of healthcare data analytics projects covering SQL analysis, HEDIS metrics, claims analysis, patient readmission insights, and data quality validation.

---

## About Me

Healthcare Data Analyst with 7+ years of experience in data quality, claims analysis, and reporting.
Skilled in **SQL**, **Power BI**, and **Excel**, with a strong focus on **HEDIS metrics**, **patient outcomes**, and **healthcare data validation**.
Passionate about transforming raw healthcare data into actionable insights that improve patient care and reduce costs.

---

## Project Highlights

| Project | Tools | Status |
|---------|-------|--------|
| Patient Readmission Analysis | SQL, Excel, Python | Complete |
| HEDIS Metrics Analysis | SQL, Python | Complete |
| Claims Data Analysis | SQL, Excel | Complete |
| Data Quality & Validation | SQL, Python | Complete |
| Healthcare Dashboard | Power BI | Documented |

---

## Tech Stack

- **SQL** (PostgreSQL / SQL Server compatible)
- **Python** (pandas, matplotlib, seaborn)
- **Excel** (pivot tables, formulas, charts)
- **Power BI** (DAX, data modeling, dashboards)
- **Healthcare Standards**: HEDIS, NCQA, ICD-10, CPT codes

---

## Repository Structure

```
Healthcare-analytics-project/
|
|-- README.md
|-- .gitignore
|
|-- SQL/
    |-- data/
    |   |-- sample-dataset.csv          (original 5-record seed)
    |   |-- patients_full.csv           (50 patients, 13 fields)
    |   |-- claims_data.csv             (30 insurance claims)
    |   |-- hedis_measures.csv          (10 HEDIS measure definitions)
    |   |-- data_dictionary.md          (ICD-10, CPT codes, column docs)
    |
    |-- docs/
    |   |-- project-overview.md         (Patient Readmission)
    |   |-- hedis-analysis-overview.md  (HEDIS Metrics)
    |   |-- claims-analysis-overview.md (Revenue Cycle)
    |   |-- data-quality-overview.md    (DQ Framework)
    |
    |-- queries/
    |   |-- 01_patient_readmission.sql  (5 sections, 15+ queries)
    |   |-- 02_hedis_metrics.sql        (denominator/numerator logic)
    |   |-- 03_claims_analysis.sql      (denial, financial analysis)
    |   |-- 04_data_quality.sql         (completeness, validity checks)
    |   |-- 05_create_tables.sql        (DDL with constraints & indexes)
    |
    |-- python/
        |-- analysis.py                 (EDA + 5 chart outputs)
        |-- hedis_calculator.py         (6-measure HEDIS engine)
        |-- requirements.txt            (Python dependencies)
```

---

## Quick Start

### SQL Setup (PostgreSQL)

```bash
# 1. Create database
createdb healthcare_analytics

# 2. Create tables
psql -d healthcare_analytics -f SQL/queries/05_create_tables.sql

# 3. Import CSVs from SQL/data/ into their respective tables

# 4. Run analyses
psql -d healthcare_analytics -f SQL/queries/01_patient_readmission.sql
psql -d healthcare_analytics -f SQL/queries/02_hedis_metrics.sql
psql -d healthcare_analytics -f SQL/queries/03_claims_analysis.sql
psql -d healthcare_analytics -f SQL/queries/04_data_quality.sql
```

### Python Setup

```bash
pip install -r SQL/python/requirements.txt
python SQL/python/analysis.py
python SQL/python/hedis_calculator.py
```

---

## Sample Results

### Patient Readmission by Diagnosis

| Diagnosis | Readmission Rate | Avg LOS |
|-----------|-----------------|----------|
| COPD | ~100% | 9.7 days |
| Stroke | ~100% | 9.8 days |
| Heart Disease | ~86% | 7.7 days |
| Diabetes | ~91% | 5.8 days |
| Hypertension | ~0% | 2.8 days |
| Asthma | ~0% | 2.3 days |

### HEDIS Compliance (Simulated)

| Measure | Compliance | Target | Status |
|---------|-----------|--------|--------|
| CBP (Hypertension) | ~75% | 60% | MET |
| CDC (Diabetes HbA1c) | ~82% | 85% | NOT MET |
| PCR (Readmissions) | ~40% | 90% | NOT MET |
| MMA (Asthma Meds) | ~80% | 75% | MET |

---

## Contribution Guidelines

We welcome contributions from data enthusiasts, analysts, and healthcare professionals!

**How to Contribute:**
1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a Pull Request

**Contribution Ideas:**
- Add real-world healthcare datasets (CMS, HCUP NIS)
- Build Power BI / Tableau dashboards
- Write additional SQL queries
- Add ML readmission prediction model
- Create additional HEDIS measure calculations

---

## Support

If you find this project useful, please give it a star and share it!

## Connect with Me

Let's connect on LinkedIn and collaborate on data projects!
