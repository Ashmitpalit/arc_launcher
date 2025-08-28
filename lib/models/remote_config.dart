import 'package:flutter/material.dart';

/// Model representing a remote configuration setting
class RemoteConfig {
  final String key;
  final String name;
  final String description;
  final dynamic value;
  final String type; // string, number, boolean, json
  final String category; // feature, ui, performance, monetization, content
  final bool isEnabled;
  final bool isRequired;
  final DateTime lastUpdated;
  final String updatedBy;
  final Map<String, dynamic> conditions; // cohort, version, device, etc.
  final Map<String, dynamic> metadata;
  final int priority; // 1-10, higher = more important
  final bool isAbtest; // A/B testing flag
  final String? abtestVariant; // A or B variant

  RemoteConfig({
    required this.key,
    required this.name,
    required this.description,
    required this.value,
    required this.type,
    required this.category,
    this.isEnabled = true,
    this.isRequired = false,
    required this.lastUpdated,
    required this.updatedBy,
    this.conditions = const {},
    this.metadata = const {},
    this.priority = 5,
    this.isAbtest = false,
    this.abtestVariant,
  });

  /// Create from JSON map
  factory RemoteConfig.fromMap(Map<String, dynamic> map) {
    return RemoteConfig(
      key: map['key'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      value: map['value'],
      type: map['type'] ?? 'string',
      category: map['category'] ?? 'feature',
      isEnabled: map['isEnabled'] ?? true,
      isRequired: map['isRequired'] ?? false,
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
      updatedBy: map['updatedBy'] ?? 'System',
      conditions: Map<String, dynamic>.from(map['conditions'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      priority: map['priority'] ?? 5,
      isAbtest: map['isAbtest'] ?? false,
      abtestVariant: map['abtestVariant'],
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'value': value,
      'type': type,
      'category': category,
      'isEnabled': isEnabled,
      'isRequired': isRequired,
      'lastUpdated': lastUpdated.toIso8601String(),
      'updatedBy': updatedBy,
      'conditions': conditions,
      'metadata': metadata,
      'priority': priority,
      'isAbtest': isAbtest,
      'abtestVariant': abtestVariant,
    };
  }

  /// Create a copy with updated values
  RemoteConfig copyWith({
    String? key,
    String? name,
    String? description,
    dynamic value,
    String? type,
    String? category,
    bool? isEnabled,
    bool? isRequired,
    DateTime? lastUpdated,
    String? updatedBy,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? metadata,
    int? priority,
    bool? isAbtest,
    String? abtestVariant,
  }) {
    return RemoteConfig(
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      type: type ?? this.type,
      category: category ?? this.category,
      isEnabled: isEnabled ?? this.isEnabled,
      isRequired: isRequired ?? this.isRequired,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
      conditions: conditions ?? this.conditions,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      isAbtest: isAbtest ?? this.isAbtest,
      abtestVariant: abtestVariant ?? this.abtestVariant,
    );
  }

  /// Get typed value
  T getValue<T>() {
    if (value is T) return value as T;
    
    // Type conversion for common cases
    switch (T) {
      case String:
        return value.toString() as T;
      case int:
        if (value is num) return value.toInt() as T;
        if (value is String) return (int.tryParse(value) ?? 0) as T;
        return 0 as T;
      case double:
        if (value is num) return value.toDouble() as T;
        if (value is String) return (double.tryParse(value) ?? 0.0) as T;
        return 0.0 as T;
      case bool:
        if (value is bool) return value as T;
        if (value is String) return (value.toLowerCase() == 'true') as T;
        if (value is num) return (value != 0) as T;
        return false as T;
      default:
        return value as T;
    }
  }

  /// Get string value
  String get stringValue => getValue<String>();
  
  /// Get int value
  int get intValue => getValue<int>();
  
  /// Get double value
  double get doubleValue => getValue<double>();
  
  /// Get bool value
  bool get boolValue => getValue<bool>();

  /// Get formatted last updated date
  String get formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).round()}w ago';
  }

