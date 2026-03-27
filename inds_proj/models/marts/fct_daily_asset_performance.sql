{{ config(materialized='table') }}

-- Fact table: one row per asset per calendar day
-- Grain: asset + date (day is the most atomic level; Power BI rolls up to week / month / quarter via dim_date)
--
-- Combines daily sensor anomaly signals with daily utilisation metrics
-- Full outer join preserves days where only one source has data:
--   - Sensor readings without usage cycles (asset idle but monitored)
--   - Usage cycles without sensor readings (sensor gap / outage)
--
-- Key derivable metrics in Power BI:
--   Utilisation rate  → AVERAGE(daily_utilization_rate) over any asset / period slice
--   Anomaly rate      → DIVIDE(SUM(anomaly_count), SUM(total_readings)) for correct weighted avg
--   Runtime           → SUM(total_runtime_hours)
--   Load profile      → AVERAGE(avg_load_pct), MAX(peak_load_pct)
--
-- date_id joins to dim_date.date_id for full calendar drill hierarchy

with anomalies as (
    select
        asset_id,
        reading_date                as performance_date,
        total_readings,
        anomaly_count,
        anomaly_rate,
        high_temp_count,
        high_vibration_count,
        high_pressure_count
    from {{ ref('int_asset_sensor_anomalies') }}
),

utilization as (
    select
        asset_id,
        cycle_date                  as performance_date,
        total_cycles_active,
        total_runtime_minutes,
        total_runtime_hours,
        avg_load_pct,
        peak_load_pct,
        daily_utilization_rate,
        has_cycle_overlap
    from {{ ref('int_asset_utilization') }}
)

select
    coalesce(a.asset_id, u.asset_id)                                        as asset_id,
    coalesce(a.performance_date, u.performance_date)                        as performance_date,
    cast(
        format_date('%Y%m%d', coalesce(a.performance_date, u.performance_date))
    as int64)                                                               as date_id,

    -- Sensor anomaly metrics (null when no sensor readings recorded on this date)
    a.total_readings,
    a.anomaly_count,
    a.anomaly_rate,
    a.high_temp_count,
    a.high_vibration_count,
    a.high_pressure_count,

    -- Utilisation metrics (null when no usage cycles recorded on this date)
    u.total_cycles_active,
    u.total_runtime_minutes,
    u.total_runtime_hours,
    u.avg_load_pct,
    u.peak_load_pct,
    u.daily_utilization_rate,
    u.has_cycle_overlap

from anomalies a
full outer join utilization u
    on  a.asset_id         = u.asset_id
    and a.performance_date = u.performance_date
