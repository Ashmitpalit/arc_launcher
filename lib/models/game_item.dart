import 'package:flutter/material.dart';

/// Model representing a game item for PlayDeck
class GameItem {
  final String id;
  final String packageName;
  final String gameName;
  final String? description;
  final String? iconUrl;
  final String? iconPath; // Local cached icon path
  final String category;
  final String genre;
  final double rating; // 0.0 to 5.0
  final int downloadCount;
  final String size;
  final bool isPremium;
  final bool isInstalled;
  final bool isFeatured;
  final bool isTrending;
  final DateTime releaseDate;
  final List<String> tags;
  final Map<String, dynamic> gamingMetadata;
  final Map<String, dynamic> promoData;

  GameItem({
    required this.id,
    required this.packageName,
    required this.gameName,
    this.description,
    this.iconUrl,
    this.iconPath,
    required this.category,
    required this.genre,
    required this.rating,
    required this.downloadCount,
    required this.size,
    this.isPremium = false,
    this.isInstalled = false,
    this.isFeatured = false,
    this.isTrending = false,
    required this.releaseDate,
    this.tags = const [],
    this.gamingMetadata = const {},
    this.promoData = const {},
  });

  /// Create from JSON map
  factory GameItem.fromMap(Map<String, dynamic> map) {
    return GameItem(
      id: map['id'] ?? '',
      packageName: map['packageName'] ?? '',
      gameName: map['gameName'] ?? '',
      description: map['description'],
      iconUrl: map['iconUrl'],
      iconPath: map['iconPath'],
      category: map['category'] ?? 'Action',
      genre: map['genre'] ?? 'Arcade',
      rating: (map['rating'] ?? 4.0).toDouble(),
      downloadCount: map['downloadCount'] ?? 1000000,
      size: map['size'] ?? '50MB',
      isPremium: map['isPremium'] ?? false,
      isInstalled: map['isInstalled'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      isTrending: map['isTrending'] ?? false,
      releaseDate: DateTime.parse(map['releaseDate'] ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(map['tags'] ?? []),
      gamingMetadata: Map<String, dynamic>.from(map['gamingMetadata'] ?? {}),
      promoData: Map<String, dynamic>.from(map['promoData'] ?? {}),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'gameName': gameName,
      'description': description,
      'iconUrl': iconUrl,
      'iconPath': iconPath,
      'category': category,
      'genre': genre,
      'rating': rating,
      'downloadCount': downloadCount,
      'size': size,
      'isPremium': isPremium,
      'isInstalled': isInstalled,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'releaseDate': releaseDate.toIso8601String(),
      'tags': tags,
      'gamingMetadata': gamingMetadata,
      'promoData': promoData,
    };
  }

  /// Create a copy with updated values
  GameItem copyWith({
    String? id,
    String? packageName,
    String? gameName,
    String? description,
    String? iconUrl,
    String? iconPath,
    String? category,
    String? genre,
    double? rating,
    int? downloadCount,
    String? size,
    bool? isPremium,
    bool? isInstalled,
    bool? isFeatured,
    bool? isTrending,
    DateTime? releaseDate,
    List<String>? tags,
    Map<String, dynamic>? gamingMetadata,
    Map<String, dynamic>? promoData,
  }) {
    return GameItem(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      gameName: gameName ?? this.gameName,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      iconPath: iconPath ?? this.iconPath,
      category: category ?? this.category,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      downloadCount: downloadCount ?? this.downloadCount,
      size: size ?? this.size,
      isPremium: isPremium ?? this.isPremium,
      isInstalled: isInstalled ?? this.isInstalled,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      releaseDate: releaseDate ?? this.releaseDate,
      tags: tags ?? this.tags,
      gamingMetadata: gamingMetadata ?? this.gamingMetadata,
      promoData: promoData ?? this.promoData,
    );
  }

  /// Get formatted download count
  String get formattedDownloadCount {
    if (downloadCount >= 1000000000) {
      return '${(downloadCount / 1000000000).toStringAsFixed(1)}B+';
    } else if (downloadCount >= 1000000) {
      return '${(downloadCount / 1000000).toStringAsFixed(1)}M+';
    } else if (downloadCount >= 1000) {
      return '${(downloadCount / 1000).toStringAsFixed(1)}K+';
    }
    return downloadCount.toString();
  }

  /// Get formatted release date
  String get formattedReleaseDate {
    final now = DateTime.now();
    final difference = now.difference(releaseDate);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).round()} weeks ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).round()} months ago';
    return '${(difference.inDays / 365).round()} years ago';
  }

  /// Get rating stars
  List<Widget> get ratingStars {
    final fullStars = rating.floor();
    final hasHalfStar = rating % 1 >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    final stars = <Widget>[];
    
    // Full stars
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
    }
    
    // Half star
    if (hasHalfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
    }
    
    // Empty stars
    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.grey, size: 16));
    }
    
    return stars;
  }

  /// Get category color
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'action':
        return Colors.red;
      case 'adventure':
        return Colors.blue;
      case 'arcade':
        return Colors.green;
      case 'puzzle':
        return Colors.purple;
      case 'racing':
        return Colors.orange;
      case 'rpg':
        return Colors.teal;
      case 'simulation':
        return Colors.indigo;
      case 'sports':
        return Colors.lime;
      case 'strategy':
        return Colors.brown;
      case 'casual':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  /// Get genre icon
  IconData get genreIcon {
    switch (genre.toLowerCase()) {
      case 'action':
        return Icons.flash_on;
      case 'adventure':
        return Icons.explore;
      case 'arcade':
        return Icons.games;
      case 'puzzle':
        return Icons.extension;
      case 'racing':
        return Icons.speed;
      case 'rpg':
        return Icons.person;
      case 'simulation':
        return Icons.build;
      case 'sports':
        return Icons.sports_soccer;
      case 'strategy':
        return Icons.psychology;
      case 'casual':
        return Icons.favorite;
      default:
        return Icons.sports_esports;
    }
  }

  /// Get game age
  int get gameAgeDays {
    return DateTime.now().difference(releaseDate).inDays;
  }

  /// Get game age label
  String get gameAgeLabel {
    final age = gameAgeDays;
    if (age == 0) return 'New Release';
    if (age < 7) return 'This Week';
    if (age < 30) return 'This Month';
    if (age < 90) return 'Recent';
    if (age < 365) return 'Popular';
    return 'Classic';
  }

  /// Check if game is new (released within 30 days)
  bool get isNewRelease => gameAgeDays < 30;

  /// Check if game is popular (high rating and downloads)
  bool get isPopular => rating >= 4.0 && downloadCount >= 1000000;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameItem &&
        other.id == id &&
        other.packageName == packageName &&
        other.gameName == gameName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ packageName.hashCode ^ gameName.hashCode;
  }

  @override
  String toString() {
    return 'GameItem(id: $id, gameName: $gameName, rating: $rating)';
  }
}
