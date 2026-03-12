{{ config(materialized='view') }}

with equip_spec_raw as (
    select * from {{ source('inds_raw', 'equipment_specs') }}
),

equip_spec_stg as (
    select
        spec_id,
        equipment_type,
        manufacturer,
        rated_capacity_tons,
        expected_lifecycle_years
    from equip_spec_raw
)

select * from equip_spec_stg