import 'package:flutter/material.dart';

import '../db/database.dart';
import '../models/models.dart';
import '../services/pdf_service.dart';
import '../theme_controller.dart';
import 'github_tab.dart';
import 'profile_tab.dart';
import 'projects_tab.dart';
import 'quality_tab.dart';
import 'skills_tab.dart';
import 'widgets.dart';

class PortfolioScreen extends StatefulWidget {
  final Student student;
  const PortfolioScreen({super.key, required this.student});
  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  int _index = 0;
  // Permet a l'onglet GitHub de rafraichir l'onglet Projets
  final ValueNotifier<int> _projectsRefresh = ValueNotifier(0);

  @override
  void dispose() {
    _projectsRefresh.dispose();
    super.dispose();
  }

  Future<void> _exportPdf() async {
    try {
      final db = AppDatabase.instance;
      final id = widget.student.id!;
      // Relit l'etudiant (le profil a pu etre modifie)
      final s = (await db.students()).firstWhere((e) => e.id == id);
      await PdfService.exportPortfolio(
          s, await db.skills(id), await db.projects(id));
    } catch (e) {
      if (mounted) showSnack(context, 'Export PDF impossible : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio – ${s.name}'),
        actions: [
          IconButton(
              tooltip: 'Exporter en PDF',
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _exportPdf),
          IconButton(
              tooltip: 'Mode clair / sombre',
              icon: const Icon(Icons.brightness_6),
              onPressed: () => toggleTheme(context)),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          ProfileTab(student: s),
          SkillsTab(studentId: s.id!),
          ProjectsTab(studentId: s.id!, refresh: _projectsRefresh),
          GithubTab(
              studentId: s.id!,
              defaultUser: s.github,
              onImported: () => _projectsRefresh.value++),
          QualityTab(studentId: s.id!, active: _index == 4),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Compétences'),
          NavigationDestination(icon: Icon(Icons.work), label: 'Projets'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'GitHub'),
          NavigationDestination(icon: Icon(Icons.verified), label: 'Qualité'),
        ],
      ),
    );
  }
}
