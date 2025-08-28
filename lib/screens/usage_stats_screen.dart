import 'package:flutter/material.dart';
import '../services/usage_stats_service.dart';
import '../utils/theme.dart';

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final UsageStatsService _usageStatsService = UsageStatsService();
  
  bool _isLoading = true;
  List<AppUsageData> _todayStats = [];
  int _totalUsageMinutes = 0;
  int _sessionCount = 0;
  bool _isDailyLimitReached = false;
  bool _isAdCapReached = false;
  int _remainingTimeBeforeAdCap = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsageStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsageStats() async {
    setState(() => _isLoading = true);
    
    try {
      // First check permission status
      final hasPermission = await _usageStatsService.refreshPermissionStatus();
      print('Permission status in _loadUsageStats: $hasPermission');
      
      if (!hasPermission) {
        print('No permission, showing dialog');
        _showPermissionRequestDialog();
        return;
      }
      
      await _usageStatsService.initialize();
      
      // Get today's statistics
      _todayStats = await _usageStatsService.getTodayUsageStats();
      _totalUsageMinutes = await _usageStatsService.getTodayTotalUsageMinutes();
      _sessionCount = _todayStats.length;
      
      print('Loaded stats: ${_todayStats.length} apps, total: ${_totalUsageMinutes}m');
      
      // Check limits and caps
      _isDailyLimitReached = await _usageStatsService.isDailyUsageLimitReached();
      _isAdCapReached = await _usageStatsService.isInterstitialCapReached();
      _remainingTimeBeforeAdCap = await _usageStatsService.getRemainingTimeBeforeAdCap();
      
      // Listen to real-time updates
      _usageStatsService.usageStream.listen((usageData) {
        if (mounted) {
          setState(() {
            _updateUsageData(usageData);
          });
        }
      });
      
    } catch (e) {
      print('Failed to load usage stats: $e');
      // Check if it's a permission issue
      if (e.toString().contains('permission') || e.toString().contains('not granted')) {
        _showPermissionRequestDialog();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateUsageData(AppUsageData usageData) {
    final index = _todayStats.indexWhere(
      (stat) => stat.packageName == usageData.packageName
    );
    
    if (index != -1) {
      _todayStats[index] = usageData;
    } else {
      _todayStats.add(usageData);
    }
    
    // Recalculate totals
    _totalUsageMinutes = _todayStats.fold(0, (sum, stat) => sum + stat.usageTime);
    _sessionCount = _todayStats.length;
    
    // Recheck limits
    _checkLimits();
  }

  Future<void> _checkLimits() async {
    _isDailyLimitReached = await _usageStatsService.isDailyUsageLimitReached();
    _isAdCapReached = await _usageStatsService.isInterstitialCapReached();
    _remainingTimeBeforeAdCap = await _usageStatsService.getRemainingTimeBeforeAdCap();
  }

  /// Show permission request dialog
  void _showPermissionRequestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.security, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Permission Required',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'To track app usage and provide accurate statistics, this app needs access to usage data. '
            'Please grant the "Usage Access" permission in Android settings.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestUsageStatsPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  /// Request usage stats permission
  Future<void> _requestUsageStatsPermission() async {
    try {
      final granted = await _usageStatsService.requestUsageStatsPermission();
      if (granted) {
        // Reload stats after permission is granted
        await _loadUsageStats();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission granted! Loading usage statistics...'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Some features may not work properly.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error requesting permission: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Refresh permission status manually
  Future<void> _refreshPermissionStatus() async {
    try {
      setState(() => _isLoading = true);
      
      final hasPermission = await _usageStatsService.refreshPermissionStatus();
      print('Manual permission refresh result: $hasPermission');
      
      if (hasPermission) {
        // Reload stats with new permission
        await _loadUsageStats();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission confirmed! Loading usage data...'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission still required. Please grant usage access.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing permission: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test usage tracking manually
  Future<void> _testUsageTracking() async {
    try {
      setState(() => _isLoading = true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing usage tracking...'),
          backgroundColor: Colors.purple,
        ),
      );
      
      // Force a refresh of usage data
      await _usageStatsService.refreshPermissionStatus();
      await _loadUsageStats();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test complete! Found ${_todayStats.length} apps with usage data'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Debug usage data for troubleshooting
  Future<void> _debugUsageData() async {
    try {
      setState(() => _isLoading = true);
      
      // Check permission status
      final hasPermission = await _usageStatsService.refreshPermissionStatus();
      
      // Try to get real data
      final realData = await _usageStatsService.getTodayUsageStats();
      
      // Show debug info
      final debugInfo = '''
Debug Information:
- Permission granted: $hasPermission
- Real data count: ${realData.length}
- Total usage minutes: ${realData.fold(0, (sum, stat) => sum + stat.usageTime)}
- Data details: ${realData.map((d) => '${d.appName}: ${d.usageTime}m').join(', ')}
- Current time: ${DateTime.now()}
- App state: ${mounted ? 'Mounted' : 'Not mounted'}
      ''';
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Debug Info', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Text(debugInfo, style: const TextStyle(color: Colors.white70)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _refreshPermissionStatus();
              },
              child: const Text('Refresh Permission'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'App Time Tracker',
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsageStats,
            tooltip: 'Refresh Usage Data',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.white),
            onPressed: _debugUsageData,
            tooltip: 'Debug Usage Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Apps'),
            Tab(text: 'Limits'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAppsTab(),
                _buildLimitsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUsageSummaryCard(),
          const SizedBox(height: 24),
          _buildPermissionStatusCard(),
          const SizedBox(height: 24),
          _buildDailyProgressCard(),
          const SizedBox(height: 24),
          _buildAdCapStatusCard(),
          const SizedBox(height: 24),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildUsageSummaryCard() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Today\'s Usage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Time',
                  '${_totalUsageMinutes}m',
                  Icons.access_time,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Apps Used',
                  _sessionCount.toString(),
                  Icons.apps,
                  Colors.green,
                ),
                _buildStatItem(
                  'Sessions',
                  _sessionCount.toString(),
                  Icons.play_circle,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgressCard() {
    final progress = _totalUsageMinutes / 240; // 4 hours = 240 minutes
    final remainingMinutes = 240 - _totalUsageMinutes;
    
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_empty, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Daily Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[700],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isDailyLimitReached ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_totalUsageMinutes}m / 240m',
                  style: TextStyle(color: Colors.grey[300]),
                ),
                Text(
                  remainingMinutes > 0 ? '${remainingMinutes}m left' : 'Limit reached!',
                  style: TextStyle(
                    color: _isDailyLimitReached ? Colors.red : Colors.grey[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCapStatusCard() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isAdCapReached ? Icons.block : Icons.ads_click,
                  color: _isAdCapReached ? Colors.red : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ad Cap Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAdCapReached ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isAdCapReached ? Colors.red : Colors.green,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAdCapReached ? Icons.block : Icons.check_circle,
                    color: _isAdCapReached ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isAdCapReached
                          ? 'Ad cap reached! No more ads today.'
                          : 'Ads will show after ${_remainingTimeBeforeAdCap}m of usage',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatusCard() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Permission Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Access',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _totalUsageMinutes > 0 ? Icons.check_circle : Icons.error,
                            color: _totalUsageMinutes > 0 ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _totalUsageMinutes > 0 ? 'Granted' : 'Required',
                            style: TextStyle(
                              color: _totalUsageMinutes > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last checked: ${DateTime.now().toString().substring(11, 19)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _refreshPermissionStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Refresh'),
                    ),
                                          const SizedBox(height: 8),
                      if (_totalUsageMinutes == 0)
                        ElevatedButton(
                          onPressed: _requestUsageStatsPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Grant Permission'),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _testUsageTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Test Tracking'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _resetDailyUsage(),
                    icon: Icon(Icons.refresh),
                    label: Text('Reset Today'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportUsageData(),
                    icon: Icon(Icons.download),
                    label: Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todayStats.length,
      itemBuilder: (context, index) {
        final stat = _todayStats[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(Icons.apps, color: Colors.blue),
            ),
            title: Text(
              stat.appName,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${stat.usageTime}m • ${stat.launchCount} launches',
              style: TextStyle(color: Colors.grey[300]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stat.usageTime}m',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_getUsagePercentage(stat.usageTime)}%',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLimitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLimitSettingCard(
            'Daily Usage Limit',
            'Set maximum screen time per day',
            '${_totalUsageMinutes}m / 240m',
            Icons.hourglass_empty,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildLimitSettingCard(
            'Ad Cap Threshold',
            'Show ads after this much usage',
            '${_remainingTimeBeforeAdCap}m remaining',
            Icons.ads_click,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildLimitSettingCard(
            'Wellness Reminders',
            'Get notified about usage patterns',
            'Enabled',
            Icons.psychology,
            Colors.purple,
          ),
        ],
      ),
    );
  }



  Widget _buildLimitSettingCard(
    String title,
    String description,
    String status,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey[300], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement limit settings
                  },
                  activeColor: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[300], fontSize: 12),
        ),
      ],
    );
  }

  double _getUsagePercentage(int usageTime) {
    if (_totalUsageMinutes == 0) return 0;
    return (usageTime / _totalUsageMinutes * 100).roundToDouble();
  }

  void _resetDailyUsage() {
    // TODO: Implement daily usage reset
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Daily usage reset feature coming soon!')),
    );
  }

  void _exportUsageData() {
    // TODO: Implement usage data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export feature coming soon!')),
    );
  }
}
