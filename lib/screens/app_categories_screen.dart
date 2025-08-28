import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AppCategoriesScreen extends StatefulWidget {
  const AppCategoriesScreen({super.key});

  @override
  State<AppCategoriesScreen> createState() => _AppCategoriesScreenState();
}

class _AppCategoriesScreenState extends State<AppCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'App Categories',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 80,
              color: Colors.green.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'App Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Organize your apps by usage patterns\nand categories for better insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Organize Apps'),
            ),
          ],
        ),
      ),
    );
  }
}
