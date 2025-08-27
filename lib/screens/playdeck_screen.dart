import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/game_item.dart';
import '../utils/theme.dart';

class PlayDeckScreen extends StatefulWidget {
  const PlayDeckScreen({super.key});

  @override
  State<PlayDeckScreen> createState() => _PlayDeckScreenState();
}

class _PlayDeckScreenState extends State<PlayDeckScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GameCategory _selectedCategory = GameCategory.all;
  final List<GameItem> _games = [];
  final List<GameItem> _promotedGames = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: GameCategory.values.length, vsync: this);
    _loadGames();
  }

  void _loadGames() {
    // Mock data - replace with real API call
    _games.addAll([
      GameItem(
        id: '1',
        title: 'Racing Legends',
        description: 'Epic racing adventure',
        iconUrl: 'https://via.placeholder.com/100',
        packageName: 'com.racing.legends',
        category: GameCategory.racing,
        rating: 4.5,
        downloadCount: 1000000,
        isPromoted: true,
        promoText: '50% OFF!',
        promoImageUrl: 'https://via.placeholder.com/300x150',
        createdAt: DateTime.now(),
      ),
      GameItem(
        id: '2',
        title: 'Puzzle Master',
        description: 'Brain-teasing puzzles',
        iconUrl: 'https://via.placeholder.com/100',
        packageName: 'com.puzzle.master',
        category: GameCategory.puzzle,
        rating: 4.8,
        downloadCount: 500000,
        createdAt: DateTime.now(),
      ),
    ]);

    _promotedGames.addAll(_games.where((game) => game.isPromoted));
    setState(() {});
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
                'PlayDeck',
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

          // Promoted Games Section
          if (_promotedGames.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildPromotedSection(),
            ),

          // Category Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppTheme.accentColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: GameCategory.values.map((category) {
                  return Tab(
                    text: _getCategoryDisplayName(category),
                  );
                }).toList(),
              ),
            ),
          ),

          // Games Grid
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              itemBuilder: (context, index) {
                return _buildGameCard(_games[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotedSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16.0),
      child: PageView.builder(
        itemCount: _promotedGames.length,
        itemBuilder: (context, index) {
          final game = _promotedGames[index];
          return _buildPromoCard(game);
        },
      ),
    );
  }

  Widget _buildPromoCard(GameItem game) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (game.promoImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: game.promoImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
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
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (game.promoText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.promoText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  game.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  game.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameItem game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Icon
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: game.iconUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 120,
                color: Colors.grey[800],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 120,
                color: Colors.grey[800],
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),

          // Game Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  game.description,
                  style: const TextStyle(
                    color: Colors.white70,
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
                      game.rating.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (game.isInstalled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'INSTALLED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(GameCategory category) {
    switch (category) {
      case GameCategory.all:
        return 'All';
      case GameCategory.action:
        return 'Action';
      case GameCategory.adventure:
        return 'Adventure';
      case GameCategory.arcade:
        return 'Arcade';
      case GameCategory.board:
        return 'Board';
      case GameCategory.card:
        return 'Card';
      case GameCategory.casual:
        return 'Casual';
      case GameCategory.educational:
        return 'Educational';
      case GameCategory.puzzle:
        return 'Puzzle';
      case GameCategory.racing:
        return 'Racing';
      case GameCategory.rpg:
        return 'RPG';
      case GameCategory.simulation:
        return 'Simulation';
      case GameCategory.sports:
        return 'Sports';
      case GameCategory.strategy:
        return 'Strategy';
      case GameCategory.trivia:
        return 'Trivia';
      case GameCategory.other:
        return 'Other';
    }
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
