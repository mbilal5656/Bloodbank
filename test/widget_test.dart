// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bloodbank/main.dart';
import 'package:bloodbank/theme/theme_provider.dart';
// Ensure that main.dart defines a class named MyApp and it is public.

void main() {
  testWidgets('Splash screen shows Blood Bank title', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame with required providers
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const BloodBankApp(),
      ),
    );

    // Verify that the splash screen displays the app title.
    expect(find.text('Blood Bank'), findsOneWidget);
    expect(find.byIcon(Icons.bloodtype), findsOneWidget);

    // Wait for the timer to complete and verify navigation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that we've navigated to the home page by checking for common elements
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
