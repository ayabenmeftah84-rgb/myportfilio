# MyPortfolio (Flutter)

Application mobile de portfolio étudiant — Projet Développement Mobile.
Auteure : Eya Benmefteh (Licence 3ème année Génie Logiciel et Systèmes d'Information, Institut International de Technologie de Sfax).

## Fonctionnalités

- **Portfolios multiples** : création et suppression d'un portfolio depuis l'accueil (la suppression efface aussi ses compétences et ses projets).
- **Profil** : informations personnelles et académiques, modification, liens email et GitHub cliquables.
- **Compétences** : ajout, modification, suppression, niveau en pourcentage.
- **Projets** : ajout, modification, suppression, détail, formulaire validé, recherche par titre, description ou technologie.
- **GitHub (API REST)** : liste des dépôts d'un pseudo, gestion du chargement et des erreurs, import d'un dépôt comme projet.
- **Qualité** : contrôle de la qualité des données du portfolio avec 15 règles de validation et un score en pourcentage (démarche inspirée du projet Data Quality Pipeline).
- **Export PDF** du portfolio (aperçu, impression, partage).
- **Mode clair / sombre** manuel.
- **Persistance** : base SQLite locale, données conservées après fermeture de l'application.

## Structure du code

```
lib/
  main.dart                 point d'entrée, thème
  theme_controller.dart     bascule clair / sombre
  models/models.dart        Student, Skill, Project
  db/database.dart          SQLite : création des tables, CRUD
  services/
    github_service.dart     appel REST à l'API GitHub
    pdf_service.dart        export PDF
  screens/
    home_screen.dart        accueil (liste des portfolios)
    student_form.dart       formulaire de nouveau portfolio
    portfolio_screen.dart   conteneur des 5 onglets
    profile_tab.dart        onglet Profil
    skills_tab.dart         onglet Compétences
    projects_tab.dart       onglet Projets (+ project_detail, project_form)
    github_tab.dart         onglet GitHub
    quality_tab.dart        onglet Qualité (score et règles)
    widgets.dart            boîte de confirmation, messages
```

## Base de données (SQLite)

```
student(id, name, filiere, etablissement, bio, email, github)
skill(id, studentId, name, level)
project(id, studentId, title, description, techs, link)
```

Les tables sont créées automatiquement au premier lancement, avec des données de départ.
Si vous modifiez ces données de départ, désinstallez l'application (ou effacez ses données) avant de relancer.

## Installation

1. Installer Flutter, Android Studio (SDK Android) et VS Code avec l'extension Flutter.
2. `flutter create --org com.myportfolio myportfolio`
3. Remplacer le dossier `lib/` et le fichier `pubspec.yaml` par ceux de cette archive.
4. Supprimer `test/widget_test.dart`.
5. Android : dans `android/app/src/main/AndroidManifest.xml`, avant `<application>`, ajouter :

   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <queries>
     <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
     <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="mailto"/></intent>
   </queries>
   ```
6. `flutter pub get`
7. Lancer sur un appareil ou émulateur **Android** : `flutter run`
   (SQLite ne fonctionne pas sur Chrome ni sur Windows.)

## Dépendances

`sqflite`, `path`, `http`, `url_launcher`, `pdf`, `printing`.

## Limites connues

- Pas de tests automatisés (scénario de démonstration testé manuellement).
- Le choix clair / sombre n'est pas conservé après la fermeture de l'application.
- Le portfolio de binôme fourni (Mariem Trabelsi) est fictif.