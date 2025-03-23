import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_forum_screen.dart';
import 'application_tracker_screen.dart';
import 'reminder_screen.dart';
import 'translated_text.dart';
import 'language_notifier.dart';
import '../main.dart'; // for darkModeNotifier
import 'chatbot_widget.dart'; // Import the ChatBotWidget

// The DashboardScreen acts as the main landing page of the app,
// providing access to various features such as scholarships, community forum, application tracker, and reminders.
class DashboardScreen extends StatelessWidget {
  final Function(bool) toggleTheme; // Function to toggle the app's theme (dark/light mode)
  final Function(String) updateLanguage; // Function to update the app's language setting
  final String preferredLanguage; // Currently selected language for UI translation

  const DashboardScreen({
    Key? key,
    required this.toggleTheme,
    required this.updateLanguage,
    required this.preferredLanguage,
  }) : super(key: key);

  // Helper method to build the user avatar using FirebaseAuth.currentUser information.
  // Displays user's profile picture if available; otherwise, shows initials.
  Widget _buildUserAvatar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Determine display name: use displayName if available, otherwise use email, or default to "User".
    String displayName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : (user?.email ?? "User");
    Widget avatar;
    // Check if user has a photoURL available.
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      avatar = CircleAvatar(
        backgroundImage: NetworkImage(user.photoURL!), // Load image from the URL
      );
    } else {
      // Create initials from the display name (max 2 initials)
      String initials = displayName.isNotEmpty
          ? displayName.trim().split(' ').map((s) => s[0]).take(2).join()
          : "";
      avatar = CircleAvatar(child: Text(initials)); // Display initials in a circle avatar
    }
    // Wrap avatar with GestureDetector to show user info dialog on tap.
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("User Information"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: $displayName"), // Show user's display name
                  Text("Email: ${user?.email ?? ""}"), // Show user's email
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"))
              ],
            );
          },
        );
      },
      child: avatar, // Display the constructed avatar
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to language changes using ValueListenableBuilder for real-time UI updates.
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, currentLang, child) {
        return Scaffold(
          appBar: AppBar(
            // The app bar title is translated based on the current language.
            title: TranslatedText(text: "Dashboard", targetLanguage: currentLang),
            // Leading icon button for settings; opens a bottom sheet when pressed.
            leading: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SettingsSheet(
                      toggleTheme: toggleTheme, // Pass toggleTheme callback to settings sheet
                      updateLanguage: updateLanguage, // Pass language update callback
                    );
                  },
                );
              },
            ),
            // Display the user's avatar in the app bar actions.
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildUserAvatar(context),
              ),
            ],
          ),
          // The main body of the dashboard contains a vertical list of buttons to access features.
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button to navigate to the Scholarship Filter screen.
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/filter');
                    },
                    child: TranslatedText(
                        text: "Find Scholarships", targetLanguage: currentLang),
                  ),
                  const SizedBox(height: 20),
                  // Button to navigate to the Community Forum screen.
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CommunityForumScreen(preferredLanguage: currentLang)),
                      );
                    },
                    child: TranslatedText(
                        text: "Community Forum", targetLanguage: currentLang),
                  ),
                  const SizedBox(height: 20),
                  // Button to navigate to the Application Tracker screen.
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ApplicationTrackerScreen(preferredLanguage: currentLang)),
                      );
                    },
                    child: TranslatedText(
                        text: "Application Tracker", targetLanguage: currentLang),
                  ),
                  const SizedBox(height: 20),
                  // Button to navigate to the Reminder screen.
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ReminderScreen(preferredLanguage: currentLang)),
                      );
                    },
                    child: TranslatedText(
                        text: "Reminders", targetLanguage: currentLang),
                  ),
                ],
              ),
            ),
          ),
          // Floating action button that opens the chatbot when pressed.
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.chat),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ChatBotWidget(preferredLanguage: currentLang),
              );
            },
          ),
        );
      },
    );
  }
}

// SettingsSheet is a bottom sheet that allows the user to modify settings such as dark mode, language, and logout.
class SettingsSheet extends StatelessWidget {
  final Function(bool) toggleTheme; // Callback to toggle theme mode
  final Function(String) updateLanguage; // Callback to update language
  const SettingsSheet({
    Key? key,
    required this.toggleTheme,
    required this.updateLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to language changes so that the settings sheet is updated in real time.
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, currentLang, child) {
        // Determine the label for the current language code.
        String currentLangLabel;
        switch (currentLang) {
          case 'hi':
            currentLangLabel = "Hindi";
            break;
          case 'kn':
            currentLangLabel = "Kannada";
            break;
          case 'en':
          default:
            currentLangLabel = "English";
            break;
        }
        // Also listen to dark mode changes.
        return ValueListenableBuilder<bool>(
          valueListenable: darkModeNotifier,
          builder: (context, isDark, child) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 260, // Fixed height for the settings sheet
              child: Column(
                children: [
                  // Row to toggle dark mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TranslatedText(
                          text: "Dark Mode",
                          targetLanguage: currentLang,
                          style: const TextStyle(fontSize: 16)),
                      // Adaptive switch for dark mode toggle
                      Switch.adaptive(
                        value: isDark,
                        onChanged: (value) {
                          toggleTheme(value); // Call toggleTheme when switch is toggled
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  // ListTile to change language
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: TranslatedText(
                        text: "Change Language", targetLanguage: currentLang),
                    subtitle: Text(currentLangLabel),
                    onTap: () {
                      // Open a dialog to select a new language
                      showDialog(
                        context: context,
                        builder: (context) {
                          return LanguageDialog(
                              currentLanguage: currentLangLabel,
                              updateLanguage: updateLanguage);
                        },
                      );
                    },
                  ),
                  const Divider(),
                  // ListTile to perform logout
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: TranslatedText(
                        text: "Logout", targetLanguage: currentLang),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                      Navigator.pop(context); // Close the settings sheet
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// LanguageDialog provides a dialog to allow users to select a new language.
class LanguageDialog extends StatefulWidget {
  final String currentLanguage; // The currently selected language label
  final Function(String) updateLanguage; // Callback to update the language
  const LanguageDialog({Key? key, required this.currentLanguage, required this.updateLanguage}) : super(key: key);

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  String? _selected; // Stores the language selected by the user
  final List<String> languages = ["English", "Hindi", "Kannada"]; // Available language options

  @override
  void initState() {
    super.initState();
    _selected = widget.currentLanguage; // Initialize with the current language
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Language"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        // Create a list of radio buttons for language selection.
        children: languages.map((lang) {
          return RadioListTile<String>(
            title: Text(lang),
            value: lang,
            groupValue: _selected,
            onChanged: (val) {
              setState(() {
                _selected = val; // Update selected language when changed
              });
            },
          );
        }).toList(),
      ),
      actions: [
        // Cancel button dismisses the dialog without changes.
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        // OK button updates the language setting and closes the dialog.
        TextButton(
          onPressed: () {
            // Map the selected language to its corresponding language code.
            String langCode =
                _selected == "English" ? "en" : _selected == "Hindi" ? "hi" : "kn";
            widget.updateLanguage(langCode); // Call the updateLanguage callback
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
