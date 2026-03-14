with source as (
    select * from {{ source('inds_raw', 'maintenance_logs') }}
),

renamed as (
    select
        maintenance_id,
        workorder_id,
        asset_id,
        cast(completion_date as date) as completion_date,
        downtime_hours,
        maintenance_cost_eur
    from source
)

select * from renamed
