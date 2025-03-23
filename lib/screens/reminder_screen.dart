import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'translated_text.dart';
import 'package:intl/intl.dart';
import 'reminder_detail_screen.dart';
import 'user_preferences.dart';

// ReminderScreen displays a list of reminders and allows users to delete or view details for each reminder.
class ReminderScreen extends StatefulWidget {
  final String preferredLanguage; // Current language for UI translation.

  const ReminderScreen({Key? key, required this.preferredLanguage})
      : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> reminders = []; // List to hold reminder data.
  late AnimationController _animationController; // Controls animation for urgent reminders.
  Timer? _timer; // Timer to update the countdown every second.

  // Loads reminders from SharedPreferences using a user-specific key.
  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    String key = userKey('reminders');
    List<String> stored = prefs.getStringList(key) ?? [];
    setState(() {
      // Parse each stored JSON string into a Map and update the reminders list.
      reminders =
          stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  // Helper to compute the remaining time until the deadline.
  // Returns a formatted string or "Expired" if the deadline has passed.
  String _getCountdown(String deadlineStr) {
    try {
      // Parse the deadline string using the given date format.
      DateTime deadline = DateFormat('dd-MM-yyyy').parse(deadlineStr);
      Duration remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative) {
        return "Expired"; // Deadline has passed.
      }
      // Format the remaining duration into days, hours, minutes, and seconds.
      return "${remaining.inDays}d ${remaining.inHours % 24}h ${remaining.inMinutes % 60}m ${remaining.inSeconds % 60}s";
    } catch (e) {
      // Return an empty string if parsing fails.
      return "";
    }
  }

  // Deletes a reminder at the specified index after user confirmation.
  Future<void> _deleteReminder(int index) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this reminder?"),
          actions: [
            // Cancel deletion.
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            // Confirm deletion.
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete")),
          ],
        );
      },
    );
    if (confirmed) {
      final prefs = await SharedPreferences.getInstance();
      String key = userKey('reminders');
      reminders.removeAt(index); // Remove the reminder from the list.
      // Encode the updated reminders list and save it back to SharedPreferences.
      List<String> stored = reminders.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList(key, stored);
      setState(() {}); // Refresh the UI.
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReminders(); // Load reminders when the screen is initialized.
    // Initialize the animation controller with a duration of 1 second.
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true); // Repeatedly animate for urgent reminders.
    // Set up a timer to update the countdown every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); // Trigger a rebuild to update countdown values.
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose animation controller.
    _timer?.cancel(); // Cancel the timer.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Translated title for the reminders screen.
        title: TranslatedText(
            text: "Reminders", targetLanguage: widget.preferredLanguage),
      ),
      // If there are no reminders, display a message; otherwise, build the list.
      body: reminders.isEmpty
          ? Center(
              child: TranslatedText(
                  text: "No reminders set.",
                  targetLanguage: widget.preferredLanguage))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                // Calculate the countdown string for the reminder.
                String countdown = _getCountdown(reminder["deadline"] ?? "");
                // Determine if the reminder is urgent (deadline is within 0 days).
                bool isUrgent =
                    countdown != "Expired" && countdown.startsWith("0d");
                // Use AnimatedBuilder to animate urgent reminders.
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // Calculate horizontal offset for a shaking effect if urgent.
                    double offset =
                        isUrgent ? 4.0 * _animationController.value : 0;
                    // Build a subtitle string concatenating reminder details.
                    String subtitleText =
                        "ID: ${reminder["scholarshipID"] ?? 'N/A'}\n"
                        "Deadline: ${reminder["deadline"]}\n"
                        "Countdown: $countdown";
                    return Transform.translate(
                      offset: Offset(offset, 0), // Apply horizontal translation.
                      child: ListTile(
                        // Display the reminder name using the translated text widget.
                        title: TranslatedText(
                          text: reminder["name"] ?? "",
                          targetLanguage: widget.preferredLanguage,
                        ),
                        // Display concatenated details as the subtitle.
                        subtitle: TranslatedText(
                          text: subtitleText,
                          targetLanguage: widget.preferredLanguage,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        isThreeLine: true, // Allow three lines for subtitle.
                        // Delete icon button to remove the reminder.
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReminder(index),
                        ),
                        // Navigate to ReminderDetailScreen on tap.
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReminderDetailScreen(
                                reminder: reminder,
                                preferredLanguage: widget.preferredLanguage,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
