import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_item.dart';

/// Service for managing Info Screen content and native ads
class InfoScreenService {
  static final InfoScreenService _instance = InfoScreenService._internal();
  factory InfoScreenService() => _instance;
  InfoScreenService._internal();

  static const String _newsKey = 'info_screen_news';
  static const String _userPreferencesKey = 'info_screen_user_preferences';
  static const String _readingHistoryKey = 'info_screen_reading_history';
  static const String _adSettingsKey = 'info_screen_ad_settings';

  List<NewsItem> _newsItems = [];
  Map<String, dynamic> _userPreferences = {};
  List<String> _readingHistory = [];
  Map<String, dynamic> _adSettings = {};
  bool _isInitialized = false;

  /// Get all news items
  List<NewsItem> get newsItems => List.unmodifiable(_newsItems);

  /// Get featured news
  List<NewsItem> get featuredNews {
    return _newsItems.where((item) => item.isFeatured).toList();
  }

  /// Get trending news
  List<NewsItem> get trendingNews {
    return _newsItems.where((item) => item.isTrending).toList();
  }

  /// Get recent news (within 7 days)
  List<NewsItem> get recentNews {
    return _newsItems.where((item) => item.isRecent).toList();
  }

  /// Get news with ads
  List<NewsItem> get newsWithAds {
    return _newsItems.where((item) => item.hasAd).toList();
  }

