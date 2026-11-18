import 'package:flutter/material.dart';
import '../db/database.dart';
import '../models/models.dart';
import '../services/github_service.dart';
import 'widgets.dart';

class GithubTab extends StatefulWidget {
  final int studentId;
  final String defaultUser;
  final VoidCallback onImported;
  const GithubTab(
      {super.key,
      required this.studentId,
      required this.defaultUser,
      required this.onImported});
  @override
  State<GithubTab> createState() => _GithubTabState();
}

class _GithubTabState extends State<GithubTab> {
  late final TextEditingController _user =
      TextEditingController(text: widget.defaultUser);
  Future<List<Repo>>? _future;

  @override
  void initState() {
    super.initState();
    _search();
  }

  void _search() {
    final u = _user.text.trim();
    if (u.isEmpty) return;
    setState(() => _future = GithubService.fetchRepos(u));
  }

  Future<void> _import(Repo r) async {
    await AppDatabase.instance.saveProject(Project(
      studentId: widget.studentId,
      title: r.name,
      description: r.description,
      techs: r.language,
      link: r.url,
    ));
    widget.onImported();
    if (mounted) showSnack(context, '« ${r.name} » ajouté aux projets');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _user,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Pseudo GitHub',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                  icon: const Icon(Icons.search), onPressed: _search),
            ),
          ),
        ),
        Expanded(
          child: _future == null
              ? const SizedBox()
              : FutureBuilder<List<Repo>>(
                  future: _future,
                  builder: (c, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      final msg = snap.error.toString().replaceFirst('Exception: ', '');
                      return Center(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off, size: 40),
                              const SizedBox(height: 8),
                              Text(msg, textAlign: TextAlign.center),
                              TextButton(
                                  onPressed: _search,
                                  child: const Text('Réessayer')),
                            ]),
                      );
                    }
                    final repos = snap.data!;
                    if (repos.isEmpty) {
                      return const Center(child: Text('Aucun dépôt public'));
                    }
                    return ListView.builder(
                      itemCount: repos.length,
                      itemBuilder: (c, i) {
                        final r = repos[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: ListTile(
                            title: Text(r.name),
                            subtitle: Text(
                                '${r.language.isEmpty ? "—" : r.language}  ·  ⭐ ${r.stars}\n${r.description}',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                            isThreeLine: true,
                            trailing: IconButton(
                              tooltip: 'Ajouter aux projets',
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _import(r),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
