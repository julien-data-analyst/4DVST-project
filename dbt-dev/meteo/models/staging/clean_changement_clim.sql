{{ config(
    tags="climat",
    materialized='table',
    schema='processing'
) }}
SELECT 
        to_date("DATE", 'YYYYMM') AS measure_date,
        NULLIF("PRENEI", '')::FLOAT AS solids_precipitations_mm,
        NULLIF("PRELIQ", '')::FLOAT AS liquid_precipitations_mm,
        NULLIF("PRETOTM", '')::FLOAT AS total_precipitations_mm,
        NULLIF("T", '')::FLOAT AS temperature_celsius,
        NULLIF("EVAP", '')::FLOAT AS evapotranspiration_reel_mm,
        NULLIF("ETP", '')::FLOAT AS evapotranspiration_potentielle_mm,
        NULLIF("PE", '')::FLOAT AS pluie_mm,
        NULLIF("SWI", '')::FLOAT AS indice_humidite_sol,
        NULLIF("SPI1", '')::FLOAT AS indice_secheresse_precipitations_1_mois,
        NULLIF("SPI3", '')::FLOAT AS indice_secheresse_precipitations_3_mois,
        NULLIF("SPI6", '')::FLOAT AS indice_secheresse_precipitations_6_mois,
        NULLIF("SPI12", '')::FLOAT AS indice_secheresse_precipitations_12_mois,
        NULLIF("SSWI1", '')::FLOAT AS indice_secheresse_sols_1_mois,
        NULLIF("SSWI3", '')::FLOAT AS indice_secheresse_sols_3_mois,
        NULLIF("SSWI6", '')::FLOAT AS indice_secheresse_sols_6_mois,
        NULLIF("SSWI12", '')::FLOAT AS indice_secheresse_sols_12_mois,
        NULLIF("DRAINC", '')::FLOAT AS drainage_mm,
        NULLIF("RUNC", '')::FLOAT AS ruissellement_mm,
        NULLIF("ECOULEMENT", '')::FLOAT AS ecoulement_neigeux_mm
        
FROM {{ source('weather_climatic_data', 'climatic_change_monthly') }}