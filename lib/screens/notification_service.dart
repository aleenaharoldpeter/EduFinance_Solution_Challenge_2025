// notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz; // Import timezone data for scheduling notifications.
import 'package:timezone/timezone.dart' as tz; // Import timezone utilities.
import 'package:flutter/services.dart'; // For handling platform-specific exceptions.

class NotificationService {
  // Create a static instance of FlutterLocalNotificationsPlugin to manage notifications.
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initializes the notification service.
  // It sets up time zones and initializes notification settings for Android.
  static Future<void> initialize() async {
    tz.initializeTimeZones(); // Initialize all available time zones.
    
    // Define Android-specific initialization settings.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Create the overall initialization settings.
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    // Initialize the notification plugin with the defined settings.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Schedules a notification to be shown at a specific date and time.
  // Required parameters include notification id, title, body, and the scheduled date.
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Define Android-specific notification details.
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scholarship_channel_id', // Unique channel ID for the notifications.
      'Scholarship Notifications', // Channel name.
      channelDescription: 'Notifications for upcoming scholarship deadlines', // Channel description.
      importance: Importance.max, // Set importance to maximum to make sure notification is prominent.
      priority: Priority.high, // Set high priority for immediate display.
    );

    // Wrap the Android-specific details into NotificationDetails.
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
    
    // Convert the provided scheduled DateTime into a TZDateTime in the local timezone.
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    try {
      // Schedule the notification using zonedSchedule to account for time zones.
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id, // Unique notification ID.
        title, // Notification title.
        body, // Notification body.
        tzScheduledDate, // When the notification should be shown.
        notificationDetails, // Notification configuration details.
        payload: null, // Optional payload for handling notification taps.
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Ensures notifications fire exactly at scheduled time even in idle mode.
        matchDateTimeComponents: null, // No recurrence; notification fires only once.
      );
    } on PlatformException catch (e) {
      // Handle specific exception for exact alarms not permitted.
      if (e.code == "exact_alarms_not_permitted") {
        // Throw an exception with a user-friendly message to enable exact alarms.
        throw Exception("Exact alarms are not permitted. Please enable exact alarms in your device settings.");
      }
      // Rethrow any other exceptions.
      rethrow;
    }
  }
}
