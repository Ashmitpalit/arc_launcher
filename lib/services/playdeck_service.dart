import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game_item.dart';

/// Service for managing PlayDeck games and gaming features
class PlayDeckService {
  static final PlayDeckService _instance = PlayDeckService._internal();
  factory PlayDeckService() => _instance;
  PlayDeckService._internal();

  static const String _gamesKey = 'playdeck_games';
  static const String _promoTilesKey = 'playdeck_promo_tiles';
  static const String _userPreferencesKey = 'playdeck_user_preferences';
  static const String _gamingHistoryKey = 'playdeck_gaming_history';

  List<GameItem> _games = [];
  List<Map<String, dynamic>> _promoTiles = [];
  Map<String, dynamic> _userPreferences = {};
  List<String> _gamingHistory = [];
  bool _isInitialized = false;

  /// Get all games
  List<GameItem> get games => List.unmodifiable(_games);

  /// Get featured games
  List<GameItem> get featuredGames {
    return _games.where((game) => game.isFeatured).toList();
  }

  /// Get trending games
  List<GameItem> get trendingGames {
    return _games.where((game) => game.isTrending).toList();
  }

  /// Get new releases (within 30 days)
  List<GameItem> get newReleases {
    return _games.where((game) => game.isNewRelease).toList();
  }

  /// Get popular games (high rating + downloads)
  List<GameItem> get popularGames {
    return _games.where((game) => game.isPopular).toList();
  }

