import 'package:flutter/material.dart';

import '../db/database.dart';
import '../models/models.dart';
import 'widgets.dart';

class SkillsTab extends StatefulWidget {
  final int studentId;
  const SkillsTab({super.key, required this.studentId});
  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  List<Skill> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await AppDatabase.instance.skills(widget.studentId);
    if (mounted) {
      setState(() {
        items = r;
        loading = false;
      });
    }
  }

  Future<void> _form([Skill? skill]) async {
    final name = TextEditingController(text: skill?.name ?? '');
    double level = (skill?.level ?? 50).toDouble();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text(skill == null ? 'Ajouter une compétence' : 'Modifier'),
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Compétence'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Champ obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              Text('Niveau : ${level.round()} %'),
              Slider(
                  value: level,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (v) => setD(() => level = v)),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) Navigator.pop(c, true);
                },
                child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await AppDatabase.instance.saveSkill(Skill(
        id: skill?.id,
        studentId: widget.studentId,
        name: name.text.trim(),
        level: level.round()));
    await _load();
  }

  Future<void> _delete(Skill s) async {
    if (await confirmDialog(context, 'Supprimer « ${s.name} » ?')) {
      await AppDatabase.instance.deleteSkill(s.id!);
      await _load();
      if (mounted) showSnack(context, 'Compétence supprimée');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('Aucune compétence. Appuyez sur +'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90),
                  itemCount: items.length,
                  itemBuilder: (c, i) {
                    final s = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(s.name),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                              value: s.level / 100,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        leading: Text('${s.level}%'),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _form(s)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(s)),
                        ]),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
          heroTag: 'skills_fab',
          onPressed: () => _form(),
          child: const Icon(Icons.add)),
    );
  }
}
