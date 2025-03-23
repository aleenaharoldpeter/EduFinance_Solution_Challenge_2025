import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financial/main.dart'; // Adjust package name if necessary
import 'package:firebase_core/firebase_core.dart';
import 'package:financial/firebase_options.dart'; // Make sure this file exists in your project

void main() {
  // Ensure Firebase is initialized before running tests.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('MyApp builds and displays LoginScreen when not authenticated', (WidgetTester tester) async {
    // Build the app widget.
    await tester.pumpWidget(MyApp());

    // Let the widget tree settle.
    await tester.pumpAndSettle();

    // Verify that a widget with text "Login" is found.
    // (Assumes that when no user is authenticated, the LoginScreen shows "Login".)
    expect(find.text('Login'), findsOneWidget);
  });
}
