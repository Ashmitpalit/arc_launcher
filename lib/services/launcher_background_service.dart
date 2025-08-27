import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LauncherBackgroundService {
  static const String _wallpaperKey = 'launcher_wallpaper_path';
  static const String _wallpaperNameKey = 'launcher_wallpaper_name';
  
  static LauncherBackgroundService? _instance;
  static LauncherBackgroundService get instance => _instance ??= LauncherBackgroundService._();
  
  LauncherBackgroundService._();
  
  String? _currentWallpaperPath;
  String? _currentWallpaperName;
  
  // Callback for UI updates
  VoidCallback? _onWallpaperChanged;
  
  // Getter for current wallpaper info
  String? get currentWallpaperPath => _currentWallpaperPath;
  String? get currentWallpaperName => _currentWallpaperName;
  
  // Set callback for wallpaper changes
  void setWallpaperChangedCallback(VoidCallback callback) {
    _onWallpaperChanged = callback;
  }
  
  // Initialize the service
  Future<void> initialize() async {
    await _loadCurrentWallpaper();
  }
  
  // Load the current wallpaper from preferences
  Future<void> _loadCurrentWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentWallpaperPath = prefs.getString(_wallpaperKey);
      _currentWallpaperName = prefs.getString(_wallpaperNameKey);
    } catch (e) {
      print('Failed to load wallpaper preferences: $e');
    }
  }
  
  // Apply a wallpaper to the launcher
  Future<bool> applyWallpaper(String imagePath, String wallpaperName) async {
    try {
      // Save the wallpaper preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wallpaperKey, imagePath);
      await prefs.setString(_wallpaperNameKey, wallpaperName);
      
      // Update the current wallpaper
      _currentWallpaperPath = imagePath;
      _currentWallpaperName = wallpaperName;
      
      // Notify UI to refresh
      _onWallpaperChanged?.call();
      
      print('Wallpaper applied successfully: $wallpaperName at $imagePath');
      return true;
    } catch (e) {
      print('Failed to apply wallpaper: $e');
      return false;
    }
  }
  
  // Get the current wallpaper as a decoration
  BoxDecoration? getCurrentWallpaperDecoration() {
    if (_currentWallpaperPath == null) return null;
    
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(_currentWallpaperPath!),
        fit: BoxFit.cover,
      ),
    );
  }
  
  // Check if a wallpaper is currently applied
  bool get hasWallpaperApplied => _currentWallpaperPath != null;
  
  // Reset to default background
  Future<bool> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_wallpaperKey);
      await prefs.remove(_wallpaperNameKey);
      
      _currentWallpaperPath = null;
      _currentWallpaperName = null;
      
      // Notify UI to refresh
      _onWallpaperChanged?.call();
      
      print('Reset to default background');
      return true;
    } catch (e) {
      print('Failed to reset background: $e');
      return false;
    }
  }
  
  // Get wallpaper info for display
  Map<String, dynamic> getWallpaperInfo() {
    return {
      'path': _currentWallpaperPath,
      'name': _currentWallpaperName,
      'isApplied': hasWallpaperApplied,
    };
  }
}
