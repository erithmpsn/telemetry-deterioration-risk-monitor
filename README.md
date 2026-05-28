# telemetry-drift-monitor
Simulated health informatics project using SQL, Python, and logistic regression to identify early clinical deterioration risk in telemetry patients.
# Telemetry Drift Monitor

## Overview
Telemetry Drift Monitor is a simulated health informatics portfolio project focused on early detection of clinical deterioration in telemetry and step-down patients.

The project uses synthetic telemetry and EHR-style data to identify patients who may be at increased risk for rapid response activation or ICU transfer.

This project combines SQL cohort logic, Python-based modeling, risk stratification, and dashboard concepts to demonstrate applied clinical informatics and healthcare analytics skills.

## Clinical Problem
Patients often show subtle signs of deterioration before a major clinical event. These signs may include rising respiratory rate, falling oxygen saturation, abnormal telemetry findings, oxygen support needs, hypotension, elevated lactate, or nurse concern.

The goal of this project is to show how clinical monitoring data can be structured and analyzed to support earlier workflow visibility.

## My Connection to the Project
This project connects my background in telemetry monitoring, clinical research data coordination, and graduate training in health informatics.

## Current Repository Contents
- `sql/telemetry_deterioration_queries.sql` — SQL analysis queries for cohort review, high-risk patient flags, deterioration rates, missing data checks, drift signal logic, and dashboard summaries.
- `README.md` — Project overview and documentation.

## Key SQL Components
- Total patient encounters
- Overall deterioration rate
- High-risk patient flag logic
- Abnormal telemetry + low SpO2 query
- Deterioration rate by unit type
- Average vitals by deterioration status
- Missing lab data check
- Risk stratification table
- Drift Signal Score concept
- Dashboard summary table

## Planned Components
- Synthetic telemetry dataset
- Python machine learning notebook
- Logistic regression deterioration risk model
- Risk score output table
- ROC curve and confusion matrix
- Feature importance visualization
- Dashboard mockup

## Tools
- SQL
- Python
- Pandas
- scikit-learn
- Logistic Regression
- Synthetic healthcare data
- Clinical analytics
- Dashboard design

## Disclaimer
This project uses simulated data only. It is for portfolio and educational purposes and is not intended for clinical use, diagnosis, treatment, or real-time patient monitoring.
