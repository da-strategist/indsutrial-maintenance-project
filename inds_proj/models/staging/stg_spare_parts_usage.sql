{{ config(materialized='view') }}

with spare_part_raw as (
    select * from {{ source('inds_raw', 'spare_parts_usage') }}
),

spare_part as (
    select
        usage_id,
        workorder_id,
        part_id,
        quantity,
        cost_eur
    from spare_part_raw
)

select * from spare_part
