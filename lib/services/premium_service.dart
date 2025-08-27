import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/analytics_service.dart';
import 'dart:async';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  // Premium features
  bool _isPremium = false;
  DateTime? _premiumExpiry;
  String _premiumPlan = '';
  List<String> _activeFeatures = [];
  
  // Subscription products
  final List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  
  // Premium themes
  final List<PremiumTheme> _premiumThemes = [];
  final List<PremiumIconPack> _premiumIconPacks = [];
  final List<PremiumWidget> _premiumWidgets = [];
  
  // Stream controllers
  final StreamController<bool> _premiumStatusController = StreamController<bool>.broadcast();
  final StreamController<List<String>> _featuresController = StreamController<List<String>>.broadcast();

  // Initialize the service
  Future<void> initialize() async {
    try {
      await _loadPremiumStatus();
      await _loadPremiumContent();
      await _initializeInAppPurchase();
      _setupPremiumFeatures();
    } catch (e) {
      print('Failed to initialize premium service: $e');
    }
  }

  // Load premium status
  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool('is_premium') ?? false;
      final expiryString = prefs.getString('premium_expiry');
      if (expiryString != null) {
        _premiumExpiry = DateTime.parse(expiryString);
      }
      _premiumPlan = prefs.getString('premium_plan') ?? '';
      _activeFeatures = prefs.getStringList('active_features') ?? [];
      
      // Check if premium has expired
      if (_isPremium && _premiumExpiry != null && DateTime.now().isAfter(_premiumExpiry!)) {
        await _expirePremium();
      }
    } catch (e) {
      print('Failed to load premium status: $e');
    }
  }

  // Save premium status
  Future<void> _savePremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', _isPremium);
      if (_premiumExpiry != null) {
        await prefs.setString('premium_expiry', _premiumExpiry!.toIso8601String());
      }
      await prefs.setString('premium_plan', _premiumPlan);
      await prefs.setStringList('active_features', _activeFeatures);
    } catch (e) {
      print('Failed to save premium status: $e');
    }
  }

  // Load premium content
  Future<void> _loadPremiumContent() async {
    // Premium themes
    _premiumThemes.addAll([
      PremiumTheme(
        id: 'dark_pro',
        name: 'Dark Pro',
        description: 'Advanced dark theme with custom colors',
        previewImage: 'https://via.placeholder.com/300x600/1a1a2e/ffffff?text=Dark+Pro',
        isPremium: true,
        price: 2.99,
        features: ['Custom colors', 'Advanced animations', 'Premium icons'],
      ),
      PremiumTheme(
        id: 'neon_future',
        name: 'Neon Future',
        description: 'Cyberpunk-inspired neon theme',
        previewImage: 'https://via.placeholder.com/300x600/00ff88/000000?text=Neon+Future',
        isPremium: true,
        price: 3.99,
        features: ['Neon effects', 'Animated backgrounds', 'Custom fonts'],
      ),
      PremiumTheme(
        id: 'minimal_zen',
        name: 'Minimal Zen',
        description: 'Clean and minimalist design',
        previewImage: 'https://via.placeholder.com/300x600/f5f5f5/333333?text=Minimal+Zen',
        isPremium: true,
        price: 1.99,
        features: ['Clean design', 'Focus mode', 'Distraction-free'],
      ),
    ]);

    // Premium icon packs
    _premiumIconPacks.addAll([
      PremiumIconPack(
        id: 'material_3',
        name: 'Material 3',
        description: 'Latest Material Design icons',
        previewImage: 'https://via.placeholder.com/300x600/6750a4/ffffff?text=Material+3',
        isPremium: true,
        price: 1.99,
        iconCount: 2000,
      ),
      PremiumIconPack(
        id: 'ios_style',
        name: 'iOS Style',
        description: 'Apple-inspired icon design',
        previewImage: 'https://via.placeholder.com/300x600/007aff/ffffff?text=iOS+Style',
        isPremium: true,
        price: 2.99,
        iconCount: 1500,
      ),
      PremiumIconPack(
        id: 'custom_icons',
        name: 'Custom Icons',
        description: 'Personalized icon designs',
        previewImage: 'https://via.placeholder.com/300x600/ff6b6b/ffffff?text=Custom+Icons',
        isPremium: true,
        price: 4.99,
        iconCount: 1000,
      ),
    ]);

    // Premium widgets
    _premiumWidgets.addAll([
      PremiumWidget(
        id: 'weather_pro',
        name: 'Weather Pro',
        description: 'Advanced weather widget with forecasts',
        previewImage: 'https://via.placeholder.com/300x600/87ceeb/ffffff?text=Weather+Pro',
        isPremium: true,
        price: 0.99,
        features: ['7-day forecast', 'Multiple locations', 'Weather alerts'],
      ),
      PremiumWidget(
        id: 'calendar_pro',
        name: 'Calendar Pro',
        description: 'Enhanced calendar widget',
        previewImage: 'https://via.placeholder.com/300x600/ff8c00/ffffff?text=Calendar+Pro',
        isPremium: true,
        price: 0.99,
        features: ['Event management', 'Reminders', 'Sync with Google'],
      ),
      PremiumWidget(
        id: 'battery_pro',
        name: 'Battery Pro',
        description: 'Advanced battery monitoring',
        previewImage: 'https://via.placeholder.com/300x600/32cd32/ffffff?text=Battery+Pro',
        isPremium: true,
        price: 0.99,
        features: ['Battery health', 'Charging time', 'Power saving tips'],
      ),
    ]);
  }

  // Initialize in-app purchase
  Future<void> _initializeInAppPurchase() async {
    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        print('In-app purchases not available');
        return;
      }

      // Load products
      final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails({
        'premium_monthly',
        'premium_yearly',
        'premium_lifetime',
        'theme_dark_pro',
        'theme_neon_future',
        'theme_minimal_zen',
        'icons_material_3',
        'icons_ios_style',
        'icons_custom',
        'widget_weather_pro',
        'widget_calendar_pro',
        'widget_battery_pro',
      });

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      _products.addAll(response.productDetails);

      // Listen to purchase updates
      InAppPurchase.instance.purchaseStream.listen(_onPurchaseUpdate);
    } catch (e) {
      print('Failed to initialize in-app purchase: $e');
    }
  }

  // Setup premium features
  void _setupPremiumFeatures() {
    if (_isPremium) {
      _activeFeatures.addAll([
        'premium_themes',
        'premium_icons',
        'premium_widgets',
        'advanced_gestures',
        'custom_animations',
        'priority_support',
        'ad_free',
        'cloud_backup',
      ]);
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _handlePendingPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handleFailedPurchase(purchaseDetails);
      }
    }
  }

  // Handle pending purchase
  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase pending: ${purchaseDetails.productID}');
  }

  // Handle successful purchase
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    print('Purchase successful: ${purchaseDetails.productID}');
    
    try {
      await _processPurchase(purchaseDetails.productID);
      await _savePremiumStatus();
      _notifyPremiumStatusChange();
      
      // Log analytics
      AnalyticsService().logEvent('premium_purchase', {
        'product_id': purchaseDetails.productID,
        'purchase_time': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to process purchase: $e');
    }
  }

  // Handle failed purchase
  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    print('Purchase failed: ${purchaseDetails.productID}');
    
    AnalyticsService().logEvent('premium_purchase_failed', {
      'product_id': purchaseDetails.productID,
      'error': purchaseDetails.error?.message ?? 'Unknown error',
    });
  }

  // Process purchase
  Future<void> _processPurchase(String productId) async {
    switch (productId) {
      case 'premium_monthly':
        await _activatePremium(30);
        break;
      case 'premium_yearly':
        await _activatePremium(365);
        break;
      case 'premium_lifetime':
        await _activatePremium(-1); // -1 for lifetime
        break;
      default:
        await _activateFeature(productId);
        break;
    }
  }

  // Activate premium
  Future<void> _activatePremium(int days) async {
    _isPremium = true;
    if (days > 0) {
      _premiumExpiry = DateTime.now().add(Duration(days: days));
    } else {
      _premiumExpiry = null; // Lifetime
    }
    
    _setupPremiumFeatures();
    _notifyPremiumStatusChange();
  }

  // Activate specific feature
  Future<void> _activateFeature(String productId) async {
    // Map product IDs to features
    final featureMap = {
      'theme_dark_pro': 'theme_dark_pro',
      'theme_neon_future': 'theme_neon_future',
      'theme_minimal_zen': 'theme_minimal_zen',
      'icons_material_3': 'icons_material_3',
      'icons_ios_style': 'icons_ios_style',
      'icons_custom': 'icons_custom',
      'widget_weather_pro': 'widget_weather_pro',
      'widget_calendar_pro': 'widget_calendar_pro',
      'widget_battery_pro': 'widget_battery_pro',
    };
    
    final feature = featureMap[productId];
    if (feature != null && !_activeFeatures.contains(feature)) {
      _activeFeatures.add(feature);
      _notifyFeaturesChange();
    }
  }

  // Expire premium
  Future<void> _expirePremium() async {
    _isPremium = false;
    _premiumExpiry = null;
    _premiumPlan = '';
    _activeFeatures.clear();
    
    await _savePremiumStatus();
    _notifyPremiumStatusChange();
    _notifyFeaturesChange();
  }

  // Check if feature is available
  bool isFeatureAvailable(String feature) {
    if (_isPremium) return true;
    return _activeFeatures.contains(feature);
  }

  // Check if theme is available
  bool isThemeAvailable(String themeId) {
    if (_isPremium) return true;
    return _activeFeatures.contains('theme_$themeId');
  }

  // Check if icon pack is available
  bool isIconPackAvailable(String packId) {
    if (_isPremium) return true;
    return _activeFeatures.contains('icons_$packId');
  }

  // Check if widget is available
  bool isWidgetAvailable(String widgetId) {
    if (_isPremium) return true;
    return _activeFeatures.contains('widget_$widgetId');
  }

  // Get premium themes
  List<PremiumTheme> getPremiumThemes() {
    return List.unmodifiable(_premiumThemes);
  }

  // Get premium icon packs
  List<PremiumIconPack> getPremiumIconPacks() {
    return List.unmodifiable(_premiumIconPacks);
  }

  // Get premium widgets
  List<PremiumWidget> getPremiumWidgets() {
    return List.unmodifiable(_premiumWidgets);
  }

  // Get available products
  List<ProductDetails> getProducts() {
    return List.unmodifiable(_products);
  }

  // Purchase product
  Future<void> purchaseProduct(ProductDetails product) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      if (product.id.startsWith('premium_')) {
        await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      print('Failed to purchase product: $e');
      rethrow;
    }
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      print('Failed to restore purchases: $e');
      rethrow;
    }
  }

  // Notify premium status change
  void _notifyPremiumStatusChange() {
    _premiumStatusController.add(_isPremium);
  }

  // Notify features change
  void _notifyFeaturesChange() {
    _featuresController.add(List.unmodifiable(_activeFeatures));
  }

  // Stream for premium status changes
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;
  
  // Stream for features changes
  Stream<List<String>> get featuresStream => _featuresController.stream;

  // Get premium status
  bool get isPremium => _isPremium;
  
  // Get premium expiry
  DateTime? get premiumExpiry => _premiumExpiry;
  
  // Get premium plan
  String get premiumPlan => _premiumPlan;
  
  // Get active features
  List<String> get activeFeatures => List.unmodifiable(_activeFeatures);

  // Dispose resources
  void dispose() {
    _premiumStatusController.close();
    _featuresController.close();
  }
}

