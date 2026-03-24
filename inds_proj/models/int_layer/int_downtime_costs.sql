
with events as (
    -- Pull completed work orders with labour cost and downtime from the events backbone
    select
        workorder_id,
        asset_id,
        maintenance_type,
        open_date,
        completion_date,
        downtime_hours,
        maintenance_cost_eur
    from {{ ref('int_maintenance_events') }}
    where is_completed = true
),

spare_parts as (
    -- Aggregate spare parts to work order level before joining
    -- Parts table has no direct asset_id; workorder_id is the link
    select
        workorder_id,
        sum(cost_eur)       as spare_parts_cost_eur,
        sum(quantity)       as total_parts_consumed
    from {{ ref('stg_spare_parts_usage') }}
    group by workorder_id
)

-- One row per completed work order
-- open_date and completion_date allow time-based slicing in the mart
-- Mart joins to dim_asset for manufacturer / equipment_type drill-down
select
    e.workorder_id,
    e.asset_id,
    e.maintenance_type,
    e.open_date,
    e.completion_date,
    e.downtime_hours,
    e.maintenance_cost_eur,
    coalesce(sp.spare_parts_cost_eur, 0)                                    as spare_parts_cost_eur,
    coalesce(sp.total_parts_consumed, 0)                                    as total_parts_consumed,
    e.maintenance_cost_eur + coalesce(sp.spare_parts_cost_eur, 0)          as total_cost_eur
from events e
left join spare_parts sp using (workorder_id)
