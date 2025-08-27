class WebAppShortcut {
  final String id;
  final String title;
  final String url;
  final String icon;
  final String category;
  final int priority;
  final String cohort;
  final DateTime? lastUsed;
  final int usageCount;
  final bool isPinned;
  final Map<String, dynamic>? metadata;

  WebAppShortcut({
    required this.id,
    required this.title,
    required this.url,
    required this.icon,
    required this.category,
    required this.priority,
    required this.cohort,
    this.lastUsed,
    this.usageCount = 0,
    this.isPinned = false,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'icon': icon,
      'category': category,
      'priority': priority,
      'cohort': cohort,
      'lastUsed': lastUsed?.toIso8601String(),
      'usageCount': usageCount,
      'isPinned': isPinned,
      'metadata': metadata,
    };
  }

  factory WebAppShortcut.fromMap(Map<String, dynamic> map) {
    return WebAppShortcut(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      icon: map['icon'],
      category: map['category'],
      priority: map['priority'],
      cohort: map['cohort'],
      lastUsed: map['lastUsed'] != null 
          ? DateTime.parse(map['lastUsed']) 
          : null,
      usageCount: map['usageCount'] ?? 0,
      isPinned: map['isPinned'] ?? false,
      metadata: map['metadata'],
    );
  }

  WebAppShortcut copyWith({
    String? id,
    String? title,
    String? url,
    String? icon,
    String? category,
    int? priority,
    String? cohort,
    DateTime? lastUsed,
    int? usageCount,
    bool? isPinned,
    Map<String, dynamic>? metadata,
  }) {
    return WebAppShortcut(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      cohort: cohort ?? this.cohort,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
      isPinned: isPinned ?? this.isPinned,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebAppShortcut && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WebAppShortcut(id: $id, title: $title, category: $category, priority: $priority)';
  }
}
