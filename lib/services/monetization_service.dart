import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';  // Temporarily disabled
import 'package:shared_preferences/shared_preferences.dart';
import 'usage_stats_service.dart';

class MonetizationService {
  static final MonetizationService _instance = MonetizationService._internal();
  factory MonetizationService() => _instance;
  MonetizationService._internal();

  // Temporarily disabled AdMob features for testing
  // Ad units (replace with your actual ad unit IDs)
  // static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  // static const String _nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110'; // Test ID
  // static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  // Ad instances - temporarily disabled
  // InterstitialAd? _interstitialAd;
  // NativeAd? _nativeAd;
  // RewardedAd? _rewardedAd;

  // Configuration
  bool _adsEnabled = false; // Temporarily disabled
  int _interstitialFrequency = 3; // Show every 3 app opens
  int _appOpenCount = 0;
  DateTime? _lastAdShown;
  
  // Usage-based ad caps
  final UsageStatsService _usageStatsService = UsageStatsService();
  bool _useUsageBasedCaps = true;
  int _dailyUsageLimitMinutes = 240; // 4 hours
  int _interstitialCapMinutes = 30; // Show ads after 30 min usage

  // Callbacks - removed unused fields
  // Function()? _onAdClosed;
  // Function()? _onAdFailed;
  // Function()? _onRewardEarned;

  // Initialize the service
  Future<void> initialize() async {
    try {
      // Temporarily disabled AdMob initialization
      // await MobileAds.instance.initialize();
      await _loadSettings();
      // await _preloadAds(); // Temporarily disabled
      print('Monetization service initialized (AdMob temporarily disabled)');
    } catch (e) {
      print('Failed to initialize monetization service: $e');
    }
  }

