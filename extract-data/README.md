# Lancer les commandes du conteneur extract-data

Pour lancer les commandes de python pour exécuter les scripts, 
il vous suffit de vous connecter au conteneur python-extract en utilisant la commande suivante :

```bash
docker exec -it python-extract bash
```

Ensuite vous pouvez lancer les commandes python à l'intérieur du conteneur, par exemple :

```bash
cd scripts
python extract_geojson.py # pour extraire les données du fichier geojson et les insérer dans la base de données
python extract_csv.py # pour extraire les données du fichier csv et les insérer dans la base de données
python main.py # pour exécuter tous les scripts d'extraction (geojson et csv) en une seule commande
```

