import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_shortcut.dart';

class UsageStatsService {
  static const MethodChannel _channel = MethodChannel('usage_stats_channel');
  static const EventChannel _eventChannel = EventChannel('usage_stats_events');
  
  static final UsageStatsService _instance = UsageStatsService._internal();
  factory UsageStatsService() => _instance;
  UsageStatsService._internal();

  StreamController<AppUsageData>? _usageStreamController;
  Stream<AppUsageData>? _usageStream;
  
  bool _isInitialized = false;
  List<AppUsageData> _cachedUsageData = [];
  
  // Daily usage limits for ad caps
  static const int _dailyUsageLimitMinutes = 240; // 4 hours
  static const int _interstitialCapMinutes = 30; // Show ads after 30 min usage

  /// Initialize the usage stats service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      if (Platform.isAndroid) {
        // Check if usage stats permission is granted
        final hasPermission = await _checkUsageStatsPermission();
        if (!hasPermission) {
          print('Usage stats permission not granted');
          return false;
        }
        
        // Start the native service
        await _startNativeService();
        
        // Listen to usage events
        _setupUsageStream();
        
        _isInitialized = true;
        print('UsageStatsService initialized successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Failed to initialize UsageStatsService: $e');
      return false;
    }
  }

  /// Check if usage stats permission is granted
  Future<bool> _checkUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('checkUsageStatsPermission');
      print('Permission check result: $result');
      return result ?? false;
    } catch (e) {
      print('Error checking usage stats permission: $e');
      return false;
    }
  }

  /// Request usage stats permission
  Future<bool> requestUsageStatsPermission() async {
    try {
      final result = await _channel.invokeMethod('requestUsageStatsPermission');
      return result ?? false;
    } catch (e) {
      print('Error requesting usage stats permission: $e');
      return false;
    }
  }

  /// Start the native Android service
  Future<void> _startNativeService() async {
    try {
      await _channel.invokeMethod('startUsageStatsService');
      print('Native usage stats service started');
    } catch (e) {
      print('Error starting native service: $e');
    }
  }

  /// Setup stream to listen to usage events from native service
  void _setupUsageStream() {
    _usageStreamController = StreamController<AppUsageData>.broadcast();
    _usageStream = _usageStreamController!.stream;
    
    _eventChannel.receiveBroadcastStream().listen((dynamic event) {
      try {
        if (event is Map) {
          final usageData = AppUsageData.fromMap(Map<String, dynamic>.from(event));
          _usageStreamController?.add(usageData);
          _updateCachedData(usageData);
        }
      } catch (e) {
        print('Error processing usage event: $e');
      }
    });
  }

  /// Update cached usage data
  void _updateCachedData(AppUsageData usageData) {
    final existingIndex = _cachedUsageData.indexWhere(
      (data) => data.packageName == usageData.packageName
    );
    
    if (existingIndex != -1) {
      _cachedUsageData[existingIndex] = usageData;
    } else {
      _cachedUsageData.add(usageData);
    }
  }

  /// Get real-time usage statistics
  Future<List<AppUsageData>> getUsageStats({
    Duration? timeRange,
    int? limit,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('getUsageStats', {
          'timeRange': timeRange?.inMilliseconds,
          'limit': limit,
        });
        
        if (result is List) {
          return result.map((data) => AppUsageData.fromMap(data)).toList();
        }
      }
      
      // Fallback to cached data
      return _cachedUsageData;
    } catch (e) {
      print('Error getting usage stats: $e');
      return _cachedUsageData;
    }
  }

  /// Get today's usage statistics
  Future<List<AppUsageData>> getTodayUsageStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final timeRange = now.difference(startOfDay);
    
    // Try to get real usage data first
    final realData = await _getRealUsageData();
    if (realData.isNotEmpty) {
      _cachedUsageData = realData;
      return realData;
    }
    
    return getUsageStats(timeRange: timeRange);
  }

  /// Get real usage data from native service
  Future<List<AppUsageData>> _getRealUsageData() async {
    try {
      if (Platform.isAndroid) {
        // First try to get current usage stats from our service
        final currentStats = await _channel.invokeMethod('getCurrentUsageStats');
        print('Current usage stats: $currentStats');
        
        if (currentStats != null && currentStats is Map && currentStats.isNotEmpty) {
          final List<AppUsageData> realData = [];
          for (final entry in currentStats.entries) {
            final packageName = entry.key;
            final usageTimeMs = entry.value as int;
            final usageTimeMinutes = (usageTimeMs / (1000 * 60)).round();
            
            if (usageTimeMinutes > 0) {
              realData.add(AppUsageData(
                packageName: packageName,
                appName: packageName, // We'll get real app names later
                icon: null,
                usageTime: usageTimeMinutes,
                launchCount: 1,
                lastUsed: DateTime.now(),
                category: 'Unknown',
                rating: null,
              ));
            }
          }
          
          if (realData.isNotEmpty) {
            print('Found ${realData.length} apps with real usage data');
            return realData;
          }
        }
        
        // Fallback to system usage stats
        final result = await _channel.invokeMethod('getUsageStats', {
          'timeRange': 24 * 60 * 60 * 1000, // 24 hours in milliseconds
          'limit': 50,
        });
        
        if (result != null && result is List) {
          final List<AppUsageData> realData = [];
          for (final item in result) {
            if (item is Map) {
              try {
                final usageData = AppUsageData.fromMap(Map<String, dynamic>.from(item));
                realData.add(usageData);
              } catch (e) {
                print('Error parsing usage data: $e');
              }
            }
          }
          return realData;
        }
      }
      return [];
    } catch (e) {
      print('Error getting real usage data: $e');
      return [];
    }
  }

  /// Get total usage time for today
  Future<int> getTodayTotalUsageMinutes() async {
    final todayStats = await getTodayUsageStats();
    int totalMinutes = 0;
    
    for (final stat in todayStats) {
      totalMinutes += stat.usageTime;
    }
    
    return totalMinutes;
  }

  /// Check if daily usage limit is reached
  Future<bool> isDailyUsageLimitReached() async {
    final totalMinutes = await getTodayTotalUsageMinutes();
    return totalMinutes >= _dailyUsageLimitMinutes;
  }

  /// Check if interstitial ad cap is reached
  Future<bool> isInterstitialCapReached() async {
    final totalMinutes = await getTodayTotalUsageMinutes();
    return totalMinutes >= _interstitialCapMinutes;
  }

  /// Get remaining time before ad cap
  Future<int> getRemainingTimeBeforeAdCap() async {
    final totalMinutes = await getTodayTotalUsageMinutes();
    final remaining = _interstitialCapMinutes - totalMinutes;
    return remaining > 0 ? remaining : 0;
  }

  /// Get usage statistics for a specific app
  Future<AppUsageData?> getAppUsageStats(String packageName) async {
    final stats = await getUsageStats();
    try {
      return stats.firstWhere((stat) => stat.packageName == packageName);
    } catch (e) {
      return null;
    }
  }

  /// Get most used apps
  Future<List<AppUsageData>> getMostUsedApps({int limit = 10}) async {
    final stats = await getUsageStats();
    stats.sort((a, b) => b.usageTime.compareTo(a.usageTime));
    return stats.take(limit).toList();
  }

  /// Get usage statistics by category
  Future<Map<String, List<AppUsageData>>> getUsageStatsByCategory() async {
    final stats = await getUsageStats();
    final Map<String, List<AppUsageData>> categorized = {};
    
    for (final stat in stats) {
      final category = stat.category ?? 'Unknown';
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(stat);
    }
    
    return categorized;
  }

  /// Get stream of usage updates
  Stream<AppUsageData> get usageStream {
    if (_usageStream == null) {
      _setupUsageStream();
    }
    return _usageStream!;
  }

  /// Manually refresh permission status
  Future<bool> refreshPermissionStatus() async {
    try {
      final hasPermission = await _checkUsageStatsPermission();
      print('Refreshed permission status: $hasPermission');
      
      if (hasPermission && !_isInitialized) {
        // Re-initialize if permission was just granted
        await initialize();
      }
      
      return hasPermission;
    } catch (e) {
      print('Error refreshing permission status: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _usageStreamController?.close();
    _usageStreamController = null;
    _usageStream = null;
  }
}

/// Extended AppUsageData model for usage statistics
class AppUsageData {
  final String packageName;
  final String appName;
  final String? icon;
  final int usageTime; // in minutes
  final int launchCount;
  final DateTime lastUsed;
  final String? category;
  final double? rating;

  AppUsageData({
    required this.packageName,
    required this.appName,
    this.icon,
    required this.usageTime,
    required this.launchCount,
    required this.lastUsed,
    this.category,
    this.rating,
  });

  factory AppUsageData.fromMap(Map<String, dynamic> map) {
    return AppUsageData(
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? '',
      icon: map['icon'],
      usageTime: map['usageTime'] ?? 0,
      launchCount: map['launchCount'] ?? 0,
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastUsed'] ?? 0),
      category: map['category'],
      rating: map['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'icon': icon,
      'usageTime': usageTime,
      'launchCount': launchCount,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
      'category': category,
      'rating': rating,
    };
  }

  AppUsageData copyWith({
    String? packageName,
    String? appName,
    String? icon,
    int? usageTime,
    int? launchCount,
    DateTime? lastUsed,
    String? category,
    double? rating,
  }) {
    return AppUsageData(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      icon: icon ?? this.icon,
      usageTime: usageTime ?? this.usageTime,
      launchCount: launchCount ?? this.launchCount,
      lastUsed: lastUsed ?? this.lastUsed,
      category: category ?? this.category,
      rating: rating ?? this.rating,
    );
  }
}