  // Load user settings
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _adsEnabled = prefs.getBool('ads_enabled') ?? false; // Default to false for now
      _interstitialFrequency = prefs.getInt('interstitial_frequency') ?? 3;
      _appOpenCount = prefs.getInt('app_open_count') ?? 0;
      final lastAdTimestamp = prefs.getInt('last_ad_shown');
      if (lastAdTimestamp != null) {
        _lastAdShown = DateTime.fromMillisecondsSinceEpoch(lastAdTimestamp);
      }
    } catch (e) {
      print('Failed to load monetization settings: $e');
    }
  }

  // Save settings
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ads_enabled', _adsEnabled);
      await prefs.setInt('interstitial_frequency', _interstitialFrequency);
      await prefs.setInt('app_open_count', _appOpenCount);
      if (_lastAdShown != null) {
        await prefs.setInt('last_ad_shown', _lastAdShown!.millisecondsSinceEpoch);
      }
    } catch (e) {
      print('Failed to save monetization settings: $e');
    }
  }

  // Preload ads - temporarily disabled
  // Future<void> _preloadAds() async {
  //   if (!_adsEnabled) return;

  //   // Temporarily disabled AdMob ad loading
  //   // await _loadInterstitialAd();
  //   // await _loadNativeAd();
  //   // await _loadRewardedAd();
  //   print('Ad preloading temporarily disabled');
  // }

  // Load interstitial ad - temporarily disabled
  // Future<void> _loadInterstitialAd() async {
  //   try {
  //     // Temporarily disabled AdMob interstitial ad loading
  //     print('Interstitial ad loading temporarily disabled');
  //   } catch (e) {
  //     print('Failed to load interstitial ad: $e');
  //   }
  // }

  // Load native ad - temporarily disabled
  // Future<void> _loadNativeAd() async {
  //   try {
  //     // Temporarily disabled AdMob native ad loading
  //     print('Native ad loading temporarily disabled');
  //   } catch (e) {
  //     print('Failed to load native ad: $e');
  //   }
  // }

  // Load rewarded ad - temporarily disabled
  // Future<void> _loadRewardedAd() async {
  //   try {
  //     // Temporarily disabled AdMob rewarded ad loading
  //     print('Rewarded ad loading temporarily disabled');
  //   } catch (e) {
  //     print('Failed to load rewarded ad: $e');
  //   }
  // }

  // Setup interstitial callbacks - temporarily disabled
  // void _setupInterstitialCallbacks() {
  //   // Temporarily disabled AdMob callbacks
  //   print('Interstitial callbacks temporarily disabled');
  // }

  // Setup rewarded callbacks - temporarily disabled
  // void _setupRewardedCallbacks() {
  //   // Temporarily disabled AdMob callbacks
  //   print('Rewarded callbacks temporarily disabled');
  // }

  // Show interstitial ad - temporarily disabled
  Future<bool> showInterstitialAd({
    Function()? onAdClosed,
    Function()? onAdFailed,
  }) async {
    // Temporarily disabled AdMob functionality
    print('Interstitial ad showing temporarily disabled');
    return false;
  }

  // Get native ad widget - temporarily disabled
  Widget? getNativeAd() {
    // Temporarily disabled AdMob functionality
    print('Native ad widget temporarily disabled');
    return null;
  }

  // Show rewarded ad - temporarily disabled
  Future<bool> showRewardedAd({
    Function()? onAdClosed,
    Function()? onAdFailed,
    Function()? onRewardEarned,
  }) async {
    // Temporarily disabled AdMob functionality
    print('Rewarded ad showing temporarily disabled');
    return false;
  }

  // Track app open
  Future<void> trackAppOpen() async {
    _appOpenCount++;
    await _saveSettings();

    // Temporarily disabled AdMob app open tracking
    // if (_adsEnabled && _shouldShowInterstitialAd()) {
    //   showInterstitialAd();
    // }
    print('App open tracked (ads temporarily disabled)');
  }

  // Check if should show interstitial ad - temporarily disabled
  // bool _shouldShowInterstitialAd() {
  //   if (!_adsEnabled) return false;
  //   if (_lastAdShown == null) return true;
  //   
  //   final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
  //   return timeSinceLastAd.inMinutes >= _interstitialFrequency;
  // }

  // Update settings
  Future<void> updateSettings({
    bool? adsEnabled,
    int? interstitialFrequency,
  }) async {
    if (adsEnabled != null) _adsEnabled = adsEnabled;
    if (interstitialFrequency != null) _interstitialFrequency = interstitialFrequency;
    await _saveSettings();
  }

  // Dispose resources
  void dispose() {
    // Temporarily disabled AdMob cleanup
    // _interstitialAd?.dispose();
    // _nativeAd?.dispose();
    // _rewardedAd?.dispose();
    
    // _interstitialAd = null;
    // _nativeAd = null;
    // _rewardedAd = null;
    print('Monetization service disposed (AdMob cleanup temporarily disabled)');
  }

  // Getters
  bool get adsEnabled => _adsEnabled;
  int get interstitialFrequency => _interstitialFrequency;
  int get appOpenCount => _appOpenCount;
  DateTime? get lastAdShown => _lastAdShown;

  // Ad availability - temporarily disabled
  bool get hasInterstitialAd => false; // _interstitialAd != null;
  bool get hasNativeAd => false; // _nativeAd != null;
  bool get hasRewardedAd => false; // _rewardedAd != null;

  // Get monetization settings
  Map<String, dynamic> getMonetizationSettings() {
    return {
      'adsEnabled': _adsEnabled,
      'interstitialFrequency': _interstitialFrequency,
      'appOpenCount': _appOpenCount,
      'lastAdShown': _lastAdShown?.toIso8601String(),
      'useUsageBasedCaps': _useUsageBasedCaps,
      'dailyUsageLimitMinutes': _dailyUsageLimitMinutes,
      'interstitialCapMinutes': _interstitialCapMinutes,
    };
  }
  
  // Get usage-based ad cap information
  Future<Map<String, dynamic>> getUsageBasedAdCapInfo() async {
    try {
      await _usageStatsService.initialize();
      
      final totalUsageMinutes = await _usageStatsService.getTodayTotalUsageMinutes();
      final isDailyLimitReached = await _usageStatsService.isDailyUsageLimitReached();
      final isAdCapReached = await _usageStatsService.isInterstitialCapReached();
      final remainingTimeBeforeAdCap = await _usageStatsService.getRemainingTimeBeforeAdCap();
      
      return {
        'totalUsageMinutes': totalUsageMinutes,
        'dailyUsageLimitMinutes': _dailyUsageLimitMinutes,
        'isDailyLimitReached': isDailyLimitReached,
        'interstitialCapMinutes': _interstitialCapMinutes,
        'isAdCapReached': isAdCapReached,
        'remainingTimeBeforeAdCap': remainingTimeBeforeAdCap,
        'canShowAds': !isDailyLimitReached && !isAdCapReached,
      };
    } catch (e) {
      print('Error getting usage-based ad cap info: $e');
      return {
        'totalUsageMinutes': 0,
        'dailyUsageLimitMinutes': _dailyUsageLimitMinutes,
        'isDailyLimitReached': false,
        'interstitialCapMinutes': _interstitialCapMinutes,
        'isAdCapReached': false,
        'remainingTimeBeforeAdCap': 0,
        'canShowAds': true,
      };
    }
  }
  
  // Update usage-based ad cap settings
  Future<void> updateUsageBasedCaps({
    bool? useUsageBasedCaps,
    int? dailyUsageLimitMinutes,
    int? interstitialCapMinutes,
  }) async {
    if (useUsageBasedCaps != null) _useUsageBasedCaps = useUsageBasedCaps;
    if (dailyUsageLimitMinutes != null) _dailyUsageLimitMinutes = dailyUsageLimitMinutes;
    if (interstitialCapMinutes != null) _interstitialCapMinutes = interstitialCapMinutes;
    
    await _saveSettings();
  }
}

// Placeholder widgets for when AdMob is disabled
class InterstitialAdWidget extends StatelessWidget {
  final VoidCallback? onShowAd;

  const InterstitialAdWidget({super.key, this.onShowAd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'AdMob temporarily disabled for testing',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class RewardedAdWidget extends StatelessWidget {
  final VoidCallback? onShowAd;

  const RewardedAdWidget({super.key, this.onShowAd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'AdMob temporarily disabled for testing',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
