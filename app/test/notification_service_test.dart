import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:daoji/src/core/services/notification_service.dart';

void main() {
  tz_data.initializeTimeZones();
  final jakarta = tz.getLocation('Asia/Jakarta');
  tz.setLocalLocation(jakarta);

  group('NotificationService nextInstanceOfTime Tests', () {
    test('Schedules for today if time is in the future', () {
      final now = tz.TZDateTime(jakarta, 2026, 7, 9, 7, 0); // 07:00 AM
      final target = NotificationService.nextInstanceOfTime(8, 0, nowOverride: now); // Target 08:00 AM

      expect(target.year, 2026);
      expect(target.month, 7);
      expect(target.day, 9);
      expect(target.hour, 8);
      expect(target.minute, 0);
    });

    test('Schedules for tomorrow if time is in the past', () {
      final now = tz.TZDateTime(jakarta, 2026, 7, 9, 9, 0); // 09:00 AM
      final target = NotificationService.nextInstanceOfTime(8, 0, nowOverride: now); // Target 08:00 AM

      expect(target.year, 2026);
      expect(target.month, 7);
      expect(target.day, 10); // Tomorrow!
      expect(target.hour, 8);
      expect(target.minute, 0);
    });
  });
}
