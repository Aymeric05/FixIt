# Plan d'implémentation : Monétisation Intelligente et Intégration de Publicités

Mettre en place une stratégie publicitaire à haut revenu et haute rétention via Google AdMob, en privilégiant les publicités récompensées (Rewarded) et les interstitiels optimisés.

## Révision utilisateur requise

> [!IMPORTANT]
> **Limitation de fréquence (Capping)** : Pour garantir une bonne rétention des joueurs, je propose de ne jamais afficher d'interstitiel (pub plein écran forcée) plus d'une fois toutes les 3 minutes, et jamais avant que le joueur n'ait atteint le Niveau 5. Cela permet de laisser le joueur s'attacher au jeu avant de lui imposer des interruptions.

## Stratégie Publicitaire Proposée

### 1. Publicités Récompensées (Rewarded Ads)
*Le levier le plus rentable et le mieux accepté par les joueurs.*
- **Vie supplémentaire** : Si le joueur tombe à 0 vie, proposer "+1 vie gratuite" contre le visionnage d'une vidéo.
- **Indice gratuit** : Dans la grille de jeu, permettre d'obtenir un indice immédiat sans dépenser de jetons en regardant une pub.
- **Multiplicateur quotidien** : Doubler les récompenses du défi journalier en fin de niveau.

### 2. Publicités Interstitielles (Interstitial Ads)
*Revenu passif généré par les transitions.*
- **Fin de niveau** : Afficher une publicité uniquement après une victoire, tous les X niveaux (ex: tous les 3 niveaux), pour ne pas casser le rythme de réflexion.
- **Retour Accueil** : Une publicité lors du retour au menu principal après une longue session.

### 3. Publicités à l'ouverture (App Open Ads)
- S'affiche brièvement au démarrage (splash screen). Très efficace pour le revenu sans interrompre le gameplay actif.

---

## Changements Proposés

### 1. Infrastructure de base
#### [NOUVEAU] `lib/core/services/ad_service.dart`
- Création d'un service singleton pour initialiser AdMob.
- Gestion du préchargement (Pre-loading) en arrière-plan pour un affichage instantané.
- Intégration du statut "No Ads" (achat In-App) pour désactiver les pubs automatiques.

### 2. Intégration dans les Blocs
#### [MODIFIER] `lib/features/home/presentation/bloc/home_bloc.dart`
- Ajout de la logique pour appeler `AdService.showRewardedAd()` lors de la demande de vies.
#### [MODIFIER] `lib/features/game/presentation/bloc/game_bloc.dart`
- Ajout de la logique pour récompenser le joueur avec un indice après une pub.

### 3. Logique d'affichage UI
#### [MODIFIER] `lib/features/game/presentation/pages/game_page.dart`
- Dans le dialogue de victoire, déclencher une vérification d'interstitiel avant de passer au niveau suivant.

### 4. Désactivation des publicités
#### [MODIFIER] `lib/features/home/presentation/widgets/no_ads_dialog.dart`
- Relier le bouton d'achat "No Ads" au service publicitaire pour supprimer définitivement les interstitiels et App Open ads.

## Plan de vérification

### Vérification Manuelle
1. **Vie Récompensée** : Passer à 0 vie, cliquer sur "Vidéo", vérifier que la vie est ajoutée UNIQUEMENT si la vidéo est vue jusqu'au bout.
2. **Respect des fréquences** : Enchaîner 3 niveaux et vérifier que l'interstitiel ne s'affiche qu'à l'intervalle prévu.
3. **Achat "No Ads"** : Simuler un achat et vérifier que seules les pubs récompensées (au choix du joueur) restent actives.
