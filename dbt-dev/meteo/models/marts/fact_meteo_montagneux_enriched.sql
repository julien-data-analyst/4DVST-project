{{
config(
    materialized='table',
    schema='marts',
    tags=['montagneux', 'marts', 'mont_enriched']
)
}}
SELECT *, 
       CASE description_avalanches WHEN 'RAS' THEN TRUE ELSE FALSE END AS presence_avalanche

FROM {{ ref('clean_meteo_montagneux') }}
