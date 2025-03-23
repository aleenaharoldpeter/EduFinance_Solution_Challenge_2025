import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'translated_text.dart';
import 'user_preferences.dart'; // Import the helper file for managing user preferences

class ApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application; // Holds the details of the application
  final String preferredLanguage; // Stores the user's preferred language for translation
  
  const ApplicationDetailScreen({Key? key, required this.application, required this.preferredLanguage})
      : super(key: key);

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  late Map<String, dynamic> applicationDetail; // Holds a mutable copy of the application details
  String _selectedStatus = "Bookmark"; // Default status selection

  // Function to save the application details to local storage using SharedPreferences
  Future<void> _saveApplication() async {
    final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    String key = userKey('applications'); // Generate a unique key for storing applications
    List<String> stored = prefs.getStringList(key) ?? []; // Retrieve the stored list or initialize an empty list
    
    // Create a unique identifier based on application name and deadline
    String uniqueId = "${applicationDetail['name']}_${applicationDetail['deadline']}";
    
    // Check if the application already exists in the stored list
    int index = stored.indexWhere((e) {
      Map<String, dynamic> app = jsonDecode(e);
      String existingId = "${app['name']}_${app['deadline']}";
      return existingId == uniqueId;
    });
    
    // If the application exists, update its details
    if (index != -1) {
      stored[index] = jsonEncode(applicationDetail);
    }
    
    // Save the updated list back to SharedPreferences
    await prefs.setStringList(key, stored);
  }

  @override
  void initState() {
    super.initState();
    applicationDetail = Map<String, dynamic>.from(widget.application); // Initialize application details
    _selectedStatus = applicationDetail["status"] ?? "Bookmark"; // Set the default status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText(
            text: "Application Detail", targetLanguage: widget.preferredLanguage),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: Column(
          children: [
            // Display the application name in a bold font
            Text(applicationDetail["name"] ?? "",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Display various application details
            Text("State: ${applicationDetail["state"]}"),
            Text("Qualification: ${applicationDetail["qualification"]}"),
            Text("Category: ${applicationDetail["category"]}"),
            const SizedBox(height: 10),
            Text("Amount: ₹${applicationDetail["amount"]}"),
            Text("Deadline: ${applicationDetail["deadline"]}"),
            const SizedBox(height: 20),
            
            // Dropdown menu for changing the application status
            DropdownButton<String>(
              value: _selectedStatus,
              items: ["Bookmark", "Applied", "In Progress", "Not Interested"]
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedStatus = val!; // Update the selected status
                  applicationDetail["status"] = _selectedStatus; // Save the updated status
                  _saveApplication(); // Save changes to SharedPreferences
                });
              },
            ),
            const SizedBox(height: 20),
            
            // Close button to navigate back to the previous screen
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: TranslatedText(
                  text: "Close", targetLanguage: widget.preferredLanguage),
            ),
          ],
        ),
      ),
    );
  }
}
