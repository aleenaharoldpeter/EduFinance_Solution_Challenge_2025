import 'package:flutter/material.dart';

// LanguageNotifier extends ValueNotifier with a String type, allowing it to hold and notify changes to the current language code.
class LanguageNotifier extends ValueNotifier<String> {
  // Constructor that initializes the notifier with an initial language value.
  LanguageNotifier(String value) : super(value);
}

// Create a global instance of LanguageNotifier with the default language set to 'en' (English).
final languageNotifier = LanguageNotifier('en');
