{{ config(materialized='table') }}

-- Fact table: one row per spare part consumed per work order
-- Grain: work order + part (most atomic; aggregates up to asset / period / part category)
--
-- Key derivable metrics in Power BI:
--   Parts burn rate   → SUM(quantity) over any part / asset / period slice
--   Parts cost        → SUM(cost_eur) by part_id, equipment_type, manufacturer, region
--   Cost per event    → SUM(cost_eur) grouped by workorder_id
--   Corrective vs PM  → filter on maintenance_type
--
-- date_id joins to dim_date.date_id; asset_id joins to dim_asset.asset_id

select
    workorder_id,
    part_id,
    asset_id,
    open_date                                                       as consumption_date,
    cast(format_date('%Y%m%d', open_date) as int64)                as date_id,
    maintenance_type,
    quantity,
    cost_eur

from {{ ref('int_spare_parts_utilization') }}
