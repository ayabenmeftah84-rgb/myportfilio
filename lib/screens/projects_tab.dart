import 'package:flutter/material.dart';
import '../db/database.dart';
import '../models/models.dart';
import 'project_detail.dart';
import 'project_form.dart';

class ProjectsTab extends StatefulWidget {
  final int studentId;
  final ValueNotifier<int> refresh;
  const ProjectsTab({super.key, required this.studentId, required this.refresh});
  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  List<Project> items = [];
  bool loading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    widget.refresh.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.refresh.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final r = await AppDatabase.instance.projects(widget.studentId);
    if (mounted) {
      setState(() {
        items = r;
        loading = false;
      });
    }
  }

  Future<void> _add() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProjectForm(studentId: widget.studentId)));
    _load();
  }

  // Recherche dans le titre, la description et les technologies
  List<Project> get _filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.techs.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un projet ou une technologie',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Text(items.isEmpty
                              ? 'Aucun projet. Appuyez sur +'
                              : 'Aucun résultat'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: list.length,
                          itemBuilder: (c, i) {
                            final p = list[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: ListTile(
                                title: Text(p.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(p.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ProjectDetail(project: p)));
                                  _load();
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
          heroTag: 'projects_fab',
          onPressed: _add,
          child: const Icon(Icons.add)),
    );
  }
}
