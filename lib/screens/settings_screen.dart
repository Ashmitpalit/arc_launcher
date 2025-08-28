import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';
import '../screens/icon_pack_screen.dart';
import '../screens/wallpaper_screen.dart';
import '../screens/usage_stats_screen.dart';
import '../screens/daily_limits_screen.dart';
import '../screens/app_categories_screen.dart';
import '../screens/screen_time_goals_screen.dart';
import '../screens/web_apps_screen.dart';
import '../screens/search_providers_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  
  // Settings values
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;

  bool _showAppLabels = true;
  bool _showSearchBar = true;
  bool _enableHapticFeedback = true;
  bool _enableAnimations = true;
  double _animationSpeed = 1.0;
  String _language = 'English';
  String _region = 'United States';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _darkMode = prefs.getBool('dark_mode') ?? true;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
        _crashReportingEnabled = prefs.getBool('crash_reporting_enabled') ?? true;

        _showAppLabels = prefs.getBool('show_app_labels') ?? true;
        _showSearchBar = prefs.getBool('show_search_bar') ?? true;
        _enableHapticFeedback = prefs.getBool('enable_haptic_feedback') ?? true;
        _enableAnimations = prefs.getBool('enable_animations') ?? true;
        _animationSpeed = prefs.getDouble('animation_speed') ?? 1.0;
        _language = prefs.getString('language') ?? 'English';
        _region = prefs.getString('region') ?? 'United States';
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('dark_mode', _darkMode);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('analytics_enabled', _analyticsEnabled);
      await prefs.setBool('crash_reporting_enabled', _crashReportingEnabled);

      await prefs.setBool('show_app_labels', _showAppLabels);
      await prefs.setBool('show_search_bar', _showSearchBar);
      await prefs.setBool('enable_haptic_feedback', _enableHapticFeedback);
      await prefs.setBool('enable_animations', _enableAnimations);
      await prefs.setDouble('animation_speed', _animationSpeed);
      await prefs.setString('language', _language);
      await prefs.setString('region', _region);
      
      _showSuccessSnackBar('Settings saved successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to save settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Appearance'),
                  _buildSwitchTile(
                    'Dark Mode',
                    'Use dark theme for the launcher',
                    _darkMode,
                    (value) => setState(() => _darkMode = value),
                  ),
                  _buildSwitchTile(
                    'Show App Labels',
                    'Display app names under icons',
                    _showAppLabels,
                    (value) => setState(() => _showAppLabels = value),
                  ),
                  _buildSwitchTile(
                    'Show Search Bar',
                    'Display search bar on home screen',
                    _showSearchBar,
                    (value) => setState(() => _showSearchBar = value),
                  ),
                  _buildActionTile(
                    'Icon Packs',
                    'Customize app icon appearance',
                    Icons.palette,
                    () => _navigateToIconPacks(),
                  ),
                  _buildActionTile(
                    'Wallpapers',
                    'Change your launcher background',
                    Icons.wallpaper,
                    () => _navigateToWallpapers(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Behavior'),
                  _buildSwitchTile(
                    'Enable Haptic Feedback',
                    'Provide tactile feedback for interactions',
                    _enableHapticFeedback,
                    (value) => setState(() => _enableHapticFeedback = value),
                  ),
                  _buildSwitchTile(
                    'Enable Animations',
                    'Show smooth animations and transitions',
                    _enableAnimations,
                    (value) => setState(() => _enableAnimations = value),
                  ),
                  if (_enableAnimations) ...[
                    _buildSliderTile(
                      'Animation Speed',
                      'Adjust the speed of animations',
                      _animationSpeed,
                      0.5,
                      2.0,
                      (value) => setState(() => _animationSpeed = value),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Search & Defaults'),
                  _buildActionTile(
                    'Search Providers',
                    'Choose your preferred search engine',
                    Icons.search,
                    () => _navigateToSearchProviders(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Notifications'),
                  _buildSwitchTile(
                    'Enable Notifications',
                    'Receive app updates and important alerts',
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Privacy & Analytics'),
                  _buildSwitchTile(
                    'Analytics',
                    'Help improve the app by sharing usage data',
                    _analyticsEnabled,
                    (value) => setState(() => _analyticsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Crash Reporting',
                    'Automatically report crashes for debugging',
                    _crashReportingEnabled,
                    (value) => setState(() => _crashReportingEnabled = value),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('App Time Tracker'),
                  _buildActionTile(
                    'Usage Statistics',
                    'View detailed app usage and screen time',
                    Icons.timer,
                    () => _navigateToUsageStats(),
                  ),
                  _buildActionTile(
                    'Daily Limits',
                    'Set screen time goals and limits',
                    Icons.hourglass_empty,
                    () => _navigateToDailyLimits(),
                  ),
                  _buildActionTile(
                    'App Categories',
                    'Organize apps by usage patterns',
                    Icons.category,
                    () => _navigateToAppCategories(),
                  ),
                                     _buildActionTile(
                     'Screen Time Goals',
                     'Configure wellness and productivity targets',
                     Icons.psychology,
                     () => _navigateToScreenTimeGoals(),
                   ),
                   
                   const SizedBox(height: 24),
                   
                   _buildSectionHeader('Web Apps & Shortcuts'),
                   _buildActionTile(
                     'Web Apps',
                     'Manage web app shortcuts and favorites',
                     Icons.language,
                     () => _navigateToWebApps(),
                   ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Localization'),
                  _buildDropdownTile(
                    'Language',
                    'Choose your preferred language',
                    _language,
                    ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
                    (value) => setState(() => _language = value),
                  ),
                  _buildDropdownTile(
                    'Region',
                    'Set your region for localized content',
                    _region,
                    ['United States', 'United Kingdom', 'Canada', 'Australia', 'Germany', 'France'],
                    (value) => setState(() => _region = value),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Data & Storage'),
                  _buildActionTile(
                    'Clear Cache',
                    'Remove temporary files and cached data',
                    Icons.cleaning_services,
                    () => _clearCache(),
                  ),
                  _buildActionTile(
                    'Export Settings',
                    'Save your current settings to a file',
                    Icons.download,
                    () => _exportSettings(),
                  ),
                  _buildActionTile(
                    'Import Settings',
                    'Load settings from a previously saved file',
                    Icons.upload,
                    () => _importSettings(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('About'),
                  _buildInfoTile('App Version', '1.0.0'),
                  _buildInfoTile('Build Number', '1'),
                  _buildActionTile(
                    'Privacy Policy',
                    'Read our privacy policy',
                    Icons.privacy_tip,
                    () => _showPrivacyPolicy(),
                  ),
                  _buildActionTile(
                    'Terms of Service',
                    'Read our terms of service',
                    Icons.description,
                    () => _showTermsOfService(),
                  ),
                  _buildActionTile(
                    'Open Source Licenses',
                    'View third-party licenses',
                    Icons.code,
                    () => _showOpenSourceLicenses(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, double value, double min, double max, ValueChanged<double> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: ((max - min) * 10).round(),
                    onChanged: onChanged,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey[700],
                  ),
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value, List<String> options, ValueChanged<String> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          underline: Container(),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          value,
          style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetToDefaults,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[400],
              side: BorderSide(color: Colors.grey[600]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Reset to Defaults',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Clear Cache',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to clear all cached data? This will free up storage space but may temporarily slow down the app.',
          style: TextStyle(color: Colors.grey[300]!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 2));
      _showSuccessSnackBar('Cache cleared successfully!');
    }
  }

  Future<void> _exportSettings() async {
    // Simulate settings export
    await Future.delayed(const Duration(seconds: 1));
    _showSuccessSnackBar('Settings exported successfully!');
  }

  Future<void> _importSettings() async {
    // Simulate settings import
    await Future.delayed(const Duration(seconds: 1));
    _showSuccessSnackBar('Settings imported successfully!');
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This app collects minimal data necessary for functionality and improvement. We do not sell your personal information to third parties.',
            style: TextStyle(color: Colors.grey[300]!),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            'By using this app, you agree to our terms of service. The app is provided "as is" without warranties. You are responsible for your use of the app.',
            style: TextStyle(color: Colors.grey[300]!),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOpenSourceLicenses() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Open Source Licenses',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            'This app uses several open source libraries. You can view the full license text for each library in the app\'s documentation.',
            style: TextStyle(color: Colors.grey[300]!),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToIconPacks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IconPackScreen(),
      ),
    );
  }

  void _navigateToWallpapers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WallpaperScreen(),
      ),
    );
  }

  void _navigateToUsageStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UsageStatsScreen(),
      ),
    );
  }

  void _navigateToDailyLimits() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyLimitsScreen(),
      ),
    );
  }

  void _navigateToAppCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppCategoriesScreen(),
      ),
    );
  }

  void _navigateToScreenTimeGoals() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScreenTimeGoalsScreen(),
      ),
    );
  }

  void _navigateToWebApps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WebAppsScreen(),
      ),
    );
  }

  void _navigateToSearchProviders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchProvidersScreen(),
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Reset to Defaults',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _darkMode = true;
        _notificationsEnabled = true;
        _analyticsEnabled = true;
        _crashReportingEnabled = true;

        _showAppLabels = true;
        _showSearchBar = true;
        _enableHapticFeedback = true;
        _enableAnimations = true;
        _animationSpeed = 1.0;
        _language = 'English';
        _region = 'United States';
      });
      
      _showSuccessSnackBar('Settings reset to defaults');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
