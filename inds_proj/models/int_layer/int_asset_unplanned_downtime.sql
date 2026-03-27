
with corrective_events as (
    -- One row per corrective (unplanned) work order
    -- Corrective maintenance_type = reactive work triggered by asset failure
    -- Mart aggregates count(*) for any date range or dimension to get unplanned downtime counts
    select
        asset_id,
        workorder_id,
        open_date   as event_date,
        priority
    from {{ ref('stg_work_orders') }}
    where maintenance_type = 'Corrective'
        and open_date is not null
)

select * from corrective_events
