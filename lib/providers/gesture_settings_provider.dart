import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing gesture-specific settings
class GestureSettingsProvider extends ChangeNotifier {
  // Gesture settings keys
  static const String _enableGesturesKey = 'enable_gestures';
  static const String _gestureSensitivityKey = 'gesture_sensitivity';
  static const String _enableSwipeGesturesKey = 'enable_swipe_gestures';
  static const String _enableTapGesturesKey = 'enable_tap_gestures';
  static const String _enableLongPressGesturesKey = 'enable_long_press_gestures';
  static const String _enablePinchGesturesKey = 'enable_pinch_gestures';
  static const String _showGestureFeedbackKey = 'show_gesture_feedback';
  static const String _enableGestureHapticsKey = 'enable_gesture_haptics';
  
  // Default values
  static const bool _defaultEnableGestures = true;
  static const double _defaultGestureSensitivity = 1.0;
  static const bool _defaultEnableSwipeGestures = true;
  static const bool _defaultEnableTapGestures = true;
  static const bool _defaultEnableLongPressGestures = true;
  static const bool _defaultEnablePinchGestures = true;
  static const bool _defaultShowGestureFeedback = true;
  static const bool _defaultEnableGestureHaptics = true;
  
  // Current values
  bool _enableGestures = _defaultEnableGestures;
  double _gestureSensitivity = _defaultGestureSensitivity;
  bool _enableSwipeGestures = _defaultEnableSwipeGestures;
  bool _enableTapGestures = _defaultEnableTapGestures;
  bool _enableLongPressGestures = _defaultEnableLongPressGestures;
  bool _enablePinchGestures = _defaultEnablePinchGestures;
  bool _showGestureFeedback = _defaultShowGestureFeedback;
  bool _enableGestureHaptics = _defaultEnableGestureHaptics;
  
  // Getters
  bool get enableGestures => _enableGestures;
  double get gestureSensitivity => _gestureSensitivity;
  bool get enableSwipeGestures => _enableSwipeGestures;
  bool get enableTapGestures => _enableTapGestures;
  bool get enableLongPressGestures => _enableLongPressGestures;
  bool get enablePinchGestures => _enablePinchGestures;
  bool get showGestureFeedback => _showGestureFeedback;
  bool get enableGestureHaptics => _enableGestureHaptics;
  
  // Initialize and load settings
  Future<void> initialize() async {
    await _loadSettings();
  }
  
  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _enableGestures = prefs.getBool(_enableGesturesKey) ?? _defaultEnableGestures;
      _gestureSensitivity = prefs.getDouble(_gestureSensitivityKey) ?? _defaultGestureSensitivity;
      _enableSwipeGestures = prefs.getBool(_enableSwipeGesturesKey) ?? _defaultEnableSwipeGestures;
      _enableTapGestures = prefs.getBool(_enableTapGesturesKey) ?? _defaultEnableTapGestures;
      _enableLongPressGestures = prefs.getBool(_enableLongPressGesturesKey) ?? _defaultEnableLongPressGestures;
      _enablePinchGestures = prefs.getBool(_enablePinchGesturesKey) ?? _defaultEnablePinchGestures;
      _showGestureFeedback = prefs.getBool(_showGestureFeedbackKey) ?? _defaultShowGestureFeedback;
      _enableGestureHaptics = prefs.getBool(_enableGestureHapticsKey) ?? _defaultEnableGestureHaptics;
      
      notifyListeners();
    } catch (e) {
      print('Failed to load gesture settings: $e');
    }
  }
  
  // Update enable gestures
  Future<void> updateEnableGestures(bool value) async {
    _enableGestures = value;
    await _saveSetting(_enableGesturesKey, value);
    notifyListeners();
  }
  
  // Update gesture sensitivity
  Future<void> updateGestureSensitivity(double value) async {
    _gestureSensitivity = value.clamp(0.5, 2.0);
    await _saveSetting(_gestureSensitivityKey, value);
    notifyListeners();
  }
  
  // Update enable swipe gestures
  Future<void> updateEnableSwipeGestures(bool value) async {
    _enableSwipeGestures = value;
    await _saveSetting(_enableSwipeGesturesKey, value);
    notifyListeners();
  }
  
  // Update enable tap gestures
  Future<void> updateEnableTapGestures(bool value) async {
    _enableTapGestures = value;
    await _saveSetting(_enableTapGesturesKey, value);
    notifyListeners();
  }
  
  // Update enable long press gestures
  Future<void> updateEnableLongPressGestures(bool value) async {
    _enableLongPressGestures = value;
    await _saveSetting(_enableLongPressGesturesKey, value);
    notifyListeners();
  }
  
  // Update enable pinch gestures
  Future<void> updateEnablePinchGestures(bool value) async {
    _enablePinchGestures = value;
    await _saveSetting(_enablePinchGesturesKey, value);
    notifyListeners();
  }
  
  // Update show gesture feedback
  Future<void> updateShowGestureFeedback(bool value) async {
    _showGestureFeedback = value;
    await _saveSetting(_showGestureFeedbackKey, value);
    notifyListeners();
  }
  
  // Update enable gesture haptics
  Future<void> updateEnableGestureHaptics(bool value) async {
    _enableGestureHaptics = value;
    await _saveSetting(_enableGestureHapticsKey, value);
    notifyListeners();
  }
  
  // Save a setting to SharedPreferences
  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      print('Failed to save gesture setting $key: $e');
    }
  }
  
  // Reset all gesture settings to defaults
  Future<void> resetToDefaults() async {
    _enableGestures = _defaultEnableGestures;
    _gestureSensitivity = _defaultGestureSensitivity;
    _enableSwipeGestures = _defaultEnableSwipeGestures;
    _enableTapGestures = _defaultEnableTapGestures;
    _enableLongPressGestures = _defaultEnableLongPressGestures;
    _enablePinchGestures = _defaultEnablePinchGestures;
    _showGestureFeedback = _defaultShowGestureFeedback;
    _enableGestureHaptics = _defaultEnableGestureHaptics;
    
    // Save all defaults
    await _saveSetting(_enableGesturesKey, _enableGestures);
    await _saveSetting(_gestureSensitivityKey, _gestureSensitivity);
    await _saveSetting(_enableSwipeGesturesKey, _enableSwipeGestures);
    await _saveSetting(_enableTapGesturesKey, _enableTapGestures);
    await _saveSetting(_enableLongPressGesturesKey, _enableLongPressGestures);
    await _saveSetting(_enablePinchGesturesKey, _enablePinchGestures);
    await _saveSetting(_showGestureFeedbackKey, _showGestureFeedback);
    await _saveSetting(_enableGestureHapticsKey, _enableGestureHaptics);
    
    notifyListeners();
  }
  
  // Get all gesture settings as a map
  Map<String, dynamic> getAllGestureSettings() {
    return {
      'enableGestures': _enableGestures,
      'gestureSensitivity': _gestureSensitivity,
      'enableSwipeGestures': _enableSwipeGestures,
      'enableTapGestures': _enableTapGestures,
      'enableLongPressGestures': _enableLongPressGestures,
      'enablePinchGestures': _enablePinchGestures,
      'showGestureFeedback': _showGestureFeedback,
      'enableGestureHaptics': _enableGestureHaptics,
    };
  }
}
