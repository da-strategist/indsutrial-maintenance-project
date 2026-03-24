
with assets as (
    select
        asset_id,
        status,
        location_region,
        installation_date
    from {{ ref('stg_asset_master') }}
),

mtbf_agg as (
    -- Aggregate event-grain MTBF model to asset level for the health snapshot
    select
        asset_id,
        count(*)                    as total_failures,
        avg(days_since_prev_event)  as mtbf_days,
        min(failure_date)           as first_failure_date,
        max(failure_date)           as last_failure_date
    from {{ ref('int_asset_failures_mtbf') }}
    group by asset_id
),

mttr_agg as (
    -- Aggregate event-grain MTTR model to asset level
    select
        asset_id,
        avg(downtime_hours)         as mttr_hours,
        sum(downtime_hours)         as total_downtime_hours,
        count(*)                    as total_repairs
    from {{ ref('int_asset_repairs_mttr') }}
    group by asset_id
),

downtime_agg as (
    -- Aggregate event-grain unplanned downtime model to asset level
    select
        asset_id,
        count(*)                                        as total_unplanned_events,
        count(case when priority = 'High' then 1 end)  as high_priority_events
    from {{ ref('int_asset_unplanned_downtime') }}
    group by asset_id
),

anomaly_agg as (
    -- Aggregate daily anomaly model to asset level
    select
        asset_id,
        sum(total_readings)                             as total_readings,
        sum(anomaly_count)                              as anomaly_count,
        safe_divide(sum(anomaly_count), sum(total_readings)) as anomaly_rate
    from {{ ref('int_asset_sensor_anomalies') }}
    group by asset_id
),

enriched as (
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
    left join mtbf_agg    m  using (asset_id)
    left join mttr_agg    r  using (asset_id)
    left join downtime_agg d using (asset_id)
    left join anomaly_agg  an using (asset_id)
),

health_scored as (
    -- Health classification based on three independent failure signals
    -- Thresholds are operational heuristics; revisit as benchmark data accumulates:
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
