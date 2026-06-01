#!/bin/bash
set -e

echo "Restauration du dump Metabase..."

pg_restore \
  --username="$POSTGRES_USER" \
  --dbname="metabase" \
  /docker-entrypoint-initdb.d/metabase.dump

echo "Restauration terminée."