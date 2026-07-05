/// Service to handle local notifications for habit reminders.
class NotificationService {
  /// Initializes the notification plugin for Android and iOS.
  static Future<void> initialize() async {
    // Local notifications are disabled in this build to keep the app runnable
    // across environments without extra platform setup.
  }

  /// Schedules a daily notification at a specific time.
  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // No-op for now.
  }

  /// Cancels a specific notification by ID.
  static Future<void> cancel(int id) async {}
}
