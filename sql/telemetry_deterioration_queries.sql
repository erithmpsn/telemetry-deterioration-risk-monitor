-- ============================================================
-- Telemetry Deterioration Risk Monitor — SQL Analysis Queries
-- Project: Portfolio/MSHI Capstone | Author: Eric Thompson
-- Data: Synthetic only — no real patient data
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. TOTAL PATIENT ENCOUNTERS
-- ─────────────────────────────────────────────────────────────
SELECT
    COUNT(*)                        AS total_encounters,
    COUNT(DISTINCT patient_id)      AS unique_patients,
    MIN(age)                        AS min_age,
    ROUND(AVG(age), 1)              AS avg_age,
    MAX(age)                        AS max_age
FROM synthetic_telemetry_data;


-- ─────────────────────────────────────────────────────────────
-- 2. OVERALL DETERIORATION RATE
-- ─────────────────────────────────────────────────────────────
SELECT
    COUNT(*)                                                        AS total_encounters,
    SUM(deterioration_event)                                        AS total_deterioration_events,
    ROUND(100.0 * SUM(deterioration_event) / COUNT(*), 2)           AS deterioration_rate_pct
FROM synthetic_telemetry_data;


-- ─────────────────────────────────────────────────────────────
-- 3. HIGH-RISK PATIENT FLAGS
--    (meets 2+ clinical deterioration criteria)
-- ─────────────────────────────────────────────────────────────
SELECT
    patient_id,
    encounter_id,
    unit_type,
    heart_rate,
    respiratory_rate,
    spo2,
    systolic_bp,
    lactate,
    abnormal_telemetry_flag,
    nurse_concern_flag,
    oxygen_support,
    deterioration_event,
    -- Risk flag count
    (
        CASE WHEN respiratory_rate > 22           THEN 1 ELSE 0 END +
        CASE WHEN spo2 < 93                       THEN 1 ELSE 0 END +
        CASE WHEN systolic_bp < 90                THEN 1 ELSE 0 END +
        CASE WHEN lactate > 2.0                   THEN 1 ELSE 0 END +
        CASE WHEN abnormal_telemetry_flag = 1     THEN 1 ELSE 0 END +
        CASE WHEN nurse_concern_flag = 1          THEN 1 ELSE 0 END +
        CASE WHEN oxygen_support != 'None'        THEN 1 ELSE 0 END
    )                                              AS clinical_flag_count
FROM synthetic_telemetry_data
WHERE (
    CASE WHEN respiratory_rate > 22           THEN 1 ELSE 0 END +
    CASE WHEN spo2 < 93                       THEN 1 ELSE 0 END +
    CASE WHEN systolic_bp < 90                THEN 1 ELSE 0 END +
    CASE WHEN lactate > 2.0                   THEN 1 ELSE 0 END +
    CASE WHEN abnormal_telemetry_flag = 1     THEN 1 ELSE 0 END +
    CASE WHEN nurse_concern_flag = 1          THEN 1 ELSE 0 END +
    CASE WHEN oxygen_support != 'None'        THEN 1 ELSE 0 END
) >= 2
ORDER BY clinical_flag_count DESC, lactate DESC;


-- ─────────────────────────────────────────────────────────────
-- 4. ABNORMAL TELEMETRY + LOW SpO2 (COMBINED HIGH-RISK FLAG)
-- ─────────────────────────────────────────────────────────────
SELECT
    patient_id,
    encounter_id,
    unit_type,
    arrhythmia_type,
    spo2,
    oxygen_support,
    nurse_concern_flag,
    deterioration_event
FROM synthetic_telemetry_data
WHERE
    abnormal_telemetry_flag = 1
    AND spo2 < 92
ORDER BY spo2 ASC, deterioration_event DESC;


-- ─────────────────────────────────────────────────────────────
-- 5. DETERIORATION RATE BY UNIT TYPE
-- ─────────────────────────────────────────────────────────────
SELECT
    unit_type,
    COUNT(*)                                                AS total_patients,
    SUM(deterioration_event)                                AS deterioration_count,
    ROUND(100.0 * SUM(deterioration_event) / COUNT(*), 2)  AS deterioration_rate_pct
FROM synthetic_telemetry_data
GROUP BY unit_type
ORDER BY deterioration_rate_pct DESC;


-- ─────────────────────────────────────────────────────────────
-- 6. AVERAGE VITALS BY DETERIORATION STATUS
-- ─────────────────────────────────────────────────────────────
SELECT
    deterioration_event,
    CASE WHEN deterioration_event = 1 THEN 'Deteriorated'
         ELSE 'Stable'
    END                                                     AS patient_status,
    COUNT(*)                                                AS n,
    ROUND(AVG(heart_rate), 1)                               AS avg_heart_rate,
    ROUND(AVG(respiratory_rate), 1)                         AS avg_resp_rate,
    ROUND(AVG(systolic_bp), 1)                              AS avg_systolic_bp,
    ROUND(AVG(spo2), 1)                                     AS avg_spo2,
    ROUND(AVG(lactate), 2)                                  AS avg_lactate,
    ROUND(AVG(wbc), 1)                                      AS avg_wbc,
    ROUND(AVG(comorbidity_score), 2)                        AS avg_comorbidity_score,
    ROUND(AVG(length_of_stay_days), 1)                      AS avg_los_days
