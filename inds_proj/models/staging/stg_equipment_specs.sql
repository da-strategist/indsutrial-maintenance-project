with source as (
    select * from {{ source('inds_raw', 'equipment_specs') }}
),

renamed as (
    select
        spec_id,
        equipment_type,
        manufacturer,
        rated_capacity_tons,
        expected_lifecycle_years
    from source
)

select * from renamed
