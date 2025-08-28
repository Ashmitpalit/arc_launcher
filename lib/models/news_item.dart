import 'package:flutter/material.dart';

/// Model representing a news item, tip, or content piece
class NewsItem {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String? imageUrl;
  final String? imagePath; // Local cached image path
  final String category;
  final String type; // news, tip, guide, review, announcement
  final DateTime publishDate;
  final DateTime? lastModified;
  final String author;
  final String? authorAvatar;
  final int readTime; // in minutes
  final bool isFeatured;
  final bool isTrending;
  final bool isPremium;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> adData; // Native ad information
  final bool hasAd;

  NewsItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    this.imageUrl,
    this.imagePath,
    required this.category,
    required this.type,
    required this.publishDate,
    this.lastModified,
    required this.author,
    this.authorAvatar,
    required this.readTime,
    this.isFeatured = false,
    this.isTrending = false,
    this.isPremium = false,
    this.tags = const [],
    this.metadata = const {},
    this.adData = const {},
    this.hasAd = false,
  });

  /// Create from JSON map
  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      imagePath: map['imagePath'],
      category: map['category'] ?? 'General',
      type: map['type'] ?? 'news',
      publishDate: DateTime.parse(map['publishDate'] ?? DateTime.now().toIso8601String()),
      lastModified: map['lastModified'] != null 
          ? DateTime.parse(map['lastModified'])
          : null,
      author: map['author'] ?? 'Arc Team',
      authorAvatar: map['authorAvatar'],
      readTime: map['readTime'] ?? 3,
      isFeatured: map['isFeatured'] ?? false,
      isTrending: map['isTrending'] ?? false,
      isPremium: map['isPremium'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      adData: Map<String, dynamic>.from(map['adData'] ?? {}),
      hasAd: map['hasAd'] ?? false,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'category': category,
      'type': type,
      'publishDate': publishDate.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'author': author,
      'authorAvatar': authorAvatar,
      'readTime': readTime,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'isPremium': isPremium,
      'tags': tags,
      'metadata': metadata,
      'adData': adData,
      'hasAd': hasAd,
    };
  }

  /// Create a copy with updated values
  NewsItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    String? imageUrl,
    String? imagePath,
    String? category,
    String? type,
    DateTime? publishDate,
    DateTime? lastModified,
    String? author,
    String? authorAvatar,
    int? readTime,
    bool? isFeatured,
    bool? isTrending,
    bool? isPremium,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? adData,
    bool? hasAd,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      type: type ?? this.type,
      publishDate: publishDate ?? this.publishDate,
      lastModified: lastModified ?? this.lastModified,
      author: author ?? this.author,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      readTime: readTime ?? this.readTime,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      adData: adData ?? this.adData,
      hasAd: hasAd ?? this.hasAd,
    );
  }

  /// Get formatted publish date
  String get formattedPublishDate {
    final now = DateTime.now();
    final difference = now.difference(publishDate);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).round()} weeks ago';
    return '${(difference.inDays / 30).round()} months ago';
  }

  /// Get read time label
  String get readTimeLabel {
    if (readTime < 1) return 'Quick read';
    if (readTime == 1) return '1 min read';
    return '${readTime} min read';
  }

  /// Get category color
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'gaming':
        return Colors.purple;
      case 'productivity':
        return Colors.green;
      case 'entertainment':
        return Colors.orange;
      case 'lifestyle':
        return Colors.pink;
      case 'business':
        return Colors.teal;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Get type icon
  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'news':
        return Icons.article;
      case 'tip':
        return Icons.lightbulb;
      case 'guide':
        return Icons.help;
      case 'review':
        return Icons.star;
      case 'announcement':
        return Icons.announcement;
      default:
        return Icons.article;
    }
  }

  /// Get type label
  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'news':
        return 'News';
      case 'tip':
        return 'Tip';
      case 'guide':
        return 'Guide';
      case 'review':
        return 'Review';
      case 'announcement':
        return 'Announcement';
      default:
        return 'Article';
    }
  }

  /// Get content preview (first 100 characters)
  String get contentPreview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// Check if content is recent (within 7 days)
  bool get isRecent => DateTime.now().difference(publishDate).inDays < 7;

  /// Check if content is popular (trending or featured)
  bool get isPopular => isTrending || isFeatured;

  /// Get ad type if has ad
  String? get adType {
    if (!hasAd) return null;
    return adData['type'] ?? 'native';
  }

  /// Get ad title if has ad
  String? get adTitle {
    if (!hasAd) return null;
    return adData['title'];
  }

  /// Get ad description if has ad
  String? get adDescription {
    if (!hasAd) return null;
    return adData['description'];
  }

  /// Get ad call to action if has ad
  String? get adCallToAction {
    if (!hasAd) return null;
    return adData['callToAction'] ?? 'Learn More';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewsItem &&
        other.id == id &&
        other.title == title &&
        other.publishDate == publishDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ publishDate.hashCode;
  }

  @override
  String toString() {
    return 'NewsItem(id: $id, title: $title, type: $type, category: $category)';
  }
}










