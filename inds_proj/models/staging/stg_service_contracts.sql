with source as (
    select * from {{ source('inds_raw', 'service_contracts') }}
),

renamed as (
    select
        contract_id,
        asset_id,
        contract_type,
        cast(contract_start as date) as contract_start,
        cast(contract_end as date) as contract_end,
        annual_value_eur
    from source
)

select * from renamed
