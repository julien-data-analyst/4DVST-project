# ─────────────────────────────────────────
# Metabase — image officielle Docker Hub
# https://hub.docker.com/r/metabase/metabase/tags
# ─────────────────────────────────────────
ARG METABASE_VERSION=v0.59.1.x

FROM metabase/metabase:${METABASE_VERSION}

LABEL maintainer="data-team"
LABEL description="Metabase BI — image officielle"

# Dossiers montés via volumes dans docker-compose
# (l'image officielle utilise déjà /metabase.db comme répertoire de données,
#  mais ici on passe par PostgreSQL donc ces dossiers sont pour nos besoins)
RUN mkdir -p /metabase-data /metabase-dashboards

# L'image officielle expose déjà le port 3000 et définit son propre CMD
# Aucune redéfinition nécessaire