  /// Get promo tiles
  List<Map<String, dynamic>> get promoTiles => List.unmodifiable(_promoTiles);

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadUserPreferences();
      await _loadGamingHistory();
      await _generateGames();
      await _generatePromoTiles();
      _isInitialized = true;
      print('PlayDeckService initialized with ${_games.length} games and ${_promoTiles.length} promo tiles');
    } catch (e) {
      print('Error initializing PlayDeckService: $e');
      await _loadDefaultGames();
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
          'preferredGenres': ['Action', 'Adventure', 'Arcade'],
          'avoidGenres': ['Gambling', 'Adult'],
          'preferFreeGames': true,
          'maxGames': 20,
          'minRating': 3.5,
          'gamingMode': 'balanced', // balanced, performance, battery
        };
      }
    } catch (e) {
      print('Error loading user preferences: $e');
      _userPreferences = {};
    }
  }

  /// Load gaming history from storage
  Future<void> _loadGamingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_gamingHistoryKey);

      if (historyJson != null) {
        _gamingHistory = List<String>.from(json.decode(historyJson));
      }
    } catch (e) {
      print('Error loading gaming history: $e');
      _gamingHistory = [];
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

  /// Save gaming history to storage
  Future<void> _saveGamingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = json.encode(_gamingHistory);
      await prefs.setString(_gamingHistoryKey, historyJson);
    } catch (e) {
      print('Error saving gaming history: $e');
    }
  }

  /// Generate games data
  Future<void> _generateGames() async {
    _games = [
      // Action Games
      GameItem(
        id: 'pubg',
        packageName: 'com.tencent.ig',
        gameName: 'PUBG Mobile',
        description: 'Battle royale game with intense action and strategy',
        category: 'Action',
        genre: 'Battle Royale',
        rating: 4.2,
        downloadCount: 1000000000,
        size: '2.1GB',
        isPremium: false,
        isFeatured: true,
        isTrending: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 15)),
        tags: ['battle royale', 'shooting', 'multiplayer'],
        gamingMetadata: {
          'players': '100 players',
          'duration': '20-30 min',
          'difficulty': 'Hard',
        },
      ),
      GameItem(
        id: 'cod',
        packageName: 'com.activision.callofduty.shooter',
        gameName: 'Call of Duty: Mobile',
        description: 'Fast-paced FPS with multiple game modes',
        category: 'Action',
        genre: 'FPS',
        rating: 4.4,
        downloadCount: 500000000,
        size: '1.8GB',
        isPremium: false,
        isFeatured: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 45)),
        tags: ['fps', 'shooting', 'multiplayer'],
        gamingMetadata: {
          'players': '10-20 players',
          'duration': '5-15 min',
          'difficulty': 'Medium',
        },
      ),
      
      // Adventure Games
      GameItem(
        id: 'minecraft',
        packageName: 'com.mojang.minecraftpe',
        gameName: 'Minecraft',
        description: 'Build, explore, and survive in a blocky world',
        category: 'Adventure',
        genre: 'Sandbox',
        rating: 4.7,
        downloadCount: 200000000,
        size: '150MB',
        isPremium: true,
        isFeatured: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 365)),
        tags: ['sandbox', 'building', 'survival'],
        gamingMetadata: {
          'players': '1-8 players',
          'duration': 'Unlimited',
          'difficulty': 'Easy',
        },
      ),
      
      // Arcade Games
      GameItem(
        id: 'subway',
        packageName: 'com.kiloo.subwaysurf',
        gameName: 'Subway Surfers',
        description: 'Endless runner with colorful graphics',
        category: 'Arcade',
        genre: 'Runner',
        rating: 4.3,
        downloadCount: 800000000,
        size: '120MB',
        isPremium: false,
        isTrending: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 90)),
        tags: ['runner', 'casual', 'endless'],
        gamingMetadata: {
          'players': '1 player',
          'duration': '2-5 min',
          'difficulty': 'Easy',
        },
      ),
      
      // Puzzle Games
      GameItem(
        id: 'candycrush',
        packageName: 'com.king.candycrushsaga',
        gameName: 'Candy Crush Saga',
        description: 'Match candies in this addictive puzzle game',
        category: 'Puzzle',
        genre: 'Match-3',
        rating: 4.1,
        downloadCount: 1000000000,
        size: '80MB',
        isPremium: false,
        releaseDate: DateTime.now().subtract(const Duration(days: 180)),
        tags: ['puzzle', 'match-3', 'casual'],
        gamingMetadata: {
          'players': '1 player',
          'duration': '3-8 min',
          'difficulty': 'Easy',
        },
      ),
      
      // Racing Games
      GameItem(
        id: 'asphalt',
        packageName: 'com.gameloft.android.ANMP.GloftA8HM',
        gameName: 'Asphalt 9: Legends',
        description: 'High-speed racing with stunning graphics',
        category: 'Racing',
        genre: 'Racing',
        rating: 4.5,
        downloadCount: 100000000,
        size: '2.5GB',
        isPremium: false,
        isFeatured: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 120)),
        tags: ['racing', 'cars', 'multiplayer'],
        gamingMetadata: {
          'players': '1-8 players',
          'duration': '2-5 min',
          'difficulty': 'Medium',
        },
      ),
      
      // RPG Games
      GameItem(
        id: 'genshin',
        packageName: 'com.miHoYo.GenshinImpact',
        gameName: 'Genshin Impact',
        description: 'Open-world action RPG with anime-style graphics',
        category: 'RPG',
        genre: 'Action RPG',
        rating: 4.6,
        downloadCount: 150000000,
        size: '15GB',
        isPremium: false,
        isFeatured: true,
        isTrending: true,
        releaseDate: DateTime.now().subtract(const Duration(days: 30)),
        tags: ['rpg', 'open world', 'anime'],
        gamingMetadata: {
          'players': '1-4 players',
          'duration': '30-60 min',
          'difficulty': 'Medium',
        },
      ),
      
      // Simulation Games
      GameItem(
        id: 'sims',
        packageName: 'com.ea.gp.simsmobile',
        gameName: 'The Sims Mobile',
        description: 'Life simulation game with endless possibilities',
        category: 'Simulation',
        genre: 'Life Sim',
        rating: 4.0,
        downloadCount: 50000000,
        size: '800MB',
        isPremium: false,
        releaseDate: DateTime.now().subtract(const Duration(days: 200)),
        tags: ['simulation', 'life', 'casual'],
        gamingMetadata: {
          'players': '1 player',
          'duration': '10-30 min',
          'difficulty': 'Easy',
        },
      ),
      
      // Sports Games
      GameItem(
        id: 'fifa',
        packageName: 'com.ea.gp.fifamobile',
        gameName: 'FIFA Mobile',
        description: 'Official football game with real teams and players',
        category: 'Sports',
        genre: 'Football',
        rating: 4.3,
        downloadCount: 200000000,
        size: '1.2GB',
        isPremium: false,
        releaseDate: DateTime.now().subtract(const Duration(days: 150)),
        tags: ['sports', 'football', 'multiplayer'],
        gamingMetadata: {
          'players': '1-2 players',
          'duration': '5-15 min',
          'difficulty': 'Medium',
        },
      ),
      
      // Strategy Games
      GameItem(
        id: 'clash',
        packageName: 'com.supercell.clashofclans',
        gameName: 'Clash of Clans',
        description: 'Build your village and battle other players',
        category: 'Strategy',
        genre: 'Strategy',
        rating: 4.4,
        downloadCount: 500000000,
        size: '200MB',
        isPremium: false,
        releaseDate: DateTime.now().subtract(const Duration(days: 300)),
        tags: ['strategy', 'building', 'multiplayer'],
        gamingMetadata: {
          'players': '1-50 players',
          'duration': '5-20 min',
          'difficulty': 'Medium',
        },
      ),
      
      // Casual Games
      GameItem(
        id: 'temple',
        packageName: 'com.imangi.templerun',
        gameName: 'Temple Run',
        description: 'Classic endless runner with treasure hunting',
        category: 'Casual',
        genre: 'Runner',
        rating: 4.2,
        downloadCount: 300000000,
        size: '60MB',
        isPremium: false,
        releaseDate: DateTime.now().subtract(const Duration(days: 400)),
        tags: ['runner', 'casual', 'adventure'],
        gamingMetadata: {
          'players': '1 player',
          'duration': '2-5 min',
          'difficulty': 'Easy',
        },
      ),
    ];

    // Filter based on user preferences
    _filterGamesByPreferences();
  }

  /// Generate promo tiles
  Future<void> _generatePromoTiles() async {
    _promoTiles = [
      {
        'id': 'promo_1',
        'title': '🎮 Gaming Weekend',
        'subtitle': 'New releases & exclusive deals',
        'imageUrl': 'https://via.placeholder.com/300x150/FF6B6B/FFFFFF?text=Gaming+Weekend',
        'actionText': 'Explore Now',
        'actionUrl': 'playstore://search?q=gaming+weekend',
        'backgroundColor': '#FF6B6B',
        'textColor': '#FFFFFF',
        'isActive': true,
        'expiresAt': DateTime.now().add(const Duration(days: 7)),
      },
      {
        'id': 'promo_2',
        'title': '🏆 Tournament Time',
        'subtitle': 'Join weekly gaming competitions',
        'imageUrl': 'https://via.placeholder.com/300x150/4ECDC4/FFFFFF?text=Tournament+Time',
        'actionText': 'Join Now',
        'actionUrl': 'playstore://search?q=gaming+tournament',
        'backgroundColor': '#4ECDC4',
        'textColor': '#FFFFFF',
        'isActive': true,
        'expiresAt': DateTime.now().add(const Duration(days: 14)),
      },
      {
        'id': 'promo_3',
        'title': '🎯 Pro Tips',
        'subtitle': 'Master your favorite games',
        'imageUrl': 'https://via.placeholder.com/300x150/45B7D1/FFFFFF?text=Pro+Tips',
        'actionText': 'Learn More',
        'actionUrl': 'playstore://search?q=gaming+guides',
        'backgroundColor': '#45B7D1',
        'textColor': '#FFFFFF',
        'isActive': true,
        'expiresAt': DateTime.now().add(const Duration(days: 30)),
      },
    ];
  }

  /// Load default games if generation fails
  Future<void> _loadDefaultGames() async {
    _games = [
      GameItem(
        id: 'default',
        packageName: 'com.example.game',
        gameName: 'Example Game',
        description: 'A great game recommendation',
        category: 'Action',
        genre: 'Arcade',
        rating: 4.0,
        downloadCount: 1000000,
        size: '100MB',
        isPremium: false,
        releaseDate: DateTime.now(),
      ),
    ];
    _isInitialized = true;
  }

  /// Filter games based on user preferences
  void _filterGamesByPreferences() {
    final maxGames = _userPreferences['maxGames'] ?? 20;
    final minRating = _userPreferences['minRating'] ?? 3.5;
    final avoidGenres = List<String>.from(_userPreferences['avoidGenres'] ?? []);

    _games = _games.where((game) {
      // Check rating
      if (game.rating < minRating) return false;
      
      // Check avoided genres
      if (avoidGenres.contains(game.genre)) return false;
      
      return true;
    }).take(maxGames).toList();
  }

  /// Get games by category
  List<GameItem> getGamesByCategory(String category) {
    if (category == 'All') {
      return _games;
    }
    return _games.where((game) => game.category == category).toList();
  }

  /// Get games by genre
  List<GameItem> getGamesByGenre(String genre) {
    return _games.where((game) => game.genre == genre).toList();
  }

  /// Search games
  List<GameItem> searchGames(String query) {
    if (query.isEmpty) return _games;
    
    final lowercaseQuery = query.toLowerCase();
    return _games.where((game) {
      return game.gameName.toLowerCase().contains(lowercaseQuery) ||
             game.description?.toLowerCase().contains(lowercaseQuery) == true ||
             game.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get personalized game recommendations
  List<GameItem> getPersonalizedRecommendations({int limit = 5}) {
    List<GameItem> recommendations = List.from(_games);
    
    // Sort by personalization score
    recommendations.sort((a, b) {
      final scoreA = _calculatePersonalizationScore(a);
      final scoreB = _calculatePersonalizationScore(b);
      return scoreB.compareTo(scoreA);
    });
    
    return recommendations.take(limit).toList();
  }

  /// Calculate personalization score for a game
  double _calculatePersonalizationScore(GameItem game) {
    double score = game.rating / 5.0 * 0.4; // 40% weight to rating
    
    // Bonus for preferred genres
    final preferredGenres = List<String>.from(_userPreferences['preferredGenres'] ?? []);
    if (preferredGenres.contains(game.genre)) {
      score += 0.3; // 30% bonus for preferred genres
    }
    
    // Bonus for free games if user prefers them
    if (_userPreferences['preferFreeGames'] == true && !game.isPremium) {
      score += 0.2; // 20% bonus for free games
    }
    
    // Bonus for trending/featured games
    if (game.isTrending || game.isFeatured) {
      score += 0.1; // 10% bonus for trending/featured
    }
    
    return score.clamp(0.0, 1.0);
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> newPreferences) async {
    _userPreferences.addAll(newPreferences);
    await _saveUserPreferences();
    
    // Re-filter games
    _filterGamesByPreferences();
  }

  /// Mark game as played
  Future<void> markGamePlayed(String gameId) async {
    if (!_gamingHistory.contains(gameId)) {
      _gamingHistory.add(gameId);
      await _saveGamingHistory();
    }
  }

  /// Get gaming statistics
  Map<String, dynamic> getGamingStats() {
    final totalGames = _games.length;
    final premiumGames = _games.where((game) => game.isPremium).length;
    final highRatedGames = _games.where((game) => game.rating >= 4.0).length;
    final installedGames = _games.where((game) => game.isInstalled).length;
    
    final categoryStats = <String, int>{};
    final genreStats = <String, int>{};
    
    for (final game in _games) {
      categoryStats[game.category] = (categoryStats[game.category] ?? 0) + 1;
      genreStats[game.genre] = (genreStats[game.genre] ?? 0) + 1;
    }

    final avgRating = _games.isNotEmpty 
        ? _games.map((game) => game.rating).reduce((a, b) => a + b) / _games.length
        : 0.0;

    return {
      'totalGames': totalGames,
      'premiumGames': premiumGames,
      'highRatedGames': highRatedGames,
      'installedGames': installedGames,
      'averageRating': avgRating.toStringAsFixed(1),
      'categoryDistribution': categoryStats,
      'genreDistribution': genreStats,
      'playedGames': _gamingHistory.length,
      'activePromoTiles': _promoTiles.where((tile) => tile['isActive'] == true).length,
    };
  }

  /// Get available categories
  List<String> getAvailableCategories() {
    final categories = _games.map((game) => game.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  /// Get available genres
  List<String> getAvailableGenres() {
    final genres = _games.map((game) => game.genre).toSet().toList();
    genres.sort();
    return ['All', ...genres];
  }

  /// Open Play Store for game installation
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

  /// Refresh games and promo tiles
  Future<void> refresh() async {
    await _generateGames();
    await _generatePromoTiles();
  }

  /// Dispose resources
  void dispose() {
    _games.clear();
    _promoTiles.clear();
    _userPreferences.clear();
    _gamingHistory.clear();
    _isInitialized = false;
  }
}
