# Game Project Context & Requirements

## 1. Vue d'ensemble du Projet
Ce projet est un jeu mobile de type puzzle/casse-tête (inspiré du modèle de progression de Candy Crush). Il est développé avec **Flutter** et **Dart**, avec pour objectif un déploiement multiplateforme sur le **Google Play Store** et l'**Apple App Store**.

L'application intègre des mécaniques de progression par niveaux, un système de vies limité dans le temps, des fonctionnalités sociales (amis et classements quotidiens) et une monétisation hybride.

## 2. Stack Technique Globale
*   **Frontend :** Flutter / Dart
*   **Gestionnaire d'état :** BLoC (Business Logic Component). Utilisé pour séparer strictement l'interface (UI) de la logique métier, fonctionnant de manière similaire à un pattern MVVM (le BLoC agissant comme le ViewModel).
*   **Backend & Base de données :** Supabase (PostgreSQL, Auth, Edge Functions). Les règles de sécurité (RLS) et les triggers SQL seront utilisés pour sécuriser les données.
*   **Stockage Local :** Isar Database (très performant pour mettre en cache la progression, l'état des vies et les paramètres hors-ligne).
*   **Monétisation (Ads) :** Google Mobile Ads (AdMob) intégré en standalone, sans dépendance à Firebase.
*   **Monétisation (IAP) :** RevenueCat pour la gestion sécurisée et unifiée des achats in-app (indices, skip de niveaux).

## 3. Interface Utilisateur (UI) - Écran d'Accueil
L'écran principal (Home Screen) est le hub central du joueur. Sa disposition est la suivante :
*   **En haut à gauche :** Icône de profil ouvrant une modale avec le pseudo du joueur, ses statistiques et la gestion de ses amis.
*   **En haut au centre :** Indicateur de vies (ex: ❤️ 3/5) avec un compte à rebours si les vies sont en cours de rechargement.
*   **En haut à droite :** Bouton Paramètres (engrenage).
*   **En bas au centre :** Bouton d'action principal "JOUER", affichant le niveau actuel (ex: "Niveau 201") et sa difficulté (Facile, Medium, Difficile).

## 4. Mécaniques de Jeu Core
### 4.1. Système de Vies et Timer
*   Chaque niveau est chronométré.
*   **Échec :** Si le temps est écoulé, le joueur perd une vie et doit recommencer.
*   **Blocage :** Si le compteur de vies atteint 0, l'accès aux niveaux est bloqué jusqu'à la recharge ou l'achat de vies.
*   **Sécurité :** La validation finale du timer et de la recharge des vies doit être vérifiée via le serveur (Supabase) pour empêcher la triche liée à l'horloge locale.

### 4.2. Aides et Indices
*   Le joueur possède un stock d'indices (hints).
*   **Acquisition :** Achat via argent réel (RevenueCat) ou visionnage d'une publicité récompensée (AdMob).
*   Possibilité de passer un niveau (skip) contre de l'argent réel.

## 5. Modes de Jeu
### 5.1. Mode Histoire (Progression principale)
*   La progression est divisée en **Mondes**. 1 Monde = 1 type de mini-jeu spécifique.
*   **Monde 1 :** Mini-jeu "Zip". La grille de départ est petite et s'agrandit tous les 100 niveaux, modifiant le level design.
*   **Génération de la difficulté :** Majorité de niveaux standards, un pourcentage de "Medium" et un très faible pourcentage de "Difficile".

### 5.2. Mode Défi Quotidien (Social)
*   Un "Jeu du jour" est généré quotidiennement pour chaque Monde débloqué.
*   Le niveau est strictement identique pour tous les joueurs le même jour.
*   **Classement :** Un leaderboard compare le temps de résolution du joueur avec celui de ses amis.

## 6. Architecture & Logique de Développement
### 6.1. L'Interface Abstraite (Évolutivité)
Pour garantir l'évolutivité vers de futurs mondes, l'architecture doit être découplée. Une classe de base abstraite (ex: `MinigameEngine` ou un `MinigameBloc` générique) définira les contrats communs : `initializeGame()`, `useHint()`, `triggerTimeout()`, `onWin()`.
Le gestionnaire de campagne ne doit jamais connaître les règles spécifiques du jeu "Zip" ou des futurs mondes.

### 6.2. Génération Procédurale vs Niveaux Codés en Dur
Au lieu de stocker des milliers de niveaux en base de données, la structure des niveaux est générée de manière procédurale (en s'appuyant sur des algorithmes de théorie des graphes et de résolution de contraintes).
*   Chaque niveau est généré à partir d'une *seed* (graine) mathématique et d'un paramètre de taille/difficulté.
*   Pour le défi quotidien, la *seed* est simplement la date du jour (ex: `20260821`), garantissant que tous les joueurs affrontent exactement la même grille.

### 6.3. Gestion du Temps Imparti (Performances)
Le compte à rebours de chaque niveau doit être géré avec les `Tickers` natifs de Flutter (via `TickerProviderStateMixin`) ou un Stream dédié, plutôt que via des `setState` globaux. Cela permet de rafraîchir uniquement le widget du chronomètre à 60 fps sans forcer la reconstruction de la grille entière du jeu.

## 7. Instructions pour l'IA Développeur
1.  **Feature-First :** Organiser le projet par fonctionnalités (`/features/auth`, `/features/social`, `/features/gameplay`) pour maintenir un code propre.
2.  **State Management :** Utiliser BLoC de manière stricte pour isoler toute la logique métier des widgets.
3.  **Validation Serveur :** Prévoir des Edge Functions sur Supabase pour la validation des scores quotidiens et l'attribution/décrémentation des vies.