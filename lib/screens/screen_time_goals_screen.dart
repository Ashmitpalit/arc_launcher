import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ScreenTimeGoalsScreen extends StatefulWidget {
  const ScreenTimeGoalsScreen({super.key});

  @override
  State<ScreenTimeGoalsScreen> createState() => _ScreenTimeGoalsScreenState();
}

class _ScreenTimeGoalsScreenState extends State<ScreenTimeGoalsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Screen Time Goals',
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
              Icons.psychology,
              size: 80,
              color: Colors.purple.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Screen Time Goals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Set wellness and productivity targets\nfor better digital habits',
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
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Set Goals'),
            ),
          ],
        ),
      ),
    );
  }
}
