"""
extract_geocsv.py
─────────────────────
Script d'extraction de données à partir d'un fichier GeoCSV et insertion dans PostgreSQL.

Librairies utilisées : psycopg2-binary, polars, shapely, orjson
"""

import gzip
import re
import polars as pl
from shapely.geometry import Point
from packages.utility_postgresql import connect, create_and_insert
from pathlib import Path 

# -----------------------------
# CONFIG
# -----------------------------
NIVOCSV_FILE = Path("/data/NIVO/")
TABLE_NAME_NIVEO = "nivo"

MENSUELCSV_FILE = Path("/data/MENSUEL/")
TABLE_NAME_MENSUEL = "mensuel"

#-----------------------------
# FONCTION DE DETECTION DE SEPARATEUR
#-----------------------------
def detect_separator(file_path):
    """
    Detecte automatiquement ; ou ,
    """

    with gzip.open(file_path, "rt", encoding="utf-8") as f:
        first_line = f.readline()

    if first_line.count(";") > first_line.count(","):
        return ";"

    return ","


#-----------------------------
# FONCTION D'EXTRACTION DES ANNEES
#-----------------------------
def extract_years(file_name):

    years = re.findall(r"\d{4}", file_name)

    if not years:
        return None, None

    if len(years) == 1:
        return int(years[0]), int(years[0])

    return int(years[0]), int(years[-1])

# -----------------------------
# LECTURE GEOCSV
# -----------------------------

def parse_geocsv(file_path):
    dfs= []
    for file in sorted(file_path.glob("*.csv.gz")):
        print(f"Processing {file}...")

        df = pl.read_csv(
            file,
            separator=detect_separator(file),
            infer_schema_length=0,
            ignore_errors=True
        )

        start_year, end_year = extract_years(file.name)

        df = df.with_columns(
            pl.lit(start_year).alias("start_year"),
            pl.lit(end_year).alias("end_year")
        )

        dfs.append(df)
    return pl.concat(dfs,how="diagonal_relaxed")

# print("Parsing NIVO CSV...")
# df_nivo = parse_geocsv(NIVOCSV_FILE)
# print(df_nivo.head(20))
# print(df_nivo.shape)

print("Parsing MENSUEL CSV...")
df_mensuel = parse_geocsv(MENSUELCSV_FILE)
# print(df_mensuel.head(20))
# print(df_mensuel.shape)

# -----------------------------
# CREATION TABLE + INSERTION
# -----------------------------

# print("debut import nivo...")
# create_and_insert(TABLE_NAME_NIVEO, df_nivo)
# print("Import NIVO terminé.")

print("debut import mensuel...")
create_and_insert(TABLE_NAME_MENSUEL, df_mensuel)
print("Import MENSUEL terminé.")