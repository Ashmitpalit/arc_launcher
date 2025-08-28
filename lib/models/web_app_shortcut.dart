import 'package:flutter/material.dart';

/// Model representing a web app shortcut that can be added to the home screen
class WebAppShortcut {
  final String id;
  final String url;
  final String title;
  final String? description;
  final String? iconUrl;
  final String? iconPath; // Local cached icon path
  final DateTime installDate;
  final DateTime lastUsed;
  final int useCount;
  final String category;
  final String cohort; // new_user, existing_user, power_user, etc.
  final bool isPinned;
  final Map<String, dynamic> metadata;

  WebAppShortcut({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    this.iconUrl,
    this.iconPath,
    required this.installDate,
    required this.lastUsed,
    this.useCount = 0,
    this.category = 'General',
    this.cohort = 'new_user',
    this.isPinned = false,
    this.metadata = const {},
  });

  /// Create from JSON map
  factory WebAppShortcut.fromMap(Map<String, dynamic> map) {
    return WebAppShortcut(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      iconUrl: map['iconUrl'],
      iconPath: map['iconPath'],
      installDate: DateTime.parse(map['installDate'] ?? DateTime.now().toIso8601String()),
      lastUsed: DateTime.parse(map['lastUsed'] ?? DateTime.now().toIso8601String()),
      useCount: map['useCount'] ?? 0,
      category: map['category'] ?? 'General',
      cohort: map['cohort'] ?? 'new_user',
      isPinned: map['isPinned'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'iconPath': iconPath,
      'installDate': installDate.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'useCount': useCount,
      'category': category,
      'cohort': cohort,
      'isPinned': isPinned,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated values
  WebAppShortcut copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    String? iconUrl,
    String? iconPath,
    DateTime? installDate,
    DateTime? lastUsed,
    int? useCount,
    String? category,
    String? cohort,
    bool? isPinned,
    Map<String, dynamic>? metadata,
  }) {
    return WebAppShortcut(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      iconPath: iconPath ?? this.iconPath,
      installDate: installDate ?? this.installDate,
      lastUsed: lastUsed ?? this.lastUsed,
      useCount: useCount ?? this.useCount,
      category: category ?? this.category,
      cohort: cohort ?? this.cohort,
      isPinned: isPinned ?? this.isPinned,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get install age in days
  int get installAgeDays {
    return DateTime.now().difference(installDate).inDays;
  }

  /// Get time since last used
  Duration get timeSinceLastUsed {
    return DateTime.now().difference(lastUsed);
  }

  /// Get formatted install age
  String get formattedInstallAge {
    final days = installAgeDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).round()} weeks ago';
    if (days < 365) return '${(days / 30).round()} months ago';
    return '${(days / 365).round()} years ago';
  }

  /// Get formatted last used
  String get formattedLastUsed {
    final duration = timeSinceLastUsed;
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    if (duration.inDays < 7) return '${duration.inDays}d ago';
    return lastUsed.toString().substring(0, 10);
  }

  /// Get usage frequency category
  String get usageFrequency {
    if (useCount == 0) return 'Never used';
    if (useCount < 5) return 'Rarely used';
    if (useCount < 20) return 'Sometimes used';
    if (useCount < 50) return 'Frequently used';
    return 'Heavily used';
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
    return 'WebAppShortcut(id: $id, title: $title, url: $url, installDate: $installDate)';
  }
}
