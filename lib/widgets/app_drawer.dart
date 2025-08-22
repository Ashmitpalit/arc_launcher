import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/launcher_provider.dart';
import '../utils/theme.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const AppDrawer({
    super.key,
    required this.onClose,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
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

  void _closeDrawer() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LauncherProvider>(
      builder: (context, launcherProvider, child) {
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
                      onTap: _closeDrawer,
                      child: Container(
                        color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                      ),
                    ),
                  ),

                  // App Drawer Content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value * 0.8),
                      child: GestureDetector(
                        onVerticalDragEnd: (details) {
                          // Close drawer on swipe down
                          if (details.primaryVelocity! > 300) {
                            _closeDrawer();
                          }
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Handle Bar with Swipe Hint
                              Container(
                                margin: const EdgeInsets.only(top: 12, bottom: 8),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Swipe down to close',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.withOpacity(0.6),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Header
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Apps',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: AppTheme.textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Search Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          style: const TextStyle(color: AppTheme.textColor),
                                          decoration: const InputDecoration(
                                            hintText: 'Search apps...',
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              _searchQuery = value.toLowerCase();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Apps Grid
                              Expanded(
                                child: _buildAppsGrid(launcherProvider),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppsGrid(LauncherProvider launcherProvider) {
    final filteredApps = launcherProvider.installedApps.where((app) {
      return _searchQuery.isEmpty || app.toLowerCase().contains(_searchQuery);
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredApps.length,
      itemBuilder: (context, index) {
        final appName = filteredApps[index];
        return _buildAppIcon(appName);
      },
    );
  }

  Widget _buildAppIcon(String appName) {
    final appData = _getAppData(appName);
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $appName'),
            duration: const Duration(seconds: 1),
            backgroundColor: appData['color'] as Color,
          ),
        );
        _closeDrawer();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: appData['color'] as Color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (appData['color'] as Color).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              appData['icon'] as IconData,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appName,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getAppData(String appName) {
    final appIcons = {
      'Settings': {'icon': Icons.settings, 'color': Colors.grey},
      'Phone': {'icon': Icons.phone, 'color': Colors.green},
      'Messages': {'icon': Icons.message, 'color': Colors.blue},
      'Camera': {'icon': Icons.camera_alt, 'color': Colors.purple},
      'Gallery': {'icon': Icons.photo_library, 'color': Colors.pink},
      'Chrome': {'icon': Icons.language, 'color': Colors.orange},
      'Gmail': {'icon': Icons.email, 'color': Colors.red},
      'Maps': {'icon': Icons.map, 'color': Colors.blue},
      'Play Store': {'icon': Icons.store, 'color': Colors.green},
      'YouTube': {'icon': Icons.play_circle_filled, 'color': Colors.red},
      'Spotify': {'icon': Icons.music_note, 'color': Colors.green},
      'WhatsApp': {'icon': Icons.chat, 'color': Colors.green},
      'Instagram': {'icon': Icons.camera_alt, 'color': Colors.purple},
      'Facebook': {'icon': Icons.facebook, 'color': Colors.blue},
      'Twitter': {'icon': Icons.alternate_email, 'color': Colors.blue},
      'Calculator': {'icon': Icons.calculate, 'color': Colors.orange},
      'Calendar': {'icon': Icons.calendar_today, 'color': Colors.blue},
      'Clock': {'icon': Icons.access_time, 'color': Colors.indigo},
      'Files': {'icon': Icons.folder, 'color': Colors.amber},
      'Weather': {'icon': Icons.wb_sunny, 'color': Colors.yellow},
      'Notes': {'icon': Icons.note, 'color': Colors.orange},
      'Music': {'icon': Icons.music_note, 'color': Colors.purple},
      'Photos': {'icon': Icons.photo, 'color': Colors.pink},
      'Drive': {'icon': Icons.cloud, 'color': Colors.blue},
    };

    return appIcons[appName] ?? {'icon': Icons.apps, 'color': Colors.grey};
  }
}
