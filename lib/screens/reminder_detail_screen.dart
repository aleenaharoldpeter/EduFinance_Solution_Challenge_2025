import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'translated_text.dart';
import 'dart:async';

// ReminderDetailScreen displays details about a specific reminder,
// including scholarship info and a real-time countdown to the deadline.
class ReminderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> reminder; // Contains reminder data (e.g., scholarship details).
  final String preferredLanguage; // Used for UI translations.
  
  const ReminderDetailScreen({Key? key, required this.reminder, required this.preferredLanguage}) : super(key: key);

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  late Timer _timer; // Timer to update the countdown every second.
  String _countdown = ""; // Holds the formatted countdown string.

  // _getCountdown calculates the remaining time until the deadline.
  // Returns a formatted string (days, hours, minutes, seconds) or "Expired" if deadline has passed.
  String _getCountdown(String deadlineStr) {
    try {
      // Parse the deadline string using a specific date format.
      DateTime deadline = DateFormat('dd-MM-yyyy').parse(deadlineStr);
      Duration remaining = deadline.difference(DateTime.now());
      // If the deadline is in the past, return "Expired".
      if (remaining.isNegative) {
        return "Expired";
      }
      // Format the remaining duration into days, hours, minutes, and seconds.
      return "${remaining.inDays}d ${remaining.inHours % 24}h ${remaining.inMinutes % 60}m ${remaining.inSeconds % 60}s";
    } catch (e) {
      // Return an empty string if parsing fails.
      return "";
    }
  }

  // _updateCountdown refreshes the _countdown string by calculating the remaining time.
  void _updateCountdown() {
    setState(() {
      _countdown = _getCountdown(widget.reminder["deadline"] ?? "");
    });
  }

  @override
  void initState() {
    super.initState();
    _updateCountdown(); // Initialize countdown immediately.
    // Set up a timer that calls _updateCountdown every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to free resources.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract various properties from the reminder map for display.
    final scholarshipID = widget.reminder["scholarshipID"] ?? "";
    final state = widget.reminder["state"] ?? "";
    final qualification = widget.reminder["qualification"] ?? "";
    final category = widget.reminder["category"] ?? "";
    final amount = widget.reminder["amount"] ?? "";
    final timestamp = widget.reminder["timestamp"];
    
    return Scaffold(
      appBar: AppBar(
        // Display a translated title for the screen.
        title: TranslatedText(text: "Reminder Details", targetLanguage: widget.preferredLanguage),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Overall padding for the content.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the name of the scholarship/reminder, styled as a header.
              TranslatedText(
                text: widget.reminder["name"] ?? "",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Display the scholarship ID.
              TranslatedText(
                text: "Scholarship ID: $scholarshipID",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              // Display the state of the scholarship.
              TranslatedText(
                text: "State: $state",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              // Display the qualification requirement.
              TranslatedText(
                text: "Qualification: $qualification",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              // Display the scholarship category.
              TranslatedText(
                text: "Category: $category",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              // Display the scholarship amount.
              TranslatedText(
                text: "Amount: ₹$amount",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              // Display the deadline for the scholarship.
              TranslatedText(
                text: "Deadline: ${widget.reminder["deadline"]}",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              // If a timestamp exists, display the creation timestamp of the reminder.
              if (timestamp != null)
                TranslatedText(
                  text: "Created: $timestamp",
                  targetLanguage: widget.preferredLanguage,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              const SizedBox(height: 10),
              // Display the live countdown, styled in red.
              TranslatedText(
                text: "Countdown: $_countdown",
                targetLanguage: widget.preferredLanguage,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
