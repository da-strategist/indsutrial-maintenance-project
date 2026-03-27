{{ config(materialized='table') }}

-- Dimension table: one row per asset
-- Denormalised asset master + equipment specs join from the int layer
-- Join anchor for all fact tables via asset_id
select * from {{ ref('int_dim_asset') }}
