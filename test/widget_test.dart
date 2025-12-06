// This is a basic Flutter widget test for Nail Studio App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nail_studio/main.dart';

void main() {
  testWidgets('Nail Studio App launches with Login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NailStudioApp());

    // Verify that the Login screen is displayed
    expect(find.text('Welcome back'), findsOneWidget);
    
    // Verify that Sign in button exists
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('Navigate to Register screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NailStudioApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Find and tap "Create one" link to go to Register screen
    final createAccountLink = find.text('Create one');
    expect(createAccountLink, findsOneWidget);
    
    await tester.tap(createAccountLink);
    await tester.pumpAndSettle();

    // Verify that Register screen is displayed
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Guest login navigates to Home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NailStudioApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Find and tap "Lanjut sebagai Guest" button
    final guestButton = find.text('Lanjut sebagai Guest');
    expect(guestButton, findsOneWidget);
    
    await tester.tap(guestButton);
    await tester.pumpAndSettle();

    // Verify that Home screen is displayed
    expect(find.text('Halo, Guest 👋'), findsOneWidget);
  });

  testWidgets('Login with credentials navigates to Home', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NailStudioApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Enter email
    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, 'sarah@mail.com');

    // Enter password
    final passwordField = find.byType(TextFormField).last;
    await tester.enterText(passwordField, 'password123');

    // Find and tap Sign in button
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign in');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // Verify that Home screen is displayed with user name
    expect(find.text('Halo, Sarah 👋'), findsOneWidget);
  });

  testWidgets('Bottom navigation works correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NailStudioApp());

    // Login as guest first
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut sebagai Guest'));
    await tester.pumpAndSettle();

    // Verify we're on Home
    expect(find.text('Halo, Guest 👋'), findsOneWidget);

    // Tap on Account tab in bottom navigation
    final accountIcon = find.byIcon(Icons.person_outline).last;
    await tester.tap(accountIcon);
    await tester.pumpAndSettle();

    // Verify Account screen is displayed
    expect(find.text('Anda Belum Login'), findsOneWidget);

    // Go back to Home
    final homeIcon = find.byIcon(Icons.home_outlined);
    await tester.tap(homeIcon);
    await tester.pumpAndSettle();

    // Verify we're back on Home
    expect(find.text('Halo, Guest 👋'), findsOneWidget);
  });
}