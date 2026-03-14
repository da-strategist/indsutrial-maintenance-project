with source as (
    select * from {{ source('inds_raw', 'environmental_conditions') }}
),

renamed as (
    select
        env_id,
        asset_id,
        cast(timestamp as timestamp) as recorded_at,
        ambient_temp_c,
        humidity_pct,
        dust_index
    from source
)

select * from renamed
