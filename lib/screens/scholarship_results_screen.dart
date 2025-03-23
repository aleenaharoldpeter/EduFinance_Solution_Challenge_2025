import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs (e.g., application links)
import 'package:shared_preferences/shared_preferences.dart'; // For persistent storage of bookmarks and reminders
import 'dart:convert'; // For JSON encoding and decoding
import 'package:intl/intl.dart'; // For date formatting and parsing
import 'translated_text.dart'; // Custom widget for translated text
import 'notification_service.dart'; // Service to schedule notifications
import 'user_preferences.dart'; // Helper for generating user-specific keys

// ScholarshipResultsScreen displays a paginated list of scholarships based on filtered results.
// It provides options to bookmark scholarships, update application status, and set reminders.
class ScholarshipResultsScreen extends StatefulWidget {
  final List<List<dynamic>> results; // Filtered scholarship data from CSV
  final String preferredLanguage; // Language for UI translation

  const ScholarshipResultsScreen(
      {Key? key, required this.results, required this.preferredLanguage})
      : super(key: key);

  @override
  State<ScholarshipResultsScreen> createState() =>
      _ScholarshipResultsScreenState();
}

class _ScholarshipResultsScreenState extends State<ScholarshipResultsScreen> {
  int currentPage = 0; // Tracks the current page in the paginated view

