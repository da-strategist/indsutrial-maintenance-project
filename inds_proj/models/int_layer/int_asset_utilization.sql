
with usage as (
    select
        asset_id,
        date(cycle_start)   as cycle_date,
        duration_minutes,
        load_percentage
    from {{ ref('stg_usage_cycles') }}
    where cycle_start is not null
),

daily_usage as (
    -- One row per asset per date
    -- daily_utilization_rate = runtime as a proportion of 1,440 minutes (24h)
    -- Assumes 24/7 availability; adjust denominator if shift schedules are defined
    -- Mart aggregates by week/month/manufacturer via dim_asset join
    select
        asset_id,
        cycle_date,
        count(*)                                        as total_cycles,
        sum(duration_minutes)                           as total_runtime_minutes,
        round(sum(duration_minutes) / 60.0, 2)         as total_runtime_hours,
        avg(load_percentage)                            as avg_load_pct,
        max(load_percentage)                            as peak_load_pct,
        safe_divide(sum(duration_minutes), 1440)        as daily_utilization_rate
    from usage
    group by asset_id, cycle_date
)

select * from daily_usage