FROM synthetic_telemetry_data
GROUP BY deterioration_event
ORDER BY deterioration_event;


-- ─────────────────────────────────────────────────────────────
-- 7. MISSING DATA CHECK (Labs)
-- ─────────────────────────────────────────────────────────────
SELECT
    'creatinine' AS variable,
    COUNT(*)     AS total,
    SUM(CASE WHEN creatinine IS NULL THEN 1 ELSE 0 END)             AS missing_count,
    ROUND(100.0 * SUM(CASE WHEN creatinine IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS missing_pct
FROM synthetic_telemetry_data

UNION ALL

SELECT
    'wbc',
    COUNT(*),
    SUM(CASE WHEN wbc IS NULL THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN wbc IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM synthetic_telemetry_data

UNION ALL

SELECT
    'lactate',
    COUNT(*),
    SUM(CASE WHEN lactate IS NULL THEN 1 ELSE 0 END),
    ROUND(100.0 * SUM(CASE WHEN lactate IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM synthetic_telemetry_data;


-- ─────────────────────────────────────────────────────────────
-- 8. RISK STRATIFICATION TABLE
--    (requires risk_score column from model output)
-- ─────────────────────────────────────────────────────────────
SELECT
    CASE
        WHEN risk_score < 0.20 THEN 'Low Risk (<20%)'
        WHEN risk_score < 0.50 THEN 'Moderate Risk (20–50%)'
        ELSE                        'High Risk (>50%)'
    END                                                     AS risk_tier,
    COUNT(*)                                                AS patient_count,
    SUM(deterioration_event)                                AS actual_deteriorations,
    ROUND(100.0 * SUM(deterioration_event) / COUNT(*), 2)  AS observed_deterioration_rate_pct,
    ROUND(AVG(risk_score) * 100, 1)                         AS avg_predicted_risk_pct
FROM synthetic_telemetry_data
-- NOTE: risk_score column is added after model scoring
-- Replace table name with your scored output table
GROUP BY 1
ORDER BY avg_predicted_risk_pct;


-- ─────────────────────────────────────────────────────────────
-- 9. RISING RESPIRATORY RATE + FALLING SpO2 (GRAY ZONE EVENTS)
--    Core query for the Drift Index concept
-- ─────────────────────────────────────────────────────────────
SELECT
    patient_id,
    encounter_id,
    unit_type,
    respiratory_rate,
    respiratory_rate_trend,
    spo2,
    spo2_trend,
    heart_rate,
    heart_rate_trend,
    abnormal_telemetry_flag,
    nurse_concern_flag,
    deterioration_event,
    -- Drift Signal Score (rules-based proxy)
    (
        CASE WHEN respiratory_rate_trend  =  1 THEN 2 ELSE 0 END +
        CASE WHEN spo2_trend             = -1 THEN 2 ELSE 0 END +  -- note: -1 = worsening for SpO2
        CASE WHEN heart_rate_trend        =  1 THEN 1 ELSE 0 END +
        CASE WHEN respiratory_rate        > 22  THEN 1 ELSE 0 END +
        CASE WHEN spo2                    < 94  THEN 1 ELSE 0 END
    )                                           AS drift_signal_score
FROM synthetic_telemetry_data
WHERE
    respiratory_rate_trend = 1    -- respiratory rate is rising
    AND spo2_trend = -1           -- SpO2 is falling
ORDER BY drift_signal_score DESC, spo2 ASC;


-- ─────────────────────────────────────────────────────────────
-- 10. DASHBOARD SUMMARY TABLE
--     Aggregated view for a monitoring dashboard tile display
-- ─────────────────────────────────────────────────────────────
SELECT
    unit_type,
    COUNT(*)                                                AS total_monitored,
    SUM(CASE WHEN abnormal_telemetry_flag = 1 THEN 1 ELSE 0 END) AS abnormal_tele_count,
    SUM(CASE WHEN nurse_concern_flag = 1 THEN 1 ELSE 0 END)       AS nurse_concern_count,
    SUM(CASE WHEN spo2 < 94 THEN 1 ELSE 0 END)                    AS low_spo2_count,
    SUM(CASE WHEN respiratory_rate > 22 THEN 1 ELSE 0 END)        AS elevated_rr_count,
    SUM(CASE WHEN oxygen_support != 'None' THEN 1 ELSE 0 END)     AS on_o2_support,
    SUM(deterioration_event)                                AS confirmed_deteriorations,
    ROUND(100.0 * SUM(deterioration_event) / COUNT(*), 1)  AS deterioration_rate_pct,
    -- Combined high-alert count (≥3 flags)
    SUM(CASE WHEN (
        CASE WHEN spo2 < 94                    THEN 1 ELSE 0 END +
        CASE WHEN respiratory_rate > 22        THEN 1 ELSE 0 END +
        CASE WHEN abnormal_telemetry_flag = 1  THEN 1 ELSE 0 END +
        CASE WHEN nurse_concern_flag = 1       THEN 1 ELSE 0 END +
        CASE WHEN oxygen_support != 'None'     THEN 1 ELSE 0 END
    ) >= 3 THEN 1 ELSE 0 END)                               AS high_alert_patients
FROM synthetic_telemetry_data
GROUP BY unit_type
ORDER BY deterioration_rate_pct DESC;
