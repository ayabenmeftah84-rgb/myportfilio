import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/models.dart';

/// Export du portfolio en PDF (apercu, impression, partage).
class PdfService {
  // La police PDF par defaut ne gere pas certains symboles : on les simplifie.
  static String _c(String s) =>
      s.replaceAll('–', '-').replaceAll('’', "'").replaceAll('⭐', '');

  static pw.Widget _title(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
        child: pw.Text(t,
            style: const pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo)),
      );

  static Future<void> exportPortfolio(
      Student s, List<Skill> skills, List<Project> projects) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        pw.Text(_c(s.name),
            style: const pw.TextStyle(
                fontSize: 26, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(_c(s.filiere)),
        pw.Text(_c(s.etablissement)),
        pw.Text('${s.email}  |  github.com/${s.github}'),
        pw.Divider(),
        _title('Profil'),
        pw.Text(_c(s.bio)),
        _title('Compétences'),
        ...skills.map((k) => pw.Bullet(text: '${_c(k.name)} (${k.level}%)')),
        _title('Projets'),
        ...projects.map((p) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_c(p.title),
                        style:
                            const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (p.techs.isNotEmpty)
                      pw.Text('Technologies : ${_c(p.techs)}'),
                    if (p.description.isNotEmpty) pw.Text(_c(p.description)),
                    if (p.link.isNotEmpty) pw.Text(p.link),
                  ]),
            )),
      ],
    ));
    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: 'Portfolio_${s.name.replaceAll(' ', '_')}.pdf',
    );
  }
}