// Premium theme model
class PremiumTheme {
  final String id;
  final String name;
  final String description;
  final String previewImage;
  final bool isPremium;
  final double price;
  final List<String> features;

  PremiumTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.isPremium,
    required this.price,
    required this.features,
  });

  factory PremiumTheme.fromMap(Map<String, dynamic> map) {
    return PremiumTheme(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      previewImage: map['previewImage'] ?? '',
      isPremium: map['isPremium'] ?? false,
      price: (map['price'] ?? 0.0).toDouble(),
      features: List<String>.from(map['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'previewImage': previewImage,
      'isPremium': isPremium,
      'price': price,
      'features': features,
    };
  }
}

// Premium icon pack model
class PremiumIconPack {
  final String id;
  final String name;
  final String description;
  final String previewImage;
  final bool isPremium;
  final double price;
  final int iconCount;

  PremiumIconPack({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.isPremium,
    required this.price,
    required this.iconCount,
  });

  factory PremiumIconPack.fromMap(Map<String, dynamic> map) {
    return PremiumIconPack(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      previewImage: map['previewImage'] ?? '',
      isPremium: map['isPremium'] ?? false,
      price: (map['price'] ?? 0.0).toDouble(),
      iconCount: map['iconCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'previewImage': previewImage,
      'isPremium': isPremium,
      'price': price,
      'iconCount': iconCount,
    };
  }
}

// Premium widget model
class PremiumWidget {
  final String id;
  final String name;
  final String description;
  final String previewImage;
  final bool isPremium;
  final double price;
  final List<String> features;

  PremiumWidget({
    required this.id,
    required this.name,
    required this.description,
    required this.previewImage,
    required this.isPremium,
    required this.price,
    required this.features,
  });

  factory PremiumWidget.fromMap(Map<String, dynamic> map) {
    return PremiumWidget(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      previewImage: map['previewImage'] ?? '',
      isPremium: map['isPremium'] ?? false,
      price: (map['price'] ?? 0.0).toDouble(),
      features: List<String>.from(map['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'previewImage': previewImage,
      'isPremium': isPremium,
      'price': price,
      'features': features,
    };
  }
}