  /// Get premium content
  List<NewsItem> get premiumContent {
    return _newsItems.where((item) => item.isPremium).toList();
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadUserPreferences();
      await _loadReadingHistory();
      await _loadAdSettings();
      await _generateNewsContent();
      _isInitialized = true;
      print('InfoScreenService initialized with ${_newsItems.length} news items');
    } catch (e) {
      print('Error initializing InfoScreenService: $e');
      await _loadDefaultNews();
    }
  }

  /// Load user preferences from storage
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? preferencesJson = prefs.getString(_userPreferencesKey);

      if (preferencesJson != null) {
        _userPreferences = Map<String, dynamic>.from(json.decode(preferencesJson));
      } else {
        // Set default preferences
        _userPreferences = {
          'preferredCategories': ['Technology', 'Gaming', 'Productivity'],
          'avoidCategories': ['Adult', 'Violence'],
          'preferShortContent': true,
          'maxNewsItems': 50,
          'adFrequency': 'moderate', // low, moderate, high
          'contentLanguage': 'en',
        };
      }
    } catch (e) {
      print('Error loading user preferences: $e');
      _userPreferences = {};
    }
  }

  /// Load reading history from storage
  Future<void> _loadReadingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_readingHistoryKey);

      if (historyJson != null) {
        _readingHistory = List<String>.from(json.decode(historyJson));
      }
    } catch (e) {
      print('Error loading reading history: $e');
      _readingHistory = [];
    }
  }

  /// Load ad settings from storage
  Future<void> _loadAdSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? adSettingsJson = prefs.getString(_adSettingsKey);

      if (adSettingsJson != null) {
        _adSettings = Map<String, dynamic>.from(json.decode(adSettingsJson));
      } else {
        // Set default ad settings
        _adSettings = {
          'nativeAdsEnabled': true,
          'adRefreshRate': 300, // seconds
          'maxAdsPerSession': 10,
          'adCategories': ['technology', 'gaming', 'productivity'],
          'adPlacement': 'natural', // natural, bottom, top
        };
      }
    } catch (e) {
      print('Error loading ad settings: $e');
      _adSettings = {};
    }
  }

  /// Save user preferences to storage
  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String preferencesJson = json.encode(_userPreferences);
      await prefs.setString(_userPreferencesKey, preferencesJson);
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  /// Save reading history to storage
  Future<void> _saveReadingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = json.encode(_readingHistory);
      await prefs.setString(_readingHistoryKey, historyJson);
    } catch (e) {
      print('Error saving reading history: $e');
    }
  }

  /// Save ad settings to storage
  Future<void> _saveAdSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String adSettingsJson = json.encode(_adSettings);
      await prefs.setString(_adSettingsKey, adSettingsJson);
    } catch (e) {
      print('Error saving ad settings: $e');
    }
  }

  /// Generate news content
  Future<void> _generateNewsContent() async {
    _newsItems = [
      // Technology News
      NewsItem(
        id: 'tech_1',
        title: 'Android 15 Developer Preview Released',
        subtitle: 'Google launches latest Android version with new features',
        content: 'Google has released the Android 15 Developer Preview, introducing new privacy features, improved battery optimization, and enhanced AI capabilities. The new version focuses on user privacy, performance improvements, and developer tools.',
        imageUrl: 'https://via.placeholder.com/400x200/2196F3/FFFFFF?text=Android+15',
        category: 'Technology',
        type: 'news',
        publishDate: DateTime.now().subtract(const Duration(hours: 2)),
        author: 'Tech Reporter',
        readTime: 5,
        isFeatured: true,
        isTrending: true,
        tags: ['android', 'google', 'mobile', 'ai'],
        metadata: {
          'source': 'Android Developers',
          'verified': true,
          'engagement': 'high',
          'url': 'https://developer.android.com/about/versions/15',
        },
      ),
      
      // Gaming News
      NewsItem(
        id: 'gaming_1',
        title: 'Mobile Gaming Market Growth 2024',
        subtitle: 'Record-breaking revenue and user engagement',
        content: 'The mobile gaming market continues its explosive growth with cloud gaming, AR integration, and cross-platform play. Mobile games now account for over 50% of the global gaming market revenue.',
        imageUrl: 'https://via.placeholder.com/400x200/9C27B0/FFFFFF?text=Mobile+Gaming',
        category: 'Gaming',
        type: 'guide',
        publishDate: DateTime.now().subtract(const Duration(hours: 6)),
        author: 'Gaming Expert',
        readTime: 8,
        isFeatured: true,
        tags: ['mobile gaming', 'trends', 'technology', 'entertainment'],
        metadata: {
          'source': 'Newzoo',
          'verified': true,
          'engagement': 'medium',
          'url': 'https://newzoo.com/insights/articles/mobile-gaming-market-2024',
        },
      ),
      
      // Productivity Tips
      NewsItem(
        id: 'productivity_1',
        title: 'Android Launcher Customization Guide',
        subtitle: 'Maximize your home screen efficiency',
        content: 'Transform your Android launcher into a productivity powerhouse with these essential customization tips. From widget optimization to gesture shortcuts, learn how to make your device work smarter, not harder.',
        imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Productivity+Tips',
        category: 'Productivity',
        type: 'tip',
        publishDate: DateTime.now().subtract(const Duration(days: 1)),
        author: 'Productivity Coach',
        readTime: 6,
        isTrending: true,
        tags: ['android', 'launcher', 'productivity', 'tips'],
        metadata: {
          'source': 'Android Authority',
          'verified': true,
          'engagement': 'high',
          'url': 'https://www.androidauthority.com/best-android-launchers-2024',
        },
      ),
      
      // Native Ad Example
      NewsItem(
        id: 'ad_1',
        title: 'Sponsored: Flutter Development Tools',
        subtitle: 'Professional tools for mobile developers',
        content: 'Discover professional-grade Flutter development tools that can significantly improve your app\'s performance and user experience. Used by top developers worldwide.',
        imageUrl: 'https://via.placeholder.com/400x200/FF9800/FFFFFF?text=Sponsored+Content',
        category: 'Technology',
        type: 'news',
        publishDate: DateTime.now().subtract(const Duration(hours: 12)),
        author: 'Sponsored Content',
        readTime: 3,
        hasAd: true,
        adData: {
          'type': 'native',
          'title': 'Flutter Dev Tools',
          'description': 'Professional development tools',
          'callToAction': 'Learn More',
          'advertiser': 'Flutter Team',
          'clickUrl': 'https://docs.flutter.dev/get-started/editor',
        },
        tags: ['sponsored', 'development', 'tools', 'flutter'],
        metadata: {
          'source': 'Sponsored',
          'verified': false,
          'engagement': 'low',
          'url': 'https://docs.flutter.dev/get-started/editor',
        },
      ),
      
      // Lifestyle Content
      NewsItem(
        id: 'lifestyle_1',
        title: 'Digital Wellness: Finding Balance in Tech',
        subtitle: 'Maintain healthy relationships with technology',
        content: 'In our connected world, maintaining digital wellness is crucial. Learn practical strategies to balance technology use with real-life experiences, ensuring your devices enhance rather than dominate your life.',
        imageUrl: 'https://via.placeholder.com/400x200/E91E63/FFFFFF?text=Digital+Wellness',
        category: 'Lifestyle',
        type: 'guide',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        author: 'Wellness Expert',
        readTime: 7,
        tags: ['wellness', 'technology', 'balance', 'health'],
        metadata: {
          'source': 'Google Digital Wellbeing',
          'verified': true,
          'engagement': 'medium',
          'url': 'https://wellbeing.google/',
        },
      ),
      
      // Business News
      NewsItem(
        id: 'business_1',
        title: 'Mobile App Market Growth in 2024',
        subtitle: 'Record-breaking revenue and user engagement',
        content: 'The mobile app market continues its explosive growth with unprecedented revenue figures and user engagement metrics. Explore the key factors driving this success and what it means for developers and users alike.',
        imageUrl: 'https://via.placeholder.com/400x200/009688/FFFFFF?text=App+Market',
        category: 'Business',
        type: 'news',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        author: 'Business Analyst',
        readTime: 9,
        isFeatured: true,
        tags: ['business', 'mobile apps', 'market', 'revenue'],
        metadata: {
          'source': 'Statista',
          'verified': true,
          'engagement': 'high',
          'url': 'https://www.statista.com/outlook/dmo/mobile-apps/worldwide',
        },
      ),
      
      // Health & Fitness
      NewsItem(
        id: 'health_1',
        title: 'Fitness Apps: Your Digital Workout Partner',
        subtitle: 'How technology is revolutionizing fitness',
        content: 'Modern fitness apps are transforming how we approach health and wellness. From AI-powered workout plans to social fitness communities, discover how your smartphone can become your ultimate fitness companion.',
        imageUrl: 'https://via.placeholder.com/400x200/F44336/FFFFFF?text=Fitness+Apps',
        category: 'Health',
        type: 'review',
        publishDate: DateTime.now().subtract(const Duration(days: 4)),
        author: 'Fitness Trainer',
        readTime: 6,
        tags: ['fitness', 'health', 'apps', 'technology'],
        metadata: {
          'source': 'Healthline',
          'verified': true,
          'engagement': 'medium',
          'url': 'https://www.healthline.com/health/fitness-exercise/best-fitness-apps',
        },
      ),
      
      // Education Content
      NewsItem(
        id: 'education_1',
        title: 'Learning on the Go: Educational Apps Review',
        subtitle: 'Top apps for continuous learning',
        content: 'Never stop learning with these exceptional educational apps designed for mobile users. From language learning to professional development, these apps make education accessible anywhere, anytime.',
        imageUrl: 'https://via.placeholder.com/400x200/3F51B5/FFFFFF?text=Educational+Apps',
        category: 'Education',
        type: 'review',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        author: 'Education Specialist',
        readTime: 8,
        tags: ['education', 'learning', 'apps', 'mobile'],
        metadata: {
          'source': 'Common Sense Media',
          'verified': true,
          'engagement': 'medium',
          'url': 'https://www.commonsensemedia.org/lists/educational-apps',
        },
      ),
      
      // Entertainment News
      NewsItem(
        id: 'entertainment_1',
        title: 'Streaming Wars: New Mobile Entertainment Options',
        subtitle: 'Latest developments in mobile streaming',
        content: 'The streaming landscape is evolving rapidly with new mobile-first platforms and features. Stay updated on the latest developments that are changing how we consume entertainment on our devices.',
        imageUrl: 'https://via.placeholder.com/400x200/FF9800/FFFFFF?text=Streaming+Wars',
        category: 'Entertainment',
        type: 'news',
        publishDate: DateTime.now().subtract(const Duration(days: 6)),
        author: 'Entertainment Reporter',
        readTime: 5,
        tags: ['streaming', 'entertainment', 'mobile', 'technology'],
        metadata: {
          'source': 'Variety',
          'verified': true,
          'engagement': 'high',
          'url': 'https://variety.com/t/streaming/',
        },
      ),
      
      // Premium Content Example
      NewsItem(
        id: 'premium_1',
        title: 'Advanced Launcher Customization Guide',
        subtitle: 'Pro-level tips and tricks for power users',
        content: 'Unlock the full potential of your Android launcher with advanced customization techniques. This comprehensive guide covers everything from custom themes to automation scripts for the ultimate personalized experience.',
        imageUrl: 'https://via.placeholder.com/400x200/FFD700/FFFFFF?text=Premium+Guide',
        category: 'Technology',
        type: 'guide',
        publishDate: DateTime.now().subtract(const Duration(days: 7)),
        author: 'Launcher Expert',
        readTime: 15,
        isPremium: true,
        tags: ['premium', 'launcher', 'customization', 'advanced'],
        metadata: {
          'source': 'XDA Developers',
          'verified': true,
          'engagement': 'high',
          'url': 'https://www.xda-developers.com/',
        },
      ),
    ];

    // Filter based on user preferences
    _filterNewsByPreferences();
  }

  /// Load default news if generation fails
  Future<void> _loadDefaultNews() async {
    _newsItems = [
      NewsItem(
        id: 'default',
        title: 'Welcome to Arc Launcher',
        subtitle: 'Your personalized Android experience',
        content: 'Welcome to Arc Launcher! This is your new home for personalized content, tips, and news.',
        category: 'General',
        type: 'announcement',
        publishDate: DateTime.now(),
        author: 'Arc Team',
        readTime: 2,
      ),
    ];
    _isInitialized = true;
  }

  /// Filter news based on user preferences
  void _filterNewsByPreferences() {
    final maxItems = _userPreferences['maxNewsItems'] ?? 50;
    final avoidCategories = List<String>.from(_userPreferences['avoidCategories'] ?? []);

    _newsItems = _newsItems.where((item) {
      // Check avoided categories
      if (avoidCategories.contains(item.category)) return false;
      
      return true;
    }).take(maxItems).toList();
  }

  /// Get news by category
  List<NewsItem> getNewsByCategory(String category) {
    if (category == 'All') {
      return _newsItems;
    }
    return _newsItems.where((item) => item.category == category).toList();
  }

  /// Get news by type
  List<NewsItem> getNewsByType(String type) {
    return _newsItems.where((item) => item.type == type).toList();
  }

  /// Search news
  List<NewsItem> searchNews(String query) {
    if (query.isEmpty) return _newsItems;
    
    final lowercaseQuery = query.toLowerCase();
    return _newsItems.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
             item.subtitle?.toLowerCase().contains(lowercaseQuery) == true ||
             item.content.toLowerCase().contains(lowercaseQuery) ||
             item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get personalized news recommendations
  List<NewsItem> getPersonalizedRecommendations({int limit = 5}) {
    List<NewsItem> recommendations = List.from(_newsItems);
    
    // Sort by personalization score
    recommendations.sort((a, b) {
      final scoreA = _calculatePersonalizationScore(a);
      final scoreB = _calculatePersonalizationScore(b);
      return scoreB.compareTo(scoreA);
    });
    
    return recommendations.take(limit).toList();
  }

  /// Calculate personalization score for news item
  double _calculatePersonalizationScore(NewsItem item) {
    double score = 0.0;
    
    // Bonus for preferred categories
    final preferredCategories = List<String>.from(_userPreferences['preferredCategories'] ?? []);
    if (preferredCategories.contains(item.category)) {
      score += 0.3; // 30% bonus for preferred categories
    }
    
    // Bonus for short content if user prefers it
    if (_userPreferences['preferShortContent'] == true && item.readTime <= 5) {
      score += 0.2; // 20% bonus for short content
    }
    
    // Bonus for trending/featured content
    if (item.isTrending || item.isFeatured) {
      score += 0.2; // 20% bonus for popular content
    }
    
    // Bonus for recent content
    if (item.isRecent) {
      score += 0.15; // 15% bonus for recent content
    }
    
    // Bonus for unread content
    if (!_readingHistory.contains(item.id)) {
      score += 0.15; // 15% bonus for unread content
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> newPreferences) async {
    _userPreferences.addAll(newPreferences);
    await _saveUserPreferences();
    
    // Re-filter news
    _filterNewsByPreferences();
  }

  /// Update ad settings
  Future<void> updateAdSettings(Map<String, dynamic> newSettings) async {
    _adSettings.addAll(newSettings);
    await _saveAdSettings();
  }

  /// Mark news item as read
  Future<void> markNewsAsRead(String newsId) async {
    if (!_readingHistory.contains(newsId)) {
      _readingHistory.add(newsId);
      await _saveReadingHistory();
    }
  }

  /// Get news statistics
  Map<String, dynamic> getNewsStats() {
    final totalNews = _newsItems.length;
    final featuredNews = _newsItems.where((item) => item.isFeatured).length;
    final trendingNews = _newsItems.where((item) => item.isTrending).length;
    final premiumNews = _newsItems.where((item) => item.isPremium).length;
    final newsWithAds = _newsItems.where((item) => item.hasAd).length;
    
    final categoryStats = <String, int>{};
    final typeStats = <String, int>{};
    
    for (final item in _newsItems) {
      categoryStats[item.category] = (categoryStats[item.category] ?? 0) + 1;
      typeStats[item.type] = (typeStats[item.type] ?? 0) + 1;
    }

    final avgReadTime = _newsItems.isNotEmpty 
        ? _newsItems.map((item) => item.readTime).reduce((a, b) => a + b) / _newsItems.length
        : 0.0;

    return {
      'totalNews': totalNews,
      'featuredNews': featuredNews,
      'trendingNews': trendingNews,
      'premiumNews': premiumNews,
      'newsWithAds': newsWithAds,
      'averageReadTime': avgReadTime.toStringAsFixed(1),
      'categoryDistribution': categoryStats,
      'typeDistribution': typeStats,
      'readNews': _readingHistory.length,
      'adSettings': _adSettings,
    };
  }

  /// Get available categories
  List<String> getAvailableCategories() {
    final categories = _newsItems.map((item) => item.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  /// Get available types
  List<String> getAvailableTypes() {
    final types = _newsItems.map((item) => item.type).toSet().toList();
    types.sort();
    return ['All', ...types];
  }

  /// Refresh news content
  Future<void> refresh() async {
    await _generateNewsContent();
  }

  /// Dispose resources
  void dispose() {
    _newsItems.clear();
    _userPreferences.clear();
    _readingHistory.clear();
    _adSettings.clear();
    _isInitialized = false;
  }
}
