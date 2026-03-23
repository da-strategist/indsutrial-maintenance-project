
with corrective_failures as (
    -- Filter to corrective work orders only; open_date marks when the asset was taken out of service
    select
        asset_id,
        open_date as failure_date
    from {{ ref('stg_work_orders') }}
    where maintenance_type = 'Corrective'
        and open_date is not null
),

asset_start as (
    -- Use installation date as time-zero anchor for computing the first failure interval
    select
        asset_id,
        installation_date as failure_date
    from {{ ref('stg_asset_master') }}
    where installation_date is not null
),

failure_timeline as (
    -- Combine installation date and corrective failures into a single ordered timeline per asset
    select asset_id, failure_date, 'installation'        as event_type from asset_start
    union all
    select asset_id, failure_date, 'corrective_failure'  as event_type from corrective_failures
),

failure_intervals as (
    -- Compute the gap between each corrective failure and the preceding event (lag over failure events only)
    select
        asset_id,
        failure_date,
        event_type,
        lag(failure_date) over (partition by asset_id order by failure_date) as prev_event_date,
        date_diff(
            failure_date,
            lag(failure_date) over (partition by asset_id order by failure_date),
            day
        ) as days_since_prev_event
    from failure_timeline
),

mtbf as (
    -- Aggregate inter-failure intervals per asset to produce the MTBF metric
    select
        asset_id,
        count(*)                      as total_failures,
        avg(days_since_prev_event)    as mtbf_days,
        min(failure_date)             as first_failure_date,
        max(failure_date)             as last_failure_date
    from failure_intervals
    where event_type = 'corrective_failure'
        and days_since_prev_event is not null
    group by asset_id
)

select * from mtbf
