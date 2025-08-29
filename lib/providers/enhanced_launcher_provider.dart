import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_shortcut.dart';
import '../models/web_app_shortcut.dart';

class EnhancedLauncherProvider extends ChangeNotifier {
  // Remote Config
  late FirebaseRemoteConfig _remoteConfig;
  late FirebaseAnalytics _analytics;
  
  // Dynamic shortcuts
  List<WebAppShortcut> _dynamicShortcuts = [];
  List<AppShortcut> _recommendedApps = [];
  
  // Cohort tracking
  String _userCohort = 'default';
  DateTime? _installDate;
  int _usageCount = 0;
  
  // Remote control values
  bool _enableDynamicShortcuts = true;
  int _shortcutRefreshInterval = 24; // hours
  bool _enableRecommendations = true;
  int _maxShortcuts = 8;
  int _maxRecommendations = 6;
  
  // Getters
  List<WebAppShortcut> get dynamicShortcuts => _dynamicShortcuts;
  List<AppShortcut> get recommendedApps => _recommendedApps;
  String get userCohort => _userCohort;
  bool get enableDynamicShortcuts => _enableDynamicShortcuts;
  bool get enableRecommendations => _enableRecommendations;
  int get maxShortcuts => _maxShortcuts;
  int get maxRecommendations => _maxRecommendations;

  EnhancedLauncherProvider() {
    _initializeFirebase();
    _loadUserData();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Initialize Remote Config
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // Set default values
      await _remoteConfig.setDefaults({
        'enable_dynamic_shortcuts': true,
        'shortcut_refresh_interval': 24,
        'enable_recommendations': true,
        'max_shortcuts': 8,
        'max_recommendations': 6,
        'cohort_shortcuts': '{}',
        'recommendation_weights': '{}',
      });
      
      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
      
      // Initialize Analytics
      _analytics = FirebaseAnalytics.instance;
      
      // Load remote values
      _loadRemoteConfigValues();
      
      // Start periodic refresh
      _startPeriodicRefresh();
      
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  }

  void _loadRemoteConfigValues() {
    _enableDynamicShortcuts = _remoteConfig.getBool('enable_dynamic_shortcuts');
    _shortcutRefreshInterval = _remoteConfig.getInt('shortcut_refresh_interval');
    _enableRecommendations = _remoteConfig.getBool('enable_recommendations');
    _maxShortcuts = _remoteConfig.getInt('max_shortcuts');
    _maxRecommendations = _remoteConfig.getInt('max_recommendations');
    
    // Parse cohort-specific shortcuts
    _parseCohortShortcuts();
    
    notifyListeners();
  }

  void _parseCohortShortcuts() {
    try {
      final cohortData = _remoteConfig.getString('cohort_shortcuts');
      if (cohortData.isNotEmpty) {
        // Parse JSON and apply cohort-specific shortcuts
        // This will be implemented based on your specific cohort logic
      }
    } catch (e) {
      print('Failed to parse cohort shortcuts: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _installDate = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('install_date') ?? DateTime.now().millisecondsSinceEpoch
      );
      _usageCount = prefs.getInt('usage_count') ?? 0;
      _userCohort = prefs.getString('user_cohort') ?? 'default';
      
      // Save install date if not exists
      if (prefs.getInt('install_date') == null) {
        await prefs.setInt('install_date', DateTime.now().millisecondsSinceEpoch);
        await _trackInstallEvent();
      }
      
      // Increment usage count
      _usageCount++;
      await prefs.setInt('usage_count', _usageCount);
      
      // Determine cohort based on install date and usage
      _determineUserCohort();
      
    } catch (e) {
      print('Failed to load user data: $e');
    }
  }

  void _determineUserCohort() {
    if (_installDate == null) return;
    
    final daysSinceInstall = DateTime.now().difference(_installDate!).inDays;
    
    if (daysSinceInstall < 7) {
      _userCohort = 'new_user';
    } else if (daysSinceInstall < 30) {
      _userCohort = 'active_user';
    } else if (_usageCount > 100) {
      _userCohort = 'power_user';
    } else {
      _userCohort = 'casual_user';
    }
    
    _saveUserCohort();
  }

