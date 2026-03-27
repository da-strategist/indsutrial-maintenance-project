{{ config(materialized='table') }}

-- Fact table: one row per work order (all types, open and completed)
-- Grain: work order
--
-- Key derivable metrics in Power BI:
--   MTBF        → AVERAGE(days_since_prev_event) where maintenance_type = 'Corrective'
--   MTTR        → AVERAGE(downtime_hours) where maintenance_type = 'Corrective' and is_completed = true
--   Completion  → DIVIDE(COUNT is_completed = true, COUNT(*))
--   Downtime    → SUM(downtime_hours) for any asset / period / region slice
--   Total cost  → SUM(total_cost_eur) sliced by type, period, manufacturer, region
--
-- Date keys: open_date_id and completion_date_id both join to dim_date.date_id

with events as (
    select
        workorder_id,
        asset_id,
        open_date,
        maintenance_type,
        priority,
        maintenance_id,
        completion_date,
        downtime_hours,
        maintenance_cost_eur,
        is_completed,
        days_to_close
    from {{ ref('int_maintenance_events') }}
),

costs as (
    -- Completed work orders only; includes spare parts cost aggregated to work order level
    select
        workorder_id,
        spare_parts_cost_eur,
        total_parts_consumed,
        total_cost_eur
    from {{ ref('int_downtime_costs') }}
),

failure_intervals as (
    -- MTBF interval for each corrective failure event
    -- days_since_prev_event is the per-event MTBF input; mart averages it over any slice
    select
        asset_id,
        failure_date,
        failure_seq,
        prev_event_date,
        days_since_prev_event
    from {{ ref('int_asset_failures_mtbf') }}
)

select
    e.workorder_id,
    e.asset_id,

    -- Open date + surrogate key for dim_date join
    e.open_date,
    cast(format_date('%Y%m%d', e.open_date) as int64)              as open_date_id,

    -- Completion date + surrogate key (null for open / pending work orders)
    e.completion_date,
    cast(
        case when e.completion_date is not null
            then format_date('%Y%m%d', e.completion_date)
        end
    as int64)                                                       as completion_date_id,

    e.maintenance_type,
    e.priority,
    e.maintenance_id,
    e.is_completed,
    e.days_to_close,

    -- Downtime: populated for completed corrective repairs only
    e.downtime_hours,

    -- Cost breakdown: labour from maintenance logs, parts from spare_parts_usage
    -- All cost fields are null for open / pending work orders
    e.maintenance_cost_eur,
    coalesce(c.spare_parts_cost_eur, 0)                            as spare_parts_cost_eur,
    coalesce(c.total_parts_consumed, 0)                            as total_parts_consumed,
    coalesce(c.total_cost_eur, e.maintenance_cost_eur)             as total_cost_eur,

    -- MTBF inputs: populated for corrective failures only, null for all other work orders
    -- Power BI measure: AVERAGE(days_since_prev_event) over any filter = MTBF for that slice
    fi.failure_seq,
    fi.prev_event_date,
    fi.days_since_prev_event

from events e
left join costs c
    using (workorder_id)
left join failure_intervals fi
    on  e.asset_id         = fi.asset_id
    and e.open_date        = fi.failure_date
    and e.maintenance_type = 'Corrective'
