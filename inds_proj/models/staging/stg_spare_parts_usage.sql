with source as (
    select * from {{ source('inds_raw', 'spare_parts_usage') }}
),

renamed as (
    select
        usage_id,
        workorder_id,
        part_id,
        quantity,
        cost_eur
    from source
)

select * from renamed
