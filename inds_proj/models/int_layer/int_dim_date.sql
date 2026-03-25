
with date_spine as (
    -- Generate one row per calendar date across the full operational window
    -- Range starts before earliest expected installation date and extends beyond project horizon
    select date_val as full_date
    from unnest(
        generate_date_array('2015-01-01', '2030-12-31')
    ) as date_val
),

date_attributes as (
    select
        -- Surrogate key as integer (YYYYMMDD) for efficient joining in fact tables
        cast(format_date('%Y%m%d', full_date) as int64)             as date_id,
        full_date,

        -- Day-level attributes
        extract(day from full_date)                                 as day_of_month,
        extract(dayofyear from full_date)                           as day_of_year,
        extract(dayofweek from full_date)                           as day_of_week_num,   -- 1=Sun, 7=Sat (BigQuery)
        format_date('%A', full_date)                                as day_name,
        format_date('%a', full_date)                                as day_name_short,

        -- Week-level attributes
        extract(isoweek from full_date)                             as week_of_year,
        extract(isoyear from full_date)                             as iso_year,

        -- Month-level attributes
        extract(month from full_date)                               as month_number,
        format_date('%B', full_date)                                as month_name,
        format_date('%b', full_date)                                as month_name_short,
        format_date('%Y-%m', full_date)                             as year_month,

        -- Quarter-level attributes
        extract(quarter from full_date)                             as quarter_number,
        concat('Q', extract(quarter from full_date))                as quarter_name,
        concat(
            cast(extract(year from full_date) as string),
            '-Q',
            cast(extract(quarter from full_date) as string)
        )                                                           as year_quarter,

        -- Year
        extract(year from full_date)                                as year,

        -- Flags
        case
            when extract(dayofweek from full_date) in (1, 7)
            then true else false
        end                                                         as is_weekend,
        case
            when extract(dayofweek from full_date) in (1, 7)
            then false else true
        end                                                         as is_weekday
    from date_spine
)

select * from date_attributes
