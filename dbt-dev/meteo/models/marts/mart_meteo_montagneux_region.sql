{{ config(
    materialized='view',
    schema='marts',
    tags=['montagneux', 'marts', 'mont_region']
) }}

SELECT
    f.id,
    f.station_name,
    f.latitude,
    f.longitude,
    f.altitude,
    f.measure_datetime,

    EXTRACT(YEAR FROM f.measure_datetime)::int AS annee,
    EXTRACT(MONTH FROM f.measure_datetime)::int AS mois,

    f.temperature_celsius,
    f.temperature_min_24h_celsius,
    f.temperature_max_24h_celsius,

    f.precipitations_24h_mm,

    f.humidity_percent,
    f.vitesse_vent_moyen_10min_m_s,

    f.hauteur_total_neige_m,
    f.hauteur_neige_fraiche_m,

    f.temperature_neige_celsius,

    f.risque_avalanches,
    f.presence_avalanche,

    d.code_departement,
    d.nom_departement,

    d.code_region,
    d.nom_region

FROM {{ ref('fact_meteo_montagneux_enriched') }} f
INNER JOIN {{ ref('dim_regions_deps') }} d
    ON ST_Contains(d.geometry_deps, f.geom)