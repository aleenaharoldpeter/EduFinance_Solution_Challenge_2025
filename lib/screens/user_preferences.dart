import 'package:firebase_auth/firebase_auth.dart';

/// Returns a key prefixed by the current user’s UID.
/// If no user is logged in, it returns the key unchanged.
String userKey(String key) {
  // Retrieve the currently logged-in user from FirebaseAuth.
  final user = FirebaseAuth.instance.currentUser;
  
  // If a user is logged in, prefix the key with the user's UID.
  // Otherwise, return the key as-is.
  return user != null ? "${user.uid}_$key" : key;
}
