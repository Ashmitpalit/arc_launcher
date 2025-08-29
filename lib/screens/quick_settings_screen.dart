import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_tracer_widget.dart';

/// Screen that displays quick settings and notifications
/// Opened with right swipe gesture from home screen
class QuickSettingsScreen extends StatefulWidget {
  const QuickSettingsScreen({super.key});

  @override
  State<QuickSettingsScreen> createState() => _QuickSettingsScreenState();
}

class _QuickSettingsScreenState extends State<QuickSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // Quick settings state
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = false;
  bool _mobileDataEnabled = true;
  bool _airplaneModeEnabled = false;
  bool _doNotDisturbEnabled = false;
  double _brightness = 0.7;
  double _volume = 0.8;
  
  // Mock notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'app': 'WhatsApp',
      'title': 'New message from John',
      'message': 'Hey, how are you doing?',
      'time': '2 min ago',
      'icon': Icons.message,
      'color': Colors.green,
    },
    {
      'app': 'Gmail',
      'title': 'New email received',
      'message': 'Meeting reminder for tomorrow',
      'time': '15 min ago',
      'icon': Icons.email,
      'color': Colors.red,
    },
    {
      'app': 'Calendar',
      'title': 'Upcoming event',
      'message': 'Team meeting in 30 minutes',
      'time': '25 min ago',
      'icon': Icons.event,
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Setup slide animation (slide in from right)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Setup fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Start entrance animation
    _startEntranceAnimation();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _startEntranceAnimation() {
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  void _closeQuickSettings() {
    // Reverse animations
    _slideAnimationController.reverse();
    _fadeAnimationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _toggleSetting(String setting) {
    setState(() {
      switch (setting) {
        case 'wifi':
          _wifiEnabled = !_wifiEnabled;
          break;
        case 'bluetooth':
          _bluetoothEnabled = !_bluetoothEnabled;
          break;
        case 'mobileData':
          _mobileDataEnabled = !_mobileDataEnabled;
          break;
        case 'airplaneMode':
          _airplaneModeEnabled = !_airplaneModeEnabled;
          break;
        case 'doNotDisturb':
          _doNotDisturbEnabled = !_doNotDisturbEnabled;
          break;
      }
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeQuickSettings();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // Header with close button
                  _buildHeader(),
                  
                  // Quick settings grid
                  _buildQuickSettingsGrid(),
                  
                  // Brightness and volume sliders
                  _buildSliders(),
                  
                  // Notifications section
                  Expanded(
                    child: _buildNotificationsSection(),
                  ),
                  
                  // Bottom widget area (App Tracer)
                  _buildBottomWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Title
          const Text(
            'Quick Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // Close button
          GestureDetector(
            onTap: _closeQuickSettings,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettingsGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildSettingTile(
            icon: Icons.wifi,
            label: 'WiFi',
            isEnabled: _wifiEnabled,
            onTap: () => _toggleSetting('wifi'),
            color: Colors.blue,
          ),
          _buildSettingTile(
            icon: Icons.bluetooth,
            label: 'Bluetooth',
            isEnabled: _bluetoothEnabled,
            onTap: () => _toggleSetting('bluetooth'),
            color: Colors.blue,
          ),
          _buildSettingTile(
            icon: Icons.mobile_friendly,
            label: 'Mobile',
            isEnabled: _mobileDataEnabled,
            onTap: () => _toggleSetting('mobileData'),
            color: Colors.green,
          ),
          _buildSettingTile(
            icon: Icons.airplanemode_active,
            label: 'Airplane',
            isEnabled: _airplaneModeEnabled,
            onTap: () => _toggleSetting('airplaneMode'),
            color: Colors.orange,
          ),
          _buildSettingTile(
            icon: Icons.do_not_disturb,
            label: 'DND',
            isEnabled: _doNotDisturbEnabled,
            onTap: () => _toggleSetting('doNotDisturb'),
            color: Colors.red,
          ),
          _buildSettingTile(
            icon: Icons.flash_on,
            label: 'Flashlight',
            isEnabled: false,
            onTap: () {},
            color: Colors.yellow,
          ),
          _buildSettingTile(
            icon: Icons.rotate_right,
            label: 'Auto Rotate',
            isEnabled: true,
            onTap: () {},
            color: Colors.purple,
          ),
          _buildSettingTile(
            icon: Icons.location_on,
            label: 'Location',
            isEnabled: true,
            onTap: () {},
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled 
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled 
                ? color.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled ? color : Colors.white.withOpacity(0.5),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? color : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliders() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Brightness slider
          Row(
            children: [
              Icon(
                Icons.brightness_6,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.orange,
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    thumbColor: Colors.orange,
                    overlayColor: Colors.orange.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _brightness,
                    onChanged: (value) {
                      setState(() {
                        _brightness = value;
                      });
                    },
                  ),
                ),
              ),
              Text(
                '${(_brightness * 100).round()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Volume slider
          Row(
            children: [
              Icon(
                Icons.volume_up,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                    thumbColor: Colors.blue,
                    overlayColor: Colors.blue.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                    },
                  ),
                ),
              ),
              Text(
                '${(_volume * 100).round()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_notifications.length}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Notifications list
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // App icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notification['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification['time'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // Action button
          IconButton(
            onPressed: () {
              // TODO: Handle notification action
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const AppTracerWidget(),
    );
  }
}
