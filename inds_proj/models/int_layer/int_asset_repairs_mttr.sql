
with repairs as (
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
    select r.asset_id, d.day
    from (select distinct asset_id from repairs) r
    cross join dates d
),
repairs_per_day as (
    select
        ad.asset_id,
        ad.day,
        count(r.failure_date) as repair_count
    from asset_days ad
    left join repairs r on ad.asset_id = r.asset_id and r.failure_date = ad.day
    group by ad.asset_id, ad.day
)
select * from repairs_per_day;
