import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading asset files
import 'package:csv/csv.dart'; // For CSV parsing
import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart'; // For persistent storage
import 'scholarship_results_screen.dart'; // Screen to display filtered scholarship results
import 'translated_text.dart'; // Widget for translating text

// A simple static translation map for filter labels.
// In a more advanced solution, you might use a localization framework.
Map<String, Map<String, String>> filterLabelTranslations = {
  "Education Qualification": {"hi": "शैक्षणिक योग्यता", "kn": "ಶೈಕ್ಷಣಿಕ ಅರ್ಹತೆ", "en": "Education Qualification"},
  "State": {"hi": "राज्य", "kn": "ರಾಜ್ಯ", "en": "State"},
  "Category": {"hi": "श्रेणी", "kn": "ವರ್ಗ", "en": "Category"},
};

/// ScholarshipFilterScreen allows users to filter scholarships based on their criteria.
/// It loads a CSV file of scholarship data, caches it for offline use,
/// and filters the data based on selected values for qualification, state, and category.
class ScholarshipFilterScreen extends StatefulWidget {
  final String preferredLanguage; // Current language for UI translations
  
  const ScholarshipFilterScreen({Key? key, required this.preferredLanguage}) : super(key: key);

  @override
  State<ScholarshipFilterScreen> createState() => _ScholarshipFilterScreenState();
}

class _ScholarshipFilterScreenState extends State<ScholarshipFilterScreen> {
  String? selectedQualification; // Currently selected education qualification
  String? selectedState; // Currently selected state
  String? selectedCategory; // Currently selected category

  // Keys used for dropdown items; these represent internal values.
  final List<String> qualificationKeys = ['Class X', 'Class XII', 'Graduation'];
  final List<String> stateKeys = ['Karnataka', 'Maharashtra', 'Delhi', 'Kerala'];
  final List<String> categoryKeys = ['General', 'SC/ST/OBC', 'Girls'];

  // Translation maps for the dropdown values.
  Map<String, Map<String, String>> qualificationTranslations = {
    'Class X': {'en': 'Class X', 'hi': 'कक्षा 10', 'kn': '10ನೇ ತರಗತಿ'},
    'Class XII': {'en': 'Class XII', 'hi': 'कक्षा 12', 'kn': '12ನೇ ತರಗತಿ'},
    'Graduation': {'en': 'Graduation', 'hi': 'स्नातक', 'kn': 'ಬ್ಯಾಚುಲರ್'},
  };

  Map<String, Map<String, String>> stateTranslations = {
    'Karnataka': {'en': 'Karnataka', 'hi': 'कर्नाटक', 'kn': 'ಕರ್ನಾಟಕ'},
    'Maharashtra': {'en': 'Maharashtra', 'hi': 'महाराष्ट्र', 'kn': 'ಮಹಾರಾಷ್ಟ್ರ'},
    'Delhi': {'en': 'Delhi', 'hi': 'दिल्ली', 'kn': 'ದೆಹಲಿ'},
    'Kerala': {'en': 'Kerala', 'hi': 'केरल', 'kn': 'ಕೇರಳ'},
  };

  Map<String, Map<String, String>> categoryTranslations = {
    'General': {'en': 'General', 'hi': 'सामान्य', 'kn': 'ಸಾಮಾನ್ಯ'},
    'SC/ST/OBC': {'en': 'SC/ST/OBC', 'hi': 'एससी/एसटी/ओबीसी', 'kn': 'ಎಸ್‌ಸಿ/ಎಸ್‌ಟಿ/ಒಬಿಸಿ'},
    'Girls': {'en': 'Girls', 'hi': 'लड़कियां', 'kn': 'ಹುಡುಗಿಯರು'},
  };

  // Load CSV file and cache it for offline use.
  // This function reads the CSV file from assets, converts it to a List<List<dynamic>>,
  // and caches the JSON encoded version in SharedPreferences.
  Future<List<List<dynamic>>> loadCSV() async {
    try {
      // Load CSV file content as a string from assets.
      final csvString = await rootBundle.loadString('assets/scholarships_data.csv');
      // Convert CSV string into a list of rows.
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
      
      // Cache the CSV table for offline use.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedScholarships', jsonEncode(csvTable));
      return csvTable;
    } catch (e) {
      // If CSV loading fails, try to get the cached version from SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      String? cached = prefs.getString('cachedScholarships');
      if (cached != null) {
        return List<List<dynamic>>.from(jsonDecode(cached));
      }
      // If no cache is available, return an empty list.
      return [];
    }
  }

