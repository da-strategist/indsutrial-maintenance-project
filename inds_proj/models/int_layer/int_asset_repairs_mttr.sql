
with repair_events as (
    -- Join maintenance logs to work orders to isolate corrective (unplanned) repairs
    -- downtime_hours is the authoritative source for repair duration
    select
        ml.asset_id,
        ml.workorder_id,
        ml.completion_date,
        ml.downtime_hours,
        ml.maintenance_cost_eur,
        wo.maintenance_type,
        wo.priority
    from {{ ref('stg_maintenance_logs') }} ml
    inner join {{ ref('stg_work_orders') }} wo
        on ml.workorder_id = wo.workorder_id
    where wo.maintenance_type = 'Corrective'
        and ml.downtime_hours is not null
),

mttr as (
    -- MTTR = average hours taken to restore an asset after a corrective failure
    select
        asset_id,
        count(*)                    as total_repairs,
        avg(downtime_hours)         as mttr_hours,
        sum(downtime_hours)         as total_downtime_hours,
        min(completion_date)        as first_repair_date,
        max(completion_date)        as last_repair_date
    from repair_events
    group by asset_id
)

select * from mttr
