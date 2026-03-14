{{ config(materialized='view') }}

with work_order_raw as (
    select * from {{ source('inds_raw', 'work_orders') }}
),

work_order as (
    select
        workorder_id,
        asset_id,
        cast(open_date as date) as open_date,
        maintenance_type,
        priority
    from work_order_raw
)

select * from work_order
