with source as (
    select * from {{ source('inds_raw', 'usage_cycles') }}
),

renamed as (
    select
        cycle_id,
        asset_id,
        cast(cycle_start as timestamp) as cycle_start,
        duration_minutes,
        load_percentage
    from source
)

select * from renamed
