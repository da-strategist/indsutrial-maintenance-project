
with assets as (
    select
        asset_id,
        spec_id,
        location_region,
        installation_date,
        status
    from {{ ref('stg_asset_master') }}
),

specs as (
    select
        spec_id,
        equipment_type,
        manufacturer,
        rated_capacity_tons,
        expected_lifecycle_years
    from {{ ref('stg_equipment_specs') }}
)

-- One row per asset with all descriptive attributes needed for dimensional drilling
-- Feeds directly into dim_asset in the mart layer
-- Enables drill-down by manufacturer, equipment_type, location_region across all fact tables
select
    a.asset_id,
    a.location_region,
    a.installation_date,
    a.status,
    s.equipment_type,
    s.manufacturer,
    s.rated_capacity_tons,
    s.expected_lifecycle_years
from assets a
left join specs s using (spec_id)
