import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/app_shortcut.dart';
import '../services/usage_stats_service.dart';
import '../screens/usage_stats_screen.dart';

class AppTracerWidget extends StatefulWidget {
  final bool isHomeScreen;
  final VoidCallback? onTap;

  const AppTracerWidget({
    super.key,
    this.isHomeScreen = false,
    this.onTap,
  });

  @override
  State<AppTracerWidget> createState() => _AppTracerWidgetState();
}

class _AppTracerWidgetState extends State<AppTracerWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  
  List<AppUsageData> _topApps = [];
  double _totalUsage = 0;
  bool _isLoading = true;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUsageData();
    _startPeriodicUpdates();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadUsageData() async {
    try {
      final usageService = UsageStatsService();
      await usageService.initialize();
      
      // Get top apps usage
      final apps = await usageService.getMostUsedApps(limit: 5);
      final total = await usageService.getTodayTotalUsageMinutes();
      
      if (mounted) {
        setState(() {
          _topApps = apps;
          _totalUsage = total.toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading usage data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startPeriodicUpdates() {
    // Update time every minute
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        _updateTime();
        _startPeriodicUpdates();
      }
    });
    
    // Update usage data every 5 minutes
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        _loadUsageData();
        _startPeriodicUpdates();
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UsageStatsScreen(),
          ),
        );
      },
      child: Container(
        width: widget.isHomeScreen ? double.infinity : 160,
        height: widget.isHomeScreen ? 80 : 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[600]!,
              Colors.purple[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _isLoading ? _buildLoadingState() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(6), // Further reduced padding from 8 to 6
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          // Header with time and battery
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App Tracer Title
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.1 * _pulseController.value),
                        child: Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 13, // Slightly reduced from 14 to 13
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 3), // Further reduced from 4 to 3
                  const Text(
                    'App Tracer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Further reduced from 11 to 10
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Time
              Text(
                _currentTime.isEmpty ? _getCurrentTime() : _currentTime,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8, // Further reduced from 9 to 8
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4), // Further reduced from 6 to 4
          
          // Usage Statistics - Reduced height to fit better
          SizedBox(
            height: 28, // Reduced from 32 to 28 to save 4px
            child: _topApps.isEmpty 
                ? _buildNoDataState()
                : _buildUsageStats(),
          ),
          
          const SizedBox(height: 2), // Further reduced from 4 to 2
          
          // Footer with total usage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total usage
              Text(
                _formatDuration(_totalUsage),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9, // Further reduced from 10 to 9
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              // Tap indicator
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.7 + (0.3 * _fadeController.value),
                    child: const Icon(
                      Icons.touch_app,
                      color: Colors.white70,
                      size: 11, // Further reduced from 12 to 11
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to prevent overflow
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Colors.white.withOpacity(0.7),
            size: 14, // Further reduced from 16 to 14
          ),
          const SizedBox(height: 1), // Further reduced from 2 to 1
          Text(
            'No usage data',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 8, // Further reduced from 9 to 8
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Added to prevent overflow
      children: [
        // Top app usage bar - limited to 2 apps to fit in 28px height
        if (_topApps.isNotEmpty) ...[
          _buildAppUsageBar(_topApps[0], 0),
          if (_topApps.length > 1) ...[
            const SizedBox(height: 1), // Reduced from 2 to 1
            _buildAppUsageBar(_topApps[1], 1),
          ],
        ],
        
        const SizedBox(height: 2), // Reduced from 4 to 2
        
        // Quick stats
        Row(
          children: [
            Expanded(
              child: _buildQuickStat(
                'Apps',
                _topApps.length.toString(),
                Icons.apps,
              ),
            ),
            Expanded(
              child: _buildQuickStat(
                'Today',
                _formatDuration(_totalUsage),
                Icons.today,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppUsageBar(AppUsageData app, int index) {
    final maxUsage = _topApps.isNotEmpty ? _topApps[0].usageTime : 1;
    final usagePercentage = maxUsage > 0 ? app.usageTime / maxUsage : 0.0;
    
    return Row(
      children: [
        // App icon or placeholder
        Container(
          width: 8, // Further reduced from 10 to 8
          height: 8, // Further reduced from 10 to 8
          decoration: BoxDecoration(
            color: _getAppColor(index),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Icon(
            Icons.apps,
            color: Colors.white,
            size: 5, // Further reduced from 6 to 5
          ),
        ),
        
        const SizedBox(width: 3), // Further reduced from 4 to 3
        
        // Usage bar
        Expanded(
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return Container(
                height: 2, // Further reduced from 3 to 2
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: usagePercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getAppColor(index),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(width: 3), // Further reduced from 4 to 3
        
        // Usage time
        Text(
          _formatDuration(app.usageTime.toDouble()),
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 7, // Further reduced from 8 to 7
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Added to prevent overflow
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 10, // Further reduced from 12 to 10
        ),
        const SizedBox(height: 0), // Removed spacing completely
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8, // Further reduced from 9 to 8
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 6, // Further reduced from 7 to 6
          ),
        ),
      ],
    );
  }

  Color _getAppColor(int index) {
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()}m';
    } else {
      final hours = (minutes / 60).floor();
      final mins = (minutes % 60).toInt();
      return '${hours}h ${mins}m';
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
