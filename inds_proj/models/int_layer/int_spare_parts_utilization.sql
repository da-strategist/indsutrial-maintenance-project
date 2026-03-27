
with parts_usage as (
    -- Link spare parts to assets and dates via work orders
    -- stg_spare_parts_usage has no asset_id; resolved through workorder_id
    -- open_date added to enable time-based slicing in the mart
    select
        sp.workorder_id,
        sp.part_id,
        sp.quantity,
        sp.cost_eur,
        wo.asset_id,
        wo.open_date,
        wo.maintenance_type
    from {{ ref('stg_spare_parts_usage') }} sp
    inner join {{ ref('stg_work_orders') }} wo
        on sp.workorder_id = wo.workorder_id
)

-- One row per work order + part combination
-- Mart aggregates by period, part, manufacturer, or region via dim_asset join
select * from parts_usage
