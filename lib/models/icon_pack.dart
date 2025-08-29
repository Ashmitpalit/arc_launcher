class IconPack {
  final String id;
  final String name;
  final String description;
  final String author;
  final String version;
  final String previewImagePath;
  final bool isBuiltIn;
  final bool isEnabled;
  final Map<String, String> appIconMappings; // packageName -> iconPath
  final List<String> supportedApps;
  final DateTime lastUpdated;

  IconPack({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.version,
    required this.previewImagePath,
    this.isBuiltIn = false,
    this.isEnabled = false,
    required this.appIconMappings,
    required this.supportedApps,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'version': version,
      'previewImagePath': previewImagePath,
      'isBuiltIn': isBuiltIn ? 1 : 0,
      'isEnabled': isEnabled ? 1 : 0,
      'appIconMappings': appIconMappings,
      'supportedApps': supportedApps,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory IconPack.fromMap(Map<String, dynamic> map) {
    return IconPack(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      version: map['version'] as String,
      previewImagePath: map['previewImagePath'] as String,
      isBuiltIn: map['isBuiltIn'] == 1,
      isEnabled: map['isEnabled'] == 1,
      appIconMappings: Map<String, String>.from(map['appIconMappings'] ?? {}),
      supportedApps: List<String>.from(map['supportedApps'] ?? []),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] as int),
    );
  }

  IconPack copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    String? version,
    String? previewImagePath,
    bool? isBuiltIn,
    bool? isEnabled,
    Map<String, String>? appIconMappings,
    List<String>? supportedApps,
    DateTime? lastUpdated,
  }) {
    return IconPack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      version: version ?? this.version,
      previewImagePath: previewImagePath ?? this.previewImagePath,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isEnabled: isEnabled ?? this.isEnabled,
      appIconMappings: appIconMappings ?? this.appIconMappings,
      supportedApps: supportedApps ?? this.supportedApps,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IconPack && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'IconPack(id: $id, name: $name, isEnabled: $isEnabled)';
  }
}
