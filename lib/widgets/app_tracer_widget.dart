import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_shortcut.dart';
import '../services/analytics_service.dart';
import '../services/usage_stats_service.dart';
import '../utils/theme.dart';

class AppTracerWidget extends StatefulWidget {
  const AppTracerWidget({super.key});

  @override
  State<AppTracerWidget> createState() => _AppTracerWidgetState();
}

class _AppTracerWidgetState extends State<AppTracerWidget> {
  List<AppUsageData> _recentApps = [];
  bool _isLoading = true;
  int _totalUsageTime = 0;
  int _sessionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWidgetData();
  }

  Future<void> _loadWidgetData() async {
    try {
      setState(() => _isLoading = true);
      
      await _loadRecentApps();
      await _loadUsageStats();
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Failed to load widget data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecentApps() async {
    try {
      // Get real usage statistics from the service
      final usageStatsService = UsageStatsService();
      await usageStatsService.initialize();
      
      // Get today's most used apps
      _recentApps = await usageStatsService.getMostUsedApps(limit: 4);
      
      // If no real data yet, show placeholder
      if (_recentApps.isEmpty) {
        _recentApps = [
          AppUsageData(
            packageName: 'com.whatsapp.android',
            appName: 'WhatsApp',
            icon: 'https://via.placeholder.com/48x48/25D366/ffffff?text=WA',
            usageTime: 0,
            launchCount: 0,
            lastUsed: DateTime.now(),
          ),
          AppUsageData(
            packageName: 'com.instagram.android',
            appName: 'Instagram',
            icon: 'https://via.placeholder.com/48x48/E4405F/ffffff?text=IG',
            usageTime: 0,
            launchCount: 0,
            lastUsed: DateTime.now(),
          ),
          AppUsageData(
            packageName: 'com.google.android.youtube',
            appName: 'YouTube',
            icon: 'https://via.placeholder.com/48x48/FF0000/ffffff?text=YT',
            usageTime: 0,
            launchCount: 0,
            lastUsed: DateTime.now(),
          ),
          AppUsageData(
            packageName: 'com.spotify.music',
            appName: 'Spotify',
            icon: 'https://via.placeholder.com/48x48/1DB954/ffffff?text=SP',
            usageTime: 0,
            launchCount: 0,
            lastUsed: DateTime.now(),
          ),
        ];
      }
    } catch (e) {
      print('Failed to load recent apps: $e');
    }
  }

  Future<void> _loadUsageStats() async {
    try {
      // Get real usage statistics from the service
      final usageStatsService = UsageStatsService();
      await usageStatsService.initialize();
      
      // Get today's total usage time
      _totalUsageTime = await usageStatsService.getTodayTotalUsageMinutes();
      
      // Get session count from today's stats
      final todayStats = await usageStatsService.getTodayUsageStats();
      _sessionCount = todayStats.length;
      
      // Listen to real-time updates
      usageStatsService.usageStream.listen((usageData) {
        if (mounted) {
          setState(() {
            _updateUsageData(usageData);
          });
        }
      });
      
    } catch (e) {
      print('Failed to load usage stats: $e');
      // Fallback to shared preferences
      final prefs = await SharedPreferences.getInstance();
      _totalUsageTime = prefs.getInt('total_usage_time') ?? 0;
      _sessionCount = prefs.getInt('session_count') ?? 0;
    }
  }
  
  void _updateUsageData(AppUsageData usageData) {
    // Update the app in the recent apps list
    final index = _recentApps.indexWhere(
      (app) => app.packageName == usageData.packageName
    );
    
    if (index != -1) {
      _recentApps[index] = usageData;
    } else {
      _recentApps.add(usageData);
      // Keep only top 4 apps
      if (_recentApps.length > 4) {
        _recentApps.sort((a, b) => b.usageTime.compareTo(a.usageTime));
        _recentApps = _recentApps.take(4).toList();
      }
    }
    
    // Update total usage time
    _totalUsageTime = _recentApps.fold(0, (sum, app) => sum + app.usageTime);
    _sessionCount = _recentApps.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120, // 4×2 widget height
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: _isLoading
          ? _buildLoadingState()
          : _buildWidgetContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildWidgetContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'App Tracer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blue, size: 18),
                onPressed: _loadWidgetData,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Usage summary
          Row(
            children: [
              _buildUsageStat('Today', '${_totalUsageTime}m', Icons.timer),
              const SizedBox(width: 8),
              _buildUsageStat('Sessions', _sessionCount.toString(), Icons.play_circle),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Ad cap status
          _buildAdCapStatus(),
          
          const SizedBox(height: 12),
          
          // Recent apps
          Expanded(
            child: Row(
              children: _recentApps.take(4).map((app) {
                return Expanded(
                  child: _buildAppItem(app),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 16,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppItem(AppUsageData app) {
    return GestureDetector(
      onTap: () => _launchApp(app),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[800],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: app.icon != null
                    ? Image.network(
                        app.icon!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.android,
                            color: Colors.grey[600],
                            size: 20,
                          );
                        },
                      )
                    : Icon(
                        Icons.android,
                        color: Colors.grey[600],
                        size: 20,
                      ),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // App name
            Text(
              app.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 2),
            
            // Usage time
            Text(
              '${app.usageTime}m',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchApp(AppUsageData app) {
    // In a real app, this would launch the app
    // For now, we'll just track the interaction
    AnalyticsService().logEvent('widget_app_launched', {
      'package_name': app.packageName,
      'app_name': app.appName,
    });
    
    // Show a snackbar or notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Launching ${app.appName}...'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }
}




// Widget configuration screen
class AppTracerWidgetConfig extends StatefulWidget {
  const AppTracerWidgetConfig({super.key});

  @override
  State<AppTracerWidgetConfig> createState() => _AppTracerWidgetConfigState();
}

class _AppTracerWidgetConfigState extends State<AppTracerWidgetConfig> {
  bool _showUsageTime = true;
  bool _showLaunchCount = true;
  bool _showLastUsed = false;
  int _refreshInterval = 30; // minutes
  bool _enableNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _showUsageTime = prefs.getBool('widget_show_usage_time') ?? true;
        _showLaunchCount = prefs.getBool('widget_show_launch_count') ?? true;
        _showLastUsed = prefs.getBool('widget_show_last_used') ?? false;
        _refreshInterval = prefs.getInt('widget_refresh_interval') ?? 30;
        _enableNotifications = prefs.getBool('widget_enable_notifications') ?? true;
      });
    } catch (e) {
      print('Failed to load widget config: $e');
    }
  }

  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('widget_show_usage_time', _showUsageTime);
      await prefs.setBool('widget_show_launch_count', _showLaunchCount);
      await prefs.setBool('widget_show_last_used', _showLastUsed);
      await prefs.setInt('widget_refresh_interval', _refreshInterval);
      await prefs.setBool('widget_enable_notifications', _enableNotifications);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widget configuration saved!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save configuration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Widget Configuration',
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
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Display Options'),
            _buildSwitchTile(
              'Show Usage Time',
              'Display app usage time in the widget',
              _showUsageTime,
              (value) => setState(() => _showUsageTime = value),
            ),
            _buildSwitchTile(
              'Show Launch Count',
              'Display app launch count in the widget',
              _showLaunchCount,
              (value) => setState(() => _showLaunchCount = value),
            ),
            _buildSwitchTile(
              'Show Last Used',
              'Display last used time in the widget',
              _showLastUsed,
              (value) => setState(() => _showLastUsed = value),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Behavior'),
            _buildSliderTile(
              'Refresh Interval (minutes)',
              'How often to update widget data',
              _refreshInterval.toDouble(),
              5,
              120,
              (value) => setState(() => _refreshInterval = value.round()),
            ),
            _buildSwitchTile(
              'Enable Notifications',
              'Show notifications for app usage insights',
              _enableNotifications,
              (value) => setState(() => _enableNotifications = value),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader('Preview'),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Center(
                child: AppTracerWidget(),
              ),
            ),
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
                    divisions: (max - min).round(),
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
                    value.round().toString(),
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
  
  Widget _buildAdCapStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ads_click,
            color: Colors.orange,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Ad Cap: 30m',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
