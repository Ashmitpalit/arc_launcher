import 'package:flutter/material.dart';
import '../utils/theme.dart';

class QuickSettingsPanel extends StatefulWidget {
  final VoidCallback onClose;

  const QuickSettingsPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<QuickSettingsPanel> createState() => _QuickSettingsPanelState();
}

class _QuickSettingsPanelState extends State<QuickSettingsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Quick settings state
  bool _isWifiEnabled = true;
  bool _isBluetoothEnabled = false;
  bool _isAirplaneModeEnabled = false;
  bool _isMobileDataEnabled = true;
  bool _isLocationEnabled = true;
  bool _isFlashlightEnabled = false;
  bool _isAutoRotateEnabled = true;
  bool _isBatterySaverEnabled = false;
  double _brightness = 0.7;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closePanel() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Backdrop
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closePanel,
                  child: Container(
                    color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                  ),
                ),
              ),

              // Quick Settings Panel Content
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value * 0.5),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle Bar
                        Container(
                          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Quick Settings',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: _closePanel,
                                icon: const Icon(
                                  Icons.close,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quick Settings Grid
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                  children: [
                                    _buildQuickSettingTile(
                                      'WiFi',
                                      Icons.wifi,
                                      _isWifiEnabled,
                                      Colors.blue,
                                      (value) => setState(() => _isWifiEnabled = value),
                                    ),
                                    _buildQuickSettingTile(
                                      'Bluetooth',
                                      Icons.bluetooth,
                                      _isBluetoothEnabled,
                                      Colors.blue,
                                      (value) => setState(() => _isBluetoothEnabled = value),
                                    ),
                                    _buildQuickSettingTile(
                                      'Airplane',
                                      Icons.airplanemode_active,
                                      _isAirplaneModeEnabled,
                                      Colors.orange,
                                      (value) => setState(() => _isAirplaneModeEnabled = value),
                                    ),
                                    _buildQuickSettingTile(
                                      'Data',
                                      Icons.signal_cellular_alt,
                                      _isMobileDataEnabled,
                                      Colors.green,
                                      (value) => setState(() => _isMobileDataEnabled = value),
                                    ),
                                    _buildQuickSettingTile(
                                      'Location',
                                      Icons.location_on,
                                      _isLocationEnabled,
                                      Colors.red,
                                      (value) => setState(() => _isLocationEnabled = value),
                                    ),
                                    _buildQuickSettingTile(
                                      'Flashlight',
                                      Icons.flashlight_on,
                                      _isFlashlightEnabled,
                                      Colors.yellow,
                                      (value) => setState(() => _isFlashlightEnabled = value),
                                    ),
                                    _buildQuickSettingTile(
                                      'Rotate',
                                      Icons.screen_rotation,
                                      _isAutoRotateEnabled,
                                      Colors.purple,
                                      (value) => setState(() => _isAutoRotateEnabled = value),
                                    ),
                                    _buildQuickSettingTile(
                                      'Battery',
                                      Icons.battery_saver,
                                      _isBatterySaverEnabled,
                                      Colors.green,
                                      (value) => setState(() => _isBatterySaverEnabled = value),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Brightness Slider
                                _buildBrightnessSlider(),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickSettingTile(
    String label,
    IconData icon,
    bool isEnabled,
    Color color,
    ValueChanged<bool> onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled 
              ? color.withOpacity(0.2)
              : AppTheme.surfaceColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled ? color : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isEnabled ? AppTheme.textColor : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isEnabled ? color : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightnessSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.brightness_6,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                'Brightness',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              Text(
                '${(_brightness * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.brightness_low,
                color: Colors.grey.withOpacity(0.7),
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: _brightness,
                  onChanged: (value) {
                    setState(() {
                      _brightness = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                  inactiveColor: Colors.grey.withOpacity(0.3),
                ),
              ),
              Icon(
                Icons.brightness_high,
                color: Colors.grey.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
