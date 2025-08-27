class NewsItem {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? author;
  final DateTime publishedAt;
  final List<String> categories;
  final bool isSponsored;
  final String? sponsorName;
  final String? sponsorLogoUrl;
  final String? sponsorUrl;
  final bool isNativeAd;
  final String? adId;
  final DateTime createdAt;
  final DateTime? expiresAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.author,
    required this.publishedAt,
    this.categories = const [],
    this.isSponsored = false,
    this.sponsorName,
    this.sponsorLogoUrl,
    this.sponsorUrl,
    this.isNativeAd = false,
    this.adId,
    required this.createdAt,
    this.expiresAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      author: json['author'],
      publishedAt: DateTime.parse(json['publishedAt']),
      categories: List<String>.from(json['categories'] ?? []),
      isSponsored: json['isSponsored'] ?? false,
      sponsorName: json['sponsorName'],
      sponsorLogoUrl: json['sponsorLogoUrl'],
      sponsorUrl: json['sponsorUrl'],
      isNativeAd: json['isNativeAd'] ?? false,
      adId: json['adId'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
      'categories': categories,
      'isSponsored': isSponsored,
      'sponsorName': sponsorName,
      'sponsorLogoUrl': sponsorLogoUrl,
      'sponsorUrl': sponsorUrl,
      'isNativeAd': isNativeAd,
      'adId': adId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  bool get isValid {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  bool get isRecent {
    final daysSincePublished = DateTime.now().difference(publishedAt).inDays;
    return daysSincePublished <= 7; // Consider recent if published within 7 days
  }
}









