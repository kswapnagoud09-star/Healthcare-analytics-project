"""
Healthcare Data Analytics Project
File: hedis_calculator.py
Purpose: HEDIS Quality Measure Calculation Engine

Supported Measures:
    CBP  - Controlling High Blood Pressure
    CDC  - Comprehensive Diabetes Care
    PCR  - Plan All-Cause Readmissions
    BCS  - Breast Cancer Screening
    MMA  - Medication Management for Asthma
"""

import pandas as pd
from dataclasses import dataclass
from pathlib import Path

DATA_DIR = Path(__file__).parent.parent / "data"


@dataclass
class HEDISResult:
    measure_id:      str
    measure_name:    str
    denominator:     int
    numerator:       int
    exclusions:      int
    compliance_rate: float
    target_rate:     float

    @property
    def gap_count(self):
        return self.denominator - self.numerator

    @property
    def meets_target(self):
        return self.compliance_rate >= self.target_rate

    def __str__(self):
        status = "MET" if self.meets_target else "NOT MET"
        return (
            f"  [{self.measure_id}] {self.measure_name}\n"
            f"    Denominator  : {self.denominator}\n"
            f"    Numerator    : {self.numerator}\n"
            f"    Compliance   : {self.compliance_rate:.1%}  (Target: {self.target_rate:.1%})\n"
            f"    Status       : {status}\n"
            f"    Gap (members): {self.gap_count}\n"
        )


class HEDISCalculator:
    """Core HEDIS calculation engine using NCQA-style logic."""

    def __init__(self, patients: pd.DataFrame, measurement_year: int = 2024):
        self.df   = patients.copy()
        self.year = measurement_year
        self._preprocess()

    def _preprocess(self):
        self.df["age"]        = pd.to_numeric(self.df["age"], errors="coerce")
        self.df["readmitted"] = self.df["readmitted"].str.strip()
        self.df["gender"]     = self.df["gender"].str.strip().str.upper()
        self.df["diagnosis"]  = self.df["diagnosis"].str.strip()
        self.df["payer_type"] = self.df["payer_type"].str.strip()
        if "comorbidity_count" not in self.df.columns:
            self.df["comorbidity_count"] = 0

    # CBP - Controlling High Blood Pressure
    def cbp(self):
        denom_df = self.df[
            self.df["diagnosis"].str.contains("Hypertension", case=False, na=False) &
            self.df["age"].between(18, 85)
        ]
        denom  = len(denom_df)
        numer  = int((denom_df["readmitted"] == "No").sum())
        rate   = numer / denom if denom > 0 else 0.0
        return HEDISResult("HED001", "Controlling High Blood Pressure (CBP)",
                           denom, numer, 0, rate, 0.60)

    # CDC - Diabetes HbA1c Testing
    def cdc_hba1c(self):
        denom_df = self.df[
            self.df["diagnosis"].str.contains("Diabetes", case=False, na=False) &
            self.df["age"].between(18, 75)
        ]
        denom  = len(denom_df)
        numer  = int((denom_df["icu_flag"] == "No").sum())
        rate   = numer / denom if denom > 0 else 0.0
        return HEDISResult("HED002", "Comprehensive Diabetes Care - HbA1c Testing (CDC)",
                           denom, numer, 0, rate, 0.85)

    # CDC - HbA1c Control
    def cdc_control(self):
        denom_df = self.df[
            self.df["diagnosis"].str.contains("Diabetes", case=False, na=False) &
            self.df["age"].between(18, 75)
        ]
        denom  = len(denom_df)
        numer  = int((denom_df["comorbidity_count"] <= 1).sum())
        rate   = numer / denom if denom > 0 else 0.0
        return HEDISResult("HED003", "Comprehensive Diabetes Care - HbA1c Control (CDC)",
                           denom, numer, 0, rate, 0.55)

    # PCR - Plan All-Cause Readmissions (inverse: lower is better)
    def pcr(self):
        denom_df = self.df[self.df["length_of_stay"] >= 1]
        denom    = len(denom_df)
        numer    = int((denom_df["readmitted"] == "Yes").sum())
        rate     = numer / denom if denom > 0 else 0.0
        compliance = 1 - rate  # % NOT readmitted
        return HEDISResult("HED009", "Plan All-Cause Readmissions (PCR) - lower readmit = better",
                           denom, int(denom - numer), 0, compliance, 0.90)

    # MMA - Medication Management for Asthma
    def mma(self):
        denom_df = self.df[
            self.df["diagnosis"].str.contains("Asthma", case=False, na=False) &
            self.df["age"].between(5, 64)
        ]
        denom  = len(denom_df)
        numer  = int(((denom_df["readmitted"] == "No") & (denom_df["length_of_stay"] <= 3)).sum())
        rate   = numer / denom if denom > 0 else 0.0
        return HEDISResult("HED010", "Medication Management for Asthma (MMA)",
                           denom, numer, 0, rate, 0.75)

    # BCS - Breast Cancer Screening
    def bcs(self):
        denom_df = self.df[
            (self.df["gender"] == "F") &
            self.df["age"].between(50, 74)
        ]
        denom  = len(denom_df)
        numer  = int((denom_df["icu_flag"] == "No").sum())
        rate   = numer / denom if denom > 0 else 0.0
        return HEDISResult("HED005", "Breast Cancer Screening (BCS)",
                           denom, numer, 0, rate, 0.70)

    def run_all(self):
        return [self.cbp(), self.cdc_hba1c(), self.cdc_control(),
                self.pcr(), self.mma(), self.bcs()]

    def summary_dataframe(self):
        return pd.DataFrame([{
            "Measure ID":      r.measure_id,
            "Measure Name":    r.measure_name,
            "Denominator":     r.denominator,
            "Numerator":       r.numerator,
            "Gap":             r.gap_count,
            "Compliance":      f"{r.compliance_rate:.1%}",
            "Target":          f"{r.target_rate:.1%}",
            "Meets Target":    "Yes" if r.meets_target else "No",
        } for r in self.run_all()])


if __name__ == "__main__":
    patients = pd.read_csv(DATA_DIR / "patients_full.csv")
    calc     = HEDISCalculator(patients, measurement_year=2024)

    print("\n" + "="*60)
    print("  HEDIS QUALITY MEASURE RESULTS - 2024")
    print("="*60)
    for result in calc.run_all():
        print(result)

    summary = calc.summary_dataframe()
    print("\n=== Summary Table ===")
    print(summary.to_string(index=False))

    out_path = Path(__file__).parent / "hedis_summary_2024.csv"
    summary.to_csv(out_path, index=False)
    print(f"\nSummary exported to {out_path}")
