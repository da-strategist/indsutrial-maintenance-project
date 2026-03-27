
with corrective_failures as (
    -- Each corrective work order represents a failure event
    select
        asset_id,
        open_date as failure_date,
        row_number() over (partition by asset_id order by open_date) as failure_seq
    from {{ ref('stg_work_orders') }}
    where maintenance_type = 'Corrective'
        and open_date is not null
),

asset_install as (
    -- Installation date anchors the first failure interval
    select
        asset_id,
        installation_date
    from {{ ref('stg_asset_master') }}
    where installation_date is not null
),

failure_intervals as (
    -- One row per failure event per asset
    -- prev_event_date = installation date for the first failure, previous failure date otherwise
    -- Mart aggregates avg(days_since_prev_event) for any date range to compute MTBF
    select
        f.asset_id,
        f.failure_date,
        f.failure_seq,
        coalesce(
            lag(f.failure_date) over (partition by f.asset_id order by f.failure_date),
            a.installation_date
        ) as prev_event_date,
        date_diff(
            f.failure_date,
            coalesce(
                lag(f.failure_date) over (partition by f.asset_id order by f.failure_date),
                a.installation_date
            ),
            day
        ) as days_since_prev_event
    from corrective_failures f
    left join asset_install a using (asset_id)
)

select *

from failure_intervals
where days_since_prev_event is not null
