# StoryFeature

StoryFeature est une application iOS développée en Swift et SwiftUI qui implémente une fonctionnalité de type "Stories" inspirée d'Instagram. L’objectif est de démontrer la qualité du code, une architecture modulaire et scalable, ainsi qu’une gestion efficace des états (stories “vu” et “liké”) et de la persistance en 4 heures.

## Table des Matières

- [Architecture & Organisation](#architecture--organisation)
- [Modèles & Persistance](#modèles--persistance)
- [Services & Chargement d’Images](#services--chargementdimages)
- [Navigation & Interactions](#navigation--interactions)
- [Gestion des États "Vu" & "Liké"](#gestion-des-états-vu--liké)
- [Améliorations Possibles](#améliorations-possibles)
- [Instructions de Lancement](#instructions-de-lancement)
- [Assomptions et Limitations](#assomptions-et-limitations)

## Architecture & Organisation

Le projet est structuré de manière modulaire pour séparer les responsabilités et faciliter la maintenance :

- **Modèles**  
  - **Entities** (ex. `UserEntity`) sont utilisées pour la persistance avec SwiftData.
  - **DTOs** (ex. `UserDTO`, `PaginatedUsers`) servent uniquement au décodage du JSON.

- **Services**  
  - `JSONUserService` charge les utilisateurs depuis un fichier JSON.
  - Un service dédié de chargement d’images, via le protocole `ImageLoaderServiceProtocol` et son implémentation `DefaultImageLoaderService`, gère le téléchargement et le cache des images.

- **ViewModels**  
  - **UserViewModel** gère la pagination des utilisateurs ainsi que la persistance des états “vu” et “liké” (via UserDefaults).
  - Un ViewModel dédié pour la navigation des stories (par exemple, `StoryFlowViewModel`) doit idéalement être créé pour séparer la logique de navigation de l’affichage.
    
- **Vues**  
  - `UsersListView` affiche la liste des profils horizontalement et ouvre en full screen le flow de stories.
  - `StoryFlowFullScreenView` affiche en plein écran les stories d’un profil, gère la navigation (taps et swipes), la barre de progression et le bouton "like" animé.
  - Des composants réutilisables, comme `CachedAsyncImage` et `ProfileItemView`, sont utilisés pour un affichage cohérent.

## Modèles & Persistance

- **SwiftData & Entities**  
  - `UserEntity` est l’entité utilisée pour la persistance des utilisateurs.
  - Les DTO (ex. `UserDTO`) servent uniquement à décoder le JSON fourni.

- **Persistance des États "Vu" et "Liké"**  
  - Les états “vu” et “liké” sont gérés dans `UserViewModel` et persistés via UserDefaults, ce qui permet de conserver ces états entre les sessions.

## Services & Chargement d’Images

- **ImageLoaderService**  
  Un service dédié (`DefaultImageLoaderService`) implémente le protocole `ImageLoaderServiceProtocol` et se charge de :
  - Vérifier le cache via `ImageCacheProtocol` (implémenté par `DiskImageCache`).
  - Télécharger l’image via URLSession si elle n’est pas en cache.
  - Sauvegarder l’image téléchargée pour améliorer les performances.

- **Avantages** :  
  - Séparation claire de la logique de téléchargement et de cache.
  - Réutilisabilité et testabilité accrues.

## Navigation & Interactions

- **UsersListView**  
  - Affiche les profils horizontalement avec une bordure indiquant l’état des stories (bleu pour des stories non vues, gris clair sinon).
  - Au tap sur un profil, un fullScreenCover ouvre le flow de stories pour ce profil.

- **StoryFlowFullScreenView**  
  - Affiche les stories (photos et vidéos) du profil sélectionné en plein écran.
  - Navigation par taps sur les zones gauche/droite et swipes horizontaux (pour changer de profil) et verticaux (pour fermer la vue).
  - Intègre une barre de progression animée ainsi qu’un header affichant le nom et l’image du profil.
  - Bouton "like" animé en bas au centre, permettant de liker/déliker une story.

## Gestion des États "Vu" & "Liké"

- **Marquage "vu"**  
  - Lorsque l’utilisateur passe d’une story à la suivante, l’ID de la story est ajouté à un set `seenStoryIDs` dans `UserViewModel`.
  - Ce set est utilisé dans `UsersListView` pour déterminer la couleur de la bordure autour du profil.

- **Marquage "liké"**  
  - Le bouton "like" déclenche la fonction `toggleLike(storyID:)` dans `UserViewModel`, qui bascule l’état et persiste l’information via UserDefaults.

## Améliorations Possibles

- **Découpage de la vue de stories**  
  - Une refactorisation plus poussée, en déplaçant davantage la logique dans un ViewModel dédié (par exemple, `StoryFlowViewModel`), améliorerait la maintenabilité.
  
- **Persistance plus robuste**  
  - Remplacer la persistance via UserDefaults par SwiftData pour centraliser la gestion des états.
  
- **Optimisation du cache d’images**  
  - Améliorer la gestion de la taille du cache et l’expiration des images.

## Instructions de Lancement

1. **Prérequis**  
   - Xcode 15 ou ultérieur  
   - iOS 17 ou ultérieur

2. **Installation**  
   - Clonez le repository  
   - Ouvrez le projet dans Xcode

3. **Exécution**  
   - Lancez l’application sur un simulateur ou un appareil réel  
   - Parcourez la liste des profils dans `UsersListView`  
   - Touchez un profil pour ouvrir le flow de stories en plein écran  
   - Testez la navigation entre stories et profils ainsi que les actions "like/unlike"  
   - Vérifiez la persistance des états "vu" et "liké" en redémarrant l’application

## Assomptions et Limitations

- **Sources de données**  
  - Les utilisateurs sont chargés via un fichier JSON de référence.  
  - Les stories sont définies de manière statique dans le code pour ce test technique.

- **Persistance**  
  - La persistance des états "vu" et "liké" est réalisée via UserDefaults. Pour une application de production, une solution plus robuste serait recommandée.

- **Découpage du Flow de Stories**  
  - En raison des contraintes de temps, la logique de navigation dans le flow de stories est partiellement intégrée dans la vue `StoryFlowFullScreenView`. Un découpage plus poussé dans un ViewModel dédié (par exemple, `StoryFlowViewModel`) améliorerait la séparation des responsabilités.

---
