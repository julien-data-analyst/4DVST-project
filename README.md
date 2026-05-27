# 4DVST - Projet de visualisation des données météorologiques montagneuses et du changement climatique
## Auteur : Julien RENOULT - Mamadou-alpha DIALLO
## Promo : SUPINFO Programme Grande École 4ème année
### Spécialité : Ingénierie Data
### Date : 27/05/2026

# Introduction

Dans le cadre du projet, nous devions construire une architecture data pour la collecte et l'analyse des voyages de taxis à New York City et la météo associée.

Pour présenter ce projet, nous allons d'abord vous présenter les technologies utilisées, ensuite les pré-requis pour pouvoir lancer l'architecture et pour finir ceux que nous avons faits pour chaque partie.

# Technologies utilisées  (Installation/Déploiement)

Pour mener à bien ce projet, plusieurs technologies ont dû être utilisées notamment :

- **python** : langage de programmation
- **dbt** : outil de transformation de données
- **PostgreSQL** : base de données permettant l'insertion et le traitement de JSON très simplement pour un gros volume de données
- **Docker** : technologie pour faciliter le déploiement de notre projet

# Comment lancer le projet

Pour lancer le projet, il vous suffit de cloner le repository et de lancer la commande suivante à la racine du projet :

```bash
docker-compose -f docker-compose.dev.yml up --build
```

Cette commande va construire les images Docker nécessaires et lancer les conteneurs pour PostgreSQL, dbt et Metabase.

# Syntaxe à respecter pour les branches et commits

- **Branches** : Les branches doivent être nommées de manière descriptive, par exemple `feature/ajout-nouvelle-fonctionnalite` ou `bugfix/correction-erreur-xyz`.
- **Commits** : Les messages de commit doivent indiquer si c'est un fix, feature ou autre, suivi d'une description concise du changement, par exemple `feat: ajout de la fonctionnalité de connexion` ou `fix: correction de l'erreur de validation des données`.

**Ne merger que si vous êtes sûr que votre code est fonctionnel et ne casse pas l'architecture.**

Quand est-ce que vous devez créer une branche ?
- Lorsque vous travaillez sur une nouvelle fonctionnalité (dashboard, dbt, etc. )
- Lorsque vous devez fixer un bug sur la branche main