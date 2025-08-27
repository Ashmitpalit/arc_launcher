import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/theme.dart';

class IconCustomizerScreen extends StatefulWidget {
  const IconCustomizerScreen({super.key});

  @override
  State<IconCustomizerScreen> createState() => _IconCustomizerScreenState();
}

class _IconCustomizerScreenState extends State<IconCustomizerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTheme = 'Dark';
  String _selectedIconPack = 'Default';

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Dark',
      'preview': 'https://via.placeholder.com/200x300/1a1a1a/ffffff?text=Dark',
      'isActive': true,
    },
    {
      'name': 'Light',
      'preview': 'https://via.placeholder.com/200x300/f5f5f5/000000?text=Light',
      'isActive': false,
    },
    {
      'name': 'Gaming',
      'preview': 'https://via.placeholder.com/200x300/ff6b35/ffffff?text=Gaming',
      'isActive': false,
    },
    {
      'name': 'Minimal',
      'preview': 'https://via.placeholder.com/200x300/2c3e50/ffffff?text=Minimal',
      'isActive': false,
    },
  ];

  final List<Map<String, dynamic>> _iconPacks = [
    {
      'name': 'Default',
      'preview': 'https://via.placeholder.com/100x100/3498db/ffffff?text=Default',
      'isActive': true,
      'downloadCount': 0,
    },
    {
      'name': 'Material',
      'preview': 'https://via.placeholder.com/100x100/e74c3c/ffffff?text=Material',
      'isActive': false,
      'downloadCount': 15000,
    },
    {
      'name': 'Gaming',
      'preview': 'https://via.placeholder.com/100x100/9b59b6/ffffff?text=Gaming',
      'isActive': false,
      'downloadCount': 8500,
    },
    {
      'name': 'Neon',
      'preview': 'https://via.placeholder.com/100x100/00ff00/000000?text=Neon',
      'isActive': false,
      'downloadCount': 12000,
    },
    {
      'name': 'Retro',
      'preview': 'https://via.placeholder.com/100x100/ff8c00/ffffff?text=Retro',
      'isActive': false,
      'downloadCount': 6500,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Icon Customizer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.accentColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Themes'),
                  Tab(text: 'Icon Packs'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildThemesTab(),
                _buildIconPacksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Theme',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize the look and feel of your launcher',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                return _buildThemeCard(theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPacksTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Icon Packs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Change the appearance of your app icons',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _iconPacks.length,
              itemBuilder: (context, index) {
                final iconPack = _iconPacks[index];
                return _buildIconPackCard(iconPack);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(Map<String, dynamic> theme) {
    final isSelected = theme['isActive'] == true;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          for (var t in _themes) {
            t['isActive'] = false;
          }
          theme['isActive'] = true;
          _selectedTheme = theme['name'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppTheme.accentColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Preview Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                child: CachedNetworkImage(
                  imageUrl: theme['preview'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            ),

            // Theme Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    theme['name'],
                    style: TextStyle(
                      color: isSelected ? AppTheme.accentColor : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accentColor : Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isSelected ? 'ACTIVE' : 'APPLY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildIconPackCard(Map<String, dynamic> iconPack) {
    final isSelected = iconPack['isActive'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.accentColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: iconPack['preview'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[800],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[800],
              child: const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
        title: Text(
          iconPack['name'],
          style: TextStyle(
            color: isSelected ? AppTheme.accentColor : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: Colors.white60,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${iconPack['downloadCount']} downloads',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentColor : Colors.grey[700],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isSelected ? 'ACTIVE' : 'APPLY',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          setState(() {
            for (var pack in _iconPacks) {
              pack['isActive'] = false;
            }
            iconPack['isActive'] = true;
            _selectedIconPack = iconPack['name'];
          });
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 
