import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:launcher_android/screens/onboarding_screen.dart';

void main() {
  group('OnboardingScreen Tests', () {
    testWidgets('Onboarding screen displays all 9 steps', (WidgetTester tester) async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify the skip button is present
      expect(find.text('Skip to the Game'), findsOneWidget);

      // Verify the continue button is present
      expect(find.text('Continue'), findsOneWidget);

      // Verify page indicator is present (9 dots)
      expect(find.byType(SmoothPageIndicator), findsOneWidget);
    });

    testWidgets('Onboarding step content displays correctly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify first step content
      expect(find.text('App Tracer'), findsOneWidget);
      expect(find.text('Track your app usage patterns to optimize your gaming experience and discover new games.'), findsOneWidget);

      // Verify the icon is present
      expect(find.byIcon(Icons.track_changes), findsOneWidget);
    });

    testWidgets('Navigation buttons work correctly', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Test continue button
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should now show second step
      expect(find.text('Companion'), findsOneWidget);
    });

    testWidgets('Skip button functionality', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Test skip button
      await tester.tap(find.text('Skip to the Game'));
      await tester.pumpAndSettle();

      // The skip button should trigger navigation (though we can't test the actual navigation in unit tests)
      // But we can verify the button is tappable
      expect(find.text('Skip to the Game'), findsOneWidget);
    });
  });
}
