from extract_geocsv import MENSUELCSV_FILE, NIVOCSV_FILE, TABLE_NAME_NIVEO, TABLE_NAME_MENSUEL, process_folder
from extract_geojson import extract_insert_geojson, GEOJSON_FILE, TABLE_NAME, GEOJSON_FILE_REGION, TABLE_NAME_REGION
import datetime

print(f"debut import nivo... {datetime.datetime.now()}")
process_folder(NIVOCSV_FILE, TABLE_NAME_NIVEO)
print(f"Import NIVO terminé. {datetime.datetime.now()}")

print(f"debut import mensuel... {datetime.datetime.now()}")
process_folder(MENSUELCSV_FILE, TABLE_NAME_MENSUEL)
print(f"Import MENSUEL terminé. {datetime.datetime.now()}")

# Application à faire
print(f"debut import départements... {datetime.datetime.now()}")
extract_insert_geojson(GEOJSON_FILE, TABLE_NAME)
print(f"Import départements terminé. {datetime.datetime.now()}")

print(f"debut import régions... {datetime.datetime.now()}")
extract_insert_geojson(GEOJSON_FILE_REGION, TABLE_NAME_REGION)
print(f"Import régions terminé. {datetime.datetime.now()}")