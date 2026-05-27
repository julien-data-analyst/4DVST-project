-- ─────────────────────────────────────────
-- init/01_metabase_db.sql
-- Exécuté automatiquement au premier démarrage
-- de PostgreSQL (docker-entrypoint-initdb.d)
-- ─────────────────────────────────────────

-- Base de données dédiée à Metabase
SELECT 'CREATE DATABASE metabase'
WHERE NOT EXISTS (
    SELECT FROM pg_database WHERE datname = 'metabase'
)\gexec

-- Schéma dbt dev (optionnel, dbt peut le créer lui-même)
-- Décommentez si vous souhaitez pré-créer le schéma
-- \c datawarehouse;
-- CREATE SCHEMA IF NOT EXISTS dbt_dev;
