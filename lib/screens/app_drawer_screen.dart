import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_shortcut.dart';
import '../providers/launcher_provider.dart';
import '../widgets/app_tracer_widget.dart';

/// Screen that displays all installed apps in a grid layout
/// Opened with left swipe gesture from home screen
class AppDrawerScreen extends StatefulWidget {
  const AppDrawerScreen({super.key});

  @override
  State<AppDrawerScreen> createState() => _AppDrawerScreenState();
}

class _AppDrawerScreenState extends State<AppDrawerScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<AppShortcut> _filteredApps = [];
  List<AppShortcut> _allApps = [];
  
  // Grid configuration
  static const int _crossAxisCount = 4;
  static const double _appIconSize = 60.0;
  static const double _appIconSpacing = 16.0;

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
    
    // Setup slide animation (slide in from left)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
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
    
    // Load apps
    _loadApps();
    
    // Start entrance animation
    _startEntranceAnimation();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadApps() {
    // Get apps from launcher provider
    final launcherProvider = Provider.of<LauncherProvider>(context, listen: false);
    _allApps = launcherProvider.installedApps;
    _filteredApps = List.from(_allApps);
  }

  void _startEntranceAnimation() {
    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  void _filterApps(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredApps = List.from(_allApps);
      } else {
        _filteredApps = _allApps.where((app) {
          return app.name.toLowerCase().contains(query.toLowerCase()) ||
                 app.packageName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _launchApp(AppShortcut app) {
    // Launch the app
    // TODO: Implement app launching functionality
    // app.launch();
    
    // Navigate back to home screen
    Navigator.of(context).pop();
  }

  void _closeDrawer() {
    // Reverse animations
    _slideAnimationController.reverse();
    _fadeAnimationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeDrawer();
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
                  // Header with search and close button
                  _buildHeader(),
                  
                  // Search bar
                  _buildSearchBar(),
                  
                  // Apps grid
                  Expanded(
                    child: _buildAppsGrid(),
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
          // Close button
          GestureDetector(
            onTap: _closeDrawer,
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
          
          const SizedBox(width: 16),
          
          // Title
          const Text(
            'App Drawer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // App count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              '${_filteredApps.length} apps',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _filterApps,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search apps...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppsGrid() {
    if (_filteredApps.isEmpty) {
      return _buildEmptyState();
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: _appIconSpacing,
        mainAxisSpacing: _appIconSpacing,
      ),
      itemCount: _filteredApps.length,
      itemBuilder: (context, index) {
        final app = _filteredApps[index];
        return _buildAppIcon(app);
      },
    );
  }

  Widget _buildAppIcon(AppShortcut app) {
    return GestureDetector(
      onTap: () => _launchApp(app),
      onLongPress: () => _showAppOptions(app),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: _appIconSize,
              height: _appIconSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.1),
              ),
                                child: Icon(
                    app.icon,
                    color: app.color,
                    size: 32,
                  ),
            ),
            
            const SizedBox(height: 8),
            
            // App name
            Text(
              app.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            color: Colors.white.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No apps found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
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

  void _showAppOptions(AppShortcut app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App icon and name
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Icon(
                    app.icon,
                    color: app.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        app.packageName,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Options
            _buildOptionButton(
              icon: Icons.launch,
              label: 'Launch App',
              onTap: () {
                Navigator.pop(context);
                _launchApp(app);
              },
            ),
            _buildOptionButton(
              icon: Icons.info,
              label: 'App Info',
              onTap: () {
                Navigator.pop(context);
                // TODO: Show app info
              },
            ),
            _buildOptionButton(
              icon: Icons.delete,
              label: 'Uninstall',
              onTap: () {
                Navigator.pop(context);
                // TODO: Uninstall app
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
