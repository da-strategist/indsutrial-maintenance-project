
with unplanned as (
    select
        asset_id,
        open_date as downtime_date
    from {{ ref('stg_work_orders') }}
    where lower(maintenance_type) = 'unplanned'
),
dates as (
    select distinct open_date as day
    from {{ ref('stg_work_orders') }}
    where open_date is not null
),
asset_days as (
    select u.asset_id, d.day
    from (select distinct asset_id from unplanned) u
    cross join dates d
),
downtime_per_day as (
    select
        ad.asset_id,
        ad.day,
        count(u.downtime_date) as unplanned_downtime_count
    from asset_days ad
    left join unplanned u on ad.asset_id = u.asset_id and u.downtime_date = ad.day
    group by ad.asset_id, ad.day
)
select * from downtime_per_day;
