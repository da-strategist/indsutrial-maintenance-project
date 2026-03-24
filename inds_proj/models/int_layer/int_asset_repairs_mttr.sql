
with repair_events as (
    -- One row per completed corrective repair event
    -- downtime_hours is the authoritative repair duration field
    -- Mart aggregates avg(downtime_hours) for any date range to compute MTTR
    select
        ml.asset_id,
        ml.workorder_id,
        ml.maintenance_id,
        ml.completion_date,
        ml.downtime_hours,
        ml.maintenance_cost_eur,
        wo.priority
    from {{ ref('stg_maintenance_logs') }} ml
    inner join {{ ref('stg_work_orders') }} wo
        on ml.workorder_id = wo.workorder_id
    where wo.maintenance_type = 'Corrective'
        and ml.downtime_hours is not null
)

select * from repair_events
