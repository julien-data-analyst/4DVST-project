{{
config(
    materialized='table',
    schema='marts',
    tags=['montagneux', 'marts', 'mont_enriched', 'regions-deps']
)
}}
SELECT deps.code AS code_departement, deps.nom AS nom_departement, r.code AS code_region, r.nom AS nom_region, 
       deps.geom AS geometry_deps, r.geom AS geometry_region
FROM {{ ref('clean_geo_departements') }} AS deps
LEFT JOIN {{ ref('clean_geo_regions') }} AS r ON public.st_contains(r.geom, deps.geom)
