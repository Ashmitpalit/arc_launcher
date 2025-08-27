import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:developer' as developer;

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Performance monitoring
  Timer? _performanceTimer;
  final List<PerformanceMetric> _metrics = [];
  bool _isMonitoring = false;
  
  // Memory management
  int _memoryThreshold = 100; // MB
  int _batteryThreshold = 20; // Percentage
  
  // Performance settings
  bool _enableAnimations = true;
  bool _enableTransitions = true;
  bool _enableShadows = true;
  int _animationDuration = 300; // ms
  
  // Cache management
  final Map<String, dynamic> _imageCache = {};
  final Map<String, dynamic> _dataCache = {};
  int _maxCacheSize = 50; // MB

  // Initialize the service
  Future<void> initialize() async {
    try {
      await _loadSettings();
      _startPerformanceMonitoring();
      _setupPerformanceCallbacks();
    } catch (e) {
      print('Failed to initialize performance service: $e');
    }
  }

  // Load performance settings
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enableAnimations = prefs.getBool('enable_animations') ?? true;
      _enableTransitions = prefs.getBool('enable_transitions') ?? true;
      _enableShadows = prefs.getBool('enable_shadows') ?? true;
      _animationDuration = prefs.getInt('animation_duration') ?? 300;
      _memoryThreshold = prefs.getInt('memory_threshold') ?? 100;
      _batteryThreshold = prefs.getInt('battery_threshold') ?? 20;
      _maxCacheSize = prefs.getInt('max_cache_size') ?? 50;
    } catch (e) {
      print('Failed to load performance settings: $e');
    }
  }

  // Save performance settings
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enable_animations', _enableAnimations);
      await prefs.setBool('enable_transitions', _enableTransitions);
      await prefs.setBool('enable_shadows', _enableShadows);
      await prefs.setInt('animation_duration', _animationDuration);
      await prefs.setInt('memory_threshold', _memoryThreshold);
      await prefs.setInt('battery_threshold', _batteryThreshold);
      await prefs.setInt('max_cache_size', _maxCacheSize);
    } catch (e) {
      print('Failed to save performance settings: $e');
    }
  }

  // Start performance monitoring
  void _startPerformanceMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _performanceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _collectPerformanceMetrics();
    });
  }

  // Stop performance monitoring
  void stopPerformanceMonitoring() {
    _isMonitoring = false;
    _performanceTimer?.cancel();
  }

  // Collect performance metrics
  Future<void> _collectPerformanceMetrics() async {
    try {
      final metric = PerformanceMetric(
        timestamp: DateTime.now(),
        memoryUsage: await _getMemoryUsage(),
        batteryLevel: await _getBatteryLevel(),
        frameRate: await _getFrameRate(),
        cpuUsage: await _getCpuUsage(),
      );
      
      _metrics.add(metric);
      
      // Keep only last 100 metrics
      if (_metrics.length > 100) {
        _metrics.removeAt(0);
      }
      
      // Check for performance issues
      _checkPerformanceIssues(metric);
      
    } catch (e) {
      print('Failed to collect performance metrics: $e');
    }
  }

  // Get memory usage
  Future<double> _getMemoryUsage() async {
    try {
      // In a real app, this would use platform channels to get actual memory usage
      // For now, we'll simulate it
      return (DateTime.now().millisecondsSinceEpoch % 100) + 50.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Get battery level
  Future<int> _getBatteryLevel() async {
    try {
      // In a real app, this would use platform channels to get actual battery level
      // For now, we'll simulate it
      return (DateTime.now().millisecondsSinceEpoch % 100);
    } catch (e) {
      return 100;
    }
  }

  // Get frame rate
  Future<double> _getFrameRate() async {
    try {
      // In a real app, this would use platform channels to get actual frame rate
      // For now, we'll simulate it
      return 55.0 + (DateTime.now().millisecondsSinceEpoch % 10);
    } catch (e) {
      return 60.0;
    }
  }

  // Get CPU usage
  Future<double> _getCpuUsage() async {
    try {
      // In a real app, this would use platform channels to get actual CPU usage
      // For now, we'll simulate it
      return (DateTime.now().millisecondsSinceEpoch % 30) + 10.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Check for performance issues
  void _checkPerformanceIssues(PerformanceMetric metric) {
    if (metric.memoryUsage > _memoryThreshold) {
      _handleHighMemoryUsage();
    }
    
    if (metric.batteryLevel < _batteryThreshold) {
      _handleLowBattery();
    }
    
    if (metric.frameRate < 30) {
      _handleLowFrameRate();
    }
    
    if (metric.cpuUsage > 80) {
      _handleHighCpuUsage();
    }
  }

  // Handle high memory usage
  void _handleHighMemoryUsage() {
    print('High memory usage detected');
    _clearImageCache();
    _clearDataCache();
    _requestGarbageCollection();
  }

  // Handle low battery
  void _handleLowBattery() {
    print('Low battery detected');
    _disableNonEssentialFeatures();
    _reduceAnimationQuality();
  }

  // Handle low frame rate
  void _handleLowFrameRate() {
    print('Low frame rate detected');
    _reduceAnimationQuality();
    _disableTransitions();
  }

  // Handle high CPU usage
  void _handleHighCpuUsage() {
    print('High CPU usage detected');
    _reduceBackgroundTasks();
    _optimizeRendering();
  }

  // Clear image cache
  void _clearImageCache() {
    _imageCache.clear();
    developer.log('Image cache cleared', name: 'PerformanceService');
  }

  // Clear data cache
  void _clearDataCache() {
    _dataCache.clear();
    developer.log('Data cache cleared', name: 'PerformanceService');
  }

  // Request garbage collection
  void _requestGarbageCollection() {
    // In a real app, this would trigger platform-specific garbage collection
    developer.log('Garbage collection requested', name: 'PerformanceService');
  }

  // Disable non-essential features
  void _disableNonEssentialFeatures() {
    _enableAnimations = false;
    _enableTransitions = false;
    _enableShadows = false;
    _saveSettings();
  }

  // Reduce animation quality
  void _reduceAnimationQuality() {
    _animationDuration = 500;
    _saveSettings();
  }

  // Disable transitions
  void _disableTransitions() {
    _enableTransitions = false;
    _saveSettings();
  }

  // Reduce background tasks
  void _reduceBackgroundTasks() {
    // Reduce background processing
    developer.log('Background tasks reduced', name: 'PerformanceService');
  }

  // Optimize rendering
  void _optimizeRendering() {
    // Optimize rendering pipeline
    developer.log('Rendering optimized', name: 'PerformanceService');
  }

  // Setup performance callbacks
  void _setupPerformanceCallbacks() {
    // Monitor app lifecycle
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      _onSystemUIChange(systemOverlaysAreVisible);
    });
  }

  // Handle system UI changes
  void _onSystemUIChange(bool systemOverlaysAreVisible) {
    if (systemOverlaysAreVisible) {
      _optimizeForVisibleUI();
    } else {
      _optimizeForHiddenUI();
    }
  }

  // Optimize for visible UI
  void _optimizeForVisibleUI() {
    _enableAnimations = true;
    _enableTransitions = true;
    _saveSettings();
  }

  // Optimize for hidden UI
  void _optimizeForHiddenUI() {
    _enableAnimations = false;
    _enableTransitions = false;
    _saveSettings();
  }

  // Get performance settings
  Map<String, dynamic> getPerformanceSettings() {
    return {
      'enableAnimations': _enableAnimations,
      'enableTransitions': _enableTransitions,
      'enableShadows': _enableShadows,
      'animationDuration': _animationDuration,
      'memoryThreshold': _memoryThreshold,
      'batteryThreshold': _batteryThreshold,
      'maxCacheSize': _maxCacheSize,
    };
  }

  // Update performance settings
  Future<void> updatePerformanceSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('enableAnimations')) {
      _enableAnimations = settings['enableAnimations'];
    }
    if (settings.containsKey('enableTransitions')) {
      _enableTransitions = settings['enableTransitions'];
    }
    if (settings.containsKey('enableShadows')) {
      _enableShadows = settings['enableShadows'];
    }
    if (settings.containsKey('animationDuration')) {
      _animationDuration = settings['animationDuration'];
    }
    if (settings.containsKey('memoryThreshold')) {
      _memoryThreshold = settings['memoryThreshold'];
    }
    if (settings.containsKey('batteryThreshold')) {
      _batteryThreshold = settings['batteryThreshold'];
    }
    if (settings.containsKey('maxCacheSize')) {
      _maxCacheSize = settings['maxCacheSize'];
    }
    
    await _saveSettings();
  }

  // Get performance metrics
  List<PerformanceMetric> getPerformanceMetrics() {
    return List.unmodifiable(_metrics);
  }

  // Get latest performance metric
  PerformanceMetric? getLatestMetric() {
    if (_metrics.isEmpty) return null;
    return _metrics.last;
  }

  // Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    if (_metrics.isEmpty) {
      return {
        'averageMemory': 0.0,
        'averageBattery': 0.0,
        'averageFrameRate': 0.0,
        'averageCpuUsage': 0.0,
        'totalMetrics': 0,
      };
    }

    final avgMemory = _metrics.map((m) => m.memoryUsage).reduce((a, b) => a + b) / _metrics.length;
    final avgBattery = _metrics.map((m) => m.batteryLevel).reduce((a, b) => a + b) / _metrics.length;
    final avgFrameRate = _metrics.map((m) => m.frameRate).reduce((a, b) => a + b) / _metrics.length;
    final avgCpuUsage = _metrics.map((m) => m.cpuUsage).reduce((a, b) => a + b) / _metrics.length;

    return {
      'averageMemory': avgMemory,
      'averageBattery': avgBattery,
      'averageFrameRate': avgFrameRate,
      'averageCpuUsage': avgCpuUsage,
      'totalMetrics': _metrics.length,
    };
  }

  // Optimize app performance
  Future<void> optimizePerformance() async {
    try {
      // Clear caches
      _clearImageCache();
      _clearDataCache();
      
      // Request garbage collection
      _requestGarbageCollection();
      
      // Optimize settings
      if ((getLatestMetric()?.frameRate ?? 60) < 45) {
        _reduceAnimationQuality();
      }
      
      developer.log('Performance optimization completed', name: 'PerformanceService');
    } catch (e) {
      print('Failed to optimize performance: $e');
    }
  }

  // Dispose resources
  void dispose() {
    stopPerformanceMonitoring();
    _imageCache.clear();
    _dataCache.clear();
    _metrics.clear();
  }
}

