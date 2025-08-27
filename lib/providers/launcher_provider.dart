import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import '../models/app_shortcut.dart';
import '../models/widget_info.dart';

// Models
class WebAppShortcut {
  final String id;
  final String name;
  final String url;
  final String iconUrl;
  final DateTime addedDate;
  final String category;
  final bool isPinned;
  final int usageCount;

  WebAppShortcut({
    required this.id,
    required this.name,
    required this.url,
    required this.iconUrl,
    required this.addedDate,
    required this.category,
    this.isPinned = false,
    this.usageCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'iconUrl': iconUrl,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'category': category,
      'isPinned': isPinned ? 1 : 0,
      'usageCount': usageCount,
    };
  }

  factory WebAppShortcut.fromMap(Map<String, dynamic> map) {
    return WebAppShortcut(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      iconUrl: map['iconUrl'],
      addedDate: DateTime.fromMillisecondsSinceEpoch(map['addedDate']),
      category: map['category'],
      isPinned: map['isPinned'] == 1,
      usageCount: map['usageCount'],
    );
  }
}

class AppAnalytics {
  final String packageName;
  final DateTime firstInstallDate;
  final DateTime lastUsedDate;
  final int totalUsageTime;
  final int launchCount;
  final String category;
  final double rating;

  AppAnalytics({
    required this.packageName,
    required this.firstInstallDate,
    required this.lastUsedDate,
    required this.totalUsageTime,
    required this.launchCount,
    required this.category,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'firstInstallDate': firstInstallDate.millisecondsSinceEpoch,
      'lastUsedDate': lastUsedDate.millisecondsSinceEpoch,
      'totalUsageTime': totalUsageTime,
      'launchCount': launchCount,
      'category': category,
      'rating': rating,
    };
  }

  factory AppAnalytics.fromMap(Map<String, dynamic> map) {
    return AppAnalytics(
      packageName: map['packageName'],
      firstInstallDate: DateTime.fromMillisecondsSinceEpoch(map['firstInstallDate']),
      lastUsedDate: DateTime.fromMillisecondsSinceEpoch(map['lastUsedDate']),
      totalUsageTime: map['totalUsageTime'],
      launchCount: map['launchCount'],
      category: map['category'],
      rating: map['rating'],
    );
  }
}

class RemoteConfig {
  final String key;
  final dynamic value;
  final String type;
  final DateTime lastUpdated;

  RemoteConfig({
    required this.key,
    required this.value,
    required this.type,
    required this.lastUpdated,
  });
}

class PromoTile {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String actionUrl;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  PromoTile({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionUrl,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String source;
  final DateTime publishDate;
  final String category;
  final bool isSponsored;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.publishDate,
    required this.category,
    this.isSponsored = false,
  });
}

class IconPack {
  final String id;
  final String name;
  final String description;
  final String previewImage;
  final String packageName;
  final bool isInstalled;
  final bool isActive;
  final double rating;
  final int downloadCount;

  IconPack({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.packageName,
    this.isInstalled = false,
    this.isActive = false,
    this.rating = 0.0,
    this.downloadCount = 0,
  });
}

class SearchProvider {
  final String id;
  final String name;
  final String searchUrl;
  final String iconUrl;
  final bool isDefault;
  final String category;

  SearchProvider({
    required this.id,
    required this.name,
    required this.searchUrl,
    required this.iconUrl,
    this.isDefault = false,
    required this.category,
  });
}

class LauncherProvider extends ChangeNotifier {
  // Basic launcher state
  int _currentPage = 0;
  bool _isAppDrawerOpen = false;
  bool _isNotificationPanelOpen = false;
  bool _isQuickSettingsOpen = false;
  List<AppShortcut> _installedApps = [];
  List<AppShortcut> _pinnedApps = [];
  List<WidgetInfo> _userWidgets = [];
  bool _isDefaultLauncher = false;

