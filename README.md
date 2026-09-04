# FixIt - Puzzle Quest

FixIt est un jeu de puzzle mobile inspiré par le modèle de progression de type "Candy Crush", développé avec **Flutter** et **Dart**.

## 🌟 Présentation du projet
L'objectif est d'offrir une expérience de jeu fluide et multiplateforme (Android & iOS). Le jeu intègre des mécaniques de progression par niveaux, un système de vies limité dans le temps, des fonctionnalités sociales (amis et classements quotidiens) et une monétisation hybride.

> [!IMPORTANT]
> L'intégralité de l'application (UI, documentation du code, assets) est en **Anglais**. Cependant, la gestion du projet Git/GitHub (commits, PRs) se fait en **Français**.

## 🛠️ Stack Technique
*   **Frontend :** Flutter / Dart
*   **Gestion d'état :** BLoC (Business Logic Component) pour une séparation stricte entre l'UI et la logique métier.
*   **Backend & Base de données :** Supabase (PostgreSQL, Auth, Realtime).
*   **Stockage local :** Drift (SQLite) pour une approche "Offline-First".
*   **Publicité :** Google Mobile Ads (AdMob).
*   **Achats In-App :** RevenueCat.

## 🏗️ Architecture
Le projet suit une architecture modulaire découpée par fonctionnalités (`features/`). Chaque module est généralement structuré ainsi :
*   `data/` : Modèles et sources de données.
*   `domain/` : Logique métier pure (Repositories).
*   `presentation/` : UI (Widgets) et gestion d'état (BLoC).

## 🚀 Installation et Démarrage
1.  S'assurer d'avoir le SDK Flutter installé (`flutter doctor`).
2.  Cloner le dépôt.
3.  Installer les dépendances :
    ```bash
    flutter pub get
    ```
4.  Générer le code nécessaire (Drift/Equatable) :
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
5.  Lancer l'application :
    ```bash
    flutter run
    ```

## 📜 Règles de Contribution
Veuillez vous référer au fichier [GITHUB_RULES.md](GITHUB_RULES.md) pour les conventions de nommage des branches, des commits et la gestion des Pull Requests.
