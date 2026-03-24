
with maintenance_costs as (
    -- Pull completed events with cost and downtime from the enriched events model
    select
        asset_id,
        workorder_id,
        maintenance_type,
        completion_date,
        downtime_hours,
        maintenance_cost_eur
    from {{ ref('int_maintenance_events') }}
    where is_completed = true
),

spare_parts_costs as (
    -- Aggregate spare parts cost to work order level, then roll up to asset
    -- workorder_id links parts to assets without needing a direct asset_id join
    select
        wo.asset_id,
        sum(sp.cost_eur)            as spare_parts_cost_eur,
        sum(sp.quantity)            as total_parts_consumed
    from {{ ref('stg_spare_parts_usage') }} sp
    inner join {{ ref('stg_work_orders') }} wo
        on sp.workorder_id = wo.workorder_id
    group by wo.asset_id
),

cost_summary as (
    select
        asset_id,
        count(*)                                                                        as total_completed_events,
        sum(downtime_hours)                                                             as total_downtime_hours,
        sum(maintenance_cost_eur)                                                       as total_maintenance_cost_eur,
        avg(maintenance_cost_eur)                                                       as avg_cost_per_event,
        sum(case when maintenance_type = 'Corrective'  then maintenance_cost_eur end)  as corrective_cost_eur,
        sum(case when maintenance_type = 'Preventive'  then maintenance_cost_eur end)  as preventive_cost_eur,
        sum(case when maintenance_type = 'Corrective'  then downtime_hours end)        as corrective_downtime_hours,
        sum(case when maintenance_type = 'Preventive'  then downtime_hours end)        as preventive_downtime_hours
    from maintenance_costs
    group by asset_id
)

select
    cs.asset_id,
    cs.total_completed_events,
    cs.total_downtime_hours,
    cs.total_maintenance_cost_eur,
    cs.avg_cost_per_event,
    cs.corrective_cost_eur,
    cs.preventive_cost_eur,
    cs.corrective_downtime_hours,
    cs.preventive_downtime_hours,
    coalesce(sp.spare_parts_cost_eur, 0)                                    as spare_parts_cost_eur,
    coalesce(sp.total_parts_consumed, 0)                                    as total_parts_consumed,
    cs.total_maintenance_cost_eur + coalesce(sp.spare_parts_cost_eur, 0)   as total_cost_eur
from cost_summary cs
left join spare_parts_costs sp using (asset_id)
