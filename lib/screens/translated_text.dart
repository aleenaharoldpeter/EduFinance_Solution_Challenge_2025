import 'package:flutter/material.dart';
import 'translation_service.dart'; // Import the service responsible for handling translations

// TranslatedText is a widget that displays translated text based on the target language.
// If the target language is English ('en'), it shows the original text.
// Otherwise, it fetches the translation from TranslationService.
class TranslatedText extends StatefulWidget {
  final String text; // Original text to be translated
  final String targetLanguage; // Target language code ('en', 'hi', or 'kn')
  final TextStyle? style; // Optional text styling

  const TranslatedText({
    Key? key,
    required this.text,
    required this.targetLanguage,
    this.style,
  }) : super(key: key);

  @override
  _TranslatedTextState createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String? _translated; // Holds the translated text once fetched

  @override
  void initState() {
    super.initState();
    _fetchTranslation(); // Fetch translation when the widget is first inserted into the tree
  }

  @override
  void didUpdateWidget(covariant TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the target language or the text has changed, fetch the new translation
    if (oldWidget.targetLanguage != widget.targetLanguage ||
        oldWidget.text != widget.text) {
      _fetchTranslation();
    }
  }

  // _fetchTranslation fetches the translation for widget.text.
  // If the target language is English, it simply uses the original text.
  // Otherwise, it calls the TranslationService to obtain the translated text.
  void _fetchTranslation() async {
    if (widget.targetLanguage == 'en') {
      // For English, no translation is needed.
      setState(() {
        _translated = widget.text;
      });
    } else {
      // Call the translation service to get the translation for the target language.
      final result = await TranslationService.translateText(widget.text, widget.targetLanguage);
      // Ensure the widget is still mounted before updating the state.
      if (mounted) {
        setState(() {
          _translated = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display the translated text if available, otherwise fallback to the original text.
    return Text(_translated ?? widget.text, style: widget.style);
  }
}
