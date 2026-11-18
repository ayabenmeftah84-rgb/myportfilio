import 'package:flutter/material.dart';
import '../db/database.dart';
import '../models/models.dart';

class ProjectForm extends StatefulWidget {
  final int studentId;
  final Project? project;
  const ProjectForm({super.key, required this.studentId, this.project});
  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _key = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.project?.title);
  late final desc = TextEditingController(text: widget.project?.description);
  late final techs = TextEditingController(text: widget.project?.techs);
  late final link = TextEditingController(text: widget.project?.link);

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    await AppDatabase.instance.saveProject(Project(
      id: widget.project?.id,
      studentId: widget.studentId,
      title: title.text.trim(),
      description: desc.text.trim(),
      techs: techs.text.trim(),
      link: link.text.trim(),
    ));
    if (mounted) Navigator.pop(context, true);
  }

  InputDecoration _dec(String l, [String? hint]) => InputDecoration(
      labelText: l, hintText: hint, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.project == null ? 'Nouveau projet' : 'Modifier')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: title,
              decoration: _dec('Titre *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Titre obligatoire' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
                controller: desc, maxLines: 4, decoration: _dec('Description')),
            const SizedBox(height: 16),
            TextFormField(
                controller: techs,
                decoration: _dec('Technologies', 'Flutter, SQLite, ...')),
            const SizedBox(height: 16),
            TextFormField(
              controller: link,
              keyboardType: TextInputType.url,
              decoration: _dec('Lien (GitHub, démo...)', 'https://...'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                return v.trim().startsWith('http')
                    ? null
                    : 'Le lien doit commencer par http';
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}
