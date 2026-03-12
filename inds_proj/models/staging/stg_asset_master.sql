{{ config(materialized='view') }}

with asset_raw as (
    select * from {{ source('inds_raw', 'asset_master') }}
),

asset_stg as (
    select
        asset_id,
        spec_id,
        location_region,
        cast(installation_date as date) as installation_date,
        status
    from asset_raw
)

select * from asset_stg
