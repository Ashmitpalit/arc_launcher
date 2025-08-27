import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_item.dart';
import '../utils/theme.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final List<NewsItem> _newsItems = [];
  final List<String> _categories = ['All', 'Gaming', 'Tech', 'Tips', 'Updates'];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    // Mock data - replace with real API call
    _newsItems.addAll([
      NewsItem(
        id: '1',
        title: 'New Gaming Features Released',
        content: 'Discover the latest gaming features and improvements in Arc Launcher...',
        imageUrl: 'https://via.placeholder.com/400x200',
        author: 'Arc Team',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        categories: ['Gaming', 'Updates'],
        createdAt: DateTime.now(),
      ),
      NewsItem(
        id: '2',
        title: 'Sponsored: Best Mobile Games 2024',
        content: 'Check out the top-rated mobile games this year...',
        imageUrl: 'https://via.placeholder.com/400x200',
        author: 'Game Reviews',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        categories: ['Gaming'],
        isSponsored: true,
        sponsorName: 'Game Reviews',
        sponsorLogoUrl: 'https://via.placeholder.com/50x50',
        sponsorUrl: 'https://example.com',
        createdAt: DateTime.now(),
      ),
      NewsItem(
        id: '3',
        title: 'Pro Tips: Optimize Your Gaming Experience',
        content: 'Learn how to get the most out of your gaming setup...',
        imageUrl: 'https://via.placeholder.com/400x200',
        author: 'Gaming Pro',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        categories: ['Tips', 'Gaming'],
        createdAt: DateTime.now(),
      ),
    ]);
    setState(() {});
  }

  List<NewsItem> get _filteredNews {
    if (_selectedCategory == 'All') return _newsItems;
    return _newsItems.where((item) => 
      item.categories.contains(_selectedCategory)
    ).toList();
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
                'Info & News',
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

          // Category Filter
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Container(
                    margin: const EdgeInsets.only(right: 12.0),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey[800],
                      selectedColor: AppTheme.accentColor,
                      checkmarkColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),

          // News Items
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final newsItem = _filteredNews[index];
                  return _buildNewsCard(newsItem);
                },
                childCount: _filteredNews.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsItem newsItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
          // Image
          if (newsItem.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: newsItem.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[800],
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sponsored Badge
                if (newsItem.isSponsored)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sponsored',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title
                Text(
                  newsItem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Content
                Text(
                  newsItem.content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Footer
                Row(
                  children: [
                    // Author
                    if (newsItem.author != null)
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white60,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            newsItem.author!,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white60,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(newsItem.publishedAt),
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Sponsor Info
                if (newsItem.isSponsored && newsItem.sponsorName != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (newsItem.sponsorLogoUrl != null)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 8.0),
                            child: CachedNetworkImage(
                              imageUrl: newsItem.sponsorLogoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[700],
                                child: const Icon(Icons.business, color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[700],
                                child: const Icon(Icons.business, color: Colors.white),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sponsored by ${newsItem.sponsorName}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (newsItem.sponsorUrl != null)
                                Text(
                                  'Learn more',
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