  // Bookmark a scholarship by saving/updating its entry in SharedPreferences.
  // Uses the scholarshipID as a unique identifier.
  Future<void> _bookmarkScholarship(Map<String, dynamic> scholarship) async {
    final prefs = await SharedPreferences.getInstance();
    String key = userKey('applications'); // Generate user-specific key for applications
    List<String> applications = prefs.getStringList(key) ?? [];
    // Convert scholarshipID to string, using empty string if null.
    String uniqueId = (scholarship["scholarshipID"] ?? "").toString();
    // Check if the scholarship is already bookmarked.
    int existingIndex = applications.indexWhere((e) {
      Map<String, dynamic> app = jsonDecode(e);
      // Default to empty string if stored scholarshipID is null.
      String existingId = (app["scholarshipID"] ?? "").toString();
      return existingId == uniqueId;
    });
    // Set the status to "Bookmark" and update the timestamp.
    scholarship["status"] = "Bookmark";
    scholarship["timestamp"] = DateTime.now().toIso8601String();
    if (existingIndex == -1) {
      // If not already bookmarked, add a new bookmark.
      applications.add(jsonEncode(scholarship));
      print("Bookmark added: $uniqueId");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Scholarship bookmarked!',
                style: const TextStyle(color: Colors.white))),
      );
    } else {
      // If already bookmarked, update the existing record.
      applications[existingIndex] = jsonEncode(scholarship);
      print("Bookmark updated: $uniqueId new status: ${scholarship["status"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Scholarship updated!',
                style: const TextStyle(color: Colors.white))),
      );
    }
    // Save the updated list of applications back to SharedPreferences.
    await prefs.setStringList(key, applications);
  }

  // Update the application status (e.g., Applied, In Progress, Not Interested) for a scholarship.
  Future<void> _updateApplicationStatus(Map<String, dynamic> scholarship) async {
    String currentStatus = scholarship["status"] ?? "Bookmark";
    String? selectedStatus = currentStatus;
    // Show a dialog to allow the user to select a new status.
    await showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to allow updating dialog state.
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: TranslatedText(
                text: "Update Application Status",
                targetLanguage: widget.preferredLanguage),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              // Provide radio buttons for available status options.
              children: ["Applied", "In Progress", "Not Interested"].map((status) {
                return RadioListTile<String>(
                  title: Text(status),
                  value: status,
                  groupValue: selectedStatus,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedStatus = value;
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              // Cancel button to close the dialog without changes.
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              // Update button to save the new status.
              TextButton(
                  onPressed: () async {
                    scholarship["status"] = selectedStatus;
                    print("Updated record: ${(scholarship["scholarshipID"] ?? "").toString()} new status: $selectedStatus");
                    final prefs = await SharedPreferences.getInstance();
                    String key = userKey('applications');
                    List<String> applications = prefs.getStringList(key) ?? [];
                    bool found = false;
                    // Search for the scholarship in the stored applications.
                    for (int i = 0; i < applications.length; i++) {
                      Map<String, dynamic> app = jsonDecode(applications[i]);
                      String storedId = (app["scholarshipID"] ?? "").toString();
                      String currentId = (scholarship["scholarshipID"] ?? "").toString();
                      if (storedId == currentId) {
                        app["status"] = selectedStatus;
                        applications[i] = jsonEncode(app);
                        found = true;
                        print("Record updated in SharedPreferences: $storedId status: ${app["status"]}");
                      }
                    }
                    // If not found, add the scholarship with the selected status.
                    if (!found) {
                      applications.add(jsonEncode(scholarship));
                      print("Record added in SharedPreferences: ${(scholarship["scholarshipID"] ?? "").toString()} status: $selectedStatus");
                    }
                    await prefs.setStringList(key, applications);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Status updated to $selectedStatus")),
                    );
                  },
                  child: const Text("Update"))
            ],
          );
        });
      },
    );
  }

  // Schedule a reminder for a scholarship deadline and save it for later display.
  Future<void> _setReminder(
      DateTime deadline,
      String scholarshipName,
      String scholarshipID,
      String state,
      String qualification,
      String category,
      String amount) async {
    // Calculate the reminder time (one day before the deadline).
    DateTime reminderTime = deadline.subtract(const Duration(days: 1));
    final prefs = await SharedPreferences.getInstance();
    String reminderKey = userKey('reminders');
    List<String> stored = prefs.getStringList(reminderKey) ?? [];
    // Construct a reminder object with scholarship details.
    Map<String, dynamic> reminder = {
      "scholarshipID": scholarshipID,
      "name": scholarshipName,
      "state": state,
      "qualification": qualification,
      "category": category,
      "amount": amount,
      "deadline": DateFormat('dd-MM-yyyy').format(deadline),
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      // Only schedule a reminder if the reminder time is in the future.
      if (reminderTime.isAfter(DateTime.now())) {
        await NotificationService.scheduleNotification(
          id: deadline.hashCode, // Use deadline's hashCode as a unique notification ID.
          title: "Scholarship Deadline Reminder",
          body: "$scholarshipName deadline is approaching on ${DateFormat('dd-MM-yyyy').format(deadline)}",
          scheduledDate: reminderTime,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reminder scheduled")),
        );
      } else {
        // Inform the user if the deadline is too close or has passed.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deadline is too close or passed")),
        );
      }
    } catch (e) {
      // Show error message if scheduling fails.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      // Save the reminder (insert at the beginning of the list).
      stored.insert(0, jsonEncode(reminder));
      await prefs.setStringList(reminderKey, stored);
      print("Reminder saved for: $scholarshipName, ID: $scholarshipID");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract the data rows from results, excluding the header.
    final List<List<dynamic>> dataRows =
        widget.results.length > 1 ? widget.results.sublist(1) : [];
    return Scaffold(
      appBar: AppBar(
        // Translated title for the scholarship results screen.
        title: TranslatedText(
            text: "Scholarship Results", targetLanguage: widget.preferredLanguage),
      ),
      // Display a message if there are no results, otherwise build the paginated view.
      body: dataRows.isEmpty
          ? Center(
              child: TranslatedText(
                  text: "No scholarships match your criteria.",
                  targetLanguage: widget.preferredLanguage))
          : Column(
              children: [
                // Display the current page indicator.
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("<${currentPage + 1}/${dataRows.length}>",
                      style: const TextStyle(fontSize: 16)),
                ),
                Expanded(
                  // Use PageView.builder for horizontal pagination of scholarship results.
                  child: PageView.builder(
                    itemCount: dataRows.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index; // Update the current page index.
                      });
                    },
                    itemBuilder: (context, index) {
                      var row = dataRows[index];
                      // Read and trim the ScholarshipID from the first column.
                      final scholarshipID = row[0].toString().trim();
                      final scholarshipName = row[1].toString();
                      // Extract application link if available; default to empty string.
                      final applicationLink =
                          row.length > 10 ? row[10].toString() : "";
                      final deadlineStr = row[9].toString();

                      DateTime? deadlineDate;
                      try {
                        // Parse the deadline string into a DateTime object.
                        deadlineDate = DateFormat('dd-MM-yyyy').parse(deadlineStr);
                      } catch (e) {
                        deadlineDate = null;
                      }
                      // Determine if the deadline has passed.
                      final bool deadlinePassed = deadlineDate != null &&
                          deadlineDate.isBefore(DateTime.now());

                      // Construct a scholarship data map for use in various actions.
                      Map<String, dynamic> scholarshipData = {
                        "scholarshipID": scholarshipID,
                        "name": scholarshipName,
                        "state": row[2].toString(),
                        "qualification": row[3].toString(),
                        "category": row[4].toString(),
                        "amount": row[8].toString(),
                        "deadline": deadlineStr,
                        "applicationLink": applicationLink,
                        "status": "Bookmark",
                      };

                      // Build the card for each scholarship result.
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display the scholarship name with translated text.
                                  TranslatedText(
                                    text: scholarshipName,
                                    targetLanguage: widget.preferredLanguage,
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  // Display the scholarship ID.
                                  Text("Scholarship ID: $scholarshipID",
                                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  // Display state, qualification, and category details using translated text.
                                  TranslatedText(
                                      text: "State: ${row[2]}",
                                      targetLanguage: widget.preferredLanguage),
                                  TranslatedText(
                                      text: "Qualification: ${row[3]}",
                                      targetLanguage: widget.preferredLanguage),
                                  TranslatedText(
                                      text: "Category: ${row[4]}",
                                      targetLanguage: widget.preferredLanguage),
                                  const SizedBox(height: 10),
                                  // Display scholarship amount.
                                  TranslatedText(
                                      text: "Amount: ₹${row[8]}",
                                      targetLanguage: widget.preferredLanguage),
                                  // Display the deadline.
                                  TranslatedText(
                                      text: "Deadline: $deadlineStr",
                                      targetLanguage: widget.preferredLanguage),
                                  const SizedBox(height: 20),
                                  // "Apply" button which is enabled only if the deadline hasn't passed and an application link is provided.
                                  ElevatedButton(
                                    onPressed: (!deadlinePassed &&
                                            applicationLink.isNotEmpty)
                                        ? () async {
                                            final Uri url = Uri.parse(applicationLink);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url,
                                                  mode: LaunchMode.inAppWebView);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Could not launch application link")),
                                              );
                                            }
                                          }
                                        : null,
                                    child: TranslatedText(
                                      text: "Apply",
                                      targetLanguage: widget.preferredLanguage,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Button to add the scholarship to bookmarks.
                                  ElevatedButton(
                                    onPressed: () {
                                      _bookmarkScholarship(scholarshipData);
                                    },
                                    child: TranslatedText(
                                      text: "Add to Bookmark",
                                      targetLanguage: widget.preferredLanguage,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Button to update the application status for the scholarship.
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateApplicationStatus(scholarshipData);
                                    },
                                    child: TranslatedText(
                                      text: "Update Status",
                                      targetLanguage: widget.preferredLanguage,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Button to set a reminder for the scholarship deadline.
                                  ElevatedButton(
                                    onPressed: (deadlineDate != null && !deadlinePassed)
                                        ? () {
                                            _setReminder(
                                              deadlineDate!,
                                              scholarshipName,
                                              scholarshipID,
                                              row[2].toString(), // state
                                              row[3].toString(), // qualification
                                              row[4].toString(), // category
                                              row[8].toString(), // amount
                                            );
                                          }
                                        : null,
                                    child: TranslatedText(
                                      text: "Set Reminder",
                                      targetLanguage: widget.preferredLanguage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
