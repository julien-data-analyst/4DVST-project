"""
utility_postgresql.py
─────────────────────
Fonctions utilitaires pour interagir avec PostgreSQL :
  - connexion via psycopg2
  - création automatique d'une table à partir des colonnes d'un DataFrame Polars
  - insertion en batch des données

Librairies utilisées : psycopg2-binary, polars
"""

import os
import logging
from contextlib import contextmanager

import psycopg2
import psycopg2.extras
import polars as pl

logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────────────────────
# Mapping types Polars → PostgreSQL
# ─────────────────────────────────────────────────────────────

POLARS_TO_PG: dict[str, str] = {
    "Int8":    "SMALLINT",
    "Int16":   "SMALLINT",
    "Int32":   "INTEGER",
    "Int64":   "BIGINT",
    "UInt8":   "SMALLINT",
    "UInt16":  "INTEGER",
    "UInt32":  "BIGINT",
    "UInt64":  "NUMERIC",
    "Float32": "REAL",
    "Float64": "DOUBLE PRECISION",
    "Boolean": "BOOLEAN",
    "Date":    "DATE",
    "Datetime":"TIMESTAMP",
    "Utf8":    "TEXT",
    "String":  "TEXT",
    "Null":    "TEXT",
}


def _pg_type(polars_dtype) -> str:
    """Convertit un dtype Polars en type SQL PostgreSQL."""
    type_name = polars_dtype.__class__.__name__
    return POLARS_TO_PG.get(type_name, "TEXT")


# ─────────────────────────────────────────────────────────────
# Connexion
# ─────────────────────────────────────────────────────────────

def get_connection_params() -> dict:
    """
    Lit les paramètres de connexion depuis les variables d'environnement.
    Compatible avec le .env monté dans le conteneur dbt-dev.

    Variables attendues (avec valeurs par défaut) :
        POSTGRES_HOST     (défaut : postgres)
        POSTGRES_PORT     (défaut : 5432)
        POSTGRES_USER     (défaut : admin)
        POSTGRES_PASSWORD (défaut : admin)
        POSTGRES_DB       (défaut : datawarehouse)
    """
    return {
        "host":     os.getenv("POSTGRES_HOST", "postgres"),
        "port":     5432,
        "user":     os.getenv("POSTGRES_USER", "admin"),
        "password": os.getenv("POSTGRES_PASSWORD", "admin"),
        "dbname":   os.getenv("POSTGRES_DB", "datawarehouse"),
    }


@contextmanager
def connect():
    """
    Context manager retournant une connexion psycopg2.
    La connexion est fermée automatiquement en sortie de bloc.

    Usage :
        with connect() as conn:
            with conn.cursor() as cur:
                cur.execute(...)
    """
    params = get_connection_params()
    conn = psycopg2.connect(**params)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# ─────────────────────────────────────────────────────────────
# Création de table
# ─────────────────────────────────────────────────────────────

def create_table_if_not_exists(
    conn: psycopg2.extensions.connection,
    table_name: str,
    df: pl.DataFrame,
    schema: str = "public",
) -> None:
    """
    Crée la table dans PostgreSQL si elle n'existe pas encore,
    en inférant les colonnes et types depuis le DataFrame Polars.

    Args:
        conn       : Connexion psycopg2 active.
        table_name : Nom de la table cible.
        df         : DataFrame dont on déduit le schéma.
        schema     : Schéma PostgreSQL (défaut : 'public').
    """
    columns_sql = ",\n    ".join(
        f'"{col}" {_pg_type(dtype)}'
        for col, dtype in zip(df.columns, df.dtypes)
    )

    sql = f"""
        CREATE TABLE IF NOT EXISTS "{schema}"."{table_name}" (
            {columns_sql}
        );
    """

    with conn.cursor() as cur:
        cur.execute(sql)

    logger.info("Table '%s.%s' vérifiée / créée.", schema, table_name)


# ─────────────────────────────────────────────────────────────
# Insertion
# ─────────────────────────────────────────────────────────────

def insert_dataframe(
    conn: psycopg2.extensions.connection,
    table_name: str,
    df: pl.DataFrame,
    schema: str = "public",
    batch_size: int = 1_000,
) -> int:
    """
    Insère toutes les lignes du DataFrame dans la table PostgreSQL
    via des batches pour éviter les problèmes mémoire sur gros volumes.

    Args:
        conn       : Connexion psycopg2 active.
        table_name : Nom de la table cible.
        df         : DataFrame Polars à insérer.
        schema     : Schéma PostgreSQL (défaut : 'public').
        batch_size : Nombre de lignes par batch (défaut : 1 000).

    Returns:
        Nombre total de lignes insérées.
    """
    if df.is_empty():
        logger.warning("DataFrame vide — aucune insertion effectuée.")
        return 0

    columns = ", ".join(f'"{c}"' for c in df.columns)
    placeholders = ", ".join(["%s"] * len(df.columns))
    sql = f'INSERT INTO "{schema}"."{table_name}" ({columns}) VALUES ({placeholders})'

    # Conversion en liste de tuples Python (None remplace les valeurs nulles)
    rows = [
        tuple(None if v is None else v for v in row)
        for row in df.iter_rows()
    ]

    total = 0
    with conn.cursor() as cur:
        for i in range(0, len(rows), batch_size):
            batch = rows[i : i + batch_size]
            psycopg2.extras.execute_batch(cur, sql, batch)
            total += len(batch)
            logger.debug("Batch inséré : %d / %d lignes.", total, len(rows))

    logger.info("%d lignes insérées dans '%s.%s'.", total, schema, table_name)
    return total


# ─────────────────────────────────────────────────────────────
# Fonction combinée (raccourci pratique)
# ─────────────────────────────────────────────────────────────

def create_and_insert(
    table_name: str,
    df: pl.DataFrame,
    schema: str = "public",
    batch_size: int = 1_000,
) -> int:
    """
    Raccourci : ouvre la connexion, crée la table si nécessaire,
    insère les données, ferme la connexion.

    Args:
        table_name : Nom de la table cible.
        df         : DataFrame Polars à insérer.
        schema     : Schéma PostgreSQL (défaut : 'public').
        batch_size : Taille des batches d'insertion.

    Returns:
        Nombre total de lignes insérées.
    """
    with connect() as conn:
        create_table_if_not_exists(conn, table_name, df, schema)
        return insert_dataframe(conn, table_name, df, schema, batch_size)
