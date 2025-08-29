import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/launcher_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/notification_panel.dart';
import '../widgets/quick_settings_panel.dart';
import '../widgets/home_page.dart';
import '../widgets/default_launcher_dialog.dart';
import '../widgets/gesture_detector_widget.dart';
import '../utils/theme.dart';
import '../screens/settings_screen.dart';
import '../screens/app_drawer_screen.dart';
import '../screens/quick_settings_screen.dart';
import '../services/launcher_background_service.dart';
import '../services/gesture_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentPage = 0;
  late LauncherBackgroundService _backgroundService;
  late GestureService _gestureService;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _backgroundService = LauncherBackgroundService.instance;
    _gestureService = GestureService();
    
    // Add observer to detect when app becomes active
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _backgroundService.initialize();
      await context.read<LauncherProvider>().loadInstalledApps();
      
      // Set callback for wallpaper changes
      _backgroundService.setWallpaperChangedCallback(() {
        if (mounted) {
          setState(() {});
        }
      });
      
      // Check system default status when home screen loads
      _checkAndShowDefaultDialog();
    });
  }

  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _gestureService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Check system default status when app becomes active
    if (state == AppLifecycleState.resumed) {
      _checkAndShowDefaultDialog();
    }
  }

  void _checkAndShowDefaultDialog() async {
    final provider = context.read<LauncherProvider>();
    final statusChanged = await provider.checkSystemDefaultStatus();
    
    // If the app is no longer default, show the dialog
    if (statusChanged && !provider.isDefaultLauncher) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const DefaultLauncherDialog(),
        );
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    context.read<LauncherProvider>().setCurrentPage(page);
  }

  void _handleLeftSwipe() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AppDrawerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _handleRightSwipe() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const QuickSettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  void _handleUpSwipe() {
    // TODO: Implement app search or recent apps
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App Search - Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleDownSwipe() {
    // TODO: Implement notification shade
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification Shade - Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LauncherProvider>(
      builder: (context, launcherProvider, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: _getBackgroundDecoration(),
            child: GestureDetectorWidget(
              gestureService: _gestureService,
              onLeftSwipe: _handleLeftSwipe,
              onRightSwipe: _handleRightSwipe,
              onUpSwipe: _handleUpSwipe,
              onDownSwipe: _handleDownSwipe,
              child: Stack(
                children: [
                  // Main Home Screen with PageView
                  PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      HomePage(
                        pageIndex: 0,
                        onSwipeUp: () => launcherProvider.toggleAppDrawer(),
                      ),
                      HomePage(
                        pageIndex: 1,
                        onSwipeUp: () => launcherProvider.toggleAppDrawer(),
                      ),
                      HomePage(
                        pageIndex: 2,
                        onSwipeUp: () => launcherProvider.toggleAppDrawer(),
                      ),
                    ],
                  ),

                  // Page Indicator
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppTheme.primaryColor
                                : Colors.white.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Top Status Bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 20,
                        right: 20,
                        bottom: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time
                          Text(
                            _getCurrentTime(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          
                          // Quick Actions
                          Row(
                            children: [
                              // Notification toggle
                              GestureDetector(
                                onTap: () => launcherProvider.toggleNotificationPanel(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // Quick settings toggle
                              GestureDetector(
                                onTap: () => launcherProvider.toggleQuickSettings(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // Launcher settings toggle
                              GestureDetector(
                                onTap: () => _openLauncherSettings(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // App Drawer (slides up from bottom)
                  if (launcherProvider.isAppDrawerOpen)
                    AppDrawer(
                      onClose: () => launcherProvider.closeAppDrawer(),
                    ),

                  // Notification Panel (slides down from top)
                  if (launcherProvider.isNotificationPanelOpen)
                    NotificationPanel(
                      onClose: () => launcherProvider.closePanels(),
                    ),

                  // Quick Settings Panel (slides down from top)
                  if (launcherProvider.isQuickSettingsOpen)
                    QuickSettingsPanel(
                      onClose: () => launcherProvider.closePanels(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _openLauncherSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  BoxDecoration _getBackgroundDecoration() {
    final wallpaperDecoration = _backgroundService.getCurrentWallpaperDecoration();
    if (wallpaperDecoration != null) {
      return wallpaperDecoration;
    }
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryColor.withValues(alpha: 0.3),
          AppTheme.secondaryColor.withValues(alpha: 0.2),
          AppTheme.backgroundColor.withValues(alpha: 0.8),
        ],
      ),
    );
  }
}