  // New features
  List<WebAppShortcut> _webAppShortcuts = [];
  List<AppAnalytics> _appAnalytics = [];
  Map<String, RemoteConfig> _remoteConfigs = {};
  List<PromoTile> _promoTiles = [];
  List<NewsItem> _newsItems = [];
  List<IconPack> _iconPacks = [];
  List<SearchProvider> _searchProviders = [];
  List<String> _recommendedApps = [];
  
  // Database
  Database? _database;
  bool _isDatabaseInitialized = false;

  // Getters
  int get currentPage => _currentPage;
  bool get isAppDrawerOpen => _isAppDrawerOpen;
  bool get isNotificationPanelOpen => _isNotificationPanelOpen;
  bool get isQuickSettingsOpen => _isQuickSettingsOpen;
  List<AppShortcut> get installedApps => _installedApps;
  List<AppShortcut> get pinnedApps => _pinnedApps;
  List<WidgetInfo> get userWidgets => _userWidgets;
  bool get isDefaultLauncher => _isDefaultLauncher;
  List<WebAppShortcut> get webAppShortcuts => _webAppShortcuts;
  List<AppAnalytics> get appAnalytics => _appAnalytics;
  Map<String, RemoteConfig> get remoteConfigs => _remoteConfigs;
  List<PromoTile> get promoTiles => _promoTiles;
  List<NewsItem> get newsItems => _newsItems;
  List<IconPack> get iconPacks => _iconPacks;
  List<SearchProvider> get searchProviders => _searchProviders;
  List<String> get recommendedApps => _recommendedApps;

  // Initialize database and load data
  Future<void> initialize() async {
    await _initDatabase();
    await _loadAllData();
    await _loadPinnedApps();
    await _loadUserWidgets();
    await _fetchRemoteConfigs();
    await _fetchPromoTiles();
    await _fetchNewsItems();
    await _fetchIconPacks();
    await _loadSearchProviders();
    await _generateRecommendedApps();
    notifyListeners();
  }

