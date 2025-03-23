// translation_service.dart
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// TranslationService handles on-device translation using ML Kit and caches results
/// to improve performance by avoiding repeated translations.
class TranslationService {
  // Cache to store already-translated texts per target language.
  // The key is the target language code, and the value is a map where
  // each entry's key is the original text and its value is the translated text.
  static final Map<String, Map<String, String>> _cache = {};

  // Cache of active OnDeviceTranslator instances, keyed by target language.
  static final Map<String, OnDeviceTranslator> _translators = {};

  /// Returns an instance of OnDeviceTranslator for the given target language.
  /// Throws an exception if the target language is English, since no translation is needed.
  static Future<OnDeviceTranslator> getTranslator(String targetLanguage) async {
    if (targetLanguage == 'en') {
      throw Exception('No translation needed for English');
    }
    // If a translator for the target language already exists, return it.
    if (_translators.containsKey(targetLanguage)) {
      return _translators[targetLanguage]!;
    }

    // Define the source language as English.
    TranslateLanguage sourceLang = TranslateLanguage.english;
    TranslateLanguage targetLang;

    // Determine the target language based on the targetLanguage code.
    if (targetLanguage == 'hi') {
      targetLang = TranslateLanguage.hindi;
    } else if (targetLanguage == 'kn') {
      targetLang = TranslateLanguage.kannada;
    } else {
      // Fallback to English if an unrecognized language code is provided.
      targetLang = TranslateLanguage.english;
    }

    // Create a new OnDeviceTranslator with the specified source and target languages.
    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );

    // Optionally, you can download the model if needed by uncommenting the following line:
    // await translator.downloadModelIfNeeded();

    // Store the translator in the cache for future use.
    _translators[targetLanguage] = translator;
    // Initialize the translation cache for this language.
    _cache[targetLanguage] = {};
    return translator;
  }

  /// Translates the provided [text] into the [targetLanguage].
  /// Returns the original text if the target language is English.
  /// Checks cache first to avoid redundant translations.
  static Future<String> translateText(String text, String targetLanguage) async {
    if (targetLanguage == 'en') return text;
    // Check if the translation already exists in the cache.
    if (_cache[targetLanguage]?.containsKey(text) ?? false) {
      return _cache[targetLanguage]![text]!;
    }
    try {
      // Get the translator for the target language.
      final translator = await getTranslator(targetLanguage);
      // Perform the translation.
      final translated = await translator.translateText(text);
      // Cache the translated result.
      _cache[targetLanguage]![text] = translated;
      return translated;
    } catch (e) {
      // In case of an error, return the original text.
      return text;
    }
  }

  /// Closes all active translator instances and clears the caches.
  static Future<void> closeTranslators() async {
    for (var translator in _translators.values) {
      await translator.close();
    }
    _translators.clear();
    _cache.clear();
  }
}
