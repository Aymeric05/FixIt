# Project Context & Gameplay Vision

Ce document décrit la vision produit, les mécaniques de jeu et les idées futures pour FixIt.

## 1. Vue d'ensemble du Projet
FixIt est un jeu de puzzle mobile inspiré par le modèle de progression de "Candy Crush". L'objectif est de proposer un jeu casual mais compétitif, facile à prendre en main mais difficile à maîtriser.

## 2. Gameplay : Le mode "Zip"
Le mini-jeu principal consiste à relier des numéros en séquence (1, 2, 3...) dans une grille de 6x6.
*   **Objectif :** Remplir chaque cellule de la grille.
*   **Contrainte de victoire :** Le parcours doit obligatoirement se terminer sur le dernier chiffre de la séquence (implémenté dans la PR #10).
*   **Difficulté :** La difficulté varie selon le temps imparti et le nombre d'indices (chiffres déjà placés) fournis au départ.
*   **Obstacles :** Des "buissons" agissent comme des murs entre les cellules, bloquant certains passages.

## 3. Modes de Jeu
### 3.1 Mode Histoire (Progression Principale)
Une suite de niveaux de difficulté croissante organisée par "Mondes". Chaque monde introduit de nouveaux thèmes visuels.

### 3.2 Défis Quotidiens
*   **Daily Single Level :** Un niveau unique par jour pour tous les joueurs. Permet de comparer son temps avec ses amis.
*   **Daily Series :** Une chaîne de 3 niveaux consécutifs. Le score final est le temps cumulé. La série peut être reprise en cours de journée si elle est interrompue.

## 4. Économie du Jeu
*   **Système de Vies :** Le joueur commence avec 5 vies. Une vie est perdue en cas d'échec ou d'abandon. Les vies se rechargent automatiquement toutes les 60 minutes.
*   **Persistance du Timer :** Le décompte de recharge des vies est persistant. Il continue de s'écouler même si l'application est fermée ou en arrière-plan. Au retour dans le jeu, les vies gagnées sont automatiquement créditées (implémenté dans la branche `fix/persistent-lives-timer`).
*   **Items (Boosters) :** 
    *   *Plus Time* : Ajoute du temps au chrono.
    *   *More Numbers* : Révèle des chiffres supplémentaires dans la grille.
    *   *Reveal Path* : Montre temporairement le prochain segment du chemin de solution.

## 5. Aspects Sociaux
*   Le joueur peut ajouter des amis par leur pseudonyme.
*   **Système de Requêtes** : Les demandes d'amis sont notifiées en temps réel via un badge rouge sur l'icône sociale.
*   Classements en temps réel sur les niveaux quotidiens.
*   Recap de victoire montrant le record mondial et le rang parmi les amis.

## 6. Authentification & Profil
*   **Login Anonyme** : Chaque nouveau joueur est automatiquement connecté avec un compte anonyme Supabase au premier lancement.
*   **Guest Profile** : Un profil Drift (local) et Supabase (distant) est créé avec un pseudo aléatoire (`Guest#1234`).
*   **Synchronisation** : Le pseudo et l'avatar sont synchronisés entre le cache local et le serveur dès qu'une connexion internet est disponible.

## 7. Monétisation
*   **Vidéos Récompensées (Ads)** : Le joueur peut regarder une publicité pour gagner une vie supplémentaire (limité à 3 par jour) ou pour ajouter du temps (+3 min) après un Game Over.
*   **Achat "No Ads"** : Possibilité de supprimer les publicités forcées via un achat in-app.
*   **Boutique (Shop)** : Achat de packs de pièces de puzzle (puzzle pieces) pour débloquer des boosters.

## 8. Vision Future
*   Intégration d'un tableau de bord administrateur (Flutter Web) pour gérer les statistiques joueurs et la modération.
*   Introduction de nouveaux types de mini-jeux dans les futurs mondes.
