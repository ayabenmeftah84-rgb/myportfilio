import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Base SQLite locale : les donnees survivent a la fermeture de l'application.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  Future<Database> get db async {
    final existing = _db;
    if (existing != null) return existing;
    final opened = await _open();
    _db = opened;
    return opened;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'myportfolio.db');
    return openDatabase(path, version: 1, onCreate: (d, v) async {
      await d.execute('''CREATE TABLE student(
        id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, filiere TEXT,
        etablissement TEXT, bio TEXT, email TEXT, github TEXT)''');
      await d.execute('''CREATE TABLE skill(
        id INTEGER PRIMARY KEY AUTOINCREMENT, studentId INTEGER,
        name TEXT, level INTEGER)''');
      await d.execute('''CREATE TABLE project(
        id INTEGER PRIMARY KEY AUTOINCREMENT, studentId INTEGER,
        title TEXT, description TEXT, techs TEXT, link TEXT)''');
      await _seed(d);
    });
  }

  // Donnees initiales : portfolio d'Eya (CV) + un binome fictif.
  Future<void> _seed(Database d) async {
    final s1 = await d.insert(
        'student',
        const Student(
          name: 'Eya Benmefteh',
          filiere:
              'Licence 3ème année – Génie Logiciel et Systèmes d\'Information',
          etablissement: 'Institut International de Technologie de Sfax',
          bio:
              'Étudiante en génie logiciel et systèmes d\'information, avec des compétences pratiques en Python, Java, SQL, administration de bases de données et développement web (React, Node.js). Familière avec le Big Data (Hadoop, MapReduce, Hive, Spark) et l\'IoT. Auteure d\'un pipeline de qualité des données publié sur GitHub.',
          email: 'ayabenmeftah84@gmail.com',
          github: 'ayabenmeftah84-rgb',
        ).toMap()
          ..remove('id'));

    // Binôme FICTIF (exemple) : à remplacer par une vraie personne si besoin.
    final s2 = await d.insert(
        'student',
        const Student(
          name: 'Mariem Trabelsi',
          filiere:
              'Licence 3ème année – Génie Logiciel et Systèmes d\'Information',
          etablissement: 'Institut International de Technologie de Sfax',
          bio:
              'Étudiante en génie logiciel, passionnée par le développement d\'applications Java et mobiles et par la conception de bases de données.',
          email: 'mariem.trabelsi@example.com',
          github: 'octocat',
        ).toMap()
          ..remove('id'));
    for (final e in [
      Skill(studentId: s2, name: 'Java', level: 80),
      Skill(studentId: s2, name: 'Spring Boot', level: 65),
      Skill(studentId: s2, name: 'MySQL', level: 75),
      Skill(studentId: s2, name: 'Flutter / Dart', level: 55),
      Skill(studentId: s2, name: 'UML / Conception', level: 80),
    ]) {
      await d.insert('skill', e.toMap()..remove('id'));
    }
    for (final p in [
      Project(
          studentId: s2,
          title: 'Gestion de bibliothèque',
          description:
              'Application de gestion des livres, adhérents et emprunts avec base de données relationnelle.',
          techs: 'Java, MySQL',
          link: ''),
      Project(
          studentId: s2,
          title: 'Gestionnaire de tâches mobile',
          description:
              'Application mobile de suivi de tâches avec stockage local.',
          techs: 'Flutter, SQLite',
          link: ''),
    ]) {
      await d.insert('project', p.toMap()..remove('id'));
    }

    // Niveaux estimes : a ajuster selon votre propre evaluation.
    for (final e in [
      Skill(studentId: s1, name: 'Python', level: 85),
      Skill(studentId: s1, name: 'SQL / MySQL', level: 80),
      Skill(
          studentId: s1, name: 'Administration de bases de données', level: 70),
      Skill(studentId: s1, name: 'Java', level: 70),
      Skill(studentId: s1, name: 'Apache Spark (PySpark)', level: 65),
      Skill(studentId: s1, name: 'Hadoop / MapReduce / Hive', level: 60),
      Skill(
          studentId: s1,
          name: 'Great Expectations (qualité des données)',
          level: 65),
      Skill(studentId: s1, name: 'React / Vite / Node.js', level: 60),
      Skill(
          studentId: s1, name: 'Git / GitHub / GitHub Actions (CI)', level: 75),
      Skill(studentId: s1, name: 'Tests unitaires (Pytest)', level: 70),
      Skill(studentId: s1, name: 'Internet des Objets (IoT)', level: 50),
    ]) {
      await d.insert('skill', e.toMap()..remove('id'));
    }

    for (final p in [
      Project(
          studentId: s1,
          title: 'Data Quality Pipeline',
          description:
              'Pipeline reproductible de qualité des données (profilage, nettoyage, validation) sur 77 679 annonces parisiennes (Inside Airbnb), avec Spark en mode local. 18 règles de validation Great Expectations : 17 respectées après nettoyage contre 5 avant. 48 lignes aux valeurs extrêmes mises en quarantaine avec motif documenté, 12 colonnes vides supprimées, prix convertis en numérique. Expérience d\'injection d\'erreurs (9 types, 4 500 erreurs) : taux de détection de 82,2 %. Tests Pytest exécutés à chaque push via GitHub Actions.',
          techs:
              'Python, Apache Spark, Great Expectations, Pytest, GitHub Actions',
          link: 'https://github.com/ayabenmeftah84-rgb/data-quality-pipeline'),
      Project(
          studentId: s1,
          title: 'SkillUp',
          description:
              'Projet personnel publié sur GitHub. (Description à compléter : objectif, fonctionnalités, rôle.)',
          techs: 'À compléter',
          link: 'https://github.com/ayabenmeftah84-rgb/skillup'),
      Project(
          studentId: s1,
          title: 'Stage IoT – 9antra Bridge',
          description:
              'Stage de 2ème année (1 mois) : travail sur des concepts et solutions d\'Internet des Objets au sein d\'une équipe technique, application des connaissances en programmation et systèmes d\'information en contexte professionnel.',
          techs: 'IoT, Systèmes d\'information',
          link: ''),
      Project(
          studentId: s1,
          title: 'MyPortfolio',
          description:
              'Application mobile Flutter de portfolio étudiant : base locale SQLite, CRUD des compétences et projets, intégration de l\'API REST GitHub.',
          techs: 'Flutter, Dart, SQLite, REST API',
          link: 'https://github.com/ayabenmeftah84-rgb'),
    ]) {
      await d.insert('project', p.toMap()..remove('id'));
    }
  }

  // ---- Etudiants
  Future<List<Student>> students() async =>
      (await (await db).query('student', orderBy: 'id'))
          .map(Student.fromMap)
          .toList();

  Future<int> insertStudent(Student s) async =>
      (await db).insert('student', s.toMap()..remove('id'));

  /// Supprime l'etudiant ET ses competences et projets (transaction).
  Future<void> deleteStudent(int id) async {
    final d = await db;
    await d.transaction((t) async {
      await t.delete('skill', where: 'studentId = ?', whereArgs: [id]);
      await t.delete('project', where: 'studentId = ?', whereArgs: [id]);
      await t.delete('student', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> updateStudent(Student s) async => (await db)
      .update('student', s.toMap(), where: 'id = ?', whereArgs: [s.id]);

  // ---- Competences (CRUD)
  Future<List<Skill>> skills(int studentId) async =>
      (await (await db).query('skill',
              where: 'studentId = ?',
              whereArgs: [studentId],
              orderBy: 'level DESC'))
          .map(Skill.fromMap)
          .toList();

  Future<void> saveSkill(Skill s) async {
    final d = await db;
    if (s.id == null) {
      await d.insert('skill', s.toMap()..remove('id'));
    } else {
      await d.update('skill', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
    }
  }

  Future<void> deleteSkill(int id) async =>
      (await db).delete('skill', where: 'id = ?', whereArgs: [id]);

  // ---- Projets (CRUD)
  Future<List<Project>> projects(int studentId) async =>
      (await (await db).query('project',
              where: 'studentId = ?',
              whereArgs: [studentId],
              orderBy: 'id DESC'))
          .map(Project.fromMap)
          .toList();

  Future<void> saveProject(Project p) async {
    final d = await db;
    if (p.id == null) {
      await d.insert('project', p.toMap()..remove('id'));
    } else {
      await d.update('project', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
    }
  }

  Future<void> deleteProject(int id) async =>
      (await db).delete('project', where: 'id = ?', whereArgs: [id]);
}
