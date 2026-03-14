{{ config(materialized='view') }}

with usage_raw as (
    select * from {{ source('inds_raw', 'usage_cycles') }}
),

usage_stg as (
    select
        cycle_id,
        asset_id,
        cast(cycle_start as timestamp) as cycle_start,
        duration_minutes,
        load_percentage
    from usage_raw
)

select * from usage_stg
