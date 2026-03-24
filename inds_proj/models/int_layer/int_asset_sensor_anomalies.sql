
with sensor_readings as (
    select
        asset_id,
        timestamp,
        temperature_c,
        vibration_mm_s,
        pressure_bar,
        -- Anomaly flags based on static operational thresholds
        -- Temperature: > 90°C exceeds safe operating limit for heavy machinery
        -- Vibration: > 4.5 mm/s exceeds ISO 10816 severity zone C threshold
        -- Pressure: > 10 bar indicates potential overpressure condition
        case
            when temperature_c  > 90   then 1
            when vibration_mm_s > 4.5  then 1
            when pressure_bar   > 10   then 1
            else 0
        end as is_anomaly,

        case when temperature_c  > 90   then 1 else 0 end as is_high_temp,
        case when vibration_mm_s > 4.5  then 1 else 0 end as is_high_vibration,
        case when pressure_bar   > 10   then 1 else 0 end as is_high_pressure
    from {{ ref('stg_sensor_telemetry') }}
    where timestamp is not null
),

anomaly_summary as (
    -- Roll up to asset level: total readings, anomaly count, and anomaly rate per sensor dimension
    select
        asset_id,
        count(*)                                        as total_readings,
        sum(is_anomaly)                                 as anomaly_count,
        safe_divide(sum(is_anomaly), count(*))          as anomaly_rate,
        sum(is_high_temp)                               as high_temp_count,
        sum(is_high_vibration)                          as high_vibration_count,
        sum(is_high_pressure)                           as high_pressure_count
    from sensor_readings
    group by asset_id
)

select * from anomaly_summary
