import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/playdeck_screen.dart';
import 'screens/info_screen.dart';
import 'screens/icon_customizer_screen.dart';
import 'screens/search_providers_screen.dart';
import 'screens/dynamic_shortcuts_screen.dart';
import 'screens/remote_controls_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wallpaper_screen.dart';
import 'providers/launcher_provider.dart';
import 'providers/enhanced_launcher_provider.dart';
import 'services/analytics_service.dart';
import 'services/monetization_service.dart';
import 'services/performance_service.dart';
import 'services/premium_service.dart';
import 'services/store_submission_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up error handling to prevent red screens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  
  // Initialize Firebase first
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  // Request necessary permissions
  try {
    await Permission.notification.request();
    await Permission.systemAlertWindow.request();
  } catch (e) {
    // Continue even if permissions fail
    print('Permission request failed: $e');
  }
  
  // Initialize services
  try {
    await AnalyticsService().initialize();
    await MonetizationService().initialize();
    await PerformanceService().initialize();
    await PremiumService().initialize();
    await StoreSubmissionService().initialize();
  } catch (e) {
    print('Service initialization failed: $e');
  }
  
  runApp(const ArcLauncherApp());
}

class ArcLauncherApp extends StatelessWidget {
  const ArcLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up custom error widget to prevent red screens
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Arc Launcher',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Something went wrong, but we\'re handling it!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Try to navigate to home screen
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LauncherProvider()),
        ChangeNotifierProvider(create: (context) => EnhancedLauncherProvider()),
      ],
      child: MaterialApp(
        title: 'Arc Launcher',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/playdeck': (context) => const PlayDeckScreen(),
          '/info': (context) => const InfoScreen(),
          '/icon-customizer': (context) => const IconCustomizerScreen(),
          '/search-providers': (context) => const SearchProvidersScreen(),
          '/dynamic-shortcuts': (context) => const DynamicShortcutsScreen(),
          '/remote-controls': (context) => const RemoteControlsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/wallpapers': (context) => const WallpaperScreen(),
        },
      ),
    );
  }
}