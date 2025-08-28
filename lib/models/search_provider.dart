import 'package:flutter/material.dart';

/// Model representing a search engine provider
class SearchProvider {
  final String id;
  final String name;
  final String description;
  final String searchUrl;
  final String? iconUrl;
  final String? iconPath; // Local cached icon path
  final Color primaryColor;
  final bool isDefault;
  final bool isEnabled;
  final String category; // web, image, video, news, etc.
  final Map<String, dynamic> metadata;

  SearchProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.searchUrl,
    this.iconUrl,
    this.iconPath,
    required this.primaryColor,
    this.isDefault = false,
    this.isEnabled = true,
    this.category = 'web',
    this.metadata = const {},
  });

  /// Create from JSON map
  factory SearchProvider.fromMap(Map<String, dynamic> map) {
    return SearchProvider(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      searchUrl: map['searchUrl'] ?? '',
      iconUrl: map['iconUrl'],
      iconPath: map['iconPath'],
      primaryColor: Color(map['primaryColor'] ?? 0xFF4285F4),
      isDefault: map['isDefault'] ?? false,
      isEnabled: map['isEnabled'] ?? true,
      category: map['category'] ?? 'web',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'searchUrl': searchUrl,
      'iconUrl': iconUrl,
      'iconPath': iconPath,
      'primaryColor': primaryColor.value,
      'isDefault': isDefault,
      'category': category,
      'isEnabled': isEnabled,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated values
  SearchProvider copyWith({
    String? id,
    String? name,
    String? description,
    String? searchUrl,
    String? iconUrl,
    String? iconPath,
    Color? primaryColor,
    bool? isDefault,
    bool? isEnabled,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return SearchProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      searchUrl: searchUrl ?? this.searchUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      iconPath: iconPath ?? this.iconPath,
      primaryColor: primaryColor ?? this.primaryColor,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get search URL with query parameter
  String getSearchUrlWithQuery(String query) {
    final encodedQuery = Uri.encodeComponent(query);
    return searchUrl.replaceAll('{query}', encodedQuery);
  }

  /// Get display name for UI
  String get displayName => isDefault ? '$name (Default)' : name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchProvider &&
        other.id == id &&
        other.name == name &&
        other.searchUrl == searchUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ searchUrl.hashCode;
  }

  @override
  String toString() {
    return 'SearchProvider(id: $id, name: $name, searchUrl: $searchUrl)';
  }
}
