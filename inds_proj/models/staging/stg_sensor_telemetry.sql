{{ config(materialized='view') }}

with sensor_raw as (
    select * from {{ source('inds_raw', 'sensor_telemetry') }}
),

sensor_stg as (
    select
        telemetry_id,
        asset_id,
        cast(timestamp as timestamp) as timestamp,
        temperature_c,
        vibration_mm_s,
        pressure_bar
    from sensor_raw
)

select * from sensor_stg
