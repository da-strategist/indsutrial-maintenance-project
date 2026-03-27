
with work_orders as (
    select
        workorder_id,
        asset_id,
        open_date,
        maintenance_type,
        priority
    from {{ ref('stg_work_orders') }}
),

maintenance_logs as (
    select
        maintenance_id,
        workorder_id,
        completion_date,
        downtime_hours,
        maintenance_cost_eur
    from {{ ref('stg_maintenance_logs') }}
),

events as (
    -- One row per work order, enriched with repair outcome from maintenance logs
    -- Work orders without a log entry are open/pending (completion_date will be null)
    select
        wo.workorder_id,
        wo.asset_id,
        wo.open_date,
        wo.maintenance_type,
        wo.priority,
        ml.maintenance_id,
        ml.completion_date,
        ml.downtime_hours,
        ml.maintenance_cost_eur,
        case when ml.completion_date is not null then true else false end   as is_completed,
        date_diff(ml.completion_date, wo.open_date, day)                   as days_to_close
    from work_orders wo
    left join maintenance_logs ml
        on wo.workorder_id = ml.workorder_id
)

select * from events
