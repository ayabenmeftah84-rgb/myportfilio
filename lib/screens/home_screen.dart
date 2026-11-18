import 'package:flutter/material.dart';

import '../db/database.dart';
import '../models/models.dart';
import '../theme_controller.dart';
import 'portfolio_screen.dart';
import 'student_form.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Student>> _future = AppDatabase.instance.students();

  void _reload() => setState(() => _future = AppDatabase.instance.students());

  Future<void> _create() async {
    final s = await showStudentForm(context);
    if (s == null) return;
    await AppDatabase.instance.insertStudent(s);
    _reload();
    if (mounted) showSnack(context, 'Portfolio créé');
  }

  Future<void> _delete(Student s) async {
    final ok = await confirmDialog(context,
        'Supprimer le portfolio de « ${s.name} » avec toutes ses compétences et tous ses projets ?');
    if (!ok) return;
    await AppDatabase.instance.deleteStudent(s.id!);
    _reload();
    if (mounted) showSnack(context, 'Portfolio supprimé');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPortfolio'),
        actions: [
          IconButton(
              tooltip: 'Mode clair / sombre',
              icon: const Icon(Icons.brightness_6),
              onPressed: () => toggleTheme(context)),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _future,
        builder: (c, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erreur : ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snap.data!;
          if (students.isEmpty) {
            return const Center(
                child:
                    Text('Aucun portfolio. Appuyez sur + pour en créer un.'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              Text('Choisissez un portfolio',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ...students.map((s) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading:
                          CircleAvatar(radius: 28, child: Text(s.initials)),
                      title: Text(s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(s.filiere),
                      trailing: IconButton(
                        tooltip: 'Supprimer ce portfolio',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(s),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PortfolioScreen(student: s)),
                      ).then((_) => _reload()),
                    ),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Portfolio'),
      ),
    );
  }
}