  // Database initialization
  Future<void> _initDatabase() async {
    if (_isDatabaseInitialized) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'arc_launcher.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Web app shortcuts table
        await db.execute('''
          CREATE TABLE web_app_shortcuts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            url TEXT NOT NULL,
            iconUrl TEXT,
            addedDate INTEGER NOT NULL,
            category TEXT NOT NULL,
            isPinned INTEGER NOT NULL,
            usageCount INTEGER NOT NULL
          )
        ''');

        // App analytics table
        await db.execute('''
          CREATE TABLE app_analytics (
            packageName TEXT PRIMARY KEY,
            firstInstallDate INTEGER NOT NULL,
            lastUsedDate INTEGER NOT NULL,
            totalUsageTime INTEGER NOT NULL,
            launchCount INTEGER NOT NULL,
            category TEXT NOT NULL,
            rating REAL NOT NULL
          )
        ''');

        // Remote configs table
        await db.execute('''
          CREATE TABLE remote_configs (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            type TEXT NOT NULL,
            lastUpdated INTEGER NOT NULL
          )
        ''');

        // Promo tiles table
        await db.execute('''
          CREATE TABLE promo_tiles (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            actionUrl TEXT NOT NULL,
            category TEXT NOT NULL,
            startDate INTEGER NOT NULL,
            endDate INTEGER NOT NULL,
            isActive INTEGER NOT NULL
          )
        ''');

        // News items table
        await db.execute('''
          CREATE TABLE news_items (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            source TEXT NOT NULL,
            publishDate INTEGER NOT NULL,
            category TEXT NOT NULL,
            isSponsored INTEGER NOT NULL
          )
        ''');

        // Icon packs table
        await db.execute('''
          CREATE TABLE icon_packs (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            previewImage TEXT NOT NULL,
            packageName TEXT NOT NULL,
            isInstalled INTEGER NOT NULL,
            isActive INTEGER NOT NULL,
            rating REAL NOT NULL,
            downloadCount INTEGER NOT NULL
          )
        ''');

        // Search providers table
        await db.execute('''
          CREATE TABLE search_providers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            searchUrl TEXT NOT NULL,
            iconUrl TEXT NOT NULL,
            isDefault INTEGER NOT NULL,
            category TEXT NOT NULL
          )
        ''');
      },
    );

    _isDatabaseInitialized = true;
  }

  // Load all data from database
  Future<void> _loadAllData() async {
    if (!_isDatabaseInitialized) return;

    // Load web app shortcuts
    final shortcutsData = await _database!.query('web_app_shortcuts');
    _webAppShortcuts = shortcutsData.map((data) => WebAppShortcut.fromMap(data)).toList();

    // Load app analytics
    final analyticsData = await _database!.query('app_analytics');
    _appAnalytics = analyticsData.map((data) => AppAnalytics.fromMap(data)).toList();

    // Load remote configs
    final configsData = await _database!.query('remote_configs');
    for (final data in configsData) {
      _remoteConfigs[data['key'] as String] = RemoteConfig(
        key: data['key'] as String,
        value: data['value'] as String,
        type: data['type'] as String,
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'] as int),
      );
    }

    // Load promo tiles
    final promosData = await _database!.query('promo_tiles');
    _promoTiles = promosData.map((data) => PromoTile(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String,
      actionUrl: data['actionUrl'] as String,
      category: data['category'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(data['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(data['endDate'] as int),
      isActive: data['isActive'] == 1,
    )).toList();

    // Load news items
    final newsData = await _database!.query('news_items');
    _newsItems = newsData.map((data) => NewsItem(
      id: data['id'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      imageUrl: data['imageUrl'] as String,
      source: data['source'] as String,
      publishDate: DateTime.fromMillisecondsSinceEpoch(data['publishDate'] as int),
      category: data['category'] as String,
      isSponsored: data['isSponsored'] == 1,
    )).toList();

    // Load icon packs
    final iconPacksData = await _database!.query('icon_packs');
    _iconPacks = iconPacksData.map((data) => IconPack(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      previewImage: data['previewImage'] as String,
      packageName: data['packageName'] as String,
      isInstalled: data['isInstalled'] == 1,
      isActive: data['isActive'] == 1,
      rating: data['rating'] as double,
      downloadCount: data['downloadCount'] as int,
    )).toList();

    // Load search providers
    final searchData = await _database!.query('search_providers');
    _searchProviders = searchData.map((data) => SearchProvider(
      id: data['id'] as String,
      name: data['name'] as String,
      searchUrl: data['searchUrl'] as String,
      iconUrl: data['iconUrl'] as String,
      isDefault: data['isDefault'] == 1,
      category: data['category'] as String,
    )).toList();
  }

  // Web App Shortcuts Management
  Future<void> addWebAppShortcut(WebAppShortcut shortcut) async {
    if (!_isDatabaseInitialized) return;

    await _database!.insert(
      'web_app_shortcuts',
      shortcut.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _webAppShortcuts.add(shortcut);
    notifyListeners();
  }

  Future<void> removeWebAppShortcut(String id) async {
    if (!_isDatabaseInitialized) return;

    await _database!.delete(
      'web_app_shortcuts',
      where: 'id = ?',
      whereArgs: [id],
    );

    _webAppShortcuts.removeWhere((shortcut) => shortcut.id == id);
    notifyListeners();
  }

  Future<void> updateWebAppShortcutUsage(String id) async {
    if (!_isDatabaseInitialized) return;

    final shortcut = _webAppShortcuts.firstWhere((s) => s.id == id);
    final updatedShortcut = WebAppShortcut(
      id: shortcut.id,
      name: shortcut.name,
      url: shortcut.url,
      iconUrl: shortcut.iconUrl,
      addedDate: shortcut.addedDate,
      category: shortcut.category,
      isPinned: shortcut.isPinned,
      usageCount: shortcut.usageCount + 1,
    );

    await _database!.update(
      'web_app_shortcuts',
      updatedShortcut.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );

    final index = _webAppShortcuts.indexWhere((s) => s.id == id);
    if (index != -1) {
      _webAppShortcuts[index] = updatedShortcut;
      notifyListeners();
    }
  }

  // App Analytics Management
  Future<void> trackAppUsage(String packageName, int usageTime) async {
    if (!_isDatabaseInitialized) return;

    final now = DateTime.now();
    final existing = _appAnalytics.firstWhere(
      (analytics) => analytics.packageName == packageName,
      orElse: () => AppAnalytics(
        packageName: packageName,
        firstInstallDate: now,
        lastUsedDate: now,
        totalUsageTime: 0,
        launchCount: 0,
        category: 'Unknown',
      ),
    );

    final updated = AppAnalytics(
      packageName: packageName,
      firstInstallDate: existing.firstInstallDate,
      lastUsedDate: now,
      totalUsageTime: existing.totalUsageTime + usageTime,
      launchCount: existing.launchCount + 1,
      category: existing.category,
      rating: existing.rating,
    );

    await _database!.insert(
      'app_analytics',
      updated.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final index = _appAnalytics.indexWhere((a) => a.packageName == packageName);
    if (index != -1) {
      _appAnalytics[index] = updated;
    } else {
      _appAnalytics.add(updated);
    }
    notifyListeners();
  }

  // Remote Config Management
  Future<void> _fetchRemoteConfigs() async {
    try {
      // Simulate fetching remote configs from server
      // In real implementation, this would connect to Firebase Remote Config or similar
      final mockConfigs = {
        'onboarding_enabled': RemoteConfig(
          key: 'onboarding_enabled',
          value: 'true',
          type: 'boolean',
          lastUpdated: DateTime.now(),
        ),
        'promo_frequency': RemoteConfig(
          key: 'promo_frequency',
          value: 'daily',
          type: 'string',
          lastUpdated: DateTime.now(),
        ),
        'max_web_shortcuts': RemoteConfig(
          key: 'max_web_shortcuts',
          value: '20',
          type: 'int',
          lastUpdated: DateTime.now(),
        ),
      };

      _remoteConfigs.addAll(mockConfigs);
      
      // Save to database
      if (_isDatabaseInitialized) {
        for (final config in mockConfigs.values) {
          await _database!.insert(
            'remote_configs',
            {
              'key': config.key,
              'value': config.value.toString(),
              'type': config.type,
              'lastUpdated': config.lastUpdated.millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } catch (e) {
      print('Error fetching remote configs: $e');
    }
  }

  // Promo Tiles Management
  Future<void> _fetchPromoTiles() async {
    try {
      // Simulate fetching promo tiles from server
      final mockPromos = [
        PromoTile(
          id: '1',
          title: 'New Gaming Features',
          description: 'Discover the latest gaming enhancements',
          imageUrl: 'https://via.placeholder.com/300x200',
          actionUrl: 'https://example.com/gaming-features',
          category: 'Gaming',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 30)),
        ),
        PromoTile(
          id: '2',
          title: 'Custom Themes',
          description: 'Personalize your launcher with new themes',
          imageUrl: 'https://via.placeholder.com/300x200',
          actionUrl: 'https://example.com/themes',
          category: 'Customization',
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 25)),
        ),
      ];

      _promoTiles = mockPromos;
      
      // Save to database
      if (_isDatabaseInitialized) {
        for (final promo in mockPromos) {
          await _database!.insert(
            'promo_tiles',
            {
              'id': promo.id,
              'title': promo.title,
              'description': promo.description,
              'imageUrl': promo.imageUrl,
              'actionUrl': promo.actionUrl,
              'category': promo.category,
              'startDate': promo.startDate.millisecondsSinceEpoch,
              'endDate': promo.endDate.millisecondsSinceEpoch,
              'isActive': promo.isActive ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } catch (e) {
      print('Error fetching promo tiles: $e');
    }
  }

  // News Items Management
  Future<void> _fetchNewsItems() async {
    try {
      // Simulate fetching news from server
      final mockNews = [
        NewsItem(
          id: '1',
          title: 'Arc Launcher v2.0 Released',
          content: 'Major update with new features and improvements',
          imageUrl: 'https://via.placeholder.com/400x250',
          source: 'Arc Team',
          publishDate: DateTime.now().subtract(const Duration(hours: 2)),
          category: 'Updates',
        ),
        NewsItem(
          id: '2',
          title: 'Gaming Performance Tips',
          content: 'Optimize your device for better gaming experience',
          imageUrl: 'https://via.placeholder.com/400x250',
          source: 'Gaming Hub',
          publishDate: DateTime.now().subtract(const Duration(hours: 6)),
          category: 'Tips',
        ),
      ];

      _newsItems = mockNews;
      
      // Save to database
      if (_isDatabaseInitialized) {
        for (final news in mockNews) {
          await _database!.insert(
            'news_items',
            {
              'id': news.id,
              'title': news.title,
              'content': news.content,
              'imageUrl': news.imageUrl,
              'source': news.source,
              'publishDate': news.publishDate.millisecondsSinceEpoch,
              'category': news.category,
              'isSponsored': news.isSponsored ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } catch (e) {
      print('Error fetching news items: $e');
    }
  }

  // Icon Packs Management
  Future<void> _fetchIconPacks() async {
    try {
      // Simulate fetching icon packs from server
      final mockIconPacks = [
        IconPack(
          id: '1',
          name: 'Material Design',
          description: 'Google\'s Material Design icon pack',
          previewImage: 'https://via.placeholder.com/200x200',
          packageName: 'com.material.icons',
          rating: 4.8,
          downloadCount: 1000000,
        ),
        IconPack(
          id: '2',
          name: 'Gaming Icons',
          description: 'Gaming-themed icon pack',
          previewImage: 'https://via.placeholder.com/200x200',
          packageName: 'com.gaming.icons',
          rating: 4.6,
          downloadCount: 500000,
        ),
      ];

      _iconPacks = mockIconPacks;
      
      // Save to database
      if (_isDatabaseInitialized) {
        for (final pack in mockIconPacks) {
          await _database!.insert(
            'icon_packs',
            {
              'id': pack.id,
              'name': pack.name,
              'description': pack.description,
              'previewImage': pack.previewImage,
              'packageName': pack.packageName,
              'isInstalled': pack.isInstalled ? 1 : 0,
              'isActive': pack.isActive ? 1 : 0,
              'rating': pack.rating,
              'downloadCount': pack.downloadCount,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } catch (e) {
      print('Error fetching icon packs: $e');
    }
  }

  // Search Providers Management
  Future<void> _loadSearchProviders() async {
    try {
      final defaultProviders = [
        SearchProvider(
          id: 'google',
          name: 'Google',
          searchUrl: 'https://www.google.com/search?q=',
          iconUrl: 'https://via.placeholder.com/48x48',
          isDefault: true,
          category: 'Search',
        ),
        SearchProvider(
          id: 'bing',
          name: 'Bing',
          searchUrl: 'https://www.bing.com/search?q=',
          iconUrl: 'https://via.placeholder.com/48x48',
          category: 'Search',
        ),
        SearchProvider(
          id: 'duckduckgo',
          name: 'DuckDuckGo',
          searchUrl: 'https://duckduckgo.com/?q=',
          iconUrl: 'https://via.placeholder.com/48x48',
          category: 'Search',
        ),
      ];

      _searchProviders = defaultProviders;
      
      // Save to database
      if (_isDatabaseInitialized) {
        for (final provider in defaultProviders) {
          await _database!.insert(
            'search_providers',
            {
              'id': provider.id,
              'name': provider.name,
              'searchUrl': provider.searchUrl,
              'iconUrl': provider.iconUrl,
              'isDefault': provider.isDefault ? 1 : 0,
              'category': provider.category,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } catch (e) {
      print('Error loading search providers: $e');
    }
  }

  // Recommended Apps Generation
  Future<void> _generateRecommendedApps() async {
    try {
      // Generate recommendations based on usage patterns and categories
      final recommendations = <String>[];
      
      // Add apps based on usage frequency
      final sortedAnalytics = List<AppAnalytics>.from(_appAnalytics)
        ..sort((a, b) => b.launchCount.compareTo(a.launchCount));
      
      for (final analytics in sortedAnalytics.take(5)) {
        if (!recommendations.contains(analytics.packageName)) {
          recommendations.add(analytics.packageName);
        }
      }
      
      // Add apps based on category preferences
      final categoryCounts = <String, int>{};
      for (final analytics in _appAnalytics) {
        categoryCounts[analytics.category] = (categoryCounts[analytics.category] ?? 0) + 1;
      }
      
      final topCategory = categoryCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      // Add some mock recommendations if we don't have enough data
      if (recommendations.length < 5) {
        final mockApps = ['Chrome', 'Gmail', 'Maps', 'YouTube', 'Spotify'];
        for (final app in mockApps) {
          if (!recommendations.contains(app)) {
            recommendations.add(app);
          }
          if (recommendations.length >= 5) break;
        }
      }
      
      _recommendedApps = recommendations;
    } catch (e) {
      print('Error generating recommended apps: $e');
      _recommendedApps = ['Chrome', 'Gmail', 'Maps', 'YouTube', 'Spotify'];
    }
  }

  // Basic launcher methods (existing functionality)
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void toggleAppDrawer() {
    _isAppDrawerOpen = !_isAppDrawerOpen;
    if (_isAppDrawerOpen) {
      _isNotificationPanelOpen = false;
      _isQuickSettingsOpen = false;
    }
    notifyListeners();
  }

  void closeAppDrawer() {
    _isAppDrawerOpen = false;
    notifyListeners();
  }

  void toggleNotificationPanel() {
    _isNotificationPanelOpen = !_isNotificationPanelOpen;
    if (_isNotificationPanelOpen) {
      _isQuickSettingsOpen = false;
      _isAppDrawerOpen = false;
    }
    notifyListeners();
  }

  void toggleQuickSettings() {
    _isQuickSettingsOpen = !_isQuickSettingsOpen;
    if (_isQuickSettingsOpen) {
      _isNotificationPanelOpen = false;
      _isAppDrawerOpen = false;
    }
    notifyListeners();
  }

  void closePanels() {
    _isNotificationPanelOpen = false;
    _isQuickSettingsOpen = false;
    _isAppDrawerOpen = false;
    notifyListeners();
  }

  void setInstalledApps(List<AppShortcut> apps) {
    _installedApps = apps;
    notifyListeners();
  }

  void pinApp(AppShortcut app) {
    if (!_pinnedApps.contains(app)) {
      _pinnedApps.add(app);
      _savePinnedApps();
      notifyListeners();
    }
  }

  void unpinApp(AppShortcut app) {
    _pinnedApps.remove(app);
    _savePinnedApps();
    notifyListeners();
  }

  Future<void> _savePinnedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinnedData = _pinnedApps.map((app) => app.toMap()).toList();
      await prefs.setString('pinned_apps', jsonEncode(pinnedData));
    } catch (e) {
      print('Failed to save pinned apps: $e');
    }
  }

  Future<void> _loadPinnedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinnedData = prefs.getString('pinned_apps');
      if (pinnedData != null) {
        final List<dynamic> decoded = jsonDecode(pinnedData);
        _pinnedApps = decoded.map((data) => AppShortcut.fromMap(data)).toList();
      }
    } catch (e) {
      print('Failed to load pinned apps: $e');
    }
  }

  void setDefaultLauncherStatus(bool status) {
    _isDefaultLauncher = status;
    _saveDefaultLauncherStatus(status);
    notifyListeners();
  }

  Future<void> launchApp(AppShortcut app) async {
    try {
      final result = await const MethodChannel('launcher_service').invokeMethod('launchApp', {
        'packageName': app.packageName,
      });
      
      if (result == true) {
        // Update app usage analytics
        _updateAppUsage(app);
      } else {
        throw Exception('Failed to launch app');
      }
    } catch (e) {
      print('Failed to launch app ${app.name}: $e');
      rethrow;
    }
  }

  void showAppInfo(AppShortcut app) {
    // This would typically open the app info page
    // For now, just show a snackbar
    print('Show app info for ${app.name}');
  }

  void _updateAppUsage(AppShortcut app) {
    // Update usage analytics
    final now = DateTime.now();
    // Implementation would go here
  }

  void addWidget(String widgetType) {
    final widget = WidgetInfo(
      id: '${widgetType}_${DateTime.now().millisecondsSinceEpoch}',
      type: widgetType,
      addedDate: DateTime.now(),
    );
    
    _userWidgets.add(widget);
    _saveUserWidgets();
    notifyListeners();
  }

  void removeWidget(String widgetId) {
    _userWidgets.removeWhere((widget) => widget.id == widgetId);
    _saveUserWidgets();
    notifyListeners();
  }

  void toggleWidget(String widgetId) {
    final widgetIndex = _userWidgets.indexWhere((widget) => widget.id == widgetId);
    if (widgetIndex != -1) {
      _userWidgets[widgetIndex] = _userWidgets[widgetIndex].copyWith(
        isEnabled: !_userWidgets[widgetIndex].isEnabled,
      );
      _saveUserWidgets();
      notifyListeners();
    }
  }

  Future<void> _saveUserWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetsData = _userWidgets.map((widget) => widget.toMap()).toList();
      await prefs.setString('user_widgets', jsonEncode(widgetsData));
    } catch (e) {
      print('Failed to save user widgets: $e');
    }
  }

  Future<void> _loadUserWidgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetsData = prefs.getString('user_widgets');
      if (widgetsData != null) {
        final List<dynamic> decoded = jsonDecode(widgetsData);
        _userWidgets = decoded.map((data) => WidgetInfo.fromMap(data)).toList();
      }
    } catch (e) {
      print('Failed to load user widgets: $e');
    }
  }

  Future<void> _saveDefaultLauncherStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDefaultLauncher', status);
  }

  Future<void> loadDefaultLauncherStatus() async {
    try {
      // Check the actual system default launcher status
      const platform = MethodChannel('arc_launcher_settings');
      final bool isSystemDefault = await platform.invokeMethod('isDefaultLauncher');
      
      // Update our status based on the actual system status
      _isDefaultLauncher = isSystemDefault;
      
      // Also update SharedPreferences to match the system status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDefaultLauncher', isSystemDefault);
      
      notifyListeners();
    } catch (e) {
      // Fallback to SharedPreferences if system check fails
      final prefs = await SharedPreferences.getInstance();
      _isDefaultLauncher = prefs.getBool('isDefaultLauncher') ?? false;
      notifyListeners();
    }
  }

  // Check system default launcher status (can be called anytime)
  Future<bool> checkSystemDefaultStatus() async {
    try {
      const platform = MethodChannel('arc_launcher_settings');
      final bool isSystemDefault = await platform.invokeMethod('isDefaultLauncher');
      
      if (_isDefaultLauncher != isSystemDefault) {
        final bool wasDefault = _isDefaultLauncher;
        _isDefaultLauncher = isSystemDefault;
        
        // Update SharedPreferences to match the system status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDefaultLauncher', isSystemDefault);
        
        notifyListeners();
        
        // Return true if status changed from default to not default
        return wasDefault && !isSystemDefault;
      }
      
      return false;
    } catch (e) {
      // If system check fails, don't change anything
      print('Failed to check system default status: $e');
      return false;
    }
  }

  // Load real installed apps
  Future<void> loadInstalledApps() async {
    try {
      final result = await const MethodChannel('launcher_service').invokeMethod('getInstalledApps');
      if (result is List) {
        _installedApps = result.map((appData) {
          return AppShortcut(
            name: appData['name'] ?? 'Unknown App',
            packageName: appData['packageName'] ?? '',
            icon: _getAppIcon(appData['packageName'] ?? ''),
            color: _getAppColor(appData['packageName'] ?? ''),
            category: appData['category'],
            installDate: appData['installDate'] != null 
                ? DateTime.fromMillisecondsSinceEpoch(appData['installDate'])
                : null,
          );
        }).toList();
        
        // Sort apps alphabetically by name
        _installedApps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        // Fallback to common system apps if real detection fails
        _loadFallbackApps();
      }
      notifyListeners();
    } catch (e) {
      print('Failed to load installed apps: $e');
      _loadFallbackApps();
      notifyListeners();
    }
  }

  void _loadFallbackApps() {
    _installedApps = [
      AppShortcut(
        name: 'Settings',
        packageName: 'com.android.settings',
        icon: Icons.settings,
        color: Colors.grey,
      ),
      AppShortcut(
        name: 'Phone',
        packageName: 'com.android.dialer',
        icon: Icons.phone,
        color: Colors.green,
      ),
      AppShortcut(
        name: 'Camera',
        packageName: 'com.android.camera',
        icon: Icons.camera_alt,
        color: Colors.purple,
      ),
      AppShortcut(
        name: 'Gallery',
        packageName: 'com.android.gallery3d',
        icon: Icons.photo_library,
        color: Colors.pink,
      ),
      AppShortcut(
        name: 'Chrome',
        packageName: 'com.android.chrome',
        icon: Icons.language,
        color: Colors.orange,
      ),
      AppShortcut(
        name: 'Gmail',
        packageName: 'com.google.android.gm',
        icon: Icons.email,
        color: Colors.red,
      ),
      AppShortcut(
        name: 'Maps',
        packageName: 'com.google.android.apps.maps',
        icon: Icons.map,
        color: Colors.blue,
      ),
      AppShortcut(
        name: 'Play Store',
        packageName: 'com.android.vending',
        icon: Icons.store,
        color: Colors.green,
      ),
    ];
  }

  IconData _getAppIcon(String packageName) {
    // Map common package names to appropriate icons
    final iconMap = {
      'com.android.settings': Icons.settings,
      'com.android.dialer': Icons.phone,
      'com.android.camera': Icons.camera_alt,
      'com.android.gallery3d': Icons.photo_library,
      'com.android.chrome': Icons.language,
      'com.google.android.gm': Icons.email,
      'com.google.android.apps.maps': Icons.map,
      'com.android.vending': Icons.store,
      'com.google.android.youtube': Icons.play_circle_filled,
      'com.spotify.music': Icons.music_note,
      'com.whatsapp': Icons.chat,
      'com.instagram.android': Icons.camera_alt,
      'com.facebook.katana': Icons.facebook,
      'com.twitter.android': Icons.alternate_email,
      'com.android.calculator2': Icons.calculate,
      'com.android.calendar': Icons.calendar_today,
      'com.android.deskclock': Icons.access_time,
      'com.android.documentsui': Icons.folder,
      'com.google.android.apps.photos': Icons.photo,
      'com.google.android.apps.docs': Icons.cloud,
    };
    
    return iconMap[packageName] ?? Icons.apps;
  }

  Color _getAppColor(String packageName) {
    // Map common package names to colors
    final colorMap = {
      'com.android.settings': Colors.grey,
      'com.android.dialer': Colors.green,
      'com.android.camera': Colors.purple,
      'com.android.gallery3d': Colors.pink,
      'com.android.chrome': Colors.orange,
      'com.google.android.gm': Colors.red,
      'com.google.android.apps.maps': Colors.blue,
      'com.android.vending': Colors.green,
      'com.google.android.youtube': Colors.red,
      'com.spotify.music': Colors.green,
      'com.whatsapp': Colors.green,
      'com.instagram.android': Colors.purple,
      'com.facebook.katana': Colors.blue,
      'com.twitter.android': Colors.blue,
      'com.android.calculator2': Colors.orange,
      'com.android.calendar': Colors.blue,
      'com.android.deskclock': Colors.indigo,
      'com.android.documentsui': Colors.amber,
      'com.google.android.apps.photos': Colors.pink,
      'com.google.android.apps.docs': Colors.blue,
    };
    
    return colorMap[packageName] ?? Colors.grey;
  }

  // Dispose resources
  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
