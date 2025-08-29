// Remove unused Flutter import - this model doesn't need UI components
// import 'package:flutter/material.dart';

/// Model representing an app recommendation
class AppRecommendation {
  final String id;
  final String packageName;
  final String appName;
  final String? description;
  final String? iconUrl;
  final String? iconPath; // Local cached icon path
  final String category;
  final String recommendationReason;
  final double confidenceScore; // 0.0 to 1.0
  final int priority; // 1-10, higher is more important
  final bool isPremium;
  final bool isInstalled;
  final DateTime recommendationDate;
  final Map<String, dynamic> metadata;

  AppRecommendation({
    required this.id,
    required this.packageName,
    required this.appName,
    this.description,
    this.iconUrl,
    this.iconPath,
    required this.category,
    required this.recommendationReason,
    required this.confidenceScore,
    this.priority = 5,
    this.isPremium = false,
    this.isInstalled = false,
    required this.recommendationDate,
    this.metadata = const {},
  });

  /// Create from JSON map
  factory AppRecommendation.fromMap(Map<String, dynamic> map) {
    return AppRecommendation(
      id: map['id'] ?? '',
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? '',
      description: map['description'],
      iconUrl: map['iconUrl'],
      iconPath: map['iconPath'],
      category: map['category'] ?? 'General',
      recommendationReason: map['recommendationReason'] ?? 'Recommended for you',
      confidenceScore: (map['confidenceScore'] ?? 0.5).toDouble(),
      priority: map['priority'] ?? 5,
      isPremium: map['isPremium'] ?? false,
      isInstalled: map['isInstalled'] ?? false,
      recommendationDate: DateTime.parse(map['recommendationDate'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'appName': appName,
      'description': description,
      'iconUrl': iconUrl,
      'iconPath': iconPath,
      'category': category,
      'recommendationReason': recommendationReason,
      'confidenceScore': confidenceScore,
      'priority': priority,
      'isPremium': isPremium,
      'isInstalled': isInstalled,
      'recommendationDate': recommendationDate.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated values
  AppRecommendation copyWith({
    String? id,
    String? packageName,
    String? appName,
    String? description,
    String? iconUrl,
    String? iconPath,
    String? category,
    String? recommendationReason,
    double? confidenceScore,
    int? priority,
    bool? isPremium,
    bool? isInstalled,
    DateTime? recommendationDate,
    Map<String, dynamic>? metadata,
  }) {
    return AppRecommendation(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      iconPath: iconPath ?? this.iconPath,
      category: category ?? this.category,
      recommendationReason: recommendationReason ?? this.recommendationReason,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      priority: priority ?? this.priority,
      isPremium: isPremium ?? this.isPremium,
      isInstalled: isInstalled ?? this.isInstalled,
      recommendationDate: recommendationDate ?? this.recommendationDate,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get recommendation quality level
  String get qualityLevel {
    if (confidenceScore >= 0.8) return 'Excellent';
    if (confidenceScore >= 0.6) return 'Good';
    if (confidenceScore >= 0.4) return 'Fair';
    return 'Basic';
  }

  /// Get priority label
  String get priorityLabel {
    if (priority >= 8) return 'High Priority';
    if (priority >= 5) return 'Medium Priority';
    return 'Low Priority';
  }

  /// Get formatted recommendation date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(recommendationDate);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).round()} weeks ago';
    return '${(difference.inDays / 30).round()} months ago';
  }

  /// Get confidence score as percentage
  String get confidencePercentage {
    return '${(confidenceScore * 100).round()}%';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppRecommendation &&
        other.id == id &&
        other.packageName == packageName &&
        other.appName == appName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ packageName.hashCode ^ appName.hashCode;
  }

  @override
  String toString() {
    return 'AppRecommendation(id: $id, appName: $appName, confidenceScore: $confidenceScore)';
  }
}
