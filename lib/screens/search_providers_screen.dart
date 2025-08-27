import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';

class SearchProvider {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String searchUrl;
  final bool isDefault;
  final bool isCustom;
  final String? customName;

  SearchProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.searchUrl,
    this.isDefault = false,
    this.isCustom = false,
    this.customName,
  });
}

class SearchProvidersScreen extends StatefulWidget {
  const SearchProvidersScreen({super.key});

  @override
  State<SearchProvidersScreen> createState() => _SearchProvidersScreenState();
}

class _SearchProvidersScreenState extends State<SearchProvidersScreen> {
  String _selectedProvider = 'google';
  final TextEditingController _customSearchController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();

  final List<SearchProvider> _searchProviders = [
    SearchProvider(
      id: 'google',
      name: 'Google',
      description: 'The world\'s most popular search engine',
      logoUrl: 'https://via.placeholder.com/60x60/4285f4/ffffff?text=G',
      searchUrl: 'https://www.google.com/search?q=',
      isDefault: true,
    ),
    SearchProvider(
      id: 'bing',
      name: 'Bing',
      description: 'Microsoft\'s search engine with rewards',
      logoUrl: 'https://via.placeholder.com/60x60/0078d4/ffffff?text=B',
      searchUrl: 'https://www.bing.com/search?q=',
    ),
    SearchProvider(
      id: 'duckduckgo',
      name: 'DuckDuckGo',
      description: 'Privacy-focused search engine',
      logoUrl: 'https://via.placeholder.com/60x60/de5833/ffffff?text=D',
      searchUrl: 'https://duckduckgo.com/?q=',
    ),
    SearchProvider(
      id: 'yahoo',
      name: 'Yahoo',
      description: 'Classic search and news portal',
      logoUrl: 'https://via.placeholder.com/60x60/720e9e/ffffff?text=Y',
      searchUrl: 'https://search.yahoo.com/search?p=',
    ),
    SearchProvider(
      id: 'ecosia',
      name: 'Ecosia',
      description: 'Search engine that plants trees',
      logoUrl: 'https://via.placeholder.com/60x60/2ecc71/ffffff?text=E',
      searchUrl: 'https://www.ecosia.org/search?q=',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProvider();
  }

  void _loadCurrentProvider() {
    // Load from SharedPreferences or other storage
    // For now, use the default
    _selectedProvider = 'google';
  }

  void _setDefaultProvider(String providerId) {
    setState(() {
      _selectedProvider = providerId;
    });
    
    // Save to SharedPreferences or other storage
    // This would persist the user's choice
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getProviderById(providerId)?.name} is now your default search engine'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  SearchProvider? _getProviderById(String id) {
    try {
      return _searchProviders.firstWhere((provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  void _addCustomProvider() {
    if (_customSearchController.text.isEmpty || _customNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final customProvider = SearchProvider(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _customNameController.text,
      description: 'Custom search provider',
      logoUrl: 'https://via.placeholder.com/60x60/95a5a6/ffffff?text=C',
      searchUrl: _customSearchController.text,
      isCustom: true,
      customName: _customNameController.text,
    );

    setState(() {
      _searchProviders.add(customProvider);
    });

    _customSearchController.clear();
    _customNameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${customProvider.name} added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testSearchProvider(SearchProvider provider) async {
    final testQuery = 'test search';
    final searchUrl = '${provider.searchUrl}$testQuery';
    
    try {
      if (await canLaunchUrl(Uri.parse(searchUrl))) {
        await launchUrl(Uri.parse(searchUrl));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open search URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening search URL'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                'Search Providers',
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

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Choose Your Default Search Engine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your preferred search engine for quick searches',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // Search Providers List
                ..._searchProviders.map((provider) => _buildProviderCard(provider)),

                const SizedBox(height: 32),

                // Add Custom Provider Section
                _buildCustomProviderSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(SearchProvider provider) {
    final isSelected = provider.id == _selectedProvider;
    
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
            imageUrl: provider.logoUrl,
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
              child: const Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
        title: Text(
          provider.name,
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
            Text(
              provider.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _testSearchProvider(provider),
                  child: const Text(
                    'Test',
                    style: TextStyle(color: AppTheme.accentColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: AppTheme.accentColor,
                size: 32,
              )
            : TextButton(
                onPressed: () => _setDefaultProvider(provider.id),
                child: const Text(
                  'Set Default',
                  style: TextStyle(color: AppTheme.accentColor),
                ),
              ),
      ),
    );
  }

  Widget _buildCustomProviderSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Custom Search Provider',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add your own search engine with custom search URL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Custom Name Input
          TextField(
            controller: _customNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Provider Name',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Search URL Input
          TextField(
            controller: _customSearchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Search URL (use {query} for search term)',
              labelStyle: const TextStyle(color: Colors.white70),
              hintText: 'https://example.com/search?q={query}',
              hintStyle: const TextStyle(color: Colors.white30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Add Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _addCustomProvider,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Custom Provider',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
