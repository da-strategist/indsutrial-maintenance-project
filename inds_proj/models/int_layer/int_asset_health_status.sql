with asset_status as (
    select
        asset_id,
        installation_date as status_change_date,
        status as asset_status
    from {{ ref('stg_asset_master') }}
),
failures as (
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
    union distinct
    select distinct installation_date as day
    from {{ ref('stg_asset_master') }}
),
asset_days as (
    select a.asset_id, d.day
    from asset_status a
    cross join dates d
),
status_history as (
    select
        ad.asset_id,
        ad.day,
        max(f.failure_date) as last_failure_date,
        a.asset_status,
        case when max(f.failure_date) is not null and max(f.failure_date) >= ad.day then 'At Risk' else a.asset_status end as health_indicator
    from asset_days ad
    left join failures f on ad.asset_id = f.asset_id and f.failure_date <= ad.day
    left join asset_status a on ad.asset_id = a.asset_id
    group by ad.asset_id, ad.day, a.asset_status
)
select * from status_history
