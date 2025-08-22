import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../providers/launcher_provider.dart';
import '../utils/theme.dart';

class DefaultLauncherDialog extends StatelessWidget {
  const DefaultLauncherDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Set as Default Launcher',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Would you like to set Arc Launcher as your default home screen? You can change this later in Settings.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handleLaterOption(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handleYesOption(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLaterOption(BuildContext context) {
    // Just proceed to home screen
    _proceedToHome(context);
  }

  void _handleYesOption(BuildContext context) async {
    try {
      // Open Android default launcher selection settings
      await _openDefaultLauncherSettings();
      
      // Update the launcher status
      context.read<LauncherProvider>().setDefaultLauncherStatus(true);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings opened! Please select Arc Launcher as default.'),
          duration: Duration(seconds: 3),
        ),
      );
      
      // Close dialog and navigate to home
      _proceedToHome(context);
    } catch (e) {
      // If settings can't be opened, show fallback message and proceed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open settings: $e'),
          duration: Duration(seconds: 3),
        ),
      );
      
      // Close dialog and navigate to home
      _proceedToHome(context);
    }
  }



  Future<void> _openDefaultLauncherSettings() async {
    try {
      // Method 1: Try to open the specific default launcher settings
      const platform = MethodChannel('arc_launcher_settings');
      await platform.invokeMethod('openDefaultLauncherSettings');
    } catch (e) {
      // Method 2: Try to open app settings as fallback
      try {
        await openAppSettings();
      } catch (e2) {
        // Method 3: Show manual instructions
        throw Exception('Could not open settings automatically. Please follow manual instructions.');
      }
    }
  }

  void _openSettings(BuildContext context) async {
    try {
      // Open Android default launcher selection settings
      await _openDefaultLauncherSettings();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings opened! Please select Arc Launcher as default.'),
          duration: Duration(seconds: 3),
        ),
      );
      
      // Proceed to home
      _proceedToHome(context);
    } catch (e) {
      // If settings can't be opened, show fallback message and proceed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open settings: $e'),
          duration: Duration(seconds: 3),
        ),
      );
      _proceedToHome(context);
    }
  }

  void _proceedToHome(BuildContext context) {
    // Set default launcher status
    context.read<LauncherProvider>().setDefaultLauncherStatus(true);
    
    // Close the dialog first
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    
    // Navigate to home after a short delay to avoid navigation conflicts
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }
}
