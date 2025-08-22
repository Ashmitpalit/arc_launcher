import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LauncherProvider extends ChangeNotifier {
  int _currentPage = 0;
  bool _isAppDrawerOpen = false;
  bool _isNotificationPanelOpen = false;
  bool _isQuickSettingsOpen = false;
  List<String> _installedApps = [];
  bool _isDefaultLauncher = false;

  // Getters
  int get currentPage => _currentPage;
  bool get isAppDrawerOpen => _isAppDrawerOpen;
  bool get isNotificationPanelOpen => _isNotificationPanelOpen;
  bool get isQuickSettingsOpen => _isQuickSettingsOpen;
  List<String> get installedApps => _installedApps;
  bool get isDefaultLauncher => _isDefaultLauncher;

  // Methods
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

  void setInstalledApps(List<String> apps) {
    _installedApps = apps;
    notifyListeners();
  }

  void setDefaultLauncherStatus(bool status) {
    _isDefaultLauncher = status;
    _saveDefaultLauncherStatus(status);
    notifyListeners();
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

  // Load mock apps for demonstration
  void loadMockApps() {
    _installedApps = [
      'Settings',
      'Phone',
      'Messages',
      'Camera',
      'Gallery',
      'Chrome',
      'Gmail',
      'Maps',
      'Play Store',
      'YouTube',
      'Spotify',
      'WhatsApp',
      'Instagram',
      'Facebook',
      'Twitter',
      'Calculator',
      'Calendar',
      'Clock',
      'Files',
      'Weather',
      'Notes',
      'Music',
      'Photos',
      'Drive',
    ];
    notifyListeners();
  }
}
