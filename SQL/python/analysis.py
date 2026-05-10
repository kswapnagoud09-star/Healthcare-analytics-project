"""
Healthcare Data Analytics Project
File: analysis.py
Purpose: Exploratory Data Analysis and Visualization
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

DATA_DIR   = Path(__file__).parent.parent / "data"
OUTPUT_DIR = Path(__file__).parent / "output"
OUTPUT_DIR.mkdir(exist_ok=True)

plt.style.use("seaborn-v0_8-whitegrid")
sns.set_palette("tab10")


def load_data():
    patients = pd.read_csv(DATA_DIR / "patients_full.csv",
                           parse_dates=["admission_date", "discharge_date"])
    claims   = pd.read_csv(DATA_DIR / "claims_data.csv", parse_dates=["service_date"])
    print(f"Loaded {len(patients)} patient records and {len(claims)} claims.")
    return patients, claims


def readmission_analysis(df):
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Patient Readmission Analysis", fontsize=16, fontweight="bold")

    readm_counts = df["readmitted"].value_counts()
    axes[0, 0].pie(readm_counts, labels=readm_counts.index, autopct="%1.1f%%",
                   colors=["#2196F3", "#FF7043"], startangle=90)
    axes[0, 0].set_title("Overall Readmission Rate")

    diag_readm = (df.groupby("diagnosis")["readmitted"]
                    .apply(lambda x: (x == "Yes").mean() * 100)
                    .sort_values(ascending=False))
    diag_readm.plot(kind="bar", ax=axes[0, 1], color="#42A5F5", edgecolor="white")
    axes[0, 1].set_title("Readmission Rate by Diagnosis (%)")
    axes[0, 1].tick_params(axis="x", rotation=30)

    df.boxplot(column="age", by="readmitted", ax=axes[1, 0], grid=False)
    axes[1, 0].set_title("Age by Readmission")

    df.boxplot(column="length_of_stay", by="readmitted", ax=axes[1, 1], grid=False)
    axes[1, 1].set_title("LOS by Readmission")

    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "01_readmission_analysis.png", dpi=150)
    plt.close(fig)
    print("Saved: 01_readmission_analysis.png")


def diagnosis_demographics(df):
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Diagnosis & Demographics", fontsize=16, fontweight="bold")

    df["diagnosis"].value_counts().plot(kind="barh", ax=axes[0], color="#64B5F6")
    axes[0].set_title("Patient Count by Diagnosis")

    gen_cnt = df["gender"].value_counts()
    axes[1].pie(gen_cnt, labels=["Male","Female"], autopct="%1.1f%%",
                colors=["#42A5F5","#EF5350"], startangle=90)
    axes[1].set_title("Gender Distribution")

    df["payer_type"].value_counts().plot(kind="bar", ax=axes[2], color="#81C784", edgecolor="white")
    axes[2].set_title("Payer Type Distribution")
    axes[2].tick_params(axis="x", rotation=15)

    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "02_diagnosis_demographics.png", dpi=150)
    plt.close(fig)
    print("Saved: 02_diagnosis_demographics.png")


def los_analysis(df):
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle("Length of Stay Analysis", fontsize=16, fontweight="bold")

    df["length_of_stay"].hist(bins=15, ax=axes[0], color="#42A5F5", edgecolor="white")
    axes[0].axvline(df["length_of_stay"].mean(), color="red", linestyle="--", label="Mean")
    axes[0].axvline(df["length_of_stay"].median(), color="orange", linestyle="--", label="Median")
    axes[0].set_title("Distribution of Length of Stay")
    axes[0].legend()

    df.groupby("department")["length_of_stay"].mean().sort_values(ascending=False)\
      .plot(kind="bar", ax=axes[1], color="#FFA726", edgecolor="white")
    axes[1].set_title("Average LOS by Department")
    axes[1].tick_params(axis="x", rotation=30)

    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "03_los_analysis.png", dpi=150)
    plt.close(fig)
    print("Saved: 03_los_analysis.png")


def claims_analysis(df_patients, df_claims):
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Claims Data Analysis", fontsize=16, fontweight="bold")

    status_cnt = df_claims["claim_status"].value_counts()
    axes[0, 0].pie(status_cnt, labels=status_cnt.index, autopct="%1.1f%%",
                   colors=["#66BB6A", "#EF5350"], startangle=90)
    axes[0, 0].set_title("Claim Status Distribution")

    payer_fin = df_claims.groupby("payer_type")[["claim_amount", "paid_amount"]].sum()
    payer_fin.plot(kind="bar", ax=axes[0, 1], color=["#42A5F5", "#66BB6A"], edgecolor="white")
    axes[0, 1].set_title("Billed vs Paid by Payer ($)")
    axes[0, 1].tick_params(axis="x", rotation=15)
    axes[0, 1].legend(["Billed", "Paid"])

    denied = df_claims[df_claims["claim_status"] == "Denied"]
    if len(denied) > 0:
        denied["denial_reason"].value_counts().plot(kind="barh", ax=axes[1, 0], color="#EF9A9A")
    axes[1, 0].set_title("Denial Reasons")

    df_claims["claim_amount"].hist(bins=20, ax=axes[1, 1], color="#AB47BC", edgecolor="white")
    axes[1, 1].set_title("Claim Amount Distribution")

    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "04_claims_analysis.png", dpi=150)
    plt.close(fig)
    print("Saved: 04_claims_analysis.png")


def risk_scoring(df):
    df = df.copy()
    df["risk_score"] = (
        df["age"].apply(lambda a: 3 if a >= 70 else 0) +
        df["length_of_stay"].apply(lambda l: 3 if l > 7 else 0) +
        df["icu_flag"].apply(lambda f: 2 if f == "Yes" else 0) +
        df["comorbidity_count"].apply(lambda c: 2 if c >= 3 else 0) +
        df["payer_type"].apply(lambda p: 1 if p == "Medicare" else 0)
    )
    df["risk_category"] = df["risk_score"].apply(
        lambda s: "HIGH" if s >= 7 else ("MEDIUM" if s >= 4 else "LOW")
    )
    fig, ax = plt.subplots(figsize=(8, 5))
    df["risk_category"].value_counts().reindex(["HIGH","MEDIUM","LOW"])\
      .plot(kind="bar", ax=ax, color=["#EF5350","#FFA726","#66BB6A"], edgecolor="white")
    ax.set_title("Patient Risk Category Distribution", fontsize=14, fontweight="bold")
    ax.set_ylabel("Patient Count")
    ax.tick_params(axis="x", rotation=0)
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "05_risk_scoring.png", dpi=150)
    plt.close(fig)
    print("Saved: 05_risk_scoring.png")
    return df


def print_summary(df, df_claims):
    total  = len(df)
    readm  = (df["readmitted"] == "Yes").sum()
    billed = df_claims["claim_amount"].sum()
    paid   = df_claims["paid_amount"].sum()
    denial = (df_claims["claim_status"] == "Denied").mean() * 100
    print("\n" + "="*50)
    print("  HEALTHCARE ANALYTICS - SUMMARY REPORT")
    print("="*50)
    print(f"  Total Patients      : {total}")
    print(f"  Readmissions        : {readm} ({readm/total*100:.1f}%)")
    print(f"  Avg LOS             : {df['length_of_stay'].mean():.1f} days")
    print(f"  Total Billed        : ${billed:,.2f}")
    print(f"  Total Paid          : ${paid:,.2f}")
    print(f"  Denial Rate         : {denial:.1f}%")
    print(f"  Payment Rate        : {paid/billed*100:.1f}%")
    print("="*50)


if __name__ == "__main__":
    patients, claims = load_data()
    readmission_analysis(patients)
    diagnosis_demographics(patients)
    los_analysis(patients)
    claims_analysis(patients, claims)
    patients_scored = risk_scoring(patients)
    print_summary(patients_scored, claims)
    print("\nAll charts saved to SQL/python/output/")
