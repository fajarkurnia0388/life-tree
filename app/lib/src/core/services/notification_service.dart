import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notification gateway for habit reminders.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _timeZonesInitialized = false;

  static bool get _isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Initializes timezone data and the native notification plugin.
  ///
  /// Daoji currently stores `Asia/Jakarta` in the user profile, so that is the
  /// safe default until timezone selection is exposed in settings.
  static Future<void> initialize({String timeZoneName = 'Asia/Jakarta'}) async {
    configureLocalTimeZone(timeZoneName);

    if (!_isSupported) {
      debugPrint(
        'NotificationService: Local notifications are not supported on this platform.',
      );
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  @visibleForTesting
  static void configureLocalTimeZone(String timeZoneName) {
    if (!_timeZonesInitialized) {
      tz_data.initializeTimeZones();
      _timeZonesInitialized = true;
    }
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } on ArgumentError {
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Stable notification ID independent of Dart's runtime [String.hashCode].
  @visibleForTesting
  static int notificationIdForHabit(String habitId, {int slot = 0}) {
    var hash = 0x811c9dc5;
    for (final codeUnit in habitId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    final id = (hash + (slot * 7919)) & 0x7fffffff;
    return id == 0 ? slot + 1 : id;
  }

  /// Schedules a reminder daily or only on selected weekdays.
  ///
  /// [weekdays] uses Dart weekday values (Monday=1 ... Sunday=7). Empty or all
  /// seven days means daily. A reminder inside quiet hours is moved to the end
  /// of the quiet window.
  static Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    Set<int> weekdays = const {},
    String quietHoursStart = '22:00',
    String quietHoursEnd = '07:00',
  }) async {
    if (!_isSupported) return;

    final adjusted = adjustForQuietHours(
      hour: hour,
      minute: minute,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );
    await cancelHabit(habitId);

    final validWeekdays = weekdays
        .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
        .toSet();
    if (validWeekdays.isEmpty || validWeekdays.length == 7) {
      await _schedule(
        id: notificationIdForHabit(habitId),
        title: title,
        body: body,
        scheduledDate: nextInstanceOfTime(adjusted.$1, adjusted.$2),
        match: DateTimeComponents.time,
      );
      return;
    }

    for (final weekday in validWeekdays) {
      await _schedule(
        id: notificationIdForHabit(habitId, slot: weekday),
        title: title,
        body: body,
        scheduledDate: nextInstanceOfWeekday(weekday, adjusted.$1, adjusted.$2),
        match: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required DateTimeComponents match,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Pengingat Kebiasaan',
          channelDescription: 'Pengingat kebiasaan dari Daoji',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: match,
    );
  }

  @visibleForTesting
  static (int, int) adjustForQuietHours({
    required int hour,
    required int minute,
    required String quietHoursStart,
    required String quietHoursEnd,
  }) {
    final reminder = (hour.clamp(0, 23) * 60) + minute.clamp(0, 59);
    final start = _parseMinutes(quietHoursStart);
    final end = _parseMinutes(quietHoursEnd);
    if (start == null || end == null || start == end) {
      return (hour.clamp(0, 23), minute.clamp(0, 59));
    }

    final inside = start < end
        ? reminder >= start && reminder < end
        : reminder >= start || reminder < end;
    return inside ? (end ~/ 60, end % 60) : (hour, minute);
  }

  static int? _parseMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;
    return (hour * 60) + minute;
  }

  @visibleForTesting
  static tz.TZDateTime nextInstanceOfTime(
    int hour,
    int minute, {
    tz.TZDateTime? nowOverride,
  }) {
    final now = nowOverride ?? tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @visibleForTesting
  static tz.TZDateTime nextInstanceOfWeekday(
    int weekday,
    int hour,
    int minute, {
    tz.TZDateTime? nowOverride,
  }) {
    final now = nowOverride ?? tz.TZDateTime.now(tz.local);
    final daysAhead = (weekday - now.weekday) % DateTime.daysPerWeek;
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysAhead,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: DateTime.daysPerWeek));
    }
    return scheduled;
  }

  static Future<void> cancel(int id) async {
    if (!_isSupported) return;
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelHabit(String habitId) async {
    if (!_isSupported) return;
    // Clean up reminders created by versions that used runtime hashCode.
    await cancel(habitId.hashCode.abs() % 100000);
    await cancel(notificationIdForHabit(habitId));
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await cancel(notificationIdForHabit(habitId, slot: weekday));
    }
  }
}
