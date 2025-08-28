import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_recommendation.dart';
import '../models/app_shortcut.dart';

/// Service for managing app recommendations and smart suggestions
class AppRecommendationService {
  static final AppRecommendationService _instance = AppRecommendationService._internal();
  factory AppRecommendationService() => _instance;
  AppRecommendationService._internal();

  static const String _recommendationsKey = 'app_recommendations';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _recommendationHistoryKey = 'recommendation_history';

  List<AppRecommendation> _recommendations = [];
  Map<String, dynamic> _userPreferences = {};
  List<String> _recommendationHistory = [];
  bool _isInitialized = false;

  /// Get all recommendations
  List<AppRecommendation> get recommendations => List.unmodifiable(_recommendations);

  /// Get top recommendations (sorted by priority and confidence)
  List<AppRecommendation> get topRecommendations {
    final sorted = List<AppRecommendation>.from(_recommendations);
    sorted.sort((a, b) {
      // First by priority (descending)
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      // Then by confidence score (descending)
      return b.confidenceScore.compareTo(a.confidenceScore);
    });
    return sorted;
  }

  /// Get recommendations by category
  List<AppRecommendation> getRecommendationsByCategory(String category) {
    return _recommendations.where((rec) => rec.category == category).toList();
  }

  /// Get premium recommendations
  List<AppRecommendation> get premiumRecommendations {
    return _recommendations.where((rec) => rec.isPremium).toList();
  }

