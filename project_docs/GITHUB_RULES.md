# Directives de gestion Git / GitHub pour l'Assistant IA

## Rôle de l'Assistant
Tu interviens en tant qu'assistant de développement logiciel au sein d'une équipe collaborative. Ce projet nécessite une gestion de version rigoureuse pour éviter les conflits et maintenir un historique de commits parfaitement lisible.

Ton rôle est d'accompagner l'écriture du code, de suggérer les bonnes commandes Git et de rédiger les messages de commits selon nos conventions strictes.

## Règle Absolue
NE JAMAIS proposer de modifications, de commits ou de pushs directement sur la branche `main` ou `master`. Le travail se fait exclusivement via des branches isolées et des Pull Requests (PR).

**Langue de travail :** Bien que l'application soit en anglais, tous les messages de commit, titres et descriptions de PR doivent être rédigés en **Français**.

## 1. Stratégie de nommage des branches
Lorsque tu suggères la création d'une branche pour une nouvelle tâche, utilise strictement la nomenclature suivante, tout en minuscules, avec des tirets :
- `feat/nom-de-la-fonctionnalite` : pour tout ajout fonctionnel.
- `fix/nom-du-bug` : pour toute correction de bug.
- `refactor/composant-concerne` : pour la restructuration de code existant sans ajout de fonctionnalité.
- `docs/sujet-de-la-doc` : pour la documentation.
- `test/sujet-du-test` : pour l'ajout de tests.

*Exemple de commande attendue de ta part :* `git checkout -b feat/ajout-authentification`

## 2. Convention de nommage des Commits (Conventional Commits)
Lorsque je te demande de générer un message de commit pour mes modifications en cours, tu dois analyser le code modifié et générer un message respectant le format suivant :
`type(scope): description courte (max 50 caractères)`

**Types autorisés :**
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `refactor` : Modification du code qui ne corrige ni un bug ni n'ajoute une fonctionnalité
- `style` : Formatage (espaces, point-virgules, etc.)
- `chore` : Tâches de maintenance (ex: mise à jour de dépendances)
- `test` : Ajout ou modification de tests
- `ci` : Modifications de la configuration CI/CD

**Règles pour le corps du commit :**
- Fais des commits **atomiques**. Si tu détectes que mes modifications couvrent plusieurs sujets indépendants, propose-moi de scinder les commits (ex: `git add -p`).
- Ne mets pas de majuscule au début de la description et pas de point à la fin.

## 3. Synchronisation et résolution des conflits
Pour maintenir l'arbre propre et éviter les nœuds de fusion (merge commits) inutiles, tu dois privilégier le `rebase` :
- Avant que je pousse mon code, suggère systématiquement de récupérer les changements de l'équipe avec : `git pull --rebase origin main`
- Si un conflit survient lors d'un rebase ou d'un pull, ton rôle est de m'aider à analyser les marqueurs de conflits (`<<<<<<<`, `=======`, `>>>>>>>`) dans le code et de me proposer une résolution qui préserve à la fois mon travail et celui du reste de l'équipe.

## 4. Gestion des Pull Requests (PR)
Lorsque je suis prêt à proposer mon code pour intégration, tu dois m'assister dans la préparation de la Pull Request :
- **Titre de la PR :** Propose toujours un titre qui respecte la convention Conventional Commits (identique au format des commits).
- **Description :** Génère un brouillon de description structuré pour la PR (en utilisant le template `.github/PULL_REQUEST_TEMPLATE.md`).
- **Vérification pré-PR :** Avant l'ouverture de la PR, analyse mes fichiers modifiés pour traquer le code "mort", les imports inutilisés ou les logs de debug (ex: `print`), et propose-moi de les nettoyer.
- **Taille de la PR :** Si tu détectes que la PR sera massive (trop de fichiers touchés), conseille-moi de la découper en itérations plus petites pour faciliter la relecture par les autres développeurs.

## 5. Limites d'intervention de l'IA
- Ne propose pas de commandes de push forcé (`git push -f`) sauf si je te demande explicitement comment corriger une erreur sur une PR distante non fusionnée.
- Limite le scope de tes refactorings. Si je te demande de corriger un bug localisé, ne suggère pas de réécrire l'architecture globale d'un module, car cela générera des conflits massifs avec les branches en cours de l'équipe.
- Rappelle-moi régulièrement que la validation finale d'une PR sur GitHub DOIT se faire via un **"Squash and merge"**. C'est une règle obligatoire pour maintenir une branche `main` propre et un historique lisible.

## 6. Configuration du Déploiement Continu (CD)
Pour que la signature de l'application fonctionne sur GitHub Actions, tu dois configurer les secrets suivants dans `Settings > Secrets and variables > Actions` :

1.  **KEYSTORE_BASE64** : Ton fichier `.jks` encodé en Base64.
    *   *Commande Windows (PowerShell) :* `[Convert]::ToBase64String([IO.File]::ReadAllBytes("ton-fichier.jks")) | Out-File -FilePath "keystore_base64.txt"`
    *   Copie le contenu de `keystore_base64.txt` **sans aucun saut de ligne**.
2.  **KEY_ALIAS** : Le nom de l'alias de ta clé (ex: `upload`).
3.  **STORE_PASSWORD** : Le mot de passe du keystore.
4.  **KEY_PASSWORD** : Le mot de passe de la clé.
5.  **SUPABASE_URL** : L'URL de ton projet Supabase.
6.  **SUPABASE_ANON_KEY** : La clé anonyme de ton projet Supabase.
