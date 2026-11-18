# MyPortfolio
 
Application mobile Flutter pour créer et gérer son portfolio : profil, compétences et projets, avec import de dépôts depuis GitHub et export en PDF.
 
<!-- Ajoutez 2 ou 3 captures d'écran dans un dossier screenshots/ puis décommentez :
| Accueil | Projets | Mode sombre |
|---|---|---|
| ![Accueil](screenshots/home.png) | ![Projets](screenshots/projects.png) | ![Sombre](screenshots/dark.png) |
-->
 
## Fonctionnalités
 
- Deux portfolios distincts
- Profil modifiable
- Gestion complète (ajout, modification, suppression) des compétences et des projets
- Base de données locale **SQLite**
- Import de dépôts via l'**API REST GitHub**
- Recherche de projets
- Mode clair / sombre
- Export du portfolio en **PDF**
## Technologies
 
- Flutter / Dart
- SQLite (stockage local)
- API REST GitHub
- `url_launcher` pour l'ouverture des liens
- Testé sur l'émulateur Android Pixel 7
## Prérequis
 
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio ou VS Code (extensions Flutter et Dart)
- Un émulateur Android ou un téléphone en mode développeur
## Installation
 
```bash
git clone https://github.com/ayabenmeftah84-rgb/myportfilio.git
cd myportfilio
flutter pub get
flutter run
```
 
> Si vous aviez déjà lancé l'application : désinstallez-la (ou effacez ses données) pour recharger les données de départ.
 
## Configuration Android
 
Les deux réglages suivants sont déjà nécessaires dans `android/app/src/main/AndroidManifest.xml`. Vérifiez-les si vous recréez le projet :
 
Avant la balise `<application>` :
 
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
 
Dans la balise `<manifest>` (pour `url_launcher`) :
 
```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https"/>
  </intent>
</queries>
```
 
## Structure du projet
 
```
myportfolio/
├── lib/            # Code source Dart
├── android/        # Configuration Android
├── pubspec.yaml    # Dépendances
└── README.md
```
 
## Auteur
 
**Eya Benmefteh**
GitHub : [@ayabenmeftah84-rgb](https://github.com/ayabenmeftah84-rgb)
 