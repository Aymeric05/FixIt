## 📝 Contexte
Cette PR introduit la persistance des sessions de jeu. Désormais, si un joueur quitte l'application ou revient au menu principal en cours de partie, son avancement (temps restant et tracé du serpent) est sauvegardé localement. Cela permet de reprendre la partie exactement là où elle s'était arrêtée.

## 💡 Changements apportés
- **Base de données** : Ajout de la table `ActiveGameStates` dans Drift et migration vers la version 6.
- **Repository** : Création du `GameSessionRepository` pour gérer le cycle de vie des sauvegardes de session (save, load, delete).
- **Logique Métier (BLoC)** : 
    - Chargement automatique d'une session existante lors du démarrage d'un niveau.
    - Sauvegarde automatique à chaque mouvement du serpent et toutes les 5 secondes (timer).
    - Suppression de la session lors d'une victoire, d'un game over ou d'une réinitialisation.
- **Tests** : Ajout d'un test de régression validant la restauration correcte du temps et du tracé.
- **Documentation** : Mise à jour du `PROJECT_CONTEXT.md` avec la section "Sauvegarde de Session".

## 🧪 Comment tester ?
1. **Reprise de partie** : Lancez un niveau, commencez à tracer le serpent, attendez quelques secondes, puis fermez l'application (ou tuez le processus). Relancez le même niveau : vous devez retrouver votre tracé et votre temps.
2. **Nettoyage** : Gagnez le niveau, revenez au menu et relancez-le : la partie doit recommencer de zéro.
3. **Tests automatisés** : Exécutez `flutter test` pour vérifier la non-régression.

## ⚠️ Rappel
Conformément aux règles du projet, la validation finale de cette PR DOIT se faire via un **Squash and merge**.
