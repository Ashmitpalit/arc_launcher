import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;
  
  // A/B Testing
  final Map<String, String> _abTestVariants = {};
  // Remove unused field
  // final Map<String, dynamic> _userProperties = {};
  
  // User tracking
  String? _userId;
  String? _userCohort;
  DateTime? _firstLaunch;
  int _sessionCount = 0;
  
  // Events
  final List<AnalyticsEvent> _pendingEvents = [];
  bool _isInitialized = false;

  // Initialize the service
  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);
      
      await _loadUserData();
      await _setupAbtests();
      await _flushPendingEvents();
      
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize analytics service: $e');
    }
  }

  // Get analytics observer for navigation
  FirebaseAnalyticsObserver get observer => _observer;

  // Load user data
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('analytics_user_id');
      _userCohort = prefs.getString('user_cohort');
      _sessionCount = prefs.getInt('session_count') ?? 0;
      
      final firstLaunchTimestamp = prefs.getInt('first_launch');
      if (firstLaunchTimestamp != null) {
        _firstLaunch = DateTime.fromMillisecondsSinceEpoch(firstLaunchTimestamp);
      } else {
        _firstLaunch = DateTime.now();
        await prefs.setInt('first_launch', _firstLaunch!.millisecondsSinceEpoch);
      }
      
      // Generate user ID if not exists
      if (_userId == null) {
        _userId = _generateUserId();
        await prefs.setString('analytics_user_id', _userId!);
      }
      
      // Increment session count
      _sessionCount++;
      await prefs.setInt('session_count', _sessionCount);
      
      // Set user properties
      await _setUserProperties();
      
    } catch (e) {
      print('Failed to load user data: $e');
    }
  }

  // Generate unique user ID
  String _generateUserId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(16, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  // Setup A/B tests
  Future<void> _setupAbtests() async {
    try {
      // Example A/B tests - in real app, these would come from Firebase Remote Config
      _abTestVariants['home_layout'] = _getRandomVariant(['grid', 'list', 'carousel']);
      _abTestVariants['color_scheme'] = _getRandomVariant(['dark', 'light', 'auto']);
      _abTestVariants['animation_speed'] = _getRandomVariant(['fast', 'normal', 'slow']);
      _abTestVariants['feature_flags'] = _getRandomVariant(['basic', 'advanced', 'premium']);
      
      // Log A/B test assignment
      for (final test in _abTestVariants.entries) {
        await _analytics.logEvent(
          name: 'ab_test_assigned',
          parameters: {
            'test_name': test.key,
            'variant': test.value,
            'user_id': _userId,
            'cohort': _userCohort,
          },
        );
      }
    } catch (e) {
      print('Failed to setup A/B tests: $e');
    }
  }

  // Get random variant for A/B test
  String _getRandomVariant(List<String> variants) {
    final random = Random();
    return variants[random.nextInt(variants.length)];
  }

  // Set user properties
  Future<void> _setUserProperties() async {
    try {
      await _analytics.setUserId(id: _userId);
      await _analytics.setUserProperty(name: 'cohort', value: _userCohort);
      await _analytics.setUserProperty(name: 'session_count', value: _sessionCount.toString());
      await _analytics.setUserProperty(name: 'first_launch', value: _firstLaunch?.toIso8601String());
      
      // Set A/B test variants as user properties
      for (final test in _abTestVariants.entries) {
        await _analytics.setUserProperty(name: 'ab_${test.key}', value: test.value);
      }
    } catch (e) {
      print('Failed to set user properties: $e');
    }
  }

  // Flush pending events
  Future<void> _flushPendingEvents() async {
    if (!_isInitialized) return;
    
    for (final event in _pendingEvents) {
      await _logEvent(event.name, event.parameters);
    }
    _pendingEvents.clear();
  }

  // Log custom event
  Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    final event = AnalyticsEvent(name, parameters);
    
    if (!_isInitialized) {
      _pendingEvents.add(event);
      return;
    }
    
    await _logEvent(name, parameters);
  }

  // Internal event logging
  Future<void> _logEvent(String name, [Map<String, dynamic>? parameters]) async {
    try {
      final enhancedParams = <String, dynamic>{
        'user_id': _userId,
        'cohort': _userCohort,
        'session_count': _sessionCount,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };
      
      await _analytics.logEvent(
        name: name,
        parameters: enhancedParams,
      );
    } catch (e) {
      print('Failed to log event $name: $e');
    }
  }

  // Predefined events
  Future<void> logAppOpen() async {
    await logEvent('app_open');
  }

  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {'screen_name': screenName});
  }

  Future<void> logFeatureUsage(String featureName) async {
    await logEvent('feature_used', {'feature_name': featureName});
  }

  Future<void> logButtonClick(String buttonName, String screenName) async {
    await logEvent('button_click', {
      'button_name': buttonName,
      'screen_name': screenName,
    });
  }

  Future<void> logAppInstall() async {
    await logEvent('app_install');
  }

  Future<void> logAppUpdate(String fromVersion, String toVersion) async {
    await logEvent('app_update', {
      'from_version': fromVersion,
      'to_version': toVersion,
    });
  }

  Future<void> logError(String errorType, String errorMessage) async {
    await logEvent('app_error', {
      'error_type': errorType,
      'error_message': errorMessage,
    });
  }

  Future<void> logPerformance(String metricName, int value) async {
    await logEvent('performance_metric', {
      'metric_name': metricName,
      'value': value,
    });
  }

  Future<void> logConversion(String conversionType, [Map<String, dynamic>? additionalParams]) async {
    await logEvent('conversion', {
      'conversion_type': conversionType,
      ...?additionalParams,
    });
  }

  // A/B Test methods
  String getAbTestVariant(String testName) {
    return _abTestVariants[testName] ?? 'control';
  }

  bool isInAbTest(String testName, String variant) {
    return _abTestVariants[testName] == variant;
  }

  Future<void> logAbTestImpression(String testName) async {
    await logEvent('ab_test_impression', {
      'test_name': testName,
      'variant': _abTestVariants[testName],
    });
  }

  Future<void> logAbTestConversion(String testName, String conversionType) async {
    await logEvent('ab_test_conversion', {
      'test_name': testName,
      'variant': _abTestVariants[testName],
      'conversion_type': conversionType,
    });
  }

  // Cohort analysis
  Future<void> logCohortEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    await logEvent('cohort_$eventName', {
      'cohort': _userCohort,
      ...?parameters,
    });
  }

  // User engagement tracking
  Future<void> logUserEngagement(String engagementType, int duration) async {
    await logEvent('user_engagement', {
      'engagement_type': engagementType,
      'duration_seconds': duration,
    });
  }

  Future<void> logRetentionEvent(int daysSinceInstall) async {
    await logEvent('retention_event', {
      'days_since_install': daysSinceInstall,
    });
  }

  // Get analytics data
  Map<String, dynamic> getAnalyticsData() {
    return {
      'user_id': _userId,
      'cohort': _userCohort,
      'session_count': _sessionCount,
      'first_launch': _firstLaunch?.toIso8601String(),
      'ab_tests': _abTestVariants,
      'is_initialized': _isInitialized,
    };
  }

  // Update user cohort
  Future<void> updateUserCohort(String newCohort) async {
    _userCohort = newCohort;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_cohort', newCohort);
      
      await _analytics.setUserProperty(name: 'cohort', value: newCohort);
      await logEvent('cohort_changed', {'new_cohort': newCohort});
    } catch (e) {
      print('Failed to update user cohort: $e');
    }
  }

  // Reset analytics (for testing)
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('analytics_user_id');
      await prefs.remove('session_count');
      await prefs.remove('first_launch');
      
      _userId = null;
      _sessionCount = 0;
      _firstLaunch = null;
      _abTestVariants.clear();
      _pendingEvents.clear();
      _isInitialized = false;
    } catch (e) {
      print('Failed to reset analytics: $e');
    }
  }
}

// Analytics event class
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? parameters;

  AnalyticsEvent(this.name, this.parameters);

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, parameters: $parameters)';
  }
}

// Analytics mixin for widgets
mixin AnalyticsMixin<T extends StatefulWidget> on State<T> {
  AnalyticsService get analytics => AnalyticsService();

  @override
  void initState() {
    super.initState();
    _logScreenView();
  }

  void _logScreenView() {
    final route = ModalRoute.of(context);
    if (route != null) {
      final screenName = route.settings.name ?? widget.runtimeType.toString();
      analytics.logScreenView(screenName);
    }
  }

  void logButtonClick(String buttonName) {
    final route = ModalRoute.of(context);
    if (route != null) {
      final screenName = route.settings.name ?? widget.runtimeType.toString();
      analytics.logButtonClick(buttonName, screenName);
    }
  }

  void logFeatureUsage(String featureName) {
    analytics.logFeatureUsage(featureName);
  }

  void logAbTestImpression(String testName) {
    analytics.logAbTestImpression(testName);
  }

  void logConversion(String conversionType, [Map<String, dynamic>? additionalParams]) {
    analytics.logConversion(conversionType, additionalParams);
  }
}
