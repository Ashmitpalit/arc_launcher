import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'App Tracer',
      description: 'Track your app usage patterns to optimize your gaming experience and discover new games.',
      icon: Icons.track_changes,
      color: Colors.blue,
    ),
    OnboardingStep(
      title: 'Companion',
      description: 'Your personal gaming companion that learns your preferences and suggests the perfect games.',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    OnboardingStep(
      title: 'Wallpapers',
      description: 'Customize your launcher with stunning gaming wallpapers and themes.',
      icon: Icons.wallpaper,
      color: Colors.orange,
    ),
    OnboardingStep(
      title: 'Icons',
      description: 'Personalize your app icons with custom packs and unique designs.',
      icon: Icons.style,
      color: Colors.green,
    ),
    OnboardingStep(
      title: 'PlayDeck',
      description: 'Organize your games in a beautiful, customizable deck layout.',
      icon: Icons.view_carousel,
      color: Colors.red,
    ),
    OnboardingStep(
      title: 'Info',
      description: 'Stay updated with gaming news, updates, and community highlights.',
      icon: Icons.info,
      color: Colors.teal,
    ),
    OnboardingStep(
      title: 'Gestures',
      description: 'Navigate with intuitive gestures for a seamless gaming experience.',
      icon: Icons.touch_app,
      color: Colors.indigo,
    ),
    OnboardingStep(
      title: 'Search',
      description: 'Find games, apps, and settings instantly with our powerful search.',
      icon: Icons.search,
      color: Colors.cyan,
    ),
    OnboardingStep(
      title: 'Done',
      description: 'You\'re all set! Let\'s start gaming with your new Arc Launcher.',
      icon: Icons.check_circle,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _skipToGame() async {
    setState(() => _isLoading = true);
    
    try {
      // Save that onboarding was skipped
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setBool('onboarding_skipped', true);
      
      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      print('Error skipping onboarding: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _continue() async {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      // Request permissions
      await _requestPermissions();
      
      // Save onboarding completion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setBool('onboarding_skipped', false);
      
      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      print('Error completing onboarding: $e');
      // Continue even if there's an error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request usage access permission (needed for App Tracer)
      if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
        // This is a workaround since usage access requires system settings
        // We'll show a dialog explaining why it's needed
        await _showUsageAccessDialog();
      }
      
      // Request notification permission
      final notificationStatus = await Permission.notification.request();
      if (notificationStatus.isDenied) {
        // Show what notifications enable
        await _showNotificationPreviewDialog();
      }
    } catch (e) {
      print('Permission request failed: $e');
      // Continue gracefully
    }
  }

  Future<void> _showUsageAccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        title: const Text(
          'Usage Access Permission',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Arc Launcher needs usage access to provide App Tracer functionality. '
          'This helps us understand your app usage patterns to optimize your gaming experience. '
          'You can enable this in Settings > Apps > Arc Launcher > Permissions > Usage Access.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotificationPreviewDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        title: const Text(
          'Notification Permission',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Notifications help you stay updated with gaming news, app updates, and important alerts. '
          'You can enable this later in Settings if you change your mind.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _isLoading ? null : _skipToGame,
                  child: Text(
                    'Skip to the Game',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return _buildStepContent(step);
                },
              ),
            ),
            
            // Bottom section
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _steps.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white24,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              _currentPage == _steps.length - 1 ? 'Get Started' : 'Continue',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: step.color,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            step.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            step.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
