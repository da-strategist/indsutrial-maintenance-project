
with cycles as (
    -- Derive cycle_end from the timestamp and duration
    -- This is the key to correctly attributing runtime across calendar days
    select
        asset_id,
        cycle_start,
        duration_minutes,
        load_percentage,
        timestamp_add(
            cycle_start,
            interval cast(duration_minutes as int64) minute
        ) as cycle_end
    from {{ ref('stg_usage_cycles') }}
    where cycle_start    is not null
        and duration_minutes is not null
),

cycle_days as (
    -- Expand each cycle into one row per calendar day it spans
    -- A cycle running from Mon 22:00 for 600 minutes spans Mon and Tue
    select
        c.asset_id,
        c.cycle_start,
        c.cycle_end,
        c.load_percentage,
        day_date
    from cycles c
    cross join unnest(
        generate_date_array(date(c.cycle_start), date(c.cycle_end))
    ) as day_date
),

daily_runtime as (
    -- For each cycle-day row, compute only the minutes that fall within that calendar day
    -- Day window: midnight of day_date → midnight of day_date + 1
    -- Overlap = least(cycle_end, day_end) - greatest(cycle_start, day_start)
    select
        asset_id,
        day_date,
        load_percentage,
        timestamp_diff(
            least(cycle_end,   timestamp_add(timestamp(day_date), interval 1440 minute)),
            greatest(cycle_start, timestamp(day_date)),
            minute
        ) as runtime_minutes_on_day
    from cycle_days
    --order by asset_id, day_date asc, runtime_minutes_on_day desc
),

daily_usage as (
    -- One row per asset per calendar date
    -- daily_utilization_rate > 1.0 at this stage indicates genuinely overlapping cycles
    -- for the same asset on the same day (a data quality issue, not a logic error)
    select
        asset_id,
        day_date                                                    as cycle_date,
        count(*)                                                    as total_cycles_active,
        sum(runtime_minutes_on_day)                                 as total_runtime_minutes,
        round(sum(runtime_minutes_on_day) / 60.0, 2)               as total_runtime_hours,
        round(avg(load_percentage), 2)                              as avg_load_pct,
        max(load_percentage)                                        as peak_load_pct,
        round(safe_divide(sum(runtime_minutes_on_day), 1440), 2)   as daily_utilization_rate
    from daily_runtime
    group by asset_id, day_date
)

select * from daily_usage
