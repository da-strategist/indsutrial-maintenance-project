{{ config(materialized='view') }}

with env_raw as (
    select * from {{ source('inds_raw', 'environmental_conditions') }}
),

env_cond_stg as (
    select
        env_id,
        asset_id,
        cast(timestamp as timestamp) as timestamp,
        ambient_temp_c,
        humidity_pct,
        dust_index
    from env_raw
)

select * from env_cond_stg