  /// Get priority label
  String get priorityLabel {
    if (priority >= 8) return 'Critical';
    if (priority >= 6) return 'High';
    if (priority >= 4) return 'Medium';
    if (priority >= 2) return 'Low';
    return 'Minimal';
  }

  /// Get priority color
  Color get priorityColor {
    if (priority >= 8) return Colors.red;
    if (priority >= 6) return Colors.orange;
    if (priority >= 4) return Colors.yellow;
    if (priority >= 2) return Colors.blue;
    return Colors.grey;
  }

  /// Get category icon
  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'feature':
        return Icons.toggle_on;
      case 'ui':
        return Icons.palette;
      case 'performance':
        return Icons.speed;
      case 'monetization':
        return Icons.monetization_on;
      case 'content':
        return Icons.article;
      case 'security':
        return Icons.security;
      case 'analytics':
        return Icons.analytics;
      default:
        return Icons.settings;
    }
  }

  /// Get category color
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'feature':
        return Colors.green;
      case 'ui':
        return Colors.purple;
      case 'performance':
        return Colors.blue;
      case 'monetization':
        return Colors.amber;
      case 'content':
        return Colors.teal;
      case 'security':
        return Colors.red;
      case 'analytics':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Check if config is recent (within 24 hours)
  bool get isRecent => DateTime.now().difference(lastUpdated).inHours < 24;

  /// Check if config is critical priority
  bool get isCritical => priority >= 8;

  /// Check if config has conditions
  bool get hasConditions => conditions.isNotEmpty;

  /// Get condition summary
  String get conditionSummary {
    if (!hasConditions) return 'No conditions';
    
    final conditionsList = <String>[];
    if (conditions.containsKey('cohort')) {
      conditionsList.add('Cohort: ${conditions['cohort']}');
    }
    if (conditions.containsKey('version')) {
      conditionsList.add('Version: ${conditions['version']}');
    }
    if (conditions.containsKey('device')) {
      conditionsList.add('Device: ${conditions['device']}');
    }
    
    return conditionsList.join(', ');
  }

  /// Check if config matches user conditions
  bool matchesConditions(Map<String, dynamic> userContext) {
    if (!hasConditions) return true;
    
    for (final entry in conditions.entries) {
      final key = entry.key;
      final expectedValue = entry.value;
      final userValue = userContext[key];
      
      if (userValue == null) continue;
      
      // Simple equality check - can be enhanced with more complex logic
      if (userValue != expectedValue) return false;
    }
    
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RemoteConfig &&
        other.key == key &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return key.hashCode ^ lastUpdated.hashCode;
  }

  @override
  String toString() {
    return 'RemoteConfig(key: $key, name: $name, category: $category, priority: $priority)';
  }
}

/// Model representing user cohort information
class UserCohort {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final Map<String, dynamic> attributes;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final bool isActive;
  final int userCount;
  final Map<String, dynamic> metadata;

  UserCohort({
    required this.id,
    required this.name,
    required this.description,
    this.tags = const [],
    this.attributes = const {},
    required this.createdAt,
    this.lastUpdated,
    this.isActive = true,
    this.userCount = 0,
    this.metadata = const {},
  });

  /// Create from JSON map
  factory UserCohort.fromMap(Map<String, dynamic> map) {
    return UserCohort(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      attributes: Map<String, dynamic>.from(map['attributes'] ?? {}),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdated: map['lastUpdated'] != null 
          ? DateTime.parse(map['lastUpdated'])
          : null,
      isActive: map['isActive'] ?? true,
      userCount: map['userCount'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'attributes': attributes,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isActive': isActive,
      'userCount': userCount,
      'metadata': metadata,
    };
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).round()} weeks ago';
    return '${(difference.inDays / 30).round()} months ago';
  }

  /// Get cohort color based on tags
  Color get cohortColor {
    if (tags.contains('premium')) return Colors.amber;
    if (tags.contains('beta')) return Colors.purple;
    if (tags.contains('early')) return Colors.green;
    if (tags.contains('test')) return Colors.blue;
    return Colors.grey;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserCohort &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }

  @override
  String toString() {
    return 'UserCohort(id: $id, name: $name, userCount: $userCount)';
  }
}
