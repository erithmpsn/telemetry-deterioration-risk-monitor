# Executive Summary
## Telemetry Deterioration Risk Monitor
### A Proof-of-Concept Clinical Decision Support Model

**Author:** Eric Thompson, MSHI Candidate | UAB O'Neal Comprehensive Cancer Center
**Classification:** Educational Portfolio Project — Synthetic Data Only

---

## Project Origin

This project evolved from work first presented at the **ATTIS 2026 Symposium** (Poster P31) at the University of Alabama at Birmingham. The original proof of concept used a 300-patient synthetic dataset with 6 features and a rule-based deterioration outcome, demonstrating feasibility.

This expanded version uses a 1,000-patient dataset, 26 clinical features, and a proper probabilistic outcome simulation with logistic weights — representing the next phase of development toward eventual validation with real EHR data.

---

## The Problem

Patients deteriorate on the cardiac floor not because the data is missing — but because the humans monitoring it are exhausted, desensitized by false alarms, and operating at reduced cognitive capacity after hour eight of a twelve-hour shift.

The failure chain breaks at the **human decision point between the telemetry technician and the bedside nurse** — specifically during gray zone events on the night shift, when alarm fatigue, self-filtering, and the social friction of repeated escalation calls create a window where real deterioration goes unescalated for one to four hours.

---

## Methods

**Dataset:** 1,000 synthetic patient encounters. Features include demographics, vital signs, laboratory values, telemetry flags, oxygen support, trend variables, and nursing concern. Deterioration outcome generated using a clinically weighted logistic simulation with an -5 intercept and feature weights derived from the author's clinical experience and the early warning score literature (NEWS, MEWS).

**Deterioration rate: 8.4%** — calibrated to realistic telemetry/step-down unit ICU transfer and rapid response rates.

**Model:** Logistic regression (primary), Random Forest (comparison). 80/20 stratified train/test split. Median imputation for missing labs (~3%). StandardScaler normalization. Class-balanced weighting to handle outcome imbalance.

---

## Results

| Metric | Logistic Regression | Random Forest |
|---|---|---|
| **AUROC** | **0.853** | 0.800 |
| Accuracy | 0.785 | — |
| Sensitivity | 0.824 | — |
| Specificity | 0.781 | — |
| F1 Score | 0.394 | — |

The model correctly identifies **82.4% of patients who deteriorated** (sensitivity). Specificity of 78.1% means the false alarm rate is clinically manageable. The lower F1 score reflects class imbalance — with only 8.4% positive cases, precision is constrained by design, which is appropriate for a screening application where missing a deterioration event carries far higher cost than a false positive.

**Versus the original ATTIS model:** The 2026 ATTIS poster reported an AUROC of 0.986 using a rule-based outcome. That figure reflects a model re-learning the rule it was given, not genuine predictive performance. The current AUC of 0.853 is an honest result from a proper train/test split on a probabilistic outcome — a meaningful improvement in methodological rigor.

---

## Key Findings

- **Lactate** and **nurse concern flag** were the strongest predictors of deterioration
- **Respiratory rate trend** (rising) outperformed absolute respiratory rate as a predictor — validating the drift-index hypothesis at the core of this project
- **Prior ICU admission** during the same hospitalization conferred significant additional risk
- **Oxygen support requirement** was a strong independent predictor across all device types
- The model's **sensitivity of 82.4%** makes it suitable as a screening tool — designed to catch most true deterioration events at the cost of some false escalations

---

## Limitations

- Synthetic data limits generalizability
- Single time-point snapshot — real deterioration is time-series
- No external validation
- Class imbalance limits precision metrics

---

## Next Steps

- [ ] MIMIC-IV credentialed access — retrain on real ICU-adjacent data
- [ ] Rolling time-window drift index replacing single snapshots
- [ ] Live Streamlit dashboard prototype
- [ ] SHAP values for patient-level explainability
- [ ] AMIA or Applied Clinical Informatics submission

---

> Synthetic data only. Not validated for clinical use. No real patient data used.
