{{ config(materialized='view') }}

with log_raw as (
    select * from {{ source('inds_raw', 'maintenance_logs') }}
),

log_stg as (
    select
        maintenance_id,
        workorder_id,
        asset_id,
        cast(completion_date as date) as completion_date,
        downtime_hours,
        maintenance_cost_eur
    from log_raw
)

select * from log_stg
