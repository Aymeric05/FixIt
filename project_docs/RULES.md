# Project Rules (Règles du Projet)

Ce fichier définit les règles strictes que l'IA doit suivre lors de chaque interaction sur ce projet.

## 1. Règle d'Or (Session Initiation)
> [!IMPORTANT]
> **Règle n°1 :** Au début de chaque nouvelle session ou tâche, tu DOIS impérativement lire tous les fichiers contenus dans le dossier `project_docs/` pour te rafraîchir la mémoire sur le contexte, les règles et les objectifs du projet.

## 2. Développement et Qualité
*   **Tests Systématiques :** Pour chaque nouvelle fonctionnalité (feature) ou correctif important implémenté, tu DOIS écrire les tests correspondants (unitaires, bloc ou widget) dans le dossier `test/`. Aucune feature n'est considérée comme terminée sans ses tests.
*   **Mise à jour du Contexte :** Lors du développement d'une nouvelle fonctionnalité, tu DOIS systématiquement mettre à jour le fichier `project_docs/PROJECT_CONTEXT.md` pour y inclure les détails de la nouvelle feature tout en conservant l'historique des fonctionnalités existantes.
*   **Analyse Statique :** Avant de considérer une tâche comme terminée, exécute toujours `flutter analyze` et corrige tous les avertissements.
*   **Logs :** Interdiction d'utiliser `print()`. Utilise systématiquement la classe utilitaire `AppLogger`.

## 3. Langues et Conventions
*   **Application :** L'intégralité de l'UI, des commentaires de code, des assets et de la documentation technique interne doit être en **Anglais**.
*   **Git / GitHub :** Toutes les interactions (messages de commit, titres et descriptions de Pull Requests) doivent être rédigées en **Français**.
*   **Formatage PR :** Interdiction d'envoyer des descriptions de PR via des chaînes de caractères complexes en ligne de commande. Utilise systématiquement un fichier temporaire et l'option `--body-file` pour garantir un rendu Markdown parfait sur GitHub.
*   **Commits :** Respecte la convention *Conventional Commits* (`type(scope): description`).

## 4. Stack Technique & Architecture
*   **State Management :** Utilisation exclusive de **BLoC**. Séparation stricte entre la couche présentation et la logique métier.
*   **Stockage :** Approche "Offline-First" avec **Drift** (SQLite local). Synchronisation avec **Supabase**.
*   **Sécurité :** Les clés API et secrets ne doivent jamais être en dur dans le code. Utilise `String.fromEnvironment` et le fichier `env.json`.

## 5. Interface Utilisateur (UI)
*   **Notifications :** Toutes les notifications in-game doivent apparaître en haut de l'écran et être sur la couche la plus haute (Overlay).
*   **Couleurs :** Utilise les extensions de `AppColors` et préfère `withValues(alpha: ...)` à `withOpacity()`.

## 6. Logique Métier
*   **Vies :** Le système de recharge de vies doit être validé côté serveur.
*   **Progression :** Système anti-downgrade. La progression ne peut qu'augmenter.
