{{
config(
    materialized='table',
    schema='marts',
    tags=['montagneux', 'marts', 'mont_enriched']
)
}}
SELECT mont.*, 
        d.nom AS departement, d.code AS code_departement, 
        r.nom AS region, r.code AS code_region
FROM {{ ref('clean_meteo_montagneux') }} AS mont
INNER JOIN {{ ref('clean_geo_departements') }} AS d ON public.st_contains(d.geom, mont.geom)
INNER JOIN {{ ref('clean_geo_regions') }} AS r ON public.st_contains(r.geom, mont.geom)