{{ config(
    tags="montagneux",
    materialized='table',
    schema='processing'
) }}
SELECT 
        id,

        NULLIF(lat, '')::FLOAT AS latitude,
        NULLIF(lon, '')::FLOAT AS longitude,
        public.st_setsrid(
            public.st_makepoint(
                NULLIF(lon, '')::FLOAT,
                NULLIF(lat, '')::FLOAT),
            4326) AS geom,
        NULLIF("Altitude", '')::FLOAT AS altitude,

        name AS station_name,
        NULLIF(validity_time, '')::TIMESTAMP AS measure_datetime,

        NULLIF(t, '')::FLOAT  - 273.15 AS temperature_celsius,

        NULLIF(dd, '')::INTEGER AS direction_vent_deg,
        NULLIF(ff, '')::FLOAT AS vitesse_vent_moyen_10min_m_s,
        NULLIF(u, '')::FLOAT AS humidity_percent,
        NULLIF(n, '')::FLOAT AS total_nebulosity_oktas,
        NULLIF(nbas, '')::FLOAT AS nebulosity_bas_oktas,
        NULLIF(hbas, '')::FLOAT AS hauteu_bas_m,
        NULLIF(rr24, '')::FLOAT AS precipitations_24h_mm,
        NULLIF(tn12, '')::FLOAT - 273.15 AS temperature_min_12h_celsius,
        NULLIF(tx12, '')::FLOAT - 273.15 AS temperature_max_12h_celsius,
        NULLIF(tn24, '')::FLOAT - 273.15 AS temperature_min_24h_celsius,
        NULLIF(tx24, '')::FLOAT - 273.15 AS temperature_max_24h_celsius,
        NULLIF(ht_neige, '')::FLOAT AS hauteur_total_neige_m,
        NULLIF(ssfrai, '')::FLOAT AS haute_neige_fraiche_m,
        NULLIF(t_neige, '')::FLOAT - 273.15 AS temperature_neige_celsius,

        CASE chasse_neige
            WHEN '0' THEN 'absence chasse-neige'
            WHEN '1' THEN 'présence chasse-neige depuis la dernière observation mais absence actuellement'
            WHEN '2' THEN 'chasse-neige modérée d''Est'
            WHEN '3' THEN 'chasse-neige modérée de Sud'
            WHEN '4' THEN 'chasse-neige modérée d''Ouest'
            WHEN '5' THEN 'chasse-neige modérée de Nord'
            WHEN '6' THEN 'chasse-neige forte d''Est'
            WHEN '7' THEN 'chasse-neige forte de Sud'
            WHEN '8' THEN 'chasse-neige forte d''Ouest'
            WHEN '9' THEN 'chasse-neige forte de Nord'
            ELSE  'observation impossible ou non renseignée'
        END AS direction_chasse_neige,

        CASE aval_descr
            WHEN '0' THEN 'RAS'
            WHEN '1' THEN 'aucune avalanche malgré des tirs'
            WHEN '2' THEN 'déclenchement(s) aritificiel(s) positif(s) (majorité de tirs négatifs, quelques tirs positifs)'
            WHEN '3' THEN 'déclenchement(s) aritificiel(s) positif(s) (majorité de tirs positifs, quelques tirs négatifs)'
            WHEN '4' THEN '1 déclenchement accidentel (aucun tir ou tirs négatifs)'
            WHEN '5' THEN '1 déclenchement accidentel (au moins 1 tir positif)'
            WHEN '6' THEN 'plusieurs déclenchements accidentels (aucun tir ou tirs négatifs)'
            WHEN '7' THEN 'plusieurs déclenchements accidentels (au moins 1 tir positif)'
            ELSE  'observation impossible ou non renseignée'
        END AS description_avalanches,

        CASE aval_genre
            WHEN '0' THEN 'RAS'
            WHEN '1' THEN 'aucune avalanche mais fissure(s) dans le manteau neigeux'
            WHEN '2' THEN 'coulées, sèches ou humides'
            WHEN '3' THEN 'avalanches de neige récente, sèche, départ ponctuel'
            WHEN '4' THEN 'avalanches de neige récente, humide, départ ponctuel'
            WHEN '5' THEN 'avalanches de plaque friable (départ linéaire, neige sèche, dépôt plutôt fin)'
            WHEN '6' THEN 'avalanches de plaque dure (départ linéaire, neige sèche, dépôt de blocs)'
            WHEN '7' THEN 'avalanches de surface de vieille neige humide ou mouillée'
            WHEN '8' THEN 'avalanches de plaque de fond de neige sèche (départ linéaire)'
            WHEN '9' THEN 'avalanches de fond de vieille neige humide ou mouillée (départ ponctuel ou linéaire)'
            ELSE  'observation impossible ou non renseignée'
        END AS genre_avalanches,

        CASE aval_expo
            WHEN '0' THEN 'RAS'
            WHEN '1' THEN 'versant Nord-Est'
            WHEN '2' THEN 'versant Est'
            WHEN '3' THEN 'versant Sud-Est'
            WHEN '4' THEN 'versant Sud'
            WHEN '5' THEN 'versant Sud-Ouest'
            WHEN '6' THEN 'versant Ouest'
            WHEN '7' THEN 'versant Nord-Ouest'
            WHEN '8' THEN 'versant Nord'
            WHEN '9' THEN 'aucune orientation'
            ELSE  'observation impossible ou non renseignée'
        END AS exposition_avalanches,

        CASE aval_depart
            WHEN '0' THEN 'RAS'
            WHEN '1' THEN 'inférieure à 1 500 m'
            WHEN '2' THEN 'entre 1 500 et 1 750 m'
            WHEN '3' THEN 'entre 1 750 et 2 000 m'
            WHEN '4' THEN 'départ à plusieurs altitudes mais la plupart inférieures à 2 000 m'
            WHEN '5' THEN 'entre 2 000 et 2 250 m'
            WHEN '6' THEN 'entre 2 250 et 2 500 m'
            WHEN '7' THEN 'entre 2 500 et 3 000 m'
            WHEN '9' THEN 'départ à plusieurs altitudes mais la plupart supérieures à 2 000 m'
            WHEN '8' THEN 'supérieure à 3 000 m'
            ELSE  'observation impossible ou non renseignée'
        END AS depart_avalanches,

        CASE aval_risque
            WHEN '1' THEN 'risque faible'
            WHEN '2' THEN 'risque limité'
            WHEN '3' THEN 'risque marqué'
            WHEN '4' THEN 'risque fort'
            WHEN '5' THEN 'risque très fort'
            ELSE  'observation impossible ou non renseignée'
        END AS risque_avalanches,

        NULLIF(dd_alti, '')::FLOAT AS direction_vent_alti_deg,
        NULLIF(ff_alti, '')::FLOAT AS force_vent_alti_moyen_ms,
        NULLIF(ht_neige_alti, '')::FLOAT AS hauteur_neige_alti_m,
        NULLIF(neige_fraiche, '')::FLOAT AS hauteur_neige_fraiche_m,
        NULLIF(teneur_eau, '')::FLOAT AS teneur_eau_neig_prct,

        CASE grain_predom
            WHEN '1' THEN 'neige fraîche'
            WHEN '2' THEN 'particules reconnaissables'
            WHEN '3' THEN 'grains fins'
            WHEN '4' THEN 'faces planes'
            WHEN '5' THEN 'gobelets'
            WHEN '6' THEN 'grains ronds'
            WHEN '7' THEN 'croûtes'
            WHEN '8' THEN 'givre de surface'
            WHEN '9' THEN 'neige roulée'
            ELSE  'observation impossible ou non renseignée'
        END AS grain_majoritaire,

        CASE grain_nombre
            WHEN '1' THEN 'neige fraîche'
            WHEN '2' THEN 'particules reconnaissables'
            WHEN '3' THEN 'grains fins'
            WHEN '4' THEN 'faces planes'
            WHEN '5' THEN 'gobelets'
            WHEN '6' THEN 'grains ronds'
            WHEN '7' THEN 'croûtes'
            WHEN '8' THEN 'givre de surface'
            WHEN '9' THEN 'neige roulée'
            ELSE  'observation impossible ou non renseignée'
        END AS grain_majoritaire_surf_minus_10,

        NULLIF(grain_diametr, '')::FLOAT AS mean_diams_grain,

        CASE homogeneite
            WHEN '0' THEN 'carottage vertica sur la planche'
            WHEN '1' THEN 'carottage horizontal entre la surface de neige et le niveau -10 cm'
            WHEN '2' THEN 'pas de mesure de masse volumique'
            ELSE  'observation impossible ou non renseignée'
        END AS homogeneite_couche, 

        NULLIF(m_vol_neige, '')::FLOAT AS masse_volumique_neige_kg_m3
FROM    

{{ source('weather_climatic_data', 'weather_mountain_nivo') }}