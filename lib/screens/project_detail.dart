import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/database.dart';
import '../models/models.dart';
import 'project_form.dart';
import 'widgets.dart';

class ProjectDetail extends StatelessWidget {
  final Project project;
  const ProjectDetail({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ProjectForm(studentId: p.studentId, project: p)));
              if (changed == true && context.mounted) Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (await confirmDialog(context, 'Supprimer ce projet ?')) {
                await AppDatabase.instance.deleteProject(p.id!);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(p.description.isEmpty ? '—' : p.description),
          const SizedBox(height: 20),
          Text('Technologies', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              children: p.techList.map((t) => Chip(label: Text(t))).toList()),
          const SizedBox(height: 20),
          if (p.link.isNotEmpty)
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir le lien'),
              onPressed: () => launchUrl(Uri.parse(p.link),
                  mode: LaunchMode.externalApplication),
            ),
        ],
      ),
    );
  }
}
