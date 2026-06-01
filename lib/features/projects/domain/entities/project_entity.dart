class ProjectEntity {
  final String id;
  final String title;
  final String shortDesc;
  final String fullDesc;
  final List<String> techStack;
  final String liveUrl;
  final String repoUrl;
  final String coverUrl;

  ProjectEntity({
    required this.id,
    required this.title,
    required this.shortDesc,
    required this.fullDesc,
    required this.techStack,
    required this.liveUrl,
    required this.repoUrl,
    required this.coverUrl,
  });

  factory ProjectEntity.fromJson(Map<String, dynamic> json) {
    return ProjectEntity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortDesc: json['short_desc'] as String? ?? '',
      fullDesc: json['full_desc'] as String? ?? '',
      techStack: (json['tech_stack'] as List<dynamic>?)?.map((e) {
        if (e is Map) return e['name']?.toString() ?? '';
        return e.toString();
      }).toList() ?? [],
      liveUrl: json['live_url'] as String? ?? '',
      repoUrl: json['repo_url'] as String? ?? '',
      coverUrl: (json['image_url'] ?? json['cover_url']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'short_desc': shortDesc,
      'full_desc': fullDesc,
      'tech_stack': techStack,
      'live_url': liveUrl,
      'repo_url': repoUrl,
      'cover_url': coverUrl,
    };
  }
}
