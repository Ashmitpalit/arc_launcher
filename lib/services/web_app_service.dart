import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/web_app_shortcut.dart';

/// Service for managing web app shortcuts and their lifecycle
class WebAppService {
  static final WebAppService _instance = WebAppService._internal();
  factory WebAppService() => _instance;
  WebAppService._internal();

  static const String _storageKey = 'web_app_shortcuts';
  static const String _iconCacheDir = 'web_app_icons';
  
  List<WebAppShortcut> _webApps = [];
  bool _isInitialized = false;

  /// Get all web app shortcuts
  List<WebAppShortcut> get webApps => List.unmodifiable(_webApps);
  
  /// Get pinned web apps
  List<WebAppShortcut> get pinnedWebApps => _webApps.where((app) => app.isPinned).toList();
  
  /// Get web apps by category
  List<WebAppShortcut> getWebAppsByCategory(String category) {
    return _webApps.where((app) => app.category == category).toList();
  }
  
  /// Get web apps by cohort
  List<WebAppShortcut> getWebAppsByCohort(String cohort) {
    return _webApps.where((app) => app.cohort == cohort).toList();
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadWebApps();
      _isInitialized = true;
      print('WebAppService initialized with ${_webApps.length} web apps');
    } catch (e) {
      print('Error initializing WebAppService: $e');
      // Load default web apps if initialization fails
      await _loadDefaultWebApps();
    }
  }

  /// Load web apps from storage
  Future<void> _loadWebApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? webAppsJson = prefs.getString(_storageKey);
      
      if (webAppsJson != null) {
        final List<dynamic> webAppsList = json.decode(webAppsJson);
        _webApps = webAppsList
            .map((json) => WebAppShortcut.fromMap(json))
            .toList();
      }
    } catch (e) {
      print('Error loading web apps: $e');
      _webApps = [];
    }
  }

  /// Save web apps to storage
  Future<void> _saveWebApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String webAppsJson = json.encode(_webApps.map((app) => app.toMap()).toList());
      await prefs.setString(_storageKey, webAppsJson);
    } catch (e) {
      print('Error saving web apps: $e');
    }
  }

  /// Load default web apps for new users
  Future<void> _loadDefaultWebApps() async {
    _webApps = [
      WebAppShortcut(
        id: 'google',
        url: 'https://www.google.com',
        title: 'Google',
        description: 'Search the web',
        category: 'Search',
        cohort: 'new_user',
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      ),
      WebAppShortcut(
        id: 'youtube',
        url: 'https://www.youtube.com',
        title: 'YouTube',
        description: 'Watch videos',
        category: 'Entertainment',
        cohort: 'new_user',
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      ),
      WebAppShortcut(
        id: 'github',
        url: 'https://github.com',
        title: 'GitHub',
        description: 'Code repository',
        category: 'Development',
        cohort: 'power_user',
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      ),
    ];
    
    await _saveWebApps();
  }

  /// Add a new web app shortcut
  Future<bool> addWebApp({
    required String url,
    required String title,
    String? description,
    String? iconUrl,
    String category = 'General',
    String cohort = 'new_user',
  }) async {
    try {
      // Validate URL
      if (!_isValidUrl(url)) {
        throw Exception('Invalid URL format');
      }

      // Check if web app already exists
      if (_webApps.any((app) => app.url == url)) {
        throw Exception('Web app already exists');
      }

      // Generate unique ID
      final String id = _generateId();
      
      // Create web app shortcut
      final webApp = WebAppShortcut(
        id: id,
        url: url,
        title: title,
        description: description,
        iconUrl: iconUrl,
        category: category,
        cohort: cohort,
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      );

      // Download and cache icon if provided
      if (iconUrl != null) {
        await _downloadAndCacheIcon(webApp);
      }

      _webApps.add(webApp);
      await _saveWebApps();
      
      print('Added web app: $title ($url)');
      return true;
    } catch (e) {
      print('Error adding web app: $e');
      return false;
    }
  }

  /// Remove a web app shortcut
  Future<bool> removeWebApp(String id) async {
    try {
      final webApp = _webApps.firstWhere((app) => app.id == id);
      
      // Remove cached icon if exists
      if (webApp.iconPath != null) {
        await _removeCachedIcon(webApp.iconPath!);
      }
      
      _webApps.removeWhere((app) => app.id == id);
      await _saveWebApps();
      
      print('Removed web app: ${webApp.title}');
      return true;
    } catch (e) {
      print('Error removing web app: $e');
      return false;
    }
  }

  /// Update web app usage
  Future<void> updateWebAppUsage(String id) async {
    try {
      final index = _webApps.indexWhere((app) => app.id == id);
      if (index != -1) {
        final webApp = _webApps[index];
        final updatedWebApp = webApp.copyWith(
          lastUsed: DateTime.now(),
          useCount: webApp.useCount + 1,
        );
        _webApps[index] = updatedWebApp;
        await _saveWebApps();
      }
    } catch (e) {
      print('Error updating web app usage: $e');
    }
  }

  /// Toggle pin status of web app
  Future<void> togglePinStatus(String id) async {
    try {
      final index = _webApps.indexWhere((app) => app.id == id);
      if (index != -1) {
        final webApp = _webApps[index];
        final updatedWebApp = webApp.copyWith(isPinned: !webApp.isPinned);
        _webApps[index] = updatedWebApp;
        await _saveWebApps();
      }
    } catch (e) {
      print('Error toggling pin status: $e');
    }
  }

  /// Get recommended web apps based on user behavior
  List<WebAppShortcut> getRecommendedWebApps({
    int limit = 5,
    String? category,
    String? cohort,
  }) {
    List<WebAppShortcut> recommendations = List.from(_webApps);
    
    // Filter by category if specified
    if (category != null) {
      recommendations = recommendations.where((app) => app.category == category).toList();
    }
    
    // Filter by cohort if specified
    if (cohort != null) {
      recommendations = recommendations.where((app) => app.cohort == cohort).toList();
    }
    
    // Sort by usage frequency and recency
    recommendations.sort((a, b) {
      // First by usage count (descending)
      if (a.useCount != b.useCount) {
        return b.useCount.compareTo(a.useCount);
      }
      // Then by last used (descending)
      return b.lastUsed.compareTo(a.lastUsed);
    });
    
    return recommendations.take(limit).toList();
  }

  /// Get web apps by install age
  List<WebAppShortcut> getWebAppsByInstallAge({
    int? maxDays,
    int? minDays,
  }) {
    return _webApps.where((app) {
      final age = app.installAgeDays;
      if (maxDays != null && age > maxDays) return false;
      if (minDays != null && age < minDays) return false;
      return true;
    }).toList();
  }

  /// Download and cache web app icon
  Future<void> _downloadAndCacheIcon(WebAppShortcut webApp) async {
    if (webApp.iconUrl == null) return;
    
    try {
      // Create cache directory if it doesn't exist
      final cacheDir = Directory('${Directory.current.path}/$_iconCacheDir');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      
      // Download icon
      final response = await http.get(Uri.parse(webApp.iconUrl!));
      if (response.statusCode == 200) {
        final iconPath = '${cacheDir.path}/${webApp.id}_icon.png';
        final iconFile = File(iconPath);
        await iconFile.writeAsBytes(response.bodyBytes);
        
        // Update web app with cached icon path
        final index = _webApps.indexWhere((app) => app.id == webApp.id);
        if (index != -1) {
          _webApps[index] = webApp.copyWith(iconPath: iconPath);
          await _saveWebApps();
        }
      }
    } catch (e) {
      print('Error downloading icon for ${webApp.title}: $e');
    }
  }

  /// Remove cached icon
  Future<void> _removeCachedIcon(String iconPath) async {
    try {
      final iconFile = File(iconPath);
      if (await iconFile.exists()) {
        await iconFile.delete();
      }
    } catch (e) {
      print('Error removing cached icon: $e');
    }
  }

  /// Validate URL format
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Generate unique ID for web app
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'webapp_${timestamp}_$random';
  }

  /// Get web app statistics
  Map<String, dynamic> getWebAppStats() {
    final totalApps = _webApps.length;
    final pinnedApps = _webApps.where((app) => app.isPinned).length;
    final totalUsage = _webApps.fold(0, (sum, app) => sum + app.useCount);
    final avgUsage = totalApps > 0 ? totalUsage / totalApps : 0;
    
    final categoryStats = <String, int>{};
    for (final app in _webApps) {
      categoryStats[app.category] = (categoryStats[app.category] ?? 0) + 1;
    }
    
    final cohortStats = <String, int>{};
    for (final app in _webApps) {
      cohortStats[app.cohort] = (cohortStats[app.cohort] ?? 0) + 1;
    }
    
    return {
      'totalApps': totalApps,
      'pinnedApps': pinnedApps,
      'totalUsage': totalUsage,
      'averageUsage': avgUsage.round(),
      'categoryStats': categoryStats,
      'cohortStats': cohortStats,
      'mostUsedApp': _webApps.isNotEmpty ? _webApps.reduce((a, b) => a.useCount > b.useCount ? a : b).title : null,
      'newestApp': _webApps.isNotEmpty ? _webApps.reduce((a, b) => a.installDate.isAfter(b.installDate) ? a : b).title : null,
    };
  }

  /// Dispose resources
  void dispose() {
    _webApps.clear();
    _isInitialized = false;
  }
}
