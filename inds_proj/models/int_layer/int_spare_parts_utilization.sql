
with parts_usage as (
    -- Link spare parts to assets via work orders (parts table has no direct asset_id)
    select
        wo.asset_id,
        sp.part_id,
        sp.workorder_id,
        sp.quantity,
        sp.cost_eur
    from {{ ref('stg_spare_parts_usage') }} sp
    inner join {{ ref('stg_work_orders') }} wo
        on sp.workorder_id = wo.workorder_id
),

parts_by_asset_and_part as (
    -- Grain: one row per asset + part combination
    -- Captures which parts are consumed most frequently per asset
    select
        asset_id,
        part_id,
        count(distinct workorder_id)    as work_orders_using_part,
        sum(quantity)                   as total_quantity_used,
        sum(cost_eur)                   as total_parts_cost_eur,
        avg(cost_eur)                   as avg_cost_per_use
    from parts_usage
    group by asset_id, part_id
)

select * from parts_by_asset_and_part