  // Filter the loaded scholarships based on the selected qualification, state, and category.
  // Returns the filtered list of scholarship data rows.
  Future<List<List<dynamic>>> getFilteredScholarships() async {
    List<List<dynamic>> data = await loadCSV();
    if (data.isEmpty) return [];
    // Extract and trim the header row.
    List<dynamic> header = data.first;
    List<String> trimmedHeader = header.map((e) => e.toString().trim()).toList();
    // Remove any BOM (Byte Order Mark) from the first header element.
    if (trimmedHeader.isNotEmpty && trimmedHeader[0].startsWith('\ufeff')) {
      trimmedHeader[0] = trimmedHeader[0].substring(1);
    }
    // Find indices for expected columns based on header values.
    int colState = trimmedHeader.indexWhere((h) => h.toLowerCase() == 'state');
    int colQualification = trimmedHeader.indexWhere((h) => h.toLowerCase() == 'qualification');
    int colCategory = trimmedHeader.indexWhere((h) => h.toLowerCase() == 'category');
    if (colState == -1 || colQualification == -1 || colCategory == -1) {
      throw Exception("CSV header does not contain expected columns: State, Qualification, Category. Header: $trimmedHeader");
    }
    // Start with the header row for the filtered data.
    List<List<dynamic>> filteredData = [header];
    // Iterate through each row of data starting from the second row.
    for (int i = 1; i < data.length; i++) {
      var row = data[i];
      bool matches = true;
      // Check qualification match if a qualification filter is set.
      if (selectedQualification != null && selectedQualification!.isNotEmpty) {
        if (row[colQualification].toString().trim().toLowerCase() != selectedQualification!.toLowerCase()) {
          matches = false;
        }
      }
      // Check state match if a state filter is set.
      if (selectedState != null && selectedState!.isNotEmpty) {
        if (row[colState].toString().trim().toLowerCase() != selectedState!.toLowerCase()) {
          matches = false;
        }
      }
      // Check category match if a category filter is set.
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        if (row[colCategory].toString().trim().toLowerCase() != selectedCategory!.toLowerCase()) {
          matches = false;
        }
      }
      // If the row matches all filters, add it to the filtered data.
      if (matches) {
        filteredData.add(row);
      }
    }
    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    // Use the static translation map for dropdown labels.
    String eduLabel = filterLabelTranslations["Education Qualification"]![widget.preferredLanguage] ?? "Education Qualification";
    String stateLabel = filterLabelTranslations["State"]![widget.preferredLanguage] ?? "State";
    String categoryLabel = filterLabelTranslations["Category"]![widget.preferredLanguage] ?? "Category";

    return Scaffold(
      appBar: AppBar(
        // Translated title for the scholarship filter screen.
        title: TranslatedText(text: "Find Scholarships", targetLanguage: widget.preferredLanguage),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the filter form.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown for selecting education qualification.
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: eduLabel),
                items: qualificationKeys.map((qual) {
                  return DropdownMenuItem(
                    value: qual,
                    child: TranslatedText(
                      text: qualificationTranslations[qual]?[widget.preferredLanguage] ?? qual,
                      targetLanguage: widget.preferredLanguage,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedQualification = value),
                value: selectedQualification,
              ),
              const SizedBox(height: 16),
              // Dropdown for selecting state.
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: stateLabel),
                items: stateKeys.map((st) {
                  return DropdownMenuItem(
                    value: st,
                    child: TranslatedText(
                      text: stateTranslations[st]?[widget.preferredLanguage] ?? st,
                      targetLanguage: widget.preferredLanguage,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedState = value),
                value: selectedState,
              ),
              const SizedBox(height: 16),
              // Dropdown for selecting scholarship category.
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: categoryLabel),
                items: categoryKeys.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: TranslatedText(
                      text: categoryTranslations[cat]?[widget.preferredLanguage] ?? cat,
                      targetLanguage: widget.preferredLanguage,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                value: selectedCategory,
              ),
              const SizedBox(height: 24),
              // Button to apply filters and show results.
              ElevatedButton(
                onPressed: () async {
                  // Get filtered scholarships based on selected criteria.
                  List<List<dynamic>> results = await getFilteredScholarships();
                  // Navigate to ScholarshipResultsScreen and pass the results along with the preferred language.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScholarshipResultsScreen(
                          results: results, preferredLanguage: widget.preferredLanguage),
                    ),
                  );
                },
                child: TranslatedText(text: "Get Results", targetLanguage: widget.preferredLanguage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
