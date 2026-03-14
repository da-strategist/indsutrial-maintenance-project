{{ config(materialized='view') }}

with service_raw as (
    select * from {{ source('inds_raw', 'service_contracts') }}
),

service_stg as (
    select
        contract_id,
        asset_id,
        contract_type,
        cast(contract_start as date) as contract_start,
        cast(contract_end as date) as contract_end,
        annual_value_eur
    from service_raw
)

select * from service_stg