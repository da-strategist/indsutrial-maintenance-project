
with anomalies as (
    select
        asset_id,
        timestamp as reading_timestamp
        -- Add anomaly detection logic here if available
    from {{ ref('stg_sensor_telemetry') }}
),
dates as (
    select distinct date(timestamp) as day
    from {{ ref('stg_sensor_telemetry') }}
    where timestamp is not null
),
asset_days as (
    select a.asset_id, d.day
    from (select distinct asset_id from anomalies) a
    cross join dates d
),
anomaly_agg as (
    select
        ad.asset_id,
        ad.day,
        count(a.reading_timestamp) as total_readings
        -- Add anomaly count and rate if anomaly logic is available
    from asset_days ad
    left join anomalies a on ad.asset_id = a.asset_id and date(a.reading_timestamp) = ad.day
    group by ad.asset_id, ad.day
)
select * from anomaly_agg;
