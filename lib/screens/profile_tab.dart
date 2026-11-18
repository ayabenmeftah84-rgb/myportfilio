import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/database.dart';
import '../models/models.dart';
import 'widgets.dart';

class ProfileTab extends StatefulWidget {
  final Student student;
  const ProfileTab({super.key, required this.student});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Student s = widget.student;

  Future<void> _edit() async {
    final name = TextEditingController(text: s.name);
    final filiere = TextEditingController(text: s.filiere);
    final etab = TextEditingController(text: s.etablissement);
    final bio = TextEditingController(text: s.bio);
    final email = TextEditingController(text: s.email);
    final github = TextEditingController(text: s.github);

    Widget field(String label, TextEditingController c, {int lines = 1}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
              controller: c,
              maxLines: lines,
              decoration: InputDecoration(
                  labelText: label, border: const OutlineInputBorder())),
        );

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: SingleChildScrollView(
          child: Column(children: [
            field('Nom complet', name),
            field('Filière / Niveau', filiere),
            field('Établissement', etab),
            field('Bio', bio, lines: 3),
            field('Email', email),
            field('Pseudo GitHub', github),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Enregistrer')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    final updated = Student(
      id: s.id,
      name: name.text.trim(),
      filiere: filiere.text.trim(),
      etablissement: etab.text.trim(),
      bio: bio.text.trim(),
      email: email.text.trim(),
      github: github.text.trim(),
    );
    await AppDatabase.instance.updateStudent(updated);
    if (!mounted) return;
    setState(() => s = updated);
    showSnack(context, 'Profil mis à jour');
  }

  Future<void> _open(String url) async {
    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) showSnack(context, 'Impossible d\'ouvrir le lien');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: CircleAvatar(radius: 48, child: Text(s.initials, style: const TextStyle(fontSize: 32)))),
        const SizedBox(height: 12),
        Center(
            child: Text(s.name,
                style: Theme.of(context).textTheme.headlineSmall)),
        Center(child: Text(s.filiere, textAlign: TextAlign.center)),
        const SizedBox(height: 20),
        Card(
          child: Column(children: [
            ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Établissement'),
                subtitle: Text(s.etablissement)),
            ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('À propos'),
                subtitle: Text(s.bio)),
            ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(s.email),
                onTap: () => _open('mailto:${s.email}')),
            ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub'),
                subtitle: Text(s.github),
                onTap: () => _open('https://github.com/${s.github}')),
          ]),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
            onPressed: _edit,
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil')),
      ],
    );
  }
}
