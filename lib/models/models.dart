class Student {
  final int? id;
  final String name, filiere, etablissement, bio, email, github;

  const Student({
    this.id,
    required this.name,
    required this.filiere,
    required this.etablissement,
    required this.bio,
    required this.email,
    required this.github,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'filiere': filiere,
        'etablissement': etablissement,
        'bio': bio,
        'email': email,
        'github': github,
      };

  factory Student.fromMap(Map<String, dynamic> m) => Student(
        id: m['id'] as int?,
        name: m['name'] as String,
        filiere: m['filiere'] as String,
        etablissement: m['etablissement'] as String,
        bio: m['bio'] as String,
        email: m['email'] as String,
        github: m['github'] as String,
      );

  String get initials {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }
}

class Skill {
  final int? id;
  final int studentId;
  final String name;
  final int level; // 0 a 100

  const Skill(
      {this.id,
      required this.studentId,
      required this.name,
      required this.level});

  Map<String, dynamic> toMap() =>
      {'id': id, 'studentId': studentId, 'name': name, 'level': level};

  factory Skill.fromMap(Map<String, dynamic> m) => Skill(
        id: m['id'] as int?,
        studentId: m['studentId'] as int,
        name: m['name'] as String,
        level: m['level'] as int,
      );
}

class Project {
  final int? id;
  final int studentId;
  final String title, description, techs, link;

  const Project({
    this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.techs,
    required this.link,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'studentId': studentId,
        'title': title,
        'description': description,
        'techs': techs,
        'link': link,
      };

  factory Project.fromMap(Map<String, dynamic> m) => Project(
        id: m['id'] as int?,
        studentId: m['studentId'] as int,
        title: m['title'] as String,
        description: m['description'] as String,
        techs: m['techs'] as String,
        link: m['link'] as String,
      );

  List<String> get techList =>
      techs.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}
