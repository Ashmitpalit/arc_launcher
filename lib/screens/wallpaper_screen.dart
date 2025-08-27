import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/wallpaper_service.dart';
import '../services/analytics_service.dart';
import '../utils/theme.dart';
import '../utils/gesture_detector.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen>
    with TickerProviderStateMixin, AnalyticsMixin {
  late TabController _tabController;
  late WallpaperService _wallpaperService;
  
  bool _isLoading = false;
  String _selectedCategory = 'live';
  
  // Wallpaper data
  List<WallpaperItem> _wallpapers = [];
  List<LiveWallpaper> _liveWallpapers = [];
  WallpaperInfo? _currentWallpaperInfo;
  
  // Preview state
  String? _previewWallpaperPath;
  bool _isPreviewing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _wallpaperService = WallpaperService();
    _initializeWallpapers();
  }

  Future<void> _initializeWallpapers() async {
    setState(() => _isLoading = true);
    
    try {
      await _wallpaperService.initialize();
      await _loadCurrentWallpaper();
      await _loadWallpapers();
    } catch (e) {
      _showErrorSnackBar('Failed to initialize wallpapers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentWallpaper() async {
    try {
      _currentWallpaperInfo = await _wallpaperService.getWallpaperInfo();
    } catch (e) {
      print('Failed to load current wallpaper: $e');
    }
  }

  Future<void> _loadWallpapers() async {
    try {
      // Load live wallpapers
      _liveWallpapers = await _wallpaperService.getAvailableLiveWallpapers();
      
      // Load sample wallpapers (in real app, these would come from a server)
      _wallpapers = _getSampleWallpapers();
      
      setState(() {});
    } catch (e) {
      print('Failed to load wallpapers: $e');
    }
  }

  List<WallpaperItem> _getSampleWallpapers() {
    return [
      // Live wallpapers
      WallpaperItem(
        id: 'live_1',
        name: 'Cosmic Flow',
        description: 'Dynamic space-themed live wallpaper',
        imagePath: 'https://via.placeholder.com/300x600/1a1a2e/ffffff?text=Cosmic+Flow',
        category: 'live',
        isLive: true,
        rating: 4.8,
        downloadCount: 15000,
      ),
      WallpaperItem(
        id: 'live_2',
        name: 'Ocean Waves',
        description: 'Calming ocean wave animation',
        imagePath: 'https://via.placeholder.com/300x600/0f3460/ffffff?text=Ocean+Waves',
        category: 'live',
        isLive: true,
        rating: 4.6,
        downloadCount: 12000,
      ),
      
      // Animated wallpapers
      WallpaperItem(
        id: 'animated_1',
        name: 'Floating Particles',
        description: 'Beautiful floating particle system',
        imagePath: 'https://via.placeholder.com/300x600/533483/ffffff?text=Floating+Particles',
        category: 'animated',
        isAnimated: true,
        rating: 4.7,
        downloadCount: 18000,
      ),
      WallpaperItem(
        id: 'animated_2',
        name: 'Neon City',
        description: 'Cyberpunk city with neon lights',
        imagePath: 'https://via.placeholder.com/300x600/16213e/ffffff?text=Neon+City',
        category: 'animated',
        isAnimated: true,
        rating: 4.5,
        downloadCount: 9500,
      ),
      
      // Static wallpapers
      WallpaperItem(
        id: 'static_1',
        name: 'Mountain Sunset',
        description: 'Breathtaking mountain landscape',
        imagePath: 'https://via.placeholder.com/300x600/e94560/ffffff?text=Mountain+Sunset',
        category: 'static',
        rating: 4.9,
        downloadCount: 25000,
      ),
      WallpaperItem(
        id: 'static_2',
        name: 'Abstract Geometry',
        description: 'Modern geometric patterns',
        imagePath: 'https://via.placeholder.com/300x600/533483/ffffff?text=Abstract+Geometry',
        category: 'static',
        rating: 4.4,
        downloadCount: 8000,
      ),
      
      // Custom wallpapers
      WallpaperItem(
        id: 'custom_1',
        name: 'Your Photos',
        description: 'Personal photo collection',
        imagePath: 'https://via.placeholder.com/300x600/0f3460/ffffff?text=Your+Photos',
        category: 'custom',
        rating: 5.0,
        downloadCount: 1,
      ),
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initializeWallpapers,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Live'),
            Tab(text: 'Animated'),
            Tab(text: 'Static'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCurrentWallpaperInfo(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLiveWallpapersTab(),
                      _buildAnimatedWallpapersTab(),
                      _buildStaticWallpapersTab(),
                      _buildCustomWallpapersTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentWallpaperInfo() {
    final status = _wallpaperService.getCurrentWallpaperStatus();
    final isLive = status['isLive'] ?? false;
    final isAnimated = status['isAnimated'] ?? false;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isLive ? Icons.animation : isAnimated ? Icons.movie : Icons.image,
            color: Colors.blue,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Wallpaper',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLive ? 'Live Wallpaper' : isAnimated ? 'Animated Wallpaper' : 'Static Wallpaper',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (status['path']?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    status['path'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blue),
            onPressed: _showWallpaperSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveWallpapersTab() {
    final liveWallpapers = _wallpapers.where((w) => w.isLive).toList();
    
    if (liveWallpapers.isEmpty) {
      return _buildEmptyState(
        'No Live Wallpapers',
        'Live wallpapers will appear here when available.',
        Icons.animation,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWallpapers,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: liveWallpapers.length,
        itemBuilder: (context, index) {
          final wallpaper = liveWallpapers[index];
          return _buildWallpaperCard(wallpaper);
        },
      ),
    );
  }

  Widget _buildAnimatedWallpapersTab() {
    final animatedWallpapers = _wallpapers.where((w) => w.isAnimated).toList();
    
    if (animatedWallpapers.isEmpty) {
      return _buildEmptyState(
        'No Animated Wallpapers',
        'Animated wallpapers will appear here when available.',
        Icons.movie,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWallpapers,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: animatedWallpapers.length,
        itemBuilder: (context, index) {
          final wallpaper = animatedWallpapers[index];
          return _buildWallpaperCard(wallpaper);
        },
      ),
    );
  }

  Widget _buildStaticWallpapersTab() {
    final staticWallpapers = _wallpapers.where((w) => !w.isLive && !w.isAnimated && w.category != 'custom').toList();
    
    if (staticWallpapers.isEmpty) {
      return _buildEmptyState(
        'No Static Wallpapers',
        'Static wallpapers will appear here when available.',
        Icons.image,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWallpapers,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: staticWallpapers.length,
        itemBuilder: (context, index) {
          final wallpaper = staticWallpapers[index];
          return _buildWallpaperCard(wallpaper);
        },
      ),
    );
  }

  Widget _buildCustomWallpapersTab() {
    final customWallpapers = _wallpapers.where((w) => w.category == 'custom').toList();
    
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.add_photo_alternate, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Custom Wallpaper',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select photos from your gallery',
                      style: TextStyle(
                        color: Colors.blue[200],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _addCustomWallpaper,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Select'),
              ),
            ],
          ),
        ),
        Expanded(
          child: customWallpapers.isEmpty
              ? _buildEmptyState(
                  'No Custom Wallpapers',
                  'Add your own photos as wallpapers.',
                  Icons.person,
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: customWallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaper = customWallpapers[index];
                    return _buildWallpaperCard(wallpaper);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWallpaperCard(WallpaperItem wallpaper) {
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => _previewWallpaper(wallpaper),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallpaper image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[800],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: wallpaper.imagePath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: Icon(
                        wallpaper.isLive ? Icons.animation : wallpaper.isAnimated ? Icons.movie : Icons.image,
                        color: Colors.grey[600],
                        size: 48,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.error,
                        color: Colors.red[400],
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Wallpaper info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallpaper.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallpaper.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        wallpaper.rating.toString(),
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (wallpaper.isInstalled)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _previewWallpaper(WallpaperItem wallpaper) {
    setState(() {
      _previewWallpaperPath = wallpaper.imagePath;
      _isPreviewing = true;
    });
    
    _showWallpaperPreview(wallpaper);
  }

  void _showWallpaperPreview(WallpaperItem wallpaper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[900],
          ),
          child: Column(
            children: [
              // Preview image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: Colors.grey[800],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[400],
                          side: BorderSide(color: Colors.grey[600]!),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _setWallpaper(wallpaper);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Set Wallpaper'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setWallpaper(WallpaperItem wallpaper) async {
    try {
      setState(() => _isLoading = true);
      
      bool success = false;
      if (wallpaper.isLive) {
        success = await _wallpaperService.setLiveWallpaper('com.example', 'LiveWallpaperService');
      } else if (wallpaper.isAnimated) {
        success = await _wallpaperService.setAnimatedWallpaper(wallpaper.imagePath, 'home');
      } else {
        success = await _wallpaperService.setWallpaperFromFile(wallpaper.imagePath, 'home');
      }
      
      if (success) {
        await _loadCurrentWallpaper();
        _showSuccessSnackBar('Wallpaper set successfully!');
        logFeatureUsage('wallpaper_set');
      } else {
        _showErrorSnackBar('Failed to set wallpaper');
      }
    } catch (e) {
      _showErrorSnackBar('Error setting wallpaper: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addCustomWallpaper() {
    // In a real app, this would open image picker
    _showInfoSnackBar('Custom wallpaper feature coming soon!');
  }

  void _showWallpaperSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Wallpaper Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Refresh Wallpapers'),
              subtitle: const Text('Update available wallpapers'),
              onTap: () {
                Navigator.pop(context);
                _initializeWallpapers();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.orange),
              title: const Text('Reset to Default'),
              subtitle: const Text('Restore system default wallpaper'),
              onTap: () {
                Navigator.pop(context);
                _resetToDefault();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefault() async {
    try {
      setState(() => _isLoading = true);
      
      final success = await _wallpaperService.resetToDefault();
      if (success) {
        await _loadCurrentWallpaper();
        _showSuccessSnackBar('Reset to default wallpaper');
      } else {
        _showErrorSnackBar('Failed to reset wallpaper');
      }
    } catch (e) {
      _showErrorSnackBar('Error resetting wallpaper: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
