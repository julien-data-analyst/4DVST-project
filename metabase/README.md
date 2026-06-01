# Metabase

## Sauvegarde des données Metabase

Pour sauvegarder les données du Metabase dans le dossier `postgres`, exécutez ces commandes :

1. Créez un dump PostgreSQL depuis le conteneur `postgres` :

```bash
docker exec postgres pg_dump \
  -U admin \
  -d metabase \
  -Fc \
  -f /tmp/metabase.dump
```

2. Copiez le fichier de sauvegarde dans le dossier `postgres` de votre projet :

```bash
docker cp postgres:/tmp/metabase.dump ./postgres/metabase.dump
```

Après cela, le fichier `postgres/metabase.dump` contiendra la sauvegarde de votre base Metabase.

3. Vous pouvez ensuite copier-coller dans le PostgreSQL de votre choix pour restaurer la base de données Metabase à partir de ce dump. Par exemple, si vous avez un autre conteneur PostgreSQL, vous pouvez utiliser le script `restore.sh` situé dans `postgres` pour restaurer la base de données à partir du dump : 

```bash
docker cp ./postgres/metabase.dump postgres:/docker-entrypoint-initdb.d/metabase.dump
```

4. Vous pouvez restaurer cette sauvegarde dans un autre conteneur PostgreSQL en utilisant le script `restore.sh` situé dans `postgres

```bash
docker exec postgres pg_restore \
  --username="admin" \
  --dbname="metabase" \
  /docker-entrypoint-initdb.d/metabase.dump
```
