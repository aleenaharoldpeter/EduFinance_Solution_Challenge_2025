import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'translated_text.dart';

// ScholarshipDetailScreen displays detailed information about a scholarship.
class ScholarshipDetailScreen extends StatelessWidget {
  final Map<String, dynamic> scholarship; // Contains the scholarship details.
  final String preferredLanguage; // Language used for UI translation.
  
  const ScholarshipDetailScreen({Key? key, required this.scholarship, required this.preferredLanguage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the deadline string from the scholarship data.
    final String deadlineStr = scholarship["deadline"] ?? "";
    DateTime? deadlineDate;
    
    // Try to parse the deadline string into a DateTime object using the specified format.
    try {
      deadlineDate = DateFormat('dd-MM-yyyy').parse(deadlineStr);
    } catch (e) {
      // If parsing fails, set deadlineDate to null.
      deadlineDate = null;
    }
    
    // Build the UI for displaying the scholarship details.
    return Scaffold(
      appBar: AppBar(
        // Use the TranslatedText widget for multi-language support on the app bar title.
        title: TranslatedText(text: "Scholarship Details", targetLanguage: preferredLanguage),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Overall padding for the content.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left).
            children: [
              // Display the scholarship name as a bold header.
              TranslatedText(
                text: scholarship["name"] ?? "",
                targetLanguage: preferredLanguage,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Display the state information.
              TranslatedText(
                text: "State: ${scholarship["state"]}",
                targetLanguage: preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              // Display the qualification requirement.
              TranslatedText(
                text: "Qualification: ${scholarship["qualification"]}",
                targetLanguage: preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              // Display the category of the scholarship.
              TranslatedText(
                text: "Category: ${scholarship["category"]}",
                targetLanguage: preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              // Display the scholarship amount with currency formatting.
              TranslatedText(
                text: "Amount: ₹${scholarship["amount"]}",
                targetLanguage: preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              // Display the deadline as it appears in the data.
              TranslatedText(
                text: "Deadline: $deadlineStr",
                targetLanguage: preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              // Display the current status of the scholarship.
              TranslatedText(
                text: "Status: ${scholarship["status"]}",
                targetLanguage: preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
