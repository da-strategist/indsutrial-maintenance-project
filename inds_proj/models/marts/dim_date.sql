{{ config(materialized='table') }}

-- Dimension table: one row per calendar date (2015-01-01 → 2030-12-31)
-- Join to fact tables via date_id (YYYYMMDD integer) or full_date (DATE)
-- Provides day / week / month / quarter / year drill hierarchy for Power BI time intelligence
select * from {{ ref('int_dim_date') }}
