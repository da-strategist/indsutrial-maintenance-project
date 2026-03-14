
with failures as (
    select
        asset_id,
        completion_date as failure_date
    from {{ ref('stg_maintenance_logs') }}
    where completion_date is not null
),
dates as (
    select distinct completion_date as day
    from {{ ref('stg_maintenance_logs') }}
    where completion_date is not null
),
asset_days as (
    select f.asset_id, d.day
    from (select distinct asset_id from failures) f
    cross join dates d
),
failures_per_day as (
    select
        ad.asset_id,
        ad.day,
        count(f.failure_date) as failure_count
    from asset_days ad
    left join failures f on ad.asset_id = f.asset_id and f.failure_date = ad.day
    group by ad.asset_id, ad.day
),
mtbf as (
    select
        asset_id,
        day,
        failure_count,
        lag(day) over (partition by asset_id order by day) as prev_failure_day,
        case when failure_count > 0 then date_diff(day, lag(day) over (partition by asset_id order by day), day) end as mtbf_days
    from failures_per_day
)
select * from mtbf;
