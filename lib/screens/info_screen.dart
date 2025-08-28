import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';
import '../services/info_screen_service.dart';
import '../utils/theme.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>
    with SingleTickerProviderStateMixin {
  final InfoScreenService _infoService = InfoScreenService();
  late TabController _tabController;
  
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  List<String> _availableCategories = ['All'];
  List<String> _availableTypes = ['All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeInfoScreen();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeInfoScreen() async {
    setState(() => _isLoading = true);
    try {
      await _infoService.initialize();
      
      // Get unique categories and types
      _availableCategories = _infoService.getAvailableCategories();
      _availableTypes = _infoService.getAvailableTypes();
      
    } catch (e) {
      print('Error initializing Info Screen: $e');
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
          '📰 Info & News',
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
            onPressed: _initializeInfoScreen,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Featured'),
            Tab(text: 'News'),
            Tab(text: 'Tips'),
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
                _buildNewsTab(),
                _buildTipsTab(),
                _buildStatsTab(),
              ],
            ),
    );
  }

  Widget _buildFeaturedTab() {
    final featuredNews = _infoService.featuredNews;
    final trendingNews = _infoService.trendingNews;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured News Section
          _buildSectionHeader('⭐ Featured Stories'),
          const SizedBox(height: 16),
          ...featuredNews.map((item) => _buildNewsCard(item)),
          
          const SizedBox(height: 24),
          
          // Trending News Section
          _buildSectionHeader('🔥 Trending Now'),
          const SizedBox(height: 16),
          ...trendingNews.map((item) => _buildNewsCard(item)),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
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
              
              // Type Filter
              Row(
                children: [
                  const Text(
                    'Type: ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _availableTypes.map((type) {
                          final isSelected = type == _selectedType;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedType = type;
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
        
        // Filtered News
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('${_selectedCategory} News'),
                const SizedBox(height: 16),
                ..._getFilteredNews().map((item) => _buildNewsCard(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsTab() {
    final tips = _infoService.getNewsByType('tip');
    final guides = _infoService.getNewsByType('guide');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tips Section
          _buildSectionHeader('💡 Tips & Tricks'),
          const SizedBox(height: 16),
          ...tips.map((item) => _buildNewsCard(item)),
          
          const SizedBox(height: 24),
          
          // Guides Section
          _buildSectionHeader('📚 Guides & How-Tos'),
          const SizedBox(height: 16),
          ...guides.map((item) => _buildNewsCard(item)),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = _infoService.getNewsStats();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('📊 Content Statistics'),
          const SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Total Articles', stats['totalNews'].toString(), Icons.article, Colors.blue),
              _buildStatCard('Featured', stats['featuredNews'].toString(), Icons.star, Colors.amber),
              _buildStatCard('Trending', stats['trendingNews'].toString(), Icons.trending_up, Colors.green),
              _buildStatCard('Premium', stats['premiumNews'].toString(), Icons.workspace_premium, Colors.purple),
              _buildStatCard('With Ads', stats['newsWithAds'].toString(), Icons.ads_click, Colors.orange),
              _buildStatCard('Avg Read Time', '${stats['averageReadTime']} min', Icons.timer, Colors.teal),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category Distribution
          _buildSectionHeader('📈 Category Distribution'),
          const SizedBox(height: 16),
          ..._buildCategoryDistributionCharts(stats['categoryDistribution']),
          
          const SizedBox(height: 24),
          
          // Type Distribution
          _buildSectionHeader('🎭 Content Type Distribution'),
          const SizedBox(height: 16),
          ..._buildTypeDistributionCharts(stats['typeDistribution']),
          
          const SizedBox(height: 24),
          
          // Ad Settings
          _buildSectionHeader('📱 Ad Settings'),
          const SizedBox(height: 16),
          _buildAdSettingsCard(stats['adSettings']),
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

  Widget _buildNewsCard(NewsItem newsItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF212121),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          if (newsItem.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                newsItem.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: newsItem.categoryColor.withOpacity(0.3),
                    child: Icon(
                      newsItem.typeIcon,
                      size: 50,
                      color: newsItem.categoryColor,
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: newsItem.categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: newsItem.categoryColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        newsItem.category,
                        style: TextStyle(
                          color: newsItem.categoryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            newsItem.typeIcon,
                            color: Colors.green,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            newsItem.typeLabel,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Premium Badge
                    if (newsItem.isPremium)
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
                
                const SizedBox(height: 12),
                
                // Title
                Text(
                  newsItem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                
                // Subtitle
                if (newsItem.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    newsItem.subtitle!,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Content Preview
                Text(
                  newsItem.contentPreview,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bottom Row
                Row(
                  children: [
                    // Author Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: newsItem.categoryColor,
                          child: Text(
                            newsItem.author[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          newsItem.author,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Read Time
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                      ),
                      child: Text(
                        newsItem.readTimeLabel,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Publish Date
                    Text(
                      newsItem.formattedPublishDate,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                // Tags
                if (newsItem.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: newsItem.tags.map((tag) {
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
                ],
                
                // Native Ad Section
                if (newsItem.hasAd) ...[
                  const SizedBox(height: 16),
                  _buildNativeAdCard(newsItem),
                ],
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openNewsUrl(newsItem),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Read Full Article'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[600]!),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showNewsDetails(newsItem),
                        icon: const Icon(Icons.info, size: 18),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    IconButton(
                      onPressed: () => _shareNews(newsItem),
                      icon: const Icon(Icons.share, color: Colors.blue),
                      tooltip: 'Share',
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

  Widget _buildNativeAdCard(NewsItem newsItem) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.ads_click,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sponsored Content',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            newsItem.adTitle ?? 'Sponsored',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          if (newsItem.adDescription != null) ...[
            const SizedBox(height: 4),
            Text(
              newsItem.adDescription!,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleAdClick(newsItem),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(newsItem.adCallToAction ?? 'Learn More'),
            ),
          ),
        ],
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
      final percentage = (_infoService.newsItems.length > 0) 
          ? (entry.value / _infoService.newsItems.length * 100).round()
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

  List<Widget> _buildTypeDistributionCharts(Map<String, dynamic> typeStats) {
    return typeStats.entries.map((entry) {
      final percentage = (_infoService.newsItems.length > 0) 
          ? (entry.value / _infoService.newsItems.length * 100).round()
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

  Widget _buildAdSettingsCard(Map<String, dynamic> adSettings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ad Configuration',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...adSettings.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '${entry.key}: ',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry.value.toString(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<NewsItem> _getFilteredNews() {
    List<NewsItem> filtered = _infoService.newsItems;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }
    
    if (_selectedType != 'All') {
      filtered = filtered.where((item) => item.type == _selectedType).toList();
    }
    
    return filtered;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'gaming':
        return Colors.purple;
      case 'productivity':
        return Colors.green;
      case 'entertainment':
        return Colors.orange;
      case 'lifestyle':
        return Colors.pink;
      case 'business':
        return Colors.teal;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _showNewsDetails(NewsItem newsItem) {
    // Mark as read
    _infoService.markNewsAsRead(newsItem.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          newsItem.title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category: ${newsItem.category}',
                style: TextStyle(color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${newsItem.typeLabel}',
                style: TextStyle(color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                'Author: ${newsItem.author}',
                style: TextStyle(color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                'Read Time: ${newsItem.readTimeLabel}',
                style: TextStyle(color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                'Published: ${newsItem.formattedPublishDate}',
                style: TextStyle(color: Colors.grey[300]),
              ),
              const SizedBox(height: 16),
              Text(
                'Content:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                newsItem.content,
                style: TextStyle(color: Colors.grey[300]),
              ),
              if (newsItem.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Tags:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: newsItem.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[700],
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                  )).toList(),
                ),
              ],
            ],
          ),
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

  void _shareNews(NewsItem newsItem) {
    // In a real app, you'd implement actual sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${newsItem.title}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleAdClick(NewsItem newsItem) {
    // In a real app, you'd track ad clicks and open the URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ad clicked: ${newsItem.adTitle ?? 'Sponsored content'}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _openNewsUrl(NewsItem newsItem) async {
    try {
      // Mark as read first
      await _infoService.markNewsAsRead(newsItem.id);
      
      // Get URL from metadata
      final url = newsItem.metadata['url'];
      
      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        
        if (await canLaunchUrl(uri)) {
          final success = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening: ${newsItem.title}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open the article. Please try again.'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot open: $url'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // No URL available, show details instead
        _showNewsDetails(newsItem);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening article: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
