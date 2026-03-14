with source as (
    select * from {{ source('inds_raw', 'sensor_telemetry') }}
),

renamed as (
    select
        telemetry_id,
        asset_id,
        cast(timestamp as timestamp) as recorded_at,
        temperature_c,
        vibration_mm_s,
        pressure_bar
    from source
)

select * from renamed
