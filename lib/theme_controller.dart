import 'package:flutter/material.dart';

/// Mode d'affichage global (systeme par defaut, bascule manuelle clair/sombre).
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

void toggleTheme(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  themeMode.value = dark ? ThemeMode.light : ThemeMode.dark;
}
