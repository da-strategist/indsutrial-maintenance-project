

with test_ext_cte as 
    (
        SELECT * from {{ref ('stg_sensor_telemetry')}}
), sensor AS

(
    SELECT * from test_ext_cte
), asset as
    (
        select * from {{ref('stg_asset_master')}}
    ), asset_status as

    (
        select distinct status from {{ref('stg_asset_master')}}
    ),
    
    equip as 
    (
       select * from {{ref('stg_equipment_specs')}} 
    ), asset_maint as
        (
            select * from {{ref('maintenance_logs')}} 
            order by asset_id asc, completion_date asc
        ), work_order as
        (
            select * from {{ref('stg_work_orders')}} 
        ), maint_type as
        (
            select distinct maintenance_type from work_order
        ), sparepart as 
        (
            select * from {{ref('stg_spare_parts_usage')}}
        ), usage as 
        (
            select * from {{ref('usage_cycles')}}
        )

select * from sensor
       