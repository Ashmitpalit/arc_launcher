import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/game_item.dart';
import '../services/playdeck_service.dart';
import '../utils/theme.dart';

class PlayDeckScreen extends StatefulWidget {
  const PlayDeckScreen({super.key});

  @override
  State<PlayDeckScreen> createState() => _PlayDeckScreenState();
}

class _PlayDeckScreenState extends State<PlayDeckScreen>
    with SingleTickerProviderStateMixin {
  final PlayDeckService _playDeckService = PlayDeckService();
  late TabController _tabController;
  
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _selectedGenre = 'All';
  List<String> _availableCategories = ['All'];
  List<String> _availableGenres = ['All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializePlayDeck();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayDeck() async {
    setState(() => _isLoading = true);
    try {
      await _playDeckService.initialize();
      
      // Get unique categories and genres
      _availableCategories = _playDeckService.getAvailableCategories();
      _availableGenres = _playDeckService.getAvailableGenres();
      
    } catch (e) {
      print('Error initializing PlayDeck: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          '🎮 PlayDeck',
          style: TextStyle(color: Colors.white, fontSize: 24),
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
            onPressed: _initializePlayDeck,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Featured'),
            Tab(text: 'Games'),
            Tab(text: 'Trending'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFeaturedTab(),
                _buildGamesTab(),
                _buildTrendingTab(),
                _buildStatsTab(),
              ],
            ),
    );
  }

  Widget _buildFeaturedTab() {
    final featuredGames = _playDeckService.featuredGames;
    final promoTiles = _playDeckService.promoTiles;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promo Tiles Section
          if (promoTiles.isNotEmpty) ...[
            _buildSectionHeader('🎯 Promotions'),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: promoTiles.length,
                itemBuilder: (context, index) {
                  final tile = promoTiles[index];
                  return _buildPromoTile(tile);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Featured Games Section
          _buildSectionHeader('⭐ Featured Games'),
          const SizedBox(height: 16),
          ...featuredGames.map((game) => _buildGameCard(game)),
        ],
      ),
    );
  }

  Widget _buildGamesTab() {
    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Category Filter
              Row(
                children: [
                  const Text(
                    'Category: ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _availableCategories.map((category) {
                          final isSelected = category == _selectedCategory;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              backgroundColor: Colors.grey[800],
                              selectedColor: Colors.blue,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[300],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Genre Filter
              Row(
                children: [
                  const Text(
                    'Genre: ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _availableGenres.map((genre) {
                          final isSelected = genre == _selectedGenre;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: FilterChip(
                              label: Text(genre),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedGenre = genre;
                                });
                              },
                              backgroundColor: Colors.grey[800],
                              selectedColor: Colors.green,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[300],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Filtered Games
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('${_selectedCategory} Games'),
                const SizedBox(height: 16),
                ..._getFilteredGames().map((game) => _buildGameCard(game)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingTab() {
    final trendingGames = _playDeckService.trendingGames;
    final newReleases = _playDeckService.newReleases;
    final popularGames = _playDeckService.popularGames;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Games
          _buildSectionHeader('🔥 Trending Now'),
          const SizedBox(height: 16),
          ...trendingGames.map((game) => _buildGameCard(game)),
          
          const SizedBox(height: 24),
          
          // New Releases
          _buildSectionHeader('🆕 New Releases'),
          const SizedBox(height: 16),
          ...newReleases.map((game) => _buildGameCard(game)),
          
          const SizedBox(height: 24),
          
          // Popular Games
          _buildSectionHeader('⭐ Popular Games'),
          const SizedBox(height: 16),
          ...popularGames.map((game) => _buildGameCard(game)),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = _playDeckService.getGamingStats();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('📊 Gaming Statistics'),
          const SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Total Games', stats['totalGames'].toString(), Icons.games, Colors.blue),
              _buildStatCard('Premium Games', stats['premiumGames'].toString(), Icons.star, Colors.amber),
              _buildStatCard('High Rated', stats['highRatedGames'].toString(), Icons.thumb_up, Colors.green),
              _buildStatCard('Installed', stats['installedGames'].toString(), Icons.download, Colors.purple),
              _buildStatCard('Average Rating', stats['averageRating'], Icons.star_rate, Colors.orange),
              _buildStatCard('Played Games', stats['playedGames'].toString(), Icons.play_circle, Colors.red),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category Distribution
          _buildSectionHeader('📈 Category Distribution'),
          const SizedBox(height: 16),
          ..._buildCategoryDistributionCharts(stats['categoryDistribution']),
          
          const SizedBox(height: 24),
          
          // Genre Distribution
          _buildSectionHeader('🎭 Genre Distribution'),
          const SizedBox(height: 16),
          ..._buildGenreDistributionCharts(stats['genreDistribution']),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPromoTile(Map<String, dynamic> tile) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _parseColor(tile['backgroundColor']),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              tile['imageUrl'],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: _parseColor(tile['backgroundColor']),
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: _parseColor(tile['textColor']),
                  ),
                );
              },
            ),
          ),
          
          // Content Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Text Content
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tile['title'],
                  style: TextStyle(
                    color: _parseColor(tile['textColor']),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tile['subtitle'],
                  style: TextStyle(
                    color: _parseColor(tile['textColor']).withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _handlePromoAction(tile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _parseColor(tile['textColor']),
                    foregroundColor: _parseColor(tile['backgroundColor']),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(tile['actionText']),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameItem game) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF212121),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Game Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: game.categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    game.genreIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Game Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.gameName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (game.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.withOpacity(0.5)),
                              ),
                              child: Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: game.categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: game.categoryColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              game.category,
                              style: TextStyle(
                                color: game.categoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.withOpacity(0.5)),
                            ),
                            child: Text(
                              game.genre,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...game.ratingStars,
                          const SizedBox(width: 8),
                          Text(
                            game.rating.toString(),
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            game.formattedDownloadCount,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              game.description ?? 'No description available',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Gaming Metadata
            if (game.gamingMetadata.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 16,
                        children: game.gamingMetadata.entries.map((entry) {
                          return Text(
                            '${entry.key}: ${entry.value}',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Tags
            if (game.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: game.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Bottom Row
            Row(
              children: [
                // Game Age Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: game.isNewRelease ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: game.isNewRelease ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    game.gameAgeLabel,
                    style: TextStyle(
                      color: game.isNewRelease ? Colors.red : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Size
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  ),
                  child: Text(
                    game.size,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Action Buttons
                if (!game.isInstalled) ...[
                  TextButton(
                    onPressed: () => _showGameDetails(game),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Details'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _installGame(game),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Install'),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Installed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
                      Text(
              title,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryDistributionCharts(Map<String, dynamic> categoryStats) {
    return categoryStats.entries.map((entry) {
      final percentage = (_playDeckService.games.length > 0) 
          ? (entry.value / _playDeckService.games.length * 100).round()
          : 0;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[600],
                    valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(entry.key)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$percentage%',
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildGenreDistributionCharts(Map<String, dynamic> genreStats) {
    return genreStats.entries.map((entry) {
      final percentage = (_playDeckService.games.length > 0) 
          ? (entry.value / _playDeckService.games.length * 100).round()
          : 0;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[600],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$percentage%',
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<GameItem> _getFilteredGames() {
    List<GameItem> filtered = _playDeckService.games;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((game) => game.category == _selectedCategory).toList();
    }
    
    if (_selectedGenre != 'All') {
      filtered = filtered.where((game) => game.genre == _selectedGenre).toList();
    }
    
    return filtered;
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'action':
        return Colors.red;
      case 'adventure':
        return Colors.blue;
      case 'arcade':
        return Colors.green;
      case 'puzzle':
        return Colors.purple;
      case 'racing':
        return Colors.orange;
      case 'rpg':
        return Colors.teal;
      case 'simulation':
        return Colors.indigo;
      case 'sports':
        return Colors.lime;
      case 'strategy':
        return Colors.brown;
      case 'casual':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handlePromoAction(Map<String, dynamic> tile) async {
    try {
      final actionUrl = tile['actionUrl'];
      if (actionUrl != null && actionUrl.isNotEmpty) {
        // Try to open the action URL
        if (await canLaunchUrl(Uri.parse(actionUrl))) {
          final success = await launchUrl(
            Uri.parse(actionUrl),
            mode: LaunchMode.externalApplication,
          );
          
          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening: ${tile['title']}'),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        } else {
          // Fallback to Play Store search
          final searchQuery = tile['title'].toString().replaceAll('🎮', '').replaceAll('🏆', '').replaceAll('🎯', '').trim();
          final playStoreSearchUrl = 'https://play.google.com/store/search?q=${Uri.encodeComponent(searchQuery)}';
          
          if (await canLaunchUrl(Uri.parse(playStoreSearchUrl))) {
            await launchUrl(
              Uri.parse(playStoreSearchUrl),
              mode: LaunchMode.externalApplication,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showGameDetails(GameItem game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          game.gameName,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${game.category}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Genre: ${game.genre}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Rating: ${game.rating}/5.0',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Downloads: ${game.formattedDownloadCount}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Size: ${game.size}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Release: ${game.formattedReleaseDate}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            if (game.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tags:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: game.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.grey[700],
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                )).toList(),
              ),
            ],
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

  Future<void> _installGame(GameItem game) async {
    try {
      // Mark as played
      await _playDeckService.markGamePlayed(game.id);
      
      // Show installation dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Install ${game.gameName}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'This will open the Google Play Store to install the game.',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openPlayStore(game.packageName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Open Store'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error installing game: $e');
    }
  }

  Future<void> _openPlayStore(String packageName) async {
    try {
      final success = await _playDeckService.openPlayStore(packageName);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening Play Store for $packageName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Play Store. Please try again.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
