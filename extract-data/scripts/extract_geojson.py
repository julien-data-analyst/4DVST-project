"""
extract_geojson.py
─────────────────────
Script d'extraction de données à partir d'un fichier GeoJSON et insertion dans PostgreSQL.

Librairies utilisées : psycopg2-binary, polars, shapely, orjson
"""

import polars as pl
import orjson
from shapely.geometry import shape
from packages.utility_postgresql import create_and_insert
import datetime

# -----------------------------
# CONFIG
# -----------------------------
GEOJSON_FILE = "/data/geodata/departements.geojson"
GEOJSON_FILE_REGION = "/data/geodata/regions.geojson"
TABLE_NAME = "departements"
TABLE_NAME_REGION = "regions"

def extract_insert_geojson(file_path, table_name):
    # -----------------------------
    # LECTURE GEOJSON
    # -----------------------------
    with open(file_path, "rb") as f:
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
    create_and_insert(table_name, df)

    print("Import terminé.")

if "__main__" == __name__:
    # Application à faire
    print(f"debut import départements... {datetime.datetime.now()}")
    extract_insert_geojson(GEOJSON_FILE, TABLE_NAME)
    print(f"Import départements terminé. {datetime.datetime.now()}")

    print(f"debut import régions... {datetime.datetime.now()}")
    extract_insert_geojson(GEOJSON_FILE_REGION, TABLE_NAME_REGION)
    print(f"Import régions terminé. {datetime.datetime.now()}")