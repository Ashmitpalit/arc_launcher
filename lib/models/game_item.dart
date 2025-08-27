class GameItem {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final String packageName;
  final String? playStoreUrl;
  final GameCategory category;
  final double rating;
  final int downloadCount;
  final bool isPromoted;
  final String? promoText;
  final String? promoImageUrl;
  final DateTime? promoExpiresAt;
  final List<String> tags;
  final bool isInstalled;
  final DateTime createdAt;

  GameItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.packageName,
    this.playStoreUrl,
    required this.category,
    this.rating = 0.0,
    this.downloadCount = 0,
    this.isPromoted = false,
    this.promoText,
    this.promoImageUrl,
    this.promoExpiresAt,
    this.tags = const [],
    this.isInstalled = false,
    required this.createdAt,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      packageName: json['packageName'] ?? '',
      playStoreUrl: json['playStoreUrl'],
      category: GameCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => GameCategory.action,
      ),
      rating: (json['rating'] ?? 0.0).toDouble(),
      downloadCount: json['downloadCount'] ?? 0,
      isPromoted: json['isPromoted'] ?? false,
      promoText: json['promoText'],
      promoImageUrl: json['promoImageUrl'],
      promoExpiresAt: json['promoExpiresAt'] != null
          ? DateTime.parse(json['promoExpiresAt'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      isInstalled: json['isInstalled'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'packageName': packageName,
      'playStoreUrl': playStoreUrl,
      'category': category.toString().split('.').last,
      'rating': rating,
      'downloadCount': downloadCount,
      'isPromoted': isPromoted,
      'promoText': promoText,
      'promoImageUrl': promoImageUrl,
      'promoExpiresAt': promoExpiresAt?.toIso8601String(),
      'tags': tags,
      'isInstalled': isInstalled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get hasValidPromo {
    if (!isPromoted) return false;
    if (promoExpiresAt != null && DateTime.now().isAfter(promoExpiresAt!)) {
      return false;
    }
    return promoText != null || promoImageUrl != null;
  }
}

enum GameCategory {
  all,
  action,
  adventure,
  arcade,
  board,
  card,
  casual,
  educational,
  puzzle,
  racing,
  rpg,
  simulation,
  sports,
  strategy,
  trivia,
  other,
}
