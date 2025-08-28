import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/search_provider.dart';

/// Service for managing search providers and search functionality
class SearchProviderService {
  static final SearchProviderService _instance = SearchProviderService._internal();
  factory SearchProviderService() => _instance;
  SearchProviderService._internal();

  static const String _currentProviderKey = 'current_search_provider';
  static const String _customProvidersKey = 'custom_search_providers';

  List<SearchProvider> _searchProviders = [];
  SearchProvider? _currentProvider;
  bool _isInitialized = false;

  /// Get all available search providers
  List<SearchProvider> get searchProviders => List.unmodifiable(_searchProviders);

  /// Get currently active search provider
  SearchProvider? get currentProvider => _currentProvider;

  /// Get enabled search providers only
  List<SearchProvider> get enabledProviders => _searchProviders.where((p) => p.isEnabled).toList();

  /// Get search providers by category
  List<SearchProvider> getProvidersByCategory(String category) {
    return _searchProviders.where((p) => p.category == category).toList();
  }

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadBuiltInProviders();
      await _loadCustomProviders();
      await _loadCurrentProvider();
      _isInitialized = true;
      print('SearchProviderService initialized with ${_searchProviders.length} providers');
    } catch (e) {
      print('Error initializing SearchProviderService: $e');
      // Load default providers if initialization fails
      await _loadDefaultProviders();
    }
  }

  /// Load built-in search providers
  Future<void> _loadBuiltInProviders() async {
    _searchProviders = [
      SearchProvider(
        id: 'google',
        name: 'Google',
        description: 'World\'s most popular search engine',
        searchUrl: 'https://www.google.com/search?q={query}',
        primaryColor: const Color(0xFF4285F4),
        isDefault: true,
        category: 'web',
        metadata: {
          'suggestions': true,
          'autocomplete': true,
          'voice_search': true,
        },
      ),
      SearchProvider(
        id: 'bing',
        name: 'Bing',
        description: 'Microsoft\'s search engine with rewards',
        searchUrl: 'https://www.bing.com/search?q={query}',
        primaryColor: const Color(0xFF0078D4),
        category: 'web',
        metadata: {
          'suggestions': true,
          'autocomplete': true,
          'rewards': true,
        },
      ),
      SearchProvider(
        id: 'duckduckgo',
        name: 'DuckDuckGo',
        description: 'Privacy-focused search engine',
        searchUrl: 'https://duckduckgo.com/?q={query}',
        primaryColor: const Color(0xFFDE5833),
        category: 'web',
        metadata: {
          'privacy': true,
          'no_tracking': true,
          'suggestions': false,
        },
      ),
      SearchProvider(
        id: 'yahoo',
        name: 'Yahoo',
        description: 'Classic search engine with news',
        searchUrl: 'https://search.yahoo.com/search?p={query}',
        primaryColor: const Color(0xFF720E9E),
        category: 'web',
        metadata: {
          'news': true,
          'suggestions': true,
          'weather': true,
        },
      ),
      SearchProvider(
        id: 'youtube',
        name: 'YouTube',
        description: 'Search for videos and content',
        searchUrl: 'https://www.youtube.com/results?search_query={query}',
        primaryColor: const Color(0xFFFF0000),
        category: 'video',
        metadata: {
          'videos': true,
          'channels': true,
          'playlists': true,
        },
      ),
      SearchProvider(
        id: 'wikipedia',
        name: 'Wikipedia',
        description: 'Search encyclopedia articles',
        searchUrl: 'https://en.wikipedia.org/wiki/Special:Search?search={query}',
        primaryColor: const Color(0xFF000000),
        category: 'reference',
        metadata: {
          'encyclopedia': true,
          'academic': true,
          'multilingual': true,
        },
      ),
    ];
  }

  /// Load custom search providers from storage
  Future<void> _loadCustomProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customProvidersJson = prefs.getString(_customProvidersKey);

      if (customProvidersJson != null) {
        final List<dynamic> customProvidersList = json.decode(customProvidersJson);
        final customProviders = customProvidersList
            .map((json) => SearchProvider.fromMap(json))
            .toList();
        
        _searchProviders.addAll(customProviders);
      }
    } catch (e) {
      print('Error loading custom search providers: $e');
    }
  }

  /// Save custom search providers to storage
  Future<void> _saveCustomProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customProviders = _searchProviders.where((p) => !p.isDefault).toList();
      final String customProvidersJson = json.encode(customProviders.map((p) => p.toMap()).toList());
      await prefs.setString(_customProvidersKey, customProvidersJson);
    } catch (e) {
      print('Error saving custom search providers: $e');
    }
  }

  /// Load current search provider from storage
  Future<void> _loadCurrentProvider() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentId = prefs.getString(_currentProviderKey);
      
      if (currentId != null) {
        _currentProvider = _searchProviders.firstWhere(
          (p) => p.id == currentId,
          orElse: () => _searchProviders.firstWhere((p) => p.isDefault),
        );
      } else {
        _currentProvider = _searchProviders.firstWhere((p) => p.isDefault);
      }
    } catch (e) {
      print('Error loading current search provider: $e');
      _currentProvider = _searchProviders.first;
    }
  }

  /// Load default providers if initialization fails
  Future<void> _loadDefaultProviders() async {
    await _loadBuiltInProviders();
    _currentProvider = _searchProviders.first;
    _isInitialized = true;
  }

  /// Set current search provider
  Future<void> setCurrentProvider(String providerId) async {
    try {
      final provider = _searchProviders.firstWhere((p) => p.id == providerId);
      
      // Update current provider
      _currentProvider = provider;
      
      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentProviderKey, providerId);
      
      print('Current search provider set to: ${provider.name}');
    } catch (e) {
      print('Error setting current search provider: $e');
    }
  }

  /// Add custom search provider
  Future<bool> addCustomProvider({
    required String name,
    required String description,
    required String searchUrl,
    Color? primaryColor,
    String category = 'web',
  }) async {
    try {
      // Validate search URL
      if (!_isValidSearchUrl(searchUrl)) {
        throw Exception('Invalid search URL format. Use {query} as placeholder.');
      }

      // Check if provider already exists
      if (_searchProviders.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
        throw Exception('Search provider with this name already exists');
      }

      // Generate unique ID
      final String id = _generateId();

      // Create custom provider
      final customProvider = SearchProvider(
        id: id,
        name: name,
        description: description,
        searchUrl: searchUrl,
        primaryColor: primaryColor ?? Colors.blue,
        category: category,
        isDefault: false,
        isEnabled: true,
      );

      _searchProviders.add(customProvider);
      await _saveCustomProviders();

      print('Added custom search provider: $name');
      return true;
    } catch (e) {
      print('Error adding custom search provider: $e');
      return false;
    }
  }

  /// Remove custom search provider
  Future<bool> removeCustomProvider(String id) async {
    try {
      final provider = _searchProviders.firstWhere((p) => p.id == id);
      
      // Don't allow removing built-in providers
      if (provider.isDefault) {
        throw Exception('Cannot remove built-in search providers');
      }

      _searchProviders.removeWhere((p) => p.id == id);
      
      // If removed provider was current, switch to default
      if (_currentProvider?.id == id) {
        await setCurrentProvider(_searchProviders.firstWhere((p) => p.isDefault).id);
      }
      
      await _saveCustomProviders();

      print('Removed custom search provider: ${provider.name}');
      return true;
    } catch (e) {
      print('Error removing custom search provider: $e');
      return false;
    }
  }

  /// Toggle provider enabled status
  Future<void> toggleProviderStatus(String id) async {
    try {
      final index = _searchProviders.indexWhere((p) => p.id == id);
      if (index != -1) {
        final provider = _searchProviders[index];
        final updatedProvider = provider.copyWith(isEnabled: !provider.isEnabled);
        _searchProviders[index] = updatedProvider;
        
        // If disabled provider was current, switch to default
        if (!updatedProvider.isEnabled && _currentProvider?.id == id) {
          await setCurrentProvider(_searchProviders.firstWhere((p) => p.isEnabled && p.isDefault).id);
        }
        
        await _saveCustomProviders();
      }
    } catch (e) {
      print('Error toggling provider status: $e');
    }
  }

  /// Perform search with current provider
  Future<bool> performSearch(String query) async {
    if (_currentProvider == null || query.trim().isEmpty) {
      return false;
    }

    try {
      final searchUrl = _currentProvider!.getSearchUrlWithQuery(query.trim());
      final uri = Uri.parse(searchUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Error performing search: $e');
      return false;
    }
  }

  /// Get search suggestions (if supported by provider)
  List<String> getSearchSuggestions(String query) {
    if (_currentProvider == null || query.trim().isEmpty) {
      return [];
    }

    // For now, return basic suggestions
    // In a real app, you'd integrate with search provider APIs
    final suggestions = [
      '$query app',
      '$query download',
      '$query tutorial',
      '$query guide',
      '$query review',
    ];

    return suggestions.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
  }

  /// Validate search URL format
  bool _isValidSearchUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && url.contains('{query}');
    } catch (e) {
      return false;
    }
  }

  /// Generate unique ID for custom provider
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'search_${timestamp}_$random';
  }

  /// Get search provider statistics
  Map<String, dynamic> getSearchProviderStats() {
    final totalProviders = _searchProviders.length;
    final enabledProviders = _searchProviders.where((p) => p.isEnabled).length;
    final customProviders = _searchProviders.where((p) => !p.isDefault).length;
    final categories = _searchProviders.map((p) => p.category).toSet().toList();

    return {
      'totalProviders': totalProviders,
      'enabledProviders': enabledProviders,
      'customProviders': customProviders,
      'categories': categories,
      'currentProvider': _currentProvider?.name ?? 'None',
      'defaultProvider': _searchProviders.firstWhere((p) => p.isDefault).name,
    };
  }

  /// Reset to default search provider
  Future<void> resetToDefault() async {
    final defaultProvider = _searchProviders.firstWhere((p) => p.isDefault);
    await setCurrentProvider(defaultProvider.id);
  }

  /// Dispose resources
  void dispose() {
    _searchProviders.clear();
    _currentProvider = null;
    _isInitialized = false;
  }
}