// Performance metric model
class PerformanceMetric {
  final DateTime timestamp;
  final double memoryUsage;
  final int batteryLevel;
  final double frameRate;
  final double cpuUsage;

  PerformanceMetric({
    required this.timestamp,
    required this.memoryUsage,
    required this.batteryLevel,
    required this.frameRate,
    required this.cpuUsage,
  });

  factory PerformanceMetric.fromMap(Map<String, dynamic> map) {
    return PerformanceMetric(
      timestamp: DateTime.parse(map['timestamp']),
      memoryUsage: (map['memoryUsage'] ?? 0.0).toDouble(),
      batteryLevel: map['batteryLevel'] ?? 0,
      frameRate: (map['frameRate'] ?? 0.0).toDouble(),
      cpuUsage: (map['cpuUsage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'memoryUsage': memoryUsage,
      'batteryLevel': batteryLevel,
      'frameRate': frameRate,
      'cpuUsage': cpuUsage,
    };
  }
}

// Performance optimization mixin
mixin PerformanceOptimized {
  PerformanceService get performanceService => PerformanceService();
  
  bool get enableAnimations => performanceService.getPerformanceSettings()['enableAnimations'] ?? true;
  bool get enableTransitions => performanceService.getPerformanceSettings()['enableTransitions'] ?? true;
  bool get enableShadows => performanceService.getPerformanceSettings()['enableShadows'] ?? true;
  int get animationDuration => performanceService.getPerformanceSettings()['animationDuration'] ?? 300;
  
  Duration get optimizedDuration => Duration(milliseconds: animationDuration);
  
  Curve get optimizedCurve => enableAnimations ? Curves.easeInOut : Curves.linear;
  
  bool get shouldAnimate => enableAnimations;
  
  bool get shouldShowTransitions => enableTransitions;
  
  bool get shouldShowShadows => enableShadows;
}
