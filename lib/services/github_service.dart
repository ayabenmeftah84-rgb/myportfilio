import 'dart:convert';
import 'package:http/http.dart' as http;

class Repo {
  final String name, description, language, url;
  final int stars;
  const Repo(
      {required this.name,
      required this.description,
      required this.language,
      required this.url,
      required this.stars});

  factory Repo.fromJson(Map<String, dynamic> j) => Repo(
        name: j['name'] ?? '',
        description: j['description'] ?? '',
        language: j['language'] ?? '',
        url: j['html_url'] ?? '',
        stars: j['stargazers_count'] ?? 0,
      );
}

/// Service REST : API publique GitHub (sans cle).
class GithubService {
  static Future<List<Repo>> fetchRepos(String username) async {
    final uri = Uri.https('api.github.com', '/users/$username/repos',
        {'sort': 'updated', 'per_page': '30'});
    final res = await http
        .get(uri, headers: {'Accept': 'application/vnd.github+json'}).timeout(
            const Duration(seconds: 10));
    if (res.statusCode == 404) {
      throw Exception('Utilisateur GitHub introuvable');
    }
    if (res.statusCode != 200) {
      throw Exception('Erreur serveur (${res.statusCode})');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Repo.fromJson(e as Map<String, dynamic>)).toList();
  }
}