  /// Get high confidence recommendations (>= 0.7)
  List<AppRecommendation> get highConfidenceRecommendations {
    return _recommendations.where((rec) => rec.confidenceScore >= 0.7).toList();
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadUserPreferences();
      await _loadRecommendationHistory();
      await _generateRecommendations();
      _isInitialized = true;
      print('AppRecommendationService initialized with ${_recommendations.length} recommendations');
    } catch (e) {
      print('Error initializing AppRecommendationService: $e');
      await _loadDefaultRecommendations();
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
          'preferredCategories': ['Productivity', 'Entertainment', 'Social'],
          'avoidCategories': ['Gambling', 'Adult'],
          'preferFreeApps': true,
          'maxRecommendations': 10,
          'minConfidenceScore': 0.5,
        };
      }
    } catch (e) {
      print('Error loading user preferences: $e');
      _userPreferences = {};
    }
  }

  /// Load recommendation history from storage
  Future<void> _loadRecommendationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_recommendationHistoryKey);

      if (historyJson != null) {
        _recommendationHistory = List<String>.from(json.decode(historyJson));
      }
    } catch (e) {
      print('Error loading recommendation history: $e');
      _recommendationHistory = [];
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

  /// Save recommendation history to storage
  Future<void> _saveRecommendationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = json.encode(_recommendationHistory);
      await prefs.setString(_recommendationHistoryKey, historyJson);
    } catch (e) {
      print('Error saving recommendation history: $e');
    }
  }

  /// Generate smart recommendations
  Future<void> _generateRecommendations() async {
    _recommendations = [
      // Productivity Apps
      AppRecommendation(
        id: 'notion',
        packageName: 'com.notion.id',
        appName: 'Notion',
        description: 'All-in-one workspace for notes, docs, and collaboration',
        category: 'Productivity',
        recommendationReason: 'Based on your productivity app usage',
        confidenceScore: 0.85,
        priority: 9,
        isPremium: false,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.8,
          'downloads': '10M+',
          'size': '45MB',
        },
      ),
      AppRecommendation(
        id: 'trello',
        packageName: 'com.trello',
        appName: 'Trello',
        description: 'Organize and prioritize your projects',
        category: 'Productivity',
        recommendationReason: 'Popular project management tool',
        confidenceScore: 0.78,
        priority: 8,
        isPremium: false,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.6,
          'downloads': '50M+',
          'size': '32MB',
        },
      ),
      
      // Entertainment Apps
      AppRecommendation(
        id: 'spotify',
        packageName: 'com.spotify.music',
        appName: 'Spotify',
        description: 'Music streaming with millions of songs',
        category: 'Entertainment',
        recommendationReason: 'Based on your music app preferences',
        confidenceScore: 0.92,
        priority: 10,
        isPremium: true,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.7,
          'downloads': '1B+',
          'size': '85MB',
        },
      ),
      AppRecommendation(
        id: 'netflix',
        packageName: 'com.netflix.mediaclient',
        appName: 'Netflix',
        description: 'Stream TV shows and movies',
        category: 'Entertainment',
        recommendationReason: 'Top entertainment app',
        confidenceScore: 0.88,
        priority: 9,
        isPremium: true,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.5,
          'downloads': '500M+',
          'size': '120MB',
        },
      ),
      
      // Social Apps
      AppRecommendation(
        id: 'discord',
        packageName: 'com.discord',
        appName: 'Discord',
        description: 'Voice and text chat for communities',
        category: 'Social',
        recommendationReason: 'Popular communication platform',
        confidenceScore: 0.75,
        priority: 7,
        isPremium: false,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.4,
          'downloads': '100M+',
          'size': '65MB',
        },
      ),
      
      // Utility Apps
      AppRecommendation(
        id: 'lastpass',
        packageName: 'com.lastpass.lpandroid',
        appName: 'LastPass',
        description: 'Password manager and digital vault',
        category: 'Utility',
        recommendationReason: 'Security and privacy focused',
        confidenceScore: 0.82,
        priority: 8,
        isPremium: true,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.6,
          'downloads': '10M+',
          'size': '28MB',
        },
      ),
      
      // Health & Fitness
      AppRecommendation(
        id: 'strava',
        packageName: 'com.strava',
        appName: 'Strava',
        description: 'Track your fitness activities',
        category: 'Health & Fitness',
        recommendationReason: 'Based on your active lifestyle',
        confidenceScore: 0.70,
        priority: 6,
        isPremium: false,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.5,
          'downloads': '50M+',
          'size': '55MB',
        },
      ),
      
      // Education
      AppRecommendation(
        id: 'duolingo',
        packageName: 'com.duolingo',
        appName: 'Duolingo',
        description: 'Learn languages for free',
        category: 'Education',
        recommendationReason: 'Popular learning platform',
        confidenceScore: 0.68,
        priority: 6,
        isPremium: false,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.4,
          'downloads': '200M+',
          'size': '42MB',
        },
      ),
      
      // Photography
      AppRecommendation(
        id: 'vsco',
        packageName: 'com.vsco.cam',
        appName: 'VSCO',
        description: 'Photo and video editor',
        category: 'Photography',
        recommendationReason: 'Creative photo editing',
        confidenceScore: 0.65,
        priority: 5,
        isPremium: false,
        recommendationDate: DateTime.now(),
        metadata: {
          'rating': 4.3,
          'downloads': '100M+',
          'size': '75MB',
        },
      ),
    ];

    // Filter based on user preferences
    _filterRecommendationsByPreferences();
  }

  /// Load default recommendations if generation fails
  Future<void> _loadDefaultRecommendations() async {
    _recommendations = [
      AppRecommendation(
        id: 'default',
        packageName: 'com.example.app',
        appName: 'Example App',
        description: 'A great app recommendation',
        category: 'General',
        recommendationReason: 'Recommended for you',
        confidenceScore: 0.5,
        priority: 5,
        isPremium: false,
        recommendationDate: DateTime.now(),
      ),
    ];
    _isInitialized = true;
  }

  /// Filter recommendations based on user preferences
  void _filterRecommendationsByPreferences() {
    final maxRecs = _userPreferences['maxRecommendations'] ?? 10;
    final minConfidence = _userPreferences['minConfidenceScore'] ?? 0.5;
    final avoidCategories = List<String>.from(_userPreferences['avoidCategories'] ?? []);

    _recommendations = _recommendations.where((rec) {
      // Check confidence score
      if (rec.confidenceScore < minConfidence) return false;
      
      // Check avoided categories
      if (avoidCategories.contains(rec.category)) return false;
      
      return true;
    }).take(maxRecs).toList();
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> newPreferences) async {
    _userPreferences.addAll(newPreferences);
    await _saveUserPreferences();
    
    // Re-filter recommendations
    _filterRecommendationsByPreferences();
  }

  /// Get personalized recommendations
  List<AppRecommendation> getPersonalizedRecommendations({
    int limit = 5,
    String? category,
    bool? premiumOnly,
  }) {
    List<AppRecommendation> filtered = List.from(_recommendations);

    // Filter by category if specified
    if (category != null) {
      filtered = filtered.where((rec) => rec.category == category).toList();
    }

    // Filter by premium if specified
    if (premiumOnly != null) {
      filtered = filtered.where((rec) => rec.isPremium == premiumOnly).toList();
    }

    // Sort by personalization score
    filtered.sort((a, b) {
      final scoreA = _calculatePersonalizationScore(a);
      final scoreB = _calculatePersonalizationScore(b);
      return scoreB.compareTo(scoreA);
    });

    return filtered.take(limit).toList();
  }

  /// Calculate personalization score for a recommendation
  double _calculatePersonalizationScore(AppRecommendation rec) {
    double score = rec.confidenceScore * 0.4; // 40% weight to confidence
    score += (rec.priority / 10.0) * 0.3; // 30% weight to priority
    
    // Bonus for preferred categories
    final preferredCategories = List<String>.from(_userPreferences['preferredCategories'] ?? []);
    if (preferredCategories.contains(rec.category)) {
      score += 0.2; // 20% bonus for preferred categories
    }
    
    // Bonus for free apps if user prefers them
    if (_userPreferences['preferFreeApps'] == true && !rec.isPremium) {
      score += 0.1; // 10% bonus for free apps
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// Mark recommendation as viewed
  Future<void> markRecommendationViewed(String recommendationId) async {
    if (!_recommendationHistory.contains(recommendationId)) {
      _recommendationHistory.add(recommendationId);
      await _saveRecommendationHistory();
    }
  }

  /// Mark recommendation as installed
  Future<void> markRecommendationInstalled(String recommendationId) async {
    final index = _recommendations.indexWhere((rec) => rec.id == recommendationId);
    if (index != -1) {
      _recommendations[index] = _recommendations[index].copyWith(isInstalled: true);
      
      // Add to history
      await markRecommendationViewed(recommendationId);
    }
  }

  /// Get recommendation statistics
  Map<String, dynamic> getRecommendationStats() {
    final totalRecs = _recommendations.length;
    final premiumRecs = _recommendations.where((rec) => rec.isPremium).length;
    final highConfidenceRecs = _recommendations.where((rec) => rec.confidenceScore >= 0.8).length;
    final installedRecs = _recommendations.where((rec) => rec.isInstalled).length;
    
    final categoryStats = <String, int>{};
    for (final rec in _recommendations) {
      categoryStats[rec.category] = (categoryStats[rec.category] ?? 0) + 1;
    }

    final avgConfidence = _recommendations.isNotEmpty 
        ? _recommendations.map((rec) => rec.confidenceScore).reduce((a, b) => a + b) / _recommendations.length
        : 0.0;

    return {
      'totalRecommendations': totalRecs,
      'premiumRecommendations': premiumRecs,
      'highConfidenceRecommendations': highConfidenceRecs,
      'installedRecommendations': installedRecs,
      'averageConfidenceScore': avgConfidence.toStringAsFixed(2),
      'categoryDistribution': categoryStats,
      'viewedRecommendations': _recommendationHistory.length,
    };
  }

  /// Refresh recommendations
  Future<void> refreshRecommendations() async {
    await _generateRecommendations();
  }

  /// Get trending apps (simulated)
  List<AppRecommendation> getTrendingApps({int limit = 5}) {
    final trending = List<AppRecommendation>.from(_recommendations);
    
    // Simulate trending by adding some randomness to scores
    for (int i = 0; i < trending.length; i++) {
      final random = Random();
      final trendBonus = random.nextDouble() * 0.2; // 0-20% bonus
      trending[i] = trending[i].copyWith(
        confidenceScore: (trending[i].confidenceScore + trendBonus).clamp(0.0, 1.0),
      );
    }
    
    // Sort by trending score
    trending.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    
    return trending.take(limit).toList();
  }

  /// Open Play Store for app installation
  Future<bool> openPlayStore(String packageName) async {
    try {
      // Play Store URL format
      final playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
      
      if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
        return await launchUrl(
          Uri.parse(playStoreUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      print('Error opening Play Store: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _recommendations.clear();
    _userPreferences.clear();
    _recommendationHistory.clear();
    _isInitialized = false;
  }
}
