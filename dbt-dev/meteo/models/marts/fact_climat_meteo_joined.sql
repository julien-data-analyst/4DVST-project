{{
config(
    materialized='table',
    schema='marts',
    tags=['montagneux', 'marts', 'clim_mont_joined', 'climats']
)
}}

WITH meteo_montagneux_agg AS (
    SELECT
        to_date(to_char(measure_datetime, 'MMYYYY'), 'MMYYYY') AS measure_date_m,
        EXTRACT(YEAR FROM measure_datetime) AS year,
        EXTRACT(MONTH FROM measure_datetime) AS month,
        AVG(temperature_celsius) AS avg_temperature_celsius_montagnes,
        AVG(precipitations_24h_mm) AS avg_precipitations_24h_mm,
        AVG(humidity_percent) AS avg_humidity_percent,
        AVG(total_nebulosity_oktas) AS avg_total_nebulosity_oktas,
        AVG(temperature_min_12h_celsius) AS avg_temperature_min_12h_celsius,
        AVG(temperature_max_12h_celsius) AS avg_temperature_max_12h_celsius,
        AVG(temperature_min_24h_celsius) AS avg_temperature_min_24h_celsius,
        AVG(temperature_max_24h_celsius) AS avg_temperature_max_24h_celsius,
        AVG(hauteur_total_neige_m) AS avg_hauteur_total_neige_m,
        AVG(haute_neige_fraiche_m) AS avg_haute_neige_fraiche_m,
        AVG(temperature_neige_celsius) AS avg_temperature_neige_celsius,
        AVG(teneur_eau_neig_prct) AS avg_teneur_eau_neig_prct,
        AVG(masse_volumique_neige_kg_m3) AS avg_masse_volumique_neige_kg_m3,
        COUNT(CASE WHEN description_avalanches LIKE '%accidentel%' THEN 1 END) AS nb_observations_avalanches_accidentelles,

        COUNT(CASE WHEN risque_avalanches LIKE 'risque faible' THEN 1 END) AS nb_observations_risque_avalanches_faible,
        COUNT(CASE WHEN risque_avalanches LIKE 'risque marqué' THEN 1 END) AS nb_observations_risque_avalanches_marque,
        COUNT(CASE WHEN risque_avalanches LIKE 'risque fort' THEN 1 END) AS nb_observations_risque_avalanches_fort,
        COUNT(CASE WHEN risque_avalanches LIKE 'risque très fort' THEN 1 END) AS nb_observations_risque_avalanches_tres_fort,
        COUNT(CASE WHEN risque_avalanches LIKE 'risque limité' THEN 1 END) AS nb_observations_risque_avalanches_limite,

        COUNT(CASE WHEN grain_majoritaire LIKE 'neige fraîche' THEN 1 END) AS nb_observations_neige_fraiche,
        COUNT(CASE WHEN grain_majoritaire LIKE 'particules reconnaissables' THEN 1 END) AS nb_observations_particules_reconnaissables,
        COUNT(CASE WHEN grain_majoritaire LIKE 'grains fins' THEN 1 END) AS nb_observations_grains_fins,
        COUNT(CASE WHEN grain_majoritaire LIKE 'faces planes' THEN 1 END) AS nb_observations_faces_planes,
        COUNT(CASE WHEN grain_majoritaire LIKE 'gobelets' THEN 1 END) AS nb_observations_gobelets,
        COUNT(CASE WHEN grain_majoritaire LIKE 'grains ronds' THEN 1 END) AS nb_observations_grains_ronds,
        COUNT(CASE WHEN grain_majoritaire LIKE 'croûtes' THEN 1 END) AS nb_observations_croûtes,
        COUNT(CASE WHEN grain_majoritaire LIKE 'givre de surface' THEN 1 END) AS nb_observations_givre_surface,
        COUNT(CASE WHEN grain_majoritaire LIKE 'neige roulée' THEN 1 END) AS nb_observations_neige_roulee,

        COUNT(CASE WHEN depart_avalanches LIKE 'inférieure à 1 500 m' THEN 1 END) AS nb_observations_depart_avalanches_absence,
        COUNT(CASE WHEN depart_avalanches LIKE 'entre 1 500 et 2 000 m' THEN 1 END) AS nb_observations_depart_avalanches_1500_2000,
        COUNT(CASE WHEN depart_avalanches LIKE 'départ à plusieurs altitudes mais la plupart inférieures à 2 000 m' THEN 1 END) AS nb_observations_depart_avalanches_plusieurs_inf_2000,
        COUNT(CASE WHEN depart_avalanches LIKE 'entre 2 000 et 2 250 m' THEN 1 END) AS nb_observations_depart_avalanches_2000_2250,
        COUNT(CASE WHEN depart_avalanches LIKE 'entre 2 250 et 2 500 m' THEN 1 END) AS nb_observations_depart_avalanches_2250_2500,  
        COUNT(CASE WHEN depart_avalanches LIKE 'entre 2 500 et 3 000 m' THEN 1 END) AS nb_observations_depart_avalanches_2500_3000,
        COUNT(CASE WHEN depart_avalanches LIKE 'départ à plusieurs altitudes mais la plupart supérieures à 2 000 m' THEN 1 END) AS nb_observations_depart_avalanches_plusieurs_sup_2₀₀₀,
        COUNT(CASE WHEN depart_avalanches LIKE 'supérieure à 3 000 m' THEN 1 END) AS nb_observations_depart_avalanches_sup_3000,

        COUNT(CASE WHEN genre_avalanches LIKE 'aucune avalanche mais fissure(s) dans le manteau neigeux' THEN 1 END) AS nb_observations_fissures_manteau_neigeux,
        COUNT(CASE WHEN genre_avalanches LIKE 'coulées, sèches ou humides' THEN 1 END) AS nb_observations_coulees_seches_humides,
        COUNT(CASE WHEN genre_avalanches LIKE 'avalanches de neige récente, sèche, départ ponctuel' THEN 1 END) AS nb_observations_avalanches_neige_seche,
        COUNT(CASE WHEN genre_avalanches LIKE 'avalanches de neige récente, humide, départ ponctuel' THEN 1 END) AS nb_observations_avalanches_neige_humide,
        COUNT(CASE WHEN genre_avalanches LIKE 'avalanches de plaque friable (départ linéaire, neige sèche, dépôt plutôt fin)' THEN 1 END) AS nb_observations_avalanches_plaque_friable,
        COUNT(CASE WHEN genre_avalanches LIKE 'avalanches de plaque dure (départ linéaire, neige sèche, dépôt de blocs)' THEN 1 END) AS nb_observations_avalanches_plaque_dure,
        COUNT(CASE WHEN genre_avalanches LIKE 'avalanches de surface de vieille neige humide ou mouillée' THEN 1 END) AS nb_observations_avalanches_surface_vieille_neige, 
        COUNT(CASE WHEN genre_avalanches LIKE 'avalanches de plaque de fond de neige sèche (départ linéaire)' THEN 1 END) AS nb_observations_avalanches_plaque_fond_neige_seche,
        COUNT(CASE WHEN genre_avalanches LIKE 'avalanches de fond de vieille neige humide ou mouillée (départ ponctuel ou linéaire)' THEN 1 END) AS nb_observations_avalanches_fond_vieille_neige,

        COUNT(*) AS nb_observations


    FROM {{ ref('clean_meteo_montagneux') }}
    GROUP BY to_char(measure_datetime, 'MMYYYY'), EXTRACT(YEAR FROM measure_datetime), EXTRACT(MONTH FROM measure_datetime)
),

