import 'package:flutter/material.dart';
import '../services/launcher_background_service.dart';
import '../utils/theme.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late LauncherBackgroundService _backgroundService;
  
  // Wallpaper data with actual image paths
  List<Map<String, dynamic>> _wallpapers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _backgroundService = LauncherBackgroundService.instance;
    _initializeService();
    _loadSampleWallpapers();
  }

  Future<void> _initializeService() async {
    await _backgroundService.initialize();
  }

  void _loadSampleWallpapers() {
    _wallpapers = [
      {
        'id': 'wall_1',
        'name': 'Cosmic Flow',
        'description': 'Beautiful space-themed wallpaper',
        'category': 'static',
        'imagePath': 'assets/images/wallpapers/pexels-eberhardgross-1366919.jpg',
        'color': const Color(0xFF1a1a2e), // Dark blue
      },
      {
        'id': 'wall_2',
        'name': 'Ocean Waves',
        'description': 'Calming ocean view',
        'category': 'static',
        'imagePath': 'assets/images/wallpapers/pexels-rahulp9800-1212487.jpg',
        'color': const Color(0xFF0f3460), // Ocean blue
      },
      {
        'id': 'wall_3',
        'name': 'Mountain Peak',
        'description': 'Stunning mountain landscape',
        'category': 'static',
        'imagePath': 'assets/images/wallpapers/pexels-todd-trapani-488382-1535162.jpg',
        'color': const Color(0xFF533483), // Purple
      },
      {
        'id': 'wall_4',
        'name': 'Forest Path',
        'description': 'Peaceful forest scene',
        'category': 'static',
        'imagePath': 'assets/images/wallpapers/pexels-rpnickson-2486168.jpg',
        'color': const Color(0xFF16213e), // Forest green
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Wallpapers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_backgroundService.hasWallpaperApplied)
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.white),
              onPressed: _resetToDefault,
              tooltip: 'Reset to Default',
            ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            color: const Color(0xFF1E1E1E),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Static'),
                Tab(text: 'Live'),
                Tab(text: 'Animated'),
                Tab(text: 'Custom'),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStaticWallpapers(),
                _buildLiveWallpapers(),
                _buildAnimatedWallpapers(),
                _buildCustomWallpapers(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticWallpapers() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _wallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = _wallpapers[index];
        return _buildWallpaperCard(wallpaper);
      },
    );
  }

  Widget _buildLiveWallpapers() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.animation, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Live Wallpapers',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedWallpapers() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Animated Wallpapers',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomWallpapers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Custom Wallpapers',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your own images',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _selectCustomWallpaper(),
            icon: const Icon(Icons.upload),
            label: const Text('Select Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard(Map<String, dynamic> wallpaper) {
    final isCurrentWallpaper = _backgroundService.currentWallpaperPath == wallpaper['imagePath'];
    
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: wallpaper['color'] ?? Colors.grey[800],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.asset(
                      wallpaper['imagePath'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                wallpaper['color'] ?? Colors.grey[700]!,
                                (wallpaper['color'] ?? Colors.grey[700]!).withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getWallpaperIcon(wallpaper['name']),
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        );
                      },
                    ),
                    if (isCurrentWallpaper)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallpaper['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  wallpaper['description'],
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentWallpaper ? null : () => _applyWallpaper(wallpaper),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentWallpaper ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(isCurrentWallpaper ? 'Applied' : 'Apply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWallpaperIcon(String name) {
    switch (name.toLowerCase()) {
      case 'cosmic flow':
        return Icons.auto_awesome;
      case 'ocean waves':
        return Icons.water;
      case 'mountain peak':
        return Icons.landscape;
      case 'forest path':
        return Icons.forest;
      default:
        return Icons.image;
    }
  }

  Future<void> _applyWallpaper(Map<String, dynamic> wallpaper) async {
    try {
      // setState(() => _isLoading = true); // Removed unused field
      
      // Actually apply the wallpaper using the background service
      final success = await _backgroundService.applyWallpaper(
        wallpaper['imagePath'],
        wallpaper['name'],
      );
      
      if (success) {
        if (mounted) {
          _showSuccessSnackBar('Wallpaper applied successfully!');
          
          // Refresh the UI to show the checkmark
          setState(() {});
          
          // Navigate back to settings after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        _showErrorSnackBar('Failed to apply wallpaper');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to apply wallpaper: $e');
    } finally {
      // if (mounted) { // Removed unused field
      //   setState(() => _isLoading = false); // Removed unused field
      // }
    }
  }

  Future<void> _resetToDefault() async {
    try {
      // setState(() => _isLoading = true); // Removed unused field
      
      final success = await _backgroundService.resetToDefault();
      if (success) {
        _showSuccessSnackBar('Reset to default background');
        setState(() {});
      } else {
        _showErrorSnackBar('Failed to reset background');
      }
    } catch (e) {
      _showErrorSnackBar('Error resetting background: $e');
    } finally {
      // setState(() => _isLoading = false); // Removed unused field
    }
  }

  Future<void> _selectCustomWallpaper() async {
    // Placeholder for custom wallpaper selection
    _showInfoSnackBar('Custom wallpaper selection coming soon!');
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