  Future<void> _saveUserCohort() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_cohort', _userCohort);
    } catch (e) {
      print('Failed to save user cohort: $e');
    }
  }

  Future<void> _trackInstallEvent() async {
    try {
      await _analytics.logEvent(
        name: 'app_install',
        parameters: {
          'install_date': _installDate?.toIso8601String(),
          'device_info': await _getDeviceInfo(),
        },
      );
    } catch (e) {
      print('Failed to track install event: $e');
    }
  }

  Future<String> _getDeviceInfo() async {
    try {
      // This method is no longer used as package_info_plus and device_info_plus are removed.
      // Keeping it for now as it might be re-introduced or replaced.
      return 'unknown'; 
    } catch (e) {
      return 'unknown';
    }
  }

  void _startPeriodicRefresh() {
    // Refresh shortcuts every hour
    Future.delayed(Duration(hours: 1), () {
      _refreshDynamicShortcuts();
      _startPeriodicRefresh(); // Recursive call
    });
  }

  Future<void> _refreshDynamicShortcuts() async {
    if (!_enableDynamicShortcuts) return;
    
    try {
      // Fetch new shortcuts based on user cohort and time
      await _fetchCohortBasedShortcuts();
      await _fetchTimeBasedShortcuts();
      
      notifyListeners();
    } catch (e) {
      print('Failed to refresh shortcuts: $e');
    }
  }

  Future<void> _fetchCohortBasedShortcuts() async {
    // This will fetch shortcuts based on user cohort
    // Implementation depends on your backend/remote config structure
    _dynamicShortcuts = [
      WebAppShortcut(
        id: '1',
        title: 'Arc News',
        url: 'https://arc-launcher.com/news',
        iconUrl: 'https://arc-launcher.com/icon1.png',
        category: 'news',
        cohort: _userCohort,
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      ),
      WebAppShortcut(
        id: '2',
        title: 'Arc Community',
        url: 'https://arc-launcher.com/community',
        iconUrl: 'https://arc-launcher.com/icon2.png',
        category: 'social',
        cohort: _userCohort,
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      ),
    ];
  }

  Future<void> _fetchTimeBasedShortcuts() async {
    // Add time-based shortcuts (e.g., morning routine, evening entertainment)
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      // Morning shortcuts
      _dynamicShortcuts.add(WebAppShortcut(
        id: 'morning_1',
        title: 'Morning Briefing',
        url: 'https://arc-launcher.com/morning',
        iconUrl: 'https://arc-launcher.com/morning.png',
        category: 'morning',
        cohort: _userCohort,
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      ));
    } else if (hour >= 18 && hour < 22) {
      // Evening shortcuts
      _dynamicShortcuts.add(WebAppShortcut(
        id: 'evening_1',
        title: 'Evening Entertainment',
        url: 'https://arc-launcher.com/evening',
        iconUrl: 'https://arc-launcher.com/evening.png',
        category: 'evening',
        cohort: _userCohort,
        installDate: DateTime.now(),
        lastUsed: DateTime.now(),
      ));
    }
  }

  Future<void> refreshRecommendations() async {
    if (!_enableRecommendations) return;
    
    try {
      // Fetch app recommendations based on usage patterns and cohort
      await _fetchAppRecommendations();
      notifyListeners();
    } catch (e) {
      print('Failed to refresh recommendations: $e');
    }
  }

  Future<void> _fetchAppRecommendations() async {
    // This will fetch app recommendations
    // Implementation depends on your app discovery logic
    _recommendedApps = [
      AppShortcut(
        packageName: 'com.example.app1',
        name: 'Recommended App 1',
        icon: Icons.apps,
        color: Colors.blue,
        category: 'productivity',
      ),
      AppShortcut(
        packageName: 'com.example.app2',
        name: 'Recommended App 2',
        icon: Icons.games,
        color: Colors.green,
        category: 'entertainment',
      ),
    ];
  }

  Future<void> forceRefresh() async {
    await _remoteConfig.fetchAndActivate();
    _loadRemoteConfigValues();
    await _refreshDynamicShortcuts();
    await refreshRecommendations();
  }

  Future<void> trackShortcutUsage(String shortcutId) async {
    try {
      await _analytics.logEvent(
        name: 'shortcut_used',
        parameters: {
          'shortcut_id': shortcutId,
          'user_cohort': _userCohort,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to track shortcut usage: $e');
    }
  }

  Future<void> trackAppRecommendationClick(String packageName) async {
    try {
      await _analytics.logEvent(
        name: 'app_recommendation_clicked',
        parameters: {
          'package_name': packageName,
          'user_cohort': _userCohort,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to track app recommendation click: $e');
    }
  }
}

