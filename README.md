 Telemetry Deterioration Risk Monitor
 A Proof-of-Concept ML Model for Early Detection of Clinical Deterioration

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python&logoColor=white)
![Scikit-Learn](https://img.shields.io/badge/scikit--learn-ML%20Framework-orange?logo=scikitlearn)
![SQL](https://img.shields.io/badge/SQL-Clinical%20Queries-informational)
![Status](https://img.shields.io/badge/Status-Portfolio%20%7C%20Educational-green)


---

## Overview

This project builds a proof-of-concept clinical decision support model that predicts
whether a telemetry or step-down patient is at risk for **clinical deterioration**,
defined as ICU transfer or rapid response team activation.

It was developed as part of an MSHI capstone portfolio to demonstrate applied skills
in health informatics, clinical analytics, machine learning, and EHR data architecture —
grounded in real clinical monitoring experience.

---

## The Clinical Problem

> *"Patients deteriorate on the cardiac floor not because the data is missing — but
> because the humans monitoring it are exhausted, desensitized by false alarms, and
> operating at reduced cognitive capacity after hour eight of a twelve-hour shift."*

The failure chain does not break at the monitor. It breaks at the **human decision
point between the telemetry technician and the bedside nurse** — during gray zone
events on the night shift, when alarm fatigue, self-filtering, and the social friction
of repeated escalation calls create a window where real deterioration goes unescalated
for one to four hours.

This model is one component of a broader system design intended to address that gap.

---

## My Connection to This Problem

I spent years as a **lead telemetry technician and cardiac monitoring specialist** before
transitioning into clinical research data coordination and health informatics. I have
personally worked the overnight shift, watched the escalation dynamics play out in real
time, and understood — from both the technical and clinical sides — exactly where the
system breaks.

This project is the bridge between that operational experience and the analytical
toolkit I am building through my MSHI program at UAB.

---

## Tools Used

| Category | Tools |
|---|---|
| Language | Python 3.10+ |
| ML Framework | scikit-learn (Logistic Regression, Random Forest) |
| Data Processing | pandas, NumPy, SciPy |
| Visualization | Matplotlib, seaborn |
| Database Queries | SQL (PostgreSQL-compatible) |
| Dashboard Concept | Streamlit (prototype design) |
| Version Control | Git / GitHub |

---

## Dataset

**1,000 synthetic patient encounters** generated using a clinically weighted logistic
simulation. Features include:

- Demographics: age, sex
- Unit and admission context: unit type, admission source, LOS, prior ICU admission
- Vital signs: HR, RR, SBP, DBP, SpO2, temperature
- Labs: creatinine, WBC, lactate (~3% missing to simulate real-world quality)
- Telemetry flags: abnormal telemetry flag, arrhythmia type, oxygen support
- Clinical flags: nurse concern flag, comorbidity score
- Trend variables: HR trend, RR trend, SpO2 trend (−1/0/+1)
- **Outcome:** `deterioration_event` (binary)

The outcome was generated using a logistic model with clinically motivated weights,
producing a deterioration rate of approximately 8.4%.

---

## Methods

1. Synthetic data generation with realistic clinical feature-outcome relationships
2. Exploratory data analysis and clinical summary statistics
3. Feature engineering (binary encoding of categorical variables)
4. Median imputation for missing lab values
5. Z-score standardization for logistic regression
6. Logistic regression (primary) + Random Forest (comparison)
7. Evaluation: AUROC, accuracy, sensitivity, specificity, precision, F1, confusion matrix
8. Risk stratification: Low (<20%) / Moderate (20–50%) / High (>50%)
9. SQL-based drift signal score as rules-based complement to probabilistic model

---

## Results

| Metric | Logistic Regression | Random Forest |
|---|---|---|
| **AUROC** | **0.752** | 0.800 |
| Accuracy | 0.785 | — |
| Sensitivity | 0.824 | — |
| Specificity | 0.781 | — |
| F1 Score | 0.394 | — |

Logistic regression was selected as the primary model for its **clinical interpretability**
— a requirement in any healthcare decision support context where clinicians must understand
and trust the model's reasoning.

---

## Key Insights

- Lactate elevation was the strongest individual predictor of deterioration
- Oxygen support requirement was the second-strongest predictor
- Nurse concern flag was a significant independent predictor — validating clinical intuition as a data point
- Rising respiratory rate trend outperformed absolute respiratory rate value, supporting
  the drift-index hypothesis central to this project's design
- Prior ICU admission during the same hospitalization conferred substantial additional risk

---

## Visualizations

| Figure | Description |
|---|---|
| `roc_curve.png` | ROC curves for LR and RF with AUC |
| `confusion_matrix.png` | LR confusion matrix (TP, FP, FN, TN) |
| `feature_coefficients.png` | Standardized LR coefficients — directional risk attribution |
| `risk_distribution.png` | Risk score histogram by outcome with tier thresholds |
| `clinical_risk_factors.png` | Deterioration rate by telemetry status and O2 support |
| `patient_vitals_trend.png` | Simulated 6-hour deterioration trajectory (HR, RR, SpO2) |

---

## File Structure

```
telemetry-risk-monitor/
├── README.md
├── data/
│   └── synthetic_telemetry_data.csv
├── scripts/
│   └── generate_data.py
├── notebooks/
│   └── telemetry_risk_model.ipynb
├── sql/
│   └── telemetry_analysis.sql
├── dashboard/
│   └── dashboard_concept.md
├── docs/
│   ├── data_dictionary.md
│   └── executive_summary.md
└── assets/
    ├── roc_curve.png
    ├── confusion_matrix.png
    ├── feature_coefficients.png
    ├── risk_distribution.png
    ├── clinical_risk_factors.png
    └── patient_vitals_trend.png
```

---

## Limitations

- Synthetic data limits generalizability to real clinical populations
- Single time-point snapshot model — real deterioration is a time-series process
- No external validation; internal test set only
- Binary outcome combines ICU transfer and rapid response into one label

---

## Future Work

- [ ] Acquire MIMIC-IV credentialed access and retrain on real telemetry/ICU data
- [ ] Implement rolling time-window drift index for trend aggregation
- [ ] Build Streamlit dashboard for live demo
- [ ] Explore SHAP values for individual patient-level explainability
- [ ] Investigate prospective validation pathway at UAB O'Neal / UAB Medicine
- [ ] Formalize gray zone escalation taxonomy for sociotechnical human factors study

---

## Author

**Eric Thompson**
MSHI Candidate — University of Alabama at Birmingham
Clinical Research Data Coordinator — UAB O'Neal Comprehensive Cancer Center
Former Lead Telemetry Technician & Cardiac Monitoring Specialist

[![LinkedIn](https://www.linkedin.com/in/checkoutericthompson/)
[![GitHub]([https://img.shields.io/badge/GitHub-Portfolio-black?logo=github)](https://github.com/yourhandle](https://github.com/erithmpsn))

---

> This project was presented conceptually at ATTIS and serves as the foundation
> for ongoing graduate capstone work in clinical informatics and AI-assisted
> patient monitoring.

## Disclaimer
This project uses simulated data only. It is for portfolio and educational purposes and is not intended for clinical use, diagnosis, treatment, or real-time patient monitoring.
