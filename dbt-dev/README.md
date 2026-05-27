# Lancer les commandes du conteneur dbt-dev

Pour lancer les commandes de dbt pour créer les différents modèles, il vous suffit de vous connecter au conteneur dbt-dev en utilisant la commande suivante :

```bash
docker exec -it dbt-dev bash
```

Ensuite vous pouvez lancer les commandes dbt à l'intérieur du conteneur, par exemple :

```bash
dbt debug # test connexion à la base de données
dbt run # exécute les modèles dbt
dbt test # exécute les tests dbt
```

