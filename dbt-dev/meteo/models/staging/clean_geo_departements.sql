{{ config(
    materialized='table',
    schema='processing',
    tags=['regions-deps', 'montagneux']
) }}

SELECT

    code,
    nom,
    -- géométrie (gère POLYGON + MULTIPOLYGON)
    CASE
        WHEN geometry IS NOT NULL
             AND geometry != ''
        THEN ST_Multi(
                public.ST_GeomFromText(CAST(geometry AS TEXT), 4326)
             )
        ELSE NULL
    END AS geom

FROM {{ source('weather_climatic_data', 'departements') }}