climat_agg AS (
    SELECT 
        measure_date,
        AVG(solids_precipitations_mm) AS avg_solids_precipitations_mm,
        AVG(liquid_precipitations_mm) AS avg_liquid_precipitations_mm,
        AVG(total_precipitations_mm) AS avg_total_precipitations_mm,
        AVG(temperature_celsius) AS avg_temperature_celsius_climat,
        AVG(evapotranspiration_reel_mm) AS avg_evapotranspiration_reel_mm,
        AVG(evapotranspiration_potentielle_mm) AS avg_evapotranspiration_potentielle_mm,
        AVG(pluie_mm) AS avg_pluie_mm,
        AVG(indice_humidite_sol) AS avg_indice_humidite_sol,
        AVG(indice_secheresse_precipitations_1_mois) AS avg_indice_secheresse_precipitations_1_mois,
        AVG(indice_secheresse_precipitations_3_mois) AS avg_indice_secheresse_precipitations_3_mois,
        AVG(indice_secheresse_precipitations_6_mois) AS avg_indice_secheresse_precipitations_6_mois,
        AVG(indice_secheresse_precipitations_12_mois) AS avg_indice_secheresse_precipitations_12_mois,
        AVG(indice_secheresse_sols_1_mois) AS avg_indice_secheresse_sols_1_mois,
        AVG(indice_secheresse_sols_3_mois) AS avg_indice_secheresse_sols_3_mois,
        AVG(indice_secheresse_sols_6_mois) AS avg_indice_secheresse_sols_6_mois,
        AVG(indice_secheresse_sols_12_mois) AS avg_indice_secheresse_sols_12_mois,
        AVG(drainage_mm) AS avg_drainage_mm,
        AVG(ruissellement_mm) AS avg_ruissellement_mm,
        AVG(ecoulement_neigeux_mm) AS avg_ecoulement_neigeux_mm
    
    FROM {{ ref('clean_changement_clim') }}

    GROUP BY measure_date

)

SELECT *  FROM climat_agg AS clim
LEFT JOIN meteo_montagneux_agg AS mont ON clim.measure_date = mont.measure_date_m