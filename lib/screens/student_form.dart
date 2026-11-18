import 'package:flutter/material.dart';

import '../models/models.dart';

/// Dialogue de creation d'un portfolio (etudiant). Retourne null si annule.
Future<Student?> showStudentForm(BuildContext context) {
  final name = TextEditingController();
  final filiere = TextEditingController();
  final etab = TextEditingController();
  final bio = TextEditingController();
  final email = TextEditingController();
  final github = TextEditingController();
  final key = GlobalKey<FormState>();

  Widget field(String label, TextEditingController c,
          {int lines = 1, bool required = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          maxLines: lines,
          decoration: InputDecoration(
              labelText: required ? '$label *' : label,
              border: const OutlineInputBorder()),
          validator: required
              ? (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null
              : null,
        ),
      );

  return showDialog<Student>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Nouveau portfolio'),
      content: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(children: [
            field('Nom complet', name, required: true),
            field('Filière / Niveau', filiere),
            field('Établissement', etab),
            field('Bio', bio, lines: 3),
            field('Email', email),
            field('Pseudo GitHub', github),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c), child: const Text('Annuler')),
        FilledButton(
          onPressed: () {
            if (!key.currentState!.validate()) return;
            Navigator.pop(
                c,
                Student(
                  name: name.text.trim(),
                  filiere: filiere.text.trim(),
                  etablissement: etab.text.trim(),
                  bio: bio.text.trim(),
                  email: email.text.trim(),
                  github: github.text.trim(),
                ));
          },
          child: const Text('Créer'),
        ),
      ],
    ),
  );
}
