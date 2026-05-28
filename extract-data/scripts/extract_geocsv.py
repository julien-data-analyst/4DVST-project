"""
extract_geocsv.py
─────────────────────
Script d'extraction de données à partir d'un fichier CSV et insertion dans PostgreSQL.

Librairies utilisées : psycopg2-binary, shapely, gzip
"""

import gzip
import re
from shapely.geometry import Point
from packages.utility_postgresql import connect
import io
from pathlib import Path 
import datetime
import csv

# -----------------------------
# CONFIG
# -----------------------------
NIVOCSV_FILE = Path("/data/NIVO/")
TABLE_NAME_NIVEO = "nivo"

MENSUELCSV_FILE = Path("/data/MENSUEL/")
TABLE_NAME_MENSUEL = "mensuel"

#-----------------------------
# FONCTION DE DETECTION DU SEPARATEUR ET DE L'EN-TETE
#-----------------------------
def get_header_and_separator(file_path):
    """
    Détecte le séparateur ("," ou ";") et les colonnes d'un fichier CSV compressé en gzip.
    Lit uniquement la première ligne du fichier pour éviter de charger tout le contenu en mémoire.

    Args:
        file_path (str): Chemin vers le fichier CSV gzip.
    
    Returns:
        tuple: (séparateur, liste des colonnes)
    """

    with gzip.open(file_path, "rt", encoding="utf-8") as f:
        first_line = f.readline().strip()

    sep = ";" if first_line.count(";") > first_line.count(",") else ","
    columns = [c.strip() for c in first_line.split(sep)]

    return sep, columns


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
# CREATION DE LA TABLE TOUT TEXTE + COPY CSV
# -----------------------------
def create_table_text(conn, table_name, columns, schema="public"):
    all_columns = columns + ["start_year", "end_year"]

    cols_sql = ",\n    ".join([f'"{c}" TEXT' for c in all_columns])

    sql = f"""
    CREATE TABLE IF NOT EXISTS "{schema}"."{table_name}" (
        {cols_sql}
    );
    """

    with conn.cursor() as cur:
        cur.execute(sql)


def copy_file_with_years(conn, table_name, file_path, sep, columns, start_year, end_year, schema="public"):

    all_columns = columns + ["start_year", "end_year"]
    cols_sql = ", ".join([f'"{c}"' for c in all_columns])

    sql = f'''
        COPY "{schema}"."{table_name}" ({cols_sql})
        FROM STDIN WITH (FORMAT csv, DELIMITER '{sep}', HEADER false)
    '''

    with conn.cursor() as cur:
        with gzip.open(file_path, "rt", encoding="utf-8") as f:

            reader = csv.reader(f, delimiter=sep)

            header = next(reader)  # skip header

            def transformed_rows():
                for row in reader:
                    yield row + [start_year, end_year]

            # buffer stream pour COPY
            buffer = io.StringIO()

            writer = csv.writer(buffer, delimiter=sep)

            for row in transformed_rows():
                writer.writerow(row)

            buffer.seek(0)
            cur.copy_expert(sql=sql, file=buffer)

# -----------------------------
# APPLICATION DU PROCESSUS SUR TOUS LES FICHIERS ZIP
# -----------------------------
def process_folder(folder_path, table_name):
    files = sorted(folder_path.glob("*.csv.gz"))

    with connect() as conn:
        for file in files:

            print(f"Processing {file}...{datetime.datetime.now()}")

            sep, columns = get_header_and_separator(file)

            start_year, end_year = extract_years(file.name)

            create_table_text(conn, table_name, columns)

            copy_file_with_years(
                conn,
                table_name,
                file,
                sep,
                columns,
                start_year,
                end_year
            )

            print(f"✔ Loaded {file.name} {datetime.datetime.now()}")

print(f"debut import nivo... {datetime.datetime.now()}")
process_folder(NIVOCSV_FILE, TABLE_NAME_NIVEO)
print(f"Import NIVO terminé. {datetime.datetime.now()}")

print(f"debut import mensuel... {datetime.datetime.now()}")
process_folder(MENSUELCSV_FILE, TABLE_NAME_MENSUEL)
print(f"Import MENSUEL terminé. {datetime.datetime.now()}")