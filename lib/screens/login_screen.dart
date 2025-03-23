import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_screen.dart';
import 'translated_text.dart'; //'../widgets/translated_text.dart';

// LoginScreen allows the user to log into the app using email and password.
class LoginScreen extends StatefulWidget {
  final String preferredLanguage; // The current language for translations.

  const LoginScreen({Key? key, required this.preferredLanguage}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance.
  final TextEditingController _emailController = TextEditingController(); // Controller for email input.
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input.
  bool _obscurePassword = true; // Controls password field visibility.

  // _login attempts to sign in the user with the provided email and password.
  Future<void> _login() async {
    try {
      // Attempt to sign in using FirebaseAuth with trimmed input values.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      User? user = userCredential.user;
      if (user != null) {
        print("Login Successful: ${user.email}"); // Debug print on successful login.
      } else {
        // If no user is returned, throw an exception.
        throw FirebaseAuthException(code: "user-not-found", message: "User not found.");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed."; // Default error message.
      // Customize error messages based on Firebase error code.
      if (e.code == 'user-not-found') {
        errorMessage = "No account found for this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }
      // Display error message using a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with a translated title.
      appBar: AppBar(
        title: TranslatedText(text: "Login", targetLanguage: widget.preferredLanguage),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // Padding around the form.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TextField for email input.
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  // Display label based on language preference.
                  labelText: widget.preferredLanguage == 'en' ? "Email" : "",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // TextField for password input.
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Obscure text based on _obscurePassword value.
                decoration: InputDecoration(
                  labelText: widget.preferredLanguage == 'en' ? "Password" : "",
                  border: const OutlineInputBorder(),
                  // Icon button to toggle password visibility.
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword; // Toggle password visibility.
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ElevatedButton that triggers the login process.
              ElevatedButton(
                onPressed: _login,
                child: TranslatedText(text: "Login", targetLanguage: widget.preferredLanguage),
              ),
              const SizedBox(height: 10),
              // TextButton to navigate to the registration screen for new users.
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen(
                              updateLanguage: (_) {}, // Dummy callback for language update.
                              preferredLanguage: widget.preferredLanguage,
                            )),
                  );
                },
                child: TranslatedText(
                    text: "Don't have an account? Register here",
                    targetLanguage: widget.preferredLanguage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
