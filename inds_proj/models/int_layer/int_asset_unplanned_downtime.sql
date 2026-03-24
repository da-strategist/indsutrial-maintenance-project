
with corrective_events as (
    -- Corrective maintenance = reactive/unplanned work triggered by asset failure
    -- 'Corrective' is the maintenance_type value used in stg_work_orders
    select
        asset_id,
        workorder_id,
        open_date       as event_date,
        priority
    from {{ ref('stg_work_orders') }}
    where maintenance_type = 'Corrective'
        and open_date is not null
),

unplanned_summary as (
    -- Summarise unplanned downtime events per asset
    select
        asset_id,
        count(*)                                            as total_unplanned_events,
        count(case when priority = 'High' then 1 end)      as high_priority_events,
        min(event_date)                                     as first_unplanned_date,
        max(event_date)                                     as last_unplanned_date
    from corrective_events
    group by asset_id
)

select * from unplanned_summary
