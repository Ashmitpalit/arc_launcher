import 'package:flutter/material.dart';
import '../models/app_recommendation.dart';
import '../services/app_recommendation_service.dart';
import '../utils/theme.dart';

class RecommendedAppsScreen extends StatefulWidget {
  const RecommendedAppsScreen({super.key});

  @override
  State<RecommendedAppsScreen> createState() => _RecommendedAppsScreenState();
}

class _RecommendedAppsScreenState extends State<RecommendedAppsScreen>
    with SingleTickerProviderStateMixin {
  final AppRecommendationService _recommendationService = AppRecommendationService();
  late TabController _tabController;
  
  bool _isLoading = true;
  String _selectedCategory = 'All';
  List<String> _availableCategories = ['All'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeRecommendations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeRecommendations() async {
    setState(() => _isLoading = true);
    try {
      await _recommendationService.initialize();
      
      // Get unique categories
      final categories = _recommendationService.recommendations
          .map((rec) => rec.category)
          .toSet()
          .toList();
      categories.sort();
      _availableCategories = ['All', ...categories];
      
    } catch (e) {
      print('Error initializing recommendations: $e');
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
          'Recommended Apps',
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
            onPressed: _initializeRecommendations,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Top Picks'),
            Tab(text: 'Categories'),
            Tab(text: 'Trending'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTopPicksTab(),
                _buildCategoriesTab(),
                _buildTrendingTab(),
              ],
            ),
    );
  }

  Widget _buildTopPicksTab() {
    final topRecommendations = _recommendationService.topRecommendations;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Top Recommendations'),
          const SizedBox(height: 16),
          ...topRecommendations.map((rec) => _buildRecommendationCard(rec)),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        // Category Filter
        Container(
          padding: const EdgeInsets.all(16),
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
        
        // Filtered Recommendations
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('${_selectedCategory} Apps'),
                const SizedBox(height: 16),
                ..._getFilteredRecommendations().map((rec) => _buildRecommendationCard(rec)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingTab() {
    final trendingApps = _recommendationService.getTrendingApps(limit: 10);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Trending Now'),
          const SizedBox(height: 16),
          ...trendingApps.map((rec) => _buildRecommendationCard(rec)),
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

  Widget _buildRecommendationCard(AppRecommendation recommendation) {
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
                // App Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(recommendation.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(recommendation.category),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // App Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recommendation.appName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (recommendation.isPremium)
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
                      Text(
                        recommendation.category,
                        style: TextStyle(
                          color: _getCategoryColor(recommendation.category),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendation.metadata['rating']?.toString() ?? '4.5',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            recommendation.metadata['downloads']?.toString() ?? '1M+',
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
              recommendation.description ?? 'No description available',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Recommendation Reason
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.recommendationReason,
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bottom Row
            Row(
              children: [
                // Confidence Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(recommendation.confidenceScore).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getConfidenceColor(recommendation.confidenceScore).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    recommendation.confidencePercentage,
                    style: TextStyle(
                      color: _getConfidenceColor(recommendation.confidenceScore),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Priority
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Text(
                    recommendation.priorityLabel,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Action Buttons
                if (!recommendation.isInstalled) ...[
                  TextButton(
                    onPressed: () => _showAppDetails(recommendation),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Details'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _installApp(recommendation),
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

  List<AppRecommendation> _getFilteredRecommendations() {
    if (_selectedCategory == 'All') {
      return _recommendationService.recommendations;
    }
    return _recommendationService.getRecommendationsByCategory(_selectedCategory);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Productivity':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Social':
        return Colors.green;
      case 'Utility':
        return Colors.orange;
      case 'Health & Fitness':
        return Colors.red;
      case 'Education':
        return Colors.teal;
      case 'Photography':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Productivity':
        return Icons.work;
      case 'Entertainment':
        return Icons.movie;
      case 'Social':
        return Icons.people;
      case 'Utility':
        return Icons.build;
      case 'Health & Fitness':
        return Icons.fitness_center;
      case 'Education':
        return Icons.school;
      case 'Photography':
        return Icons.camera_alt;
      default:
        return Icons.apps;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _showAppDetails(AppRecommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          recommendation.appName,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${recommendation.category}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${recommendation.confidencePercentage}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Priority: ${recommendation.priorityLabel}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${recommendation.recommendationReason}',
              style: TextStyle(color: Colors.grey[300]),
            ),
            if (recommendation.metadata.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'App Details:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...recommendation.metadata.entries.map((entry) => Text(
                '${entry.key}: ${entry.value}',
                style: TextStyle(color: Colors.grey[300]),
              )),
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

  Future<void> _installApp(AppRecommendation recommendation) async {
    try {
      // Mark as viewed
      await _recommendationService.markRecommendationViewed(recommendation.id);
      
      // Show installation dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Install ${recommendation.appName}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'This will open the Google Play Store to install the app.',
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
                  _openPlayStore(recommendation.packageName);
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
      print('Error installing app: $e');
    }
  }

  Future<void> _openPlayStore(String packageName) async {
    try {
      final success = await _recommendationService.openPlayStore(packageName);
      
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
