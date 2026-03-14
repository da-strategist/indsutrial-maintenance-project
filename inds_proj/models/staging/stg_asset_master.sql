with source as (
    select * from {{ source('inds_raw', 'asset_master') }}
),

renamed as (
    select
        asset_id,
        spec_id,
        location_region,
        cast(installation_date as date) as installation_date,
        status
    from source
)

select * from renamed
