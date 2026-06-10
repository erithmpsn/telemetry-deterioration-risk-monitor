"""
Synthetic Telemetry Dataset Generator
======================================
Project: Telemetry Deterioration Risk Monitor
Author:  Eric Thompson | MSHI Candidate, UAB
Built on: Original ATTIS 2026 proof-of-concept work

This script generates the synthetic dataset that powers the project.
Variable names, distributions, and logistic weights are derived from
the author's own notebook design — not from an external dataset.

DISCLAIMER: Synthetic data only. No real patient data used.
Educational and portfolio use only.
"""

import numpy as np
import pandas as pd
from scipy.special import expit
import os

np.random.seed(42)
n = 1000

df = pd.DataFrame({
    'patient_id':    [f'P{str(i).zfill(4)}' for i in range(1, n+1)],
    'encounter_id':  [f'E{str(i).zfill(5)}' for i in range(1, n+1)],
    'age':           np.random.randint(25, 90, n),
    'sex':           np.random.choice(['Male','Female'], n),
    'unit_type':     np.random.choice(
                        ['Telemetry','Step-down','Med-Surg','Cardiac'],
                        n, p=[0.35, 0.30, 0.20, 0.15]),
    'admission_source': np.random.choice(
                        ['ED','Transfer','Direct Admit','Post-op'],
                        n, p=[0.45, 0.25, 0.20, 0.10]),
    'heart_rate':       np.random.normal(92, 18, n).round(0),
    'respiratory_rate': np.random.normal(20, 5,  n).round(0),
    'systolic_bp':      np.random.normal(122, 22, n).round(0),
    'diastolic_bp':     np.random.normal(76, 12,  n).round(0),
    'spo2':             np.random.normal(95, 4,   n).round(0),
    'temperature':      np.random.normal(98.7, 1.2, n).round(1),
    'creatinine':       np.random.normal(1.1, 0.4,  n).round(2),
    'wbc':              np.random.normal(9.5, 3.0,  n).round(1),
    'lactate':          np.random.normal(1.6, 0.8,  n).round(2),
    'comorbidity_score': np.random.poisson(2, n),
    'oxygen_support':   np.random.choice(
                        ['None','Nasal Cannula','Non-rebreather','High Flow'],
                        n, p=[0.55, 0.30, 0.10, 0.05]),
    'abnormal_telemetry_flag': np.random.choice([0,1], n, p=[0.75, 0.25]),
    'heart_rate_trend':       np.random.choice([-1,0,1], n, p=[0.25, 0.45, 0.30]),
    'respiratory_rate_trend': np.random.choice([-1,0,1], n, p=[0.20, 0.45, 0.35]),
    'spo2_trend':             np.random.choice([-1,0,1], n, p=[0.35, 0.45, 0.20]),
    'nurse_concern_flag':     np.random.choice([0,1], n, p=[0.80, 0.20]),
    'prior_icu_admission':    np.random.choice([0,1], n, p=[0.85, 0.15]),
    'length_of_stay_days':    np.random.exponential(4, n).round(1),
})

# Clip to clinically reasonable ranges
df['heart_rate']         = df['heart_rate'].clip(45, 160)
df['respiratory_rate']   = df['respiratory_rate'].clip(10, 40)
df['systolic_bp']        = df['systolic_bp'].clip(70, 200)
df['diastolic_bp']       = df['diastolic_bp'].clip(40, 120)
df['spo2']               = df['spo2'].clip(75, 100)
df['creatinine']         = df['creatinine'].clip(0.4, 5.0)
df['wbc']                = df['wbc'].clip(3.0, 25.0)
df['lactate']            = df['lactate'].clip(0.5, 8.0)
df['comorbidity_score']  = df['comorbidity_score'].clip(0, 8)

# Arrhythmia type
arrhythmias = ['Atrial Fibrillation','PVCs','SVT','Ventricular Tachycardia','Bradycardia']
df['arrhythmia_type'] = np.where(
    df['abnormal_telemetry_flag'] == 1,
    np.random.choice(arrhythmias, n, p=[0.35, 0.25, 0.15, 0.10, 0.15]),
    'None'
)

# Deterioration outcome — logistic simulation with clinical weights
risk_logit = (
    -5
    + 0.035 * (df['age'] - 60)
    + 0.045 * (df['heart_rate'] - 90)
    + 0.120 * (df['respiratory_rate'] - 20)
    - 0.110 * (df['spo2'] - 95)
    - 0.035 * (df['systolic_bp'] - 120)
    + 0.550 * (df['lactate'] - 1.5)
    + 0.080 * (df['wbc'] - 9)
    + 0.220 * df['comorbidity_score']
    + 0.650 * df['abnormal_telemetry_flag']
    + 0.750 * df['nurse_concern_flag']
    + 0.600 * df['prior_icu_admission']
    + 0.500 * (df['oxygen_support'] != 'None').astype(int)
    + 0.350 * (df['heart_rate_trend'] == 1).astype(int)
    + 0.450 * (df['respiratory_rate_trend'] == 1).astype(int)
    + 0.450 * (df['spo2_trend'] == -1).astype(int)
)

df['deterioration_event'] = np.random.binomial(1, expit(risk_logit))

# ~3% missing lab values (real-world data quality simulation)
for col in ['creatinine','wbc','lactate']:
    idx = np.random.choice(df.index, size=int(0.03*n), replace=False)
    df.loc[idx, col] = np.nan

out = os.path.join(os.path.dirname(__file__), '../data/synthetic_telemetry_data.csv')
df.to_csv(out, index=False)
print(f"Generated {n} encounters | Deterioration rate: {df.deterioration_event.mean():.1%}")
