import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/enhanced_launcher_provider.dart';
import '../models/web_app_shortcut.dart';
import '../models/app_shortcut.dart';
import '../utils/theme.dart';

class DynamicShortcutsScreen extends StatefulWidget {
  const DynamicShortcutsScreen({super.key});

  @override
  State<DynamicShortcutsScreen> createState() => _DynamicShortcutsScreenState();
}

class _DynamicShortcutsScreenState extends State<DynamicShortcutsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<EnhancedLauncherProvider>();
    await provider.refreshRecommendations();
    
    setState(() => _isLoading = false);
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
          'Dynamic Shortcuts',
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
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Web Shortcuts'),
            Tab(text: 'Recommended Apps'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWebShortcutsTab(),
          _buildRecommendedAppsTab(),
        ],
      ),
    );
  }

  Widget _buildWebShortcutsTab() {
    return Consumer<EnhancedLauncherProvider>(
      builder: (context, provider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final shortcuts = provider.dynamicShortcuts;
        
        if (shortcuts.isEmpty) {
          return _buildEmptyState(
            'No Dynamic Shortcuts',
            'Shortcuts will appear here based on your usage patterns and time of day.',
            Icons.link,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shortcuts.length,
            itemBuilder: (context, index) {
              final shortcut = shortcuts[index];
              return _buildShortcutCard(shortcut, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecommendedAppsTab() {
    return Consumer<EnhancedLauncherProvider>(
      builder: (context, provider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final apps = provider.recommendedApps;
        
        if (apps.isEmpty) {
          return _buildEmptyState(
            'No Recommendations',
            'App recommendations will appear here based on your preferences.',
            Icons.apps,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _buildAppCard(app, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildShortcutCard(WebAppShortcut shortcut, EnhancedLauncherProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => _launchShortcut(shortcut, provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: shortcut.iconUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Icon(
                      Icons.link,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.link,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortcut.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortcut.category,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    if (shortcut.useCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Used ${shortcut.useCount} times',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  if (shortcut.isPinned)
                    Icon(
                      Icons.push_pin,
                      color: Colors.blue,
                      size: 20,
                    ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.open_in_new,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppCard(AppShortcut app, EnhancedLauncherProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: InkWell(
        onTap: () => _openAppDetails(app, provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: 'https://via.placeholder.com/64x64/${app.color.value.toRadixString(16).substring(2)}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Icon(
                      Icons.android,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.android,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          app.category ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        Text(
                          '4.5',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '1M+',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Free',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  if (true)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
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

  Future<void> _launchShortcut(WebAppShortcut shortcut, EnhancedLauncherProvider provider) async {
    try {
      // Track usage
      await provider.trackShortcutUsage(shortcut.id);
      
      // Launch URL
      final uri = Uri.parse(shortcut.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch shortcut');
      }
    } catch (e) {
      _showErrorSnackBar('Error launching shortcut: $e');
    }
  }

  void _openAppDetails(AppShortcut app, EnhancedLauncherProvider provider) {
    // Track recommendation click
    provider.trackAppRecommendationClick(app.packageName);
    
    // Show app details or open Play Store
    _showAppDetailsDialog(app);
  }

  void _showAppDetailsDialog(AppShortcut app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          app.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A great app for your needs',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Category', app.category ?? 'Unknown'),
            _buildDetailRow('Rating', '4.5/5.0'),
            _buildDetailRow('Installs', '1M+'),
            _buildDetailRow('Price', 'Free'),
            _buildDetailRow('Developer', 'Arc Launcher Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openPlayStore(app.packageName);
            },
            child: const Text('View on Play Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _openPlayStore(String packageName) async {
    try {
      final uri = Uri.parse('market://details?id=$packageName');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to web Play Store
        final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showErrorSnackBar('Could not open Play Store');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
