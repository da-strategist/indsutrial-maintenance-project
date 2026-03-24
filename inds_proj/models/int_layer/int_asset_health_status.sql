
with assets as (
    select
        asset_id,
        status,
        location_region,
        installation_date
    from {{ ref('stg_asset_master') }}
),

mtbf as (
    select
        asset_id,
        total_failures,
        mtbf_days,
        first_failure_date,
        last_failure_date
    from {{ ref('int_asset_failures_mtbf') }}
),

mttr as (
    select
        asset_id,
        mttr_hours,
        total_repairs,
        total_downtime_hours
    from {{ ref('int_asset_repairs_mttr') }}
),

downtime as (
    select
        asset_id,
        total_unplanned_events,
        high_priority_events
    from {{ ref('int_asset_unplanned_downtime') }}
),

anomalies as (
    select
        asset_id,
        anomaly_rate,
        anomaly_count,
        total_readings
    from {{ ref('int_asset_sensor_anomalies') }}
),

enriched as (
    -- Combine all reliability signals onto each asset
    -- coalesce to 0 for assets with no failures or sensor data yet
    select
        a.asset_id,
        a.status                                        as operational_status,
        a.location_region,
        a.installation_date,
        coalesce(m.total_failures, 0)                   as total_failures,
        m.mtbf_days,
        r.mttr_hours,
        coalesce(r.total_downtime_hours, 0)             as total_downtime_hours,
        coalesce(d.total_unplanned_events, 0)           as total_unplanned_events,
        coalesce(d.high_priority_events, 0)             as high_priority_events,
        coalesce(an.anomaly_rate, 0)                    as anomaly_rate,
        coalesce(an.anomaly_count, 0)                   as anomaly_count
    from assets a
    left join mtbf     m  using (asset_id)
    left join mttr     r  using (asset_id)
    left join downtime d  using (asset_id)
    left join anomalies an using (asset_id)
),

health_scored as (
    -- Health classification based on three independent failure signals
    -- Thresholds are based on operational risk heuristics and should be revisited
    -- as benchmark data accumulates:
    --   Critical : >= 5 failures  OR  avg repair >= 24h  OR  anomaly rate >= 10%
    --   At Risk  : >= 2 failures  OR  avg repair >= 8h   OR  anomaly rate >= 5%
    --   Healthy  : all signals below At Risk thresholds
    select
        *,
        case
            when total_failures >= 5
              or mttr_hours      >= 24
              or anomaly_rate    >= 0.10  then 'Critical'
            when total_failures >= 2
              or mttr_hours      >= 8
              or anomaly_rate    >= 0.05  then 'At Risk'
            else 'Healthy'
        end as health_status
    from enriched
)

select * from health_scored
