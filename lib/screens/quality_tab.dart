import 'package:flutter/material.dart';

import '../db/database.dart';
import '../models/models.dart';

/// Une regle de validation (inspiree de Great Expectations).
class _Rule {
  final String label;
  final bool ok;
  final String detail;
  const _Rule(this.label, this.ok, [this.detail = '']);
}

/// Onglet "Qualite" : controle la qualite des donnees du portfolio
/// avec des regles de validation et calcule un score.
class QualityTab extends StatefulWidget {
  final int studentId;
  final bool active; // vrai quand l'onglet est affiche (pour recalculer)
  const QualityTab({super.key, required this.studentId, required this.active});
  @override
  State<QualityTab> createState() => _QualityTabState();
}

class _QualityTabState extends State<QualityTab> {
  List<_Rule> rules = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(QualityTab old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _load();
  }

  Future<void> _load() async {
    final db = AppDatabase.instance;
    final s = (await db.students()).firstWhere((e) => e.id == widget.studentId);
    final skills = await db.skills(widget.studentId);
    final projects = await db.projects(widget.studentId);
    final r = _evaluate(s, skills, projects);
    if (mounted) {
      setState(() {
        rules = r;
        loading = false;
      });
    }
  }

  List<_Rule> _evaluate(Student s, List<Skill> skills, List<Project> projects) {
    bool filled(String v) => v.trim().isNotEmpty;
    final emailOk =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s.email.trim());

    final skillNames = skills.map((e) => e.name.trim().toLowerCase()).toList();
    final dupSkills = skillNames.length != skillNames.toSet().length;
    final titles = projects.map((e) => e.title.trim().toLowerCase()).toList();
    final dupTitles = titles.length != titles.toSet().length;

    List<String> badProjects(bool Function(Project) valid) =>
        projects.where((p) => !valid(p)).map((p) => p.title).toList();
    final noDesc = badProjects((p) => p.description.trim().length >= 30);
    final noTech = badProjects((p) => filled(p.techs));
    final noLink = badProjects((p) => p.link.trim().startsWith('http'));

    // Champs encore a l'etat de modele
    const marker = 'à compléter';
    final placeholders = <String>[
      if ([s.filiere, s.etablissement, s.bio, s.email]
          .any((v) => v.toLowerCase().contains(marker)))
        'profil',
      ...skills
          .where((k) => k.name.toLowerCase().contains(marker))
          .map((k) => k.name),
      ...projects
          .where((p) => '${p.title} ${p.description} ${p.techs}'
              .toLowerCase()
              .contains(marker))
          .map((p) => p.title),
    ];

    return [
      _Rule('Nom renseigné', filled(s.name)),
      _Rule('Filière renseignée', filled(s.filiere)),
      _Rule('Établissement renseigné', filled(s.etablissement)),
      _Rule('Bio d\'au moins 80 caractères', s.bio.trim().length >= 80,
          '${s.bio.trim().length} caractères'),
      _Rule('Email valide', emailOk, 'Format attendu : nom@domaine.com'),
      _Rule('Pseudo GitHub renseigné', filled(s.github)),
      _Rule('Aucun champ « À compléter »', placeholders.isEmpty,
          'À remplir : ${placeholders.join(', ')}'),
      _Rule('Au moins 5 compétences', skills.length >= 5,
          '${skills.length} compétence(s)'),
      _Rule('Aucune compétence en double', !dupSkills),
      _Rule('Aucun niveau à 100 %', skills.every((k) => k.level < 100),
          'Un niveau parfait est peu crédible'),
      _Rule('Au moins 3 projets', projects.length >= 3,
          '${projects.length} projet(s)'),
      _Rule('Aucun titre de projet en double', !dupTitles),
      _Rule('Description de 30 caractères minimum par projet', noDesc.isEmpty,
          'À corriger : ${noDesc.join(', ')}'),
      _Rule('Technologies renseignées pour chaque projet', noTech.isEmpty,
          'À corriger : ${noTech.join(', ')}'),
      _Rule('Lien valide (http) pour chaque projet', noLink.isEmpty,
          'À corriger : ${noLink.join(', ')}'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final passed = rules.where((r) => r.ok).length;
    final total = rules.length;
    final score = total == 0 ? 0 : (passed * 100 / total).round();
    final verdict =
        score >= 90 ? 'Excellent' : (score >= 70 ? 'Bon' : 'À améliorer');
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                        value: score / 100, strokeWidth: 10),
                  ),
                  Text('$score %',
                      style: Theme.of(context).textTheme.headlineMedium),
                ]),
              ),
              const SizedBox(height: 12),
              Text(verdict,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: scheme.primary)),
              Text('$passed règles sur $total respectées'),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text('Contrôle de la qualité des données',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        ...rules.map((r) => Card(
              child: ListTile(
                leading: Icon(r.ok ? Icons.check_circle : Icons.cancel,
                    color: r.ok ? Colors.green : Colors.red),
                title: Text(r.label),
                subtitle:
                    (!r.ok && r.detail.isNotEmpty) ? Text(r.detail) : null,
              ),
            )),
      ],
    );
  }
}
