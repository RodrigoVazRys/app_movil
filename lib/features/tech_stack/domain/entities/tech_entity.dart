enum TechCategory {
  frontend,
  backend,
  mobile,
  tools,
  lenguajes;

  static TechCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'frontend': return TechCategory.frontend;
      case 'backend': return TechCategory.backend;
      case 'mobile': return TechCategory.mobile;
      case 'tools': return TechCategory.tools;
      case 'lenguajes': return TechCategory.lenguajes;
      default: return TechCategory.tools;
    }
  }

  String get label {
    switch (this) {
      case TechCategory.frontend: return 'Frontend';
      case TechCategory.backend: return 'Backend';
      case TechCategory.mobile: return 'Mobile';
      case TechCategory.tools: return 'Tools';
      case TechCategory.lenguajes: return 'Lenguajes';
    }
  }
}

class TechEntity {
  final String id;
  final String name;
  final TechCategory category;
  final String iconUrl;

  TechEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.iconUrl,
  });

  factory TechEntity.fromJson(Map<String, dynamic> json) {
    return TechEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: TechCategory.fromString(json['category'] as String? ?? ''),
      iconUrl: (json['image_url'] ?? json['icon_url']) as String? ?? '',
    );
  }
}
