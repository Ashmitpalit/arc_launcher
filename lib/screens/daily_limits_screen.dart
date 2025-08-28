import 'package:flutter/material.dart';
import '../utils/theme.dart';

class DailyLimitsScreen extends StatefulWidget {
  const DailyLimitsScreen({super.key});

  @override
  State<DailyLimitsScreen> createState() => _DailyLimitsScreenState();
}

class _DailyLimitsScreenState extends State<DailyLimitsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daily Limits',
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
              Icons.hourglass_empty,
              size: 80,
              color: Colors.orange.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Daily Limits Configuration',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Configure your daily screen time limits\nand wellness goals',
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Set Limits'),
            ),
          ],
        ),
      ),
    );
  }
}
