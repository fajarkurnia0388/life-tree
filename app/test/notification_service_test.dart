import 'package:daoji/src/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  NotificationService.configureLocalTimeZone('Asia/Jakarta');
  final jakarta = tz.getLocation('Asia/Jakarta');

  group('NotificationService scheduling', () {
    test('schedules for today if time is in the future', () {
      final now = tz.TZDateTime(jakarta, 2026, 7, 9, 7);
      final target = NotificationService.nextInstanceOfTime(
        8,
        0,
        nowOverride: now,
      );

      expect(target, tz.TZDateTime(jakarta, 2026, 7, 9, 8));
    });

    test('schedules for tomorrow if time is past or exactly now', () {
      final past = tz.TZDateTime(jakarta, 2026, 7, 9, 9);
      expect(
        NotificationService.nextInstanceOfTime(8, 0, nowOverride: past),
        tz.TZDateTime(jakarta, 2026, 7, 10, 8),
      );

      final exact = tz.TZDateTime(jakarta, 2026, 7, 9, 8);
      expect(
        NotificationService.nextInstanceOfTime(8, 0, nowOverride: exact),
        tz.TZDateTime(jakarta, 2026, 7, 10, 8),
      );
    });

    test('weekly schedule advances to requested weekday', () {
      final thursday = tz.TZDateTime(jakarta, 2026, 7, 9, 9);
      final monday = NotificationService.nextInstanceOfWeekday(
        DateTime.monday,
        8,
        0,
        nowOverride: thursday,
      );
      expect(monday, tz.TZDateTime(jakarta, 2026, 7, 13, 8));
    });

    test('quiet hours move a reminder to quiet-hours end', () {
      expect(
        NotificationService.adjustForQuietHours(
          hour: 23,
          minute: 30,
          quietHoursStart: '22:00',
          quietHoursEnd: '07:00',
        ),
        (7, 0),
      );
      expect(
        NotificationService.adjustForQuietHours(
          hour: 8,
          minute: 0,
          quietHoursStart: '22:00',
          quietHoursEnd: '07:00',
        ),
        (8, 0),
      );
    });

    test('notification IDs are deterministic and slot-specific', () {
      final first = NotificationService.notificationIdForHabit('habit-uuid');
      expect(NotificationService.notificationIdForHabit('habit-uuid'), first);
      expect(
        NotificationService.notificationIdForHabit('habit-uuid', slot: 1),
        isNot(first),
      );
    });
  });
}
