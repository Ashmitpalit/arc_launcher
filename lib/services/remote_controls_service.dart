import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/remote_config.dart';

/// Service for managing remote controls and cloud configurations
class RemoteControlsService {
  static final RemoteControlsService _instance = RemoteControlsService._internal();
  factory RemoteControlsService() => _instance;
  RemoteControlsService._internal();

  static const String _configKey = 'remote_controls_config';
  static const String _cohortsKey = 'remote_controls_cohorts';
  static const String _userContextKey = 'remote_controls_user_context';
  static const String _settingsKey = 'remote_controls_settings';

  List<RemoteConfig> _configs = [];
  List<UserCohort> _cohorts = [];
  Map<String, dynamic> _userContext = {};
  Map<String, dynamic> _settings = {};
  bool _isInitialized = false;

  /// Get all remote configs
  List<RemoteConfig> get configs => List.unmodifiable(_configs);

  /// Get enabled configs
  List<RemoteConfig> get enabledConfigs {
    return _configs.where((config) => config.isEnabled).toList();
  }

  /// Get configs by category
  List<RemoteConfig> getConfigsByCategory(String category) {
    return _configs.where((config) => config.category == category).toList();
  }

  /// Get critical configs
  List<RemoteConfig> get criticalConfigs {
    return _configs.where((config) => config.isCritical).toList();
  }

  /// Get recent configs (within 24 hours)
  List<RemoteConfig> get recentConfigs {
    return _configs.where((config) => config.isRecent).toList();
  }

  /// Get A/B test configs
  List<RemoteConfig> get abtestConfigs {
    return _configs.where((config) => config.isAbtest).toList();
  }

  /// Get all cohorts
  List<UserCohort> get cohorts => List.unmodifiable(_cohorts);

