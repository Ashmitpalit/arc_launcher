import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'providers/launcher_provider.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up error handling to prevent red screens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  
  // Request necessary permissions
  try {
    await Permission.notification.request();
    await Permission.systemAlertWindow.request();
  } catch (e) {
    // Continue even if permissions fail
    print('Permission request failed: $e');
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

    return ChangeNotifierProvider(
      create: (context) => LauncherProvider(),
      child: MaterialApp(
        title: 'Arc Launcher',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}