import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/launcher_provider.dart';
import '../utils/theme.dart';
import '../models/app_shortcut.dart';
import 'custom_app_icon.dart';

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
      return _searchQuery.isEmpty || app.name.toLowerCase().contains(_searchQuery);
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
        final app = filteredApps[index];
        return _buildAppIcon(app, launcherProvider);
      },
    );
  }

  Widget _buildAppIcon(AppShortcut app, LauncherProvider launcherProvider) {
    return CustomAppIcon(
      app: app,
      size: 56.0,
      onTap: () {
        launcherProvider.launchApp(app);
        _closeDrawer();
      },
      onLongPress: () {
        _showAppOptions(context, app, launcherProvider);
      },
      labelStyle: const TextStyle(
        fontSize: 11,
        color: AppTheme.textColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _showAppOptions(BuildContext context, AppShortcut app, LauncherProvider launcherProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('Add to Home Screen'),
              onTap: () {
                launcherProvider.pinApp(app);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${app.name} added to home screen'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Info'),
              onTap: () {
                Navigator.pop(context);
                launcherProvider.showAppInfo(app);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}