
with usage as (
    select
        asset_id,
        cycle_start,
        duration_minutes,
        load_percentage
    from {{ ref('stg_usage_cycles') }}
    where cycle_start is not null
),

utilization_summary as (
    -- Aggregate operational usage per asset
    -- Utilization rate = total runtime relative to the observed operating window
    -- Available minutes derived from first to last cycle date (calendar days × 24h)
    -- Note: assumes 24/7 availability; adjust denominator if shift patterns are known
    select
        asset_id,
        count(*)                                                    as total_cycles,
        sum(duration_minutes)                                       as total_runtime_minutes,
        round(sum(duration_minutes) / 60.0, 2)                     as total_runtime_hours,
        avg(load_percentage)                                        as avg_load_pct,
        max(load_percentage)                                        as peak_load_pct,
        min(date(cycle_start))                                      as first_cycle_date,
        max(date(cycle_start))                                      as last_cycle_date,
        date_diff(
            max(date(cycle_start)),
            min(date(cycle_start)),
            day
        ) + 1                                                       as observed_days,
        safe_divide(
            sum(duration_minutes),
            (date_diff(max(date(cycle_start)), min(date(cycle_start)), day) + 1) * 24 * 60
        )                                                           as utilization_rate
    from usage
    group by asset_id
)

select * from utilization_summary
