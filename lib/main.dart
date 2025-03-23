import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scholarship_filter_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/language_notifier.dart'; // Global language notifier
import 'screens/notification_service.dart';

/// Global notifier for dark mode.
/// This allows real-time theme changes across the app.
final darkModeNotifier = ValueNotifier<bool>(false);

void main() async {
  // Ensure that widget binding is initialized before any async calls.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize local notifications.
  await NotificationService.initialize();

  // Load user preferences from persistent storage.
  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDarkMode') ?? false;
  String preferredLanguage = prefs.getString('preferredLanguage') ?? 'en';
  
  // Set initial values for global notifiers.
  languageNotifier.value = preferredLanguage; // Initialize global language notifier.
  darkModeNotifier.value = isDark; // Initialize dark mode notifier.
  
  // Run the app.
  runApp(MyApp());
}

/// The main application widget.
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  /// Function to update dark mode preference.
  /// This updates the global darkModeNotifier and saves the preference.
  void toggleTheme(bool isDark) async {
    darkModeNotifier.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  /// Function to update language preference.
  /// This updates the global languageNotifier and saves the preference.
  void updateLanguage(String lang) async {
    languageNotifier.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferredLanguage', lang);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to dark mode changes using ValueListenableBuilder.
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDark, child) {
        // Listen to language changes using another ValueListenableBuilder.
        return ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (context, preferredLanguage, child) {
            // Define light and dark themes.
            final ThemeData lightTheme = ThemeData.light();
            final ThemeData darkTheme = ThemeData.dark();
            return MaterialApp(
              title: 'EduFinanceConnect',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              // Choose theme mode based on the dark mode notifier.
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              builder: (context, child) {
                // Wrap the child in AnimatedTheme for smooth theme transitions.
                return AnimatedTheme(
                  data: isDark ? darkTheme : lightTheme,
                  duration: const Duration(milliseconds: 500),
                  child: child!,
                );
              },
              // AuthWrapper determines the initial screen based on user authentication state.
              home: AuthWrapper(
                toggleTheme: toggleTheme,
                updateLanguage: updateLanguage,
                preferredLanguage: preferredLanguage,
              ),
              // Define app routes for navigation.
              routes: {
                '/register': (context) => RegistrationScreen(
                      updateLanguage: updateLanguage,
                      preferredLanguage: preferredLanguage,
                    ),
                '/dashboard': (context) => DashboardScreen(
                      toggleTheme: toggleTheme,
                      updateLanguage: updateLanguage,
                      preferredLanguage: preferredLanguage,
                    ),
                '/filter': (context) =>
                    ScholarshipFilterScreen(preferredLanguage: preferredLanguage),
              },
            );
          },
        );
      },
    );
  }
}

/// AuthWrapper handles navigation based on the user's authentication state.
/// If the user is logged in, it shows the DashboardScreen; otherwise, it shows the LoginScreen.
class AuthWrapper extends StatelessWidget {
  final Function(bool) toggleTheme; // Callback to toggle theme mode.
  final Function(String) updateLanguage; // Callback to update language.
  final String preferredLanguage; // Current language for UI translations.

  const AuthWrapper({
    Key? key,
    required this.toggleTheme,
    required this.updateLanguage,
    required this.preferredLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to authentication state changes from Firebase.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for authentication state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // If the user is logged in, navigate to the DashboardScreen.
        if (snapshot.hasData) {
          return DashboardScreen(
            toggleTheme: toggleTheme,
            updateLanguage: updateLanguage,
            preferredLanguage: preferredLanguage,
          );
        }
        // If no user is logged in, show the LoginScreen.
        return LoginScreen(preferredLanguage: preferredLanguage);
      },
    );
  }
}
