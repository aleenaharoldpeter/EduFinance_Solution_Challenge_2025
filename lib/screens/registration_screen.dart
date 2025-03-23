import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translated_text.dart'; //'../widgets/translated_text.dart';

// RegistrationScreen allows a new user to create an account,
// set their display name, and choose a preferred language.
class RegistrationScreen extends StatefulWidget {
  final Function(String) updateLanguage; // Callback to update the app's language preference.
  final String preferredLanguage; // Currently selected language for UI translations.

  const RegistrationScreen({Key? key, required this.updateLanguage, required this.preferredLanguage}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance.
  final TextEditingController _nameController = TextEditingController(); // Controller for name input.
  final TextEditingController _emailController = TextEditingController(); // Controller for email input.
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input.
  String _selectedLanguage = "English"; // Default language selection.
  final List<String> languages = ["English", "Hindi", "Kannada"]; // List of available languages.

  // _register creates a new user using FirebaseAuth,
  // updates the display name, saves the preferred language,
  // and navigates to the dashboard upon success.
  Future<void> _register() async {
    try {
      // Attempt to create a new user account with trimmed email and password.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        // Update the user's display name with the provided name.
        await user.updateDisplayName(_nameController.text.trim());
        // Save the selected language preference to SharedPreferences.
        final prefs = await SharedPreferences.getInstance();
        String langCode = _selectedLanguage == "English" ? "en" : _selectedLanguage == "Hindi" ? "hi" : "kn";
        await prefs.setString('preferredLanguage', langCode);
        // Update the app's language setting via the callback.
        widget.updateLanguage(langCode);
        print("Registration Successful: ${user.email}");
        // Navigate to the dashboard screen, replacing the current screen.
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Throw an error if the user is null.
        throw FirebaseAuthException(code: "registration-failed", message: "Registration failed.");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed."; // Default error message.
      // Customize error messages based on FirebaseAuth error codes.
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered. Try logging in.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password should be at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }
      // Show the error message using a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with a translated title.
      appBar: AppBar(
        title: TranslatedText(text: "Register", targetLanguage: widget.preferredLanguage),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Padding around the registration form.
          child: Column(
            children: [
              // TextField for entering the user's name.
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: widget.preferredLanguage == 'en' ? "Name" : "",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // TextField for entering the user's email.
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: widget.preferredLanguage == 'en' ? "Email" : "",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // TextField for entering the user's password.
              TextField(
                controller: _passwordController,
                obscureText: true, // Hide the password input.
                decoration: InputDecoration(
                  labelText: widget.preferredLanguage == 'en' ? "Password" : "",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Dropdown to select the user's preferred language.
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: widget.preferredLanguage == 'en' ? "Preferred Language" : ""),
                items: languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                onChanged: (value) => setState(() => _selectedLanguage = value ?? "English"),
                value: _selectedLanguage,
              ),
              const SizedBox(height: 20),
              // Button to trigger registration.
              ElevatedButton(
                onPressed: _register,
                child: TranslatedText(text: "Register", targetLanguage: widget.preferredLanguage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
