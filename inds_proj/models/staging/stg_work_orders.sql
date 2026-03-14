with source as (
    select * from {{ source('inds_raw', 'work_orders') }}
),

renamed as (
    select
        workorder_id,
        asset_id,
        cast(open_date as date) as open_date,
        maintenance_type,
        priority
    from source
)

select * from renamed
