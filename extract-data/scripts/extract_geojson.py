"""
extract_geojson.py
─────────────────────
Script d'extraction de données à partir d'un fichier GeoJSON et insertion dans PostgreSQL.

Librairies utilisées : psycopg2-binary, polars, shapely, orjson
"""

import polars as pl
import orjson
from shapely.geometry import shape
from packages.utility_postgresql import connect, create_and_insert
import os

# -----------------------------
# CONFIG
# -----------------------------
GEOJSON_FILE = "/data/geodata/departements.geojson"
TABLE_NAME = "departements"

# -----------------------------
# LECTURE GEOJSON
# -----------------------------
with open(GEOJSON_FILE, "rb") as f:
    geojson = orjson.loads(f.read())

features = geojson["features"]

rows = []

for feature in features:
    props = feature.get("properties", {})

    geom = feature.get("geometry")

    # conversion en WKT
    wkt_geom = shape(geom).wkt if geom else None

    row = {
        **props,
        "geometry": wkt_geom
    }

    rows.append(row)

# print(rows[0])

# -----------------------------
# POLARS DATAFRAME
# -----------------------------
df = pl.DataFrame(rows)

print(df)

# -----------------------------
# CREATION TABLE + INSERTION
# -----------------------------
create_and_insert(TABLE_NAME, df)

print("Import terminé.")