  /// Get active cohorts
  List<UserCohort> get activeCohorts {
    return _cohorts.where((cohort) => cohort.isActive).toList();
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadSettings();
      await _loadUserContext();
      await _generateDefaultConfigs();
      await _generateDefaultCohorts();
      _isInitialized = true;
      print('RemoteControlsService initialized with ${_configs.length} configs and ${_cohorts.length} cohorts');
    } catch (e) {
      print('Error initializing RemoteControlsService: $e');
      await _loadDefaultData();
    }
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        _settings = Map<String, dynamic>.from(json.decode(settingsJson));
      } else {
        // Set default settings
        _settings = {
          'autoSync': true,
          'syncInterval': 300, // seconds
          'enableAbtesting': true,
          'enableCohorts': true,
          'enableAnalytics': true,
          'maxConfigs': 100,
          'maxCohorts': 50,
        };
      }
    } catch (e) {
      print('Error loading settings: $e');
      _settings = {};
    }
  }

  /// Load user context from storage
  Future<void> _loadUserContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? contextJson = prefs.getString(_userContextKey);

      if (contextJson != null) {
        _userContext = Map<String, dynamic>.from(json.decode(contextJson));
      } else {
        // Set default user context
        _userContext = {
          'cohort': 'general',
          'version': '1.0.0',
          'device': 'android',
          'region': 'US',
          'language': 'en',
          'premium': false,
          'beta': false,
        };
      }
    } catch (e) {
      print('Error loading user context: $e');
      _userContext = {};
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String settingsJson = json.encode(_settings);
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  /// Save user context to storage
  Future<void> _saveUserContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String contextJson = json.encode(_userContext);
      await prefs.setString(_userContextKey, contextJson);
    } catch (e) {
      print('Error saving user context: $e');
    }
  }

  /// Generate default remote configs
  Future<void> _generateDefaultConfigs() async {
    _configs = [
      // Feature Toggles
      RemoteConfig(
        key: 'enable_dark_mode',
        name: 'Dark Mode',
        description: 'Enable dark theme across the launcher',
        value: true,
        type: 'boolean',
        category: 'feature',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        updatedBy: 'System',
        priority: 7,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': true,
          'requiresRestart': false,
          'userOverride': true,
        },
      ),
      
      RemoteConfig(
        key: 'enable_gestures',
        name: 'Gesture Navigation',
        description: 'Enable swipe gestures for navigation',
        value: true,
        type: 'boolean',
        category: 'feature',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        updatedBy: 'System',
        priority: 6,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': true,
          'requiresRestart': false,
          'userOverride': true,
        },
      ),
      
      RemoteConfig(
        key: 'enable_widgets',
        name: 'Widget System',
        description: 'Enable home screen widgets',
        value: true,
        type: 'boolean',
        category: 'feature',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
        updatedBy: 'System',
        priority: 8,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': true,
          'requiresRestart': false,
          'userOverride': false,
        },
      ),
      
      // UI Settings
      RemoteConfig(
        key: 'icon_size',
        name: 'Icon Size',
        description: 'Size of app icons on home screen',
        value: 'medium',
        type: 'string',
        category: 'ui',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        updatedBy: 'System',
        priority: 5,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': 'medium',
          'options': ['small', 'medium', 'large'],
          'requiresRestart': true,
        },
      ),
      
      RemoteConfig(
        key: 'grid_columns',
        name: 'Grid Columns',
        description: 'Number of columns in app grid',
        value: 4,
        type: 'number',
        category: 'ui',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        updatedBy: 'System',
        priority: 5,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': 4,
          'minValue': 3,
          'maxValue': 6,
          'requiresRestart': true,
        },
      ),
      
      // Performance Settings
      RemoteConfig(
        key: 'animation_speed',
        name: 'Animation Speed',
        description: 'Speed of UI animations',
        value: 1.0,
        type: 'number',
        category: 'performance',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        updatedBy: 'System',
        priority: 4,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': 1.0,
          'minValue': 0.5,
          'maxValue': 2.0,
          'requiresRestart': false,
        },
      ),
      
      RemoteConfig(
        key: 'cache_size',
        name: 'Cache Size',
        description: 'Maximum cache size in MB',
        value: 100,
        type: 'number',
        category: 'performance',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        updatedBy: 'System',
        priority: 6,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': 100,
          'minValue': 50,
          'maxValue': 500,
          'requiresRestart': true,
        },
      ),
      
      // Monetization Settings
      RemoteConfig(
        key: 'ad_frequency',
        name: 'Ad Frequency',
        description: 'Frequency of interstitial ads',
        value: 'moderate',
        type: 'string',
        category: 'monetization',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        updatedBy: 'System',
        priority: 7,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': 'moderate',
          'options': ['low', 'moderate', 'high'],
          'requiresRestart': false,
        },
      ),
      
      RemoteConfig(
        key: 'premium_features',
        name: 'Premium Features',
        description: 'Enable premium feature access',
        value: false,
        type: 'boolean',
        category: 'monetization',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        updatedBy: 'System',
        priority: 8,
        conditions: {'cohort': 'premium'},
        metadata: {
          'defaultValue': false,
          'requiresRestart': false,
          'userOverride': false,
        },
      ),
      
      // Content Settings
      RemoteConfig(
        key: 'news_frequency',
        name: 'News Update Frequency',
        description: 'How often to refresh news content',
        value: 3600,
        type: 'number',
        category: 'content',
        lastUpdated: DateTime.now().subtract(const Duration(days: 4)),
        updatedBy: 'System',
        priority: 4,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': 3600,
          'minValue': 1800,
          'maxValue': 7200,
          'requiresRestart': false,
        },
      ),
      
      // A/B Testing Examples
      RemoteConfig(
        key: 'new_home_layout',
        name: 'New Home Layout',
        description: 'Test new home screen layout design',
        value: 'grid',
        type: 'string',
        category: 'ui',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        updatedBy: 'System',
        priority: 6,
        isAbtest: true,
        abtestVariant: 'A',
        conditions: {'cohort': 'beta'},
        metadata: {
          'defaultValue': 'list',
          'options': ['list', 'grid', 'masonry'],
          'requiresRestart': true,
          'abtestId': 'home_layout_2024',
        },
      ),
      
      RemoteConfig(
        key: 'new_home_layout_b',
        name: 'New Home Layout (Variant B)',
        description: 'Test new home screen layout design - Variant B',
        value: 'masonry',
        type: 'string',
        category: 'ui',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        updatedBy: 'System',
        priority: 6,
        isAbtest: true,
        abtestVariant: 'B',
        conditions: {'cohort': 'beta'},
        metadata: {
          'defaultValue': 'list',
          'options': ['list', 'grid', 'masonry'],
          'requiresRestart': true,
          'abtestId': 'home_layout_2024',
        },
      ),
      
      // Security Settings
      RemoteConfig(
        key: 'biometric_auth',
        name: 'Biometric Authentication',
        description: 'Enable fingerprint/face unlock',
        value: true,
        type: 'boolean',
        category: 'security',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        updatedBy: 'System',
        priority: 9,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': true,
          'requiresRestart': false,
          'userOverride': true,
        },
      ),
      
      // Analytics Settings
      RemoteConfig(
        key: 'analytics_enabled',
        name: 'Analytics Collection',
        description: 'Enable usage analytics collection',
        value: true,
        type: 'boolean',
        category: 'analytics',
        lastUpdated: DateTime.now().subtract(const Duration(days: 6)),
        updatedBy: 'System',
        priority: 5,
        conditions: {'cohort': 'general'},
        metadata: {
          'defaultValue': true,
          'requiresRestart': false,
          'userOverride': true,
        },
      ),
    ];
  }

  /// Generate default user cohorts
  Future<void> _generateDefaultCohorts() async {
    _cohorts = [
      UserCohort(
        id: 'general',
        name: 'General Users',
        description: 'Standard user cohort with basic features',
        tags: ['standard', 'basic'],
        attributes: {
          'featureAccess': 'basic',
          'updateFrequency': 'normal',
          'supportLevel': 'standard',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        userCount: 10000,
        metadata: {
          'creationReason': 'default',
          'targetAudience': 'general',
        },
      ),
      
      UserCohort(
        id: 'premium',
        name: 'Premium Users',
        description: 'Premium subscribers with advanced features',
        tags: ['premium', 'advanced', 'subscriber'],
        attributes: {
          'featureAccess': 'premium',
          'updateFrequency': 'high',
          'supportLevel': 'priority',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        userCount: 2500,
        metadata: {
          'creationReason': 'subscription',
          'targetAudience': 'power_users',
        },
      ),
      
      UserCohort(
        id: 'beta',
        name: 'Beta Testers',
        description: 'Early access users for testing new features',
        tags: ['beta', 'early_access', 'testing'],
        attributes: {
          'featureAccess': 'beta',
          'updateFrequency': 'very_high',
          'supportLevel': 'priority',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        userCount: 500,
        metadata: {
          'creationReason': 'testing',
          'targetAudience': 'developers',
        },
      ),
      
      UserCohort(
        id: 'enterprise',
        name: 'Enterprise Users',
        description: 'Business users with enterprise features',
        tags: ['enterprise', 'business', 'corporate'],
        attributes: {
          'featureAccess': 'enterprise',
          'updateFrequency': 'controlled',
          'supportLevel': 'dedicated',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        userCount: 100,
        metadata: {
          'creationReason': 'business',
          'targetAudience': 'corporations',
        },
      ),
      
      UserCohort(
        id: 'new_users',
        name: 'New Users',
        description: 'Recently onboarded users',
        tags: ['new', 'onboarding', 'learning'],
        attributes: {
          'featureAccess': 'basic',
          'updateFrequency': 'normal',
          'supportLevel': 'enhanced',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        userCount: 1500,
        metadata: {
          'creationReason': 'onboarding',
          'targetAudience': 'beginners',
        },
      ),
    ];
  }

  /// Load default data if generation fails
  Future<void> _loadDefaultData() async {
    _configs = [
      RemoteConfig(
        key: 'default',
        name: 'Default Config',
        description: 'Default remote configuration',
        value: true,
        type: 'boolean',
        category: 'feature',
        lastUpdated: DateTime.now(),
        updatedBy: 'System',
        priority: 5,
      ),
    ];
    
    _cohorts = [
      UserCohort(
        id: 'default',
        name: 'Default Cohort',
        description: 'Default user cohort',
        tags: ['default'],
        attributes: {},
        createdAt: DateTime.now(),
        userCount: 1,
      ),
    ];
    
    _isInitialized = true;
  }

  /// Get config by key
  RemoteConfig? getConfig(String key) {
    try {
      return _configs.firstWhere((config) => config.key == key);
    } catch (e) {
      return null;
    }
  }

  /// Get config value with fallback
  T getConfigValue<T>(String key, T fallback) {
    final config = getConfig(key);
    if (config != null && config.isEnabled && config.matchesConditions(_userContext)) {
      return config.getValue<T>();
    }
    return fallback;
  }

  /// Get boolean config value
  bool getBoolConfig(String key, {bool fallback = false}) {
    return getConfigValue<bool>(key, fallback);
  }

  /// Get string config value
  String getStringConfig(String key, {String fallback = ''}) {
    return getConfigValue<String>(key, fallback);
  }

  /// Get int config value
  int getIntConfig(String key, {int fallback = 0}) {
    return getConfigValue<int>(key, fallback);
  }

  /// Get double config value
  double getDoubleConfig(String key, {double fallback = 0.0}) {
    return getConfigValue<double>(key, fallback);
  }

  /// Update config value
  Future<void> updateConfig(String key, dynamic newValue) async {
    final config = getConfig(key);
    if (config != null) {
      final updatedConfig = config.copyWith(
        value: newValue,
        lastUpdated: DateTime.now(),
        updatedBy: 'User',
      );
      
      final index = _configs.indexWhere((c) => c.key == key);
      if (index != -1) {
        _configs[index] = updatedConfig;
        await _saveConfigs();
      }
    }
  }

  /// Toggle boolean config
  Future<void> toggleConfig(String key) async {
    final config = getConfig(key);
    if (config != null && config.type == 'boolean') {
      await updateConfig(key, !config.boolValue);
    }
  }

  /// Get cohort by ID
  UserCohort? getCohort(String id) {
    try {
      return _cohorts.firstWhere((cohort) => cohort.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get current user cohort
  UserCohort? get currentUserCohort {
    final cohortId = _userContext['cohort'];
    if (cohortId != null) {
      return getCohort(cohortId);
    }
    return null;
  }

  /// Update user context
  Future<void> updateUserContext(Map<String, dynamic> newContext) async {
    _userContext.addAll(newContext);
    await _saveUserContext();
  }

  /// Update settings
  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    _settings.addAll(newSettings);
    await _saveSettings();
  }

  /// Save configs to storage
  Future<void> _saveConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String configsJson = json.encode(_configs.map((c) => c.toMap()).toList());
      await prefs.setString(_configKey, configsJson);
    } catch (e) {
      print('Error saving configs: $e');
    }
  }

  /// Save cohorts to storage
  Future<void> _saveCohorts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cohortsJson = json.encode(_cohorts.map((c) => c.toMap()).toList());
      await prefs.setString(_cohortsKey, cohortsJson);
    } catch (e) {
      print('Error saving cohorts: $e');
    }
  }

  /// Get remote controls statistics
  Map<String, dynamic> getRemoteControlsStats() {
    final totalConfigs = _configs.length;
    final enabledConfigs = _configs.where((config) => config.isEnabled).length;
    final criticalConfigs = _configs.where((config) => config.isCritical).length;
    final abtestConfigs = _configs.where((config) => config.isAbtest).length;
    
    final categoryStats = <String, int>{};
    final priorityStats = <String, int>{};
    
    for (final config in _configs) {
      categoryStats[config.category] = (categoryStats[config.category] ?? 0) + 1;
      priorityStats[config.priorityLabel] = (priorityStats[config.priorityLabel] ?? 0) + 1;
    }

    final totalCohorts = _cohorts.length;
    final activeCohorts = _cohorts.where((cohort) => cohort.isActive).length;
    final totalUsers = _cohorts.fold(0, (sum, cohort) => sum + cohort.userCount);

    return {
      'totalConfigs': totalConfigs,
      'enabledConfigs': enabledConfigs,
      'criticalConfigs': criticalConfigs,
      'abtestConfigs': abtestConfigs,
      'categoryDistribution': categoryStats,
      'priorityDistribution': priorityStats,
      'totalCohorts': totalCohorts,
      'activeCohorts': activeCohorts,
      'totalUsers': totalUsers,
      'currentUserCohort': currentUserCohort?.name ?? 'Unknown',
      'userContext': _userContext,
      'settings': _settings,
    };
  }

  /// Get available categories
  List<String> getAvailableCategories() {
    final categories = _configs.map((config) => config.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  /// Get available priorities
  List<String> getAvailablePriorities() {
    final priorities = _configs.map((config) => config.priorityLabel).toSet().toList();
    priorities.sort((a, b) {
      final priorityOrder = ['Critical', 'High', 'Medium', 'Low', 'Minimal'];
      return priorityOrder.indexOf(a).compareTo(priorityOrder.indexOf(b));
    });
    return ['All', ...priorities];
  }

  /// Filter configs
  List<RemoteConfig> filterConfigs({
    String? category,
    String? priority,
    bool? isEnabled,
    bool? isAbtest,
    String? searchQuery,
  }) {
    List<RemoteConfig> filtered = List.from(_configs);
    
    if (category != null && category != 'All') {
      filtered = filtered.where((config) => config.category == category).toList();
    }
    
    if (priority != null && priority != 'All') {
      filtered = filtered.where((config) => config.priorityLabel == priority).toList();
    }
    
    if (isEnabled != null) {
      filtered = filtered.where((config) => config.isEnabled == isEnabled).toList();
    }
    
    if (isAbtest != null) {
      filtered = filtered.where((config) => config.isAbtest == isAbtest).toList();
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filtered = filtered.where((config) {
        return config.name.toLowerCase().contains(lowercaseQuery) ||
               config.description.toLowerCase().contains(lowercaseQuery) ||
               config.key.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }
    
    return filtered;
  }

  /// Refresh remote controls
  Future<void> refresh() async {
    await _generateDefaultConfigs();
    await _generateDefaultCohorts();
  }

  /// Dispose resources
  void dispose() {
    _configs.clear();
    _cohorts.clear();
    _userContext.clear();
    _settings.clear();
    _isInitialized = false;
  }
}
