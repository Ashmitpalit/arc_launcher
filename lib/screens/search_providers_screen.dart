import 'package:flutter/material.dart';
import '../models/search_provider.dart';
import '../services/search_provider_service.dart';
import '../utils/theme.dart';

class SearchProvidersScreen extends StatefulWidget {
  const SearchProvidersScreen({super.key});

  @override
  State<SearchProvidersScreen> createState() => _SearchProvidersScreenState();
}

class _SearchProvidersScreenState extends State<SearchProvidersScreen> {
  final SearchProviderService _searchProviderService = SearchProviderService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSearchProviders();
  }

  Future<void> _initializeSearchProviders() async {
    setState(() => _isLoading = true);
    try {
      await _searchProviderService.initialize();
    } catch (e) {
      print('Error initializing search providers: $e');
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
          'Search Providers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSearchProvidersList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomProviderDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchProvidersList() {
    final currentProvider = _searchProviderService.currentProvider;
    final allProviders = _searchProviderService.searchProviders;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentProvider != null) ...[
            _buildCurrentProviderSection(currentProvider),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader('Available Search Providers'),
          const SizedBox(height: 16),
          ...allProviders.map((provider) => _buildProviderTile(provider)),
        ],
      ),
    );
  }

  Widget _buildCurrentProviderSection(SearchProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Search Provider',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF212121),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: provider.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildProviderTile(SearchProvider provider) {
    final isCurrent = _searchProviderService.currentProvider?.id == provider.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF212121),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: provider.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.search,
            color: Colors.white,
            size: 25,
          ),
        ),
        title: Text(
          provider.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          provider.description,
          style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
        ),
        trailing: isCurrent
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : TextButton(
                onPressed: () => _selectProvider(provider),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Use'),
              ),
        onTap: isCurrent ? null : () => _selectProvider(provider),
      ),
    );
  }

  Future<void> _selectProvider(SearchProvider provider) async {
    try {
      await _searchProviderService.setCurrentProvider(provider.id);
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${provider.name} is now your default search provider'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set search provider: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddCustomProviderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add Custom Search Provider',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Custom search provider feature is coming soon! You can currently use the built-in search providers.',
          style: TextStyle(color: Color(0xFFBDBDBD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
