## 📝 Contexte
Cette PR apporte des optimisations majeures de performance pour supprimer les micro-freezes au lancement des niveaux et fluidifier l'expérience utilisateur globale.

## 💡 Changements apportés
- **Isolates pour la Génération** : Déplacement de l'algorithme de calcul du chemin (Hamiltonian Path) dans un Isolate séparé via `compute`. Cela libère le thread UI pendant le chargement des niveaux.
- **Pre-caching des Assets** : Mise en cache proactive de toutes les images et polices critiques durant l'écran de chargement initial. L'ouverture des niveaux et des dialogues est désormais instantanée.
- **Rendu Optimisé** : Utilisation de `RepaintBoundary` autour de la grille de jeu pour isoler le dessin du serpent et réduire la charge GPU.
- **Réactivité de Victoire** : 
    - Introduction d'un état `winning` permettant le déclenchement immédiat des confettis.
    - Parallélisation des écritures Supabase (`Future.wait`) pour supprimer le délai d'attente à la fin d'une partie.
- **Identité Visuelle** : Mise à jour de l'icône de l'application avec `logo_pas_finit.jpg`.
- **Qualité** : Correction du bug de progression en mode Histoire et mise à jour de la suite de tests.

## 🧪 Comment tester ?
1.  **Fluidité** : Lancez l'application et cliquez sur PLAY. La transition doit être parfaitement fluide sans saccade.
2.  **Victoire** : Terminez un niveau. La célébration doit commencer au moment précis où vous touchez la dernière case.
3.  **Logo** : Vérifiez que l'icône de l'app sur le téléphone est le nouveau logo.

## ⚠️ Rappel
Conformément aux règles du projet, la validation finale de cette PR DOIT se faire via un **Squash and merge**.
