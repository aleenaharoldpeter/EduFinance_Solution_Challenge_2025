import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'translated_text.dart';
import 'scholarship_detail_screen.dart';
import 'user_preferences.dart';
import 'language_notifier.dart';

class ApplicationTrackerScreen extends StatefulWidget {
  final String preferredLanguage; // Stores the user's preferred language for translations
  
  const ApplicationTrackerScreen({Key? key, required this.preferredLanguage})
      : super(key: key);

  @override
  State<ApplicationTrackerScreen> createState() => _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> applications = []; // List to store scholarship applications
  late TabController _tabController; // Controller for managing tab navigation
  final List<String> statuses = ["Bookmark", "Applied", "In Progress", "Not Interested"];

  // Load saved applications from shared preferences
  Future<void> _loadApplications() async {
    final prefs = await SharedPreferences.getInstance(); // Retrieve shared preferences instance
    String key = userKey('applications'); // Generate unique key for applications storage
    List<String> stored = prefs.getStringList(key) ?? []; // Retrieve stored applications or initialize empty list
    setState(() {
      applications = stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList(); // Convert stored data back into a list of maps
    });
  }

  // Delete an application from the saved list
  Future<void> _deleteApplication(Map<String, dynamic> appToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    String key = userKey('applications');
    List<String> stored = prefs.getStringList(key) ?? [];
    String uniqueId = (appToDelete["scholarshipID"] ?? "").toString(); // Extract unique scholarship ID
    
    print("Attempting to delete application with ID: $uniqueId"); // Debugging statement
    int beforeCount = stored.length; // Count applications before deletion
    
    // Remove the matching application
    stored.removeWhere((e) {
      Map<String, dynamic> app = jsonDecode(e);
      String existingId = (app["scholarshipID"] ?? "").toString();
      return existingId == uniqueId;
    });
    
    int afterCount = stored.length; // Count applications after deletion
    print("Deleted ${beforeCount - afterCount} records."); // Debugging statement
    
    await prefs.setStringList(key, stored); // Update shared preferences
    _loadApplications(); // Reload application list to reflect changes
  }

  @override
  void initState() {
    super.initState();
    _loadApplications(); // Load applications on screen initialization
    _tabController = TabController(length: statuses.length, vsync: this); // Initialize tab controller with the statuses list
  }

  // Filter applications by selected status
  List<Map<String, dynamic>> _filterByStatus(String status) {
    return applications.where((app) {
      String appStatus = app["status"] ?? "Bookmark";
      return appStatus == status;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier, // Listens for language changes dynamically
      builder: (context, currentLang, child) {
        return Scaffold(
          appBar: AppBar(
            title: TranslatedText(
                text: "Application Tracker", targetLanguage: currentLang), // Translate title based on language preference
            bottom: TabBar(
              controller: _tabController,
              tabs: statuses.map((s) => Tab(text: s)).toList(), // Generate tabs dynamically for each status
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: statuses.map((status) {
              List<Map<String, dynamic>> filtered = _filterByStatus(status); // Filter applications for the tab
              
              // Show a message if no applications match the current status
              if (filtered.isEmpty) {
                return Center(
                  child: TranslatedText(
                      text: "No items.", targetLanguage: currentLang),
                );
              }
              
              // Build a list of applications for the current status
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final app = filtered[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Add margin for better spacing
                    child: ListTile(
                      title: TranslatedText(
                          text: app["name"] ?? "", targetLanguage: currentLang), // Scholarship name
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                              text: "Scholarship ID: ${(app["scholarshipID"] ?? 'N/A').toString()}",
                              targetLanguage: currentLang,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)), // Display Scholarship ID
                          TranslatedText(
                              text: "Deadline: ${app["deadline"]}",
                              targetLanguage: currentLang,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)), // Display deadline
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteApplication(app), // Delete application on button press
                      ),
                      
                      // Navigate to detailed scholarship page on tap
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScholarshipDetailScreen(
                              scholarship: app,
                              preferredLanguage: currentLang,
                            ),
                          ),
                        );
                        _loadApplications(); // Reload applications after returning from detail screen
                      },
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
