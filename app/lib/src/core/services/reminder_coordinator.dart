import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/local_db/database.dart';
import '../providers/db_provider.dart';
import '../i18n/daoji_vocabulary_provider.dart';
import '../i18n/daoji_vocabulary_level.dart';
import '../i18n/daoji_text_resolver.dart';
import '../i18n/daoji_text_key.dart';
import '../domain/app_constants.dart';
import 'notification_service.dart';

class ReminderCoordinator {
  final AppDatabase db;
  final Ref? ref;

  ReminderCoordinator(this.db, [this.ref]);

  Future<void> cancelAll(String userId) async {
    final habits = await (db.select(db.habits)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull()))
        .get();
    for (final habit in habits) {
      await NotificationService.cancelHabit(habit.habitId);
    }
  }

  Future<void> reconcileAll(String userId) async {
    final userProfile = await (db.select(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId))
          ..limit(1))
        .getSingleOrNull();

    final habits = await (db.select(db.habits)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull()))
        .get();

    // If user is in Recovery mode, cancel all notifications
    if (userProfile != null && userProfile.supportMode == SupportMode.recovery) {
      for (final habit in habits) {
        await NotificationService.cancelHabit(habit.habitId);
      }
      return;
    }

    final vocabularyLevel = ref?.read(daojiVocabularyLevelValueProvider) ?? DaojiVocabularyLevel.earth;

    for (final habit in habits) {
      final reminder = await (db.select(db.reminderPreferences)
            ..where((tbl) => tbl.habitId.equals(habit.habitId)))
          .getSingleOrNull();

      if (reminder != null && reminder.reminderEnabled) {
        final parts = reminder.reminderTime.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]) ?? 8;
          final minute = int.tryParse(parts[1]) ?? 0;

          final weekdays = <int>{};
          if (habit.frequency == HabitFrequency.weekly && habit.scheduledDays != null) {
            final days = habit.scheduledDays!
                .split(',')
                .map((e) => int.tryParse(e))
                .whereType<int>()
                .toSet();
            weekdays.addAll(days);
          }

          await NotificationService.scheduleHabitReminder(
            habitId: habit.habitId,
            title: DaojiText.resolve(
              DaojiTextKey.habitReminderTitle,
              vocabularyLevel,
              params: {'title': habit.title},
            ),
            body: DaojiText.resolve(DaojiTextKey.habitReminderBody, vocabularyLevel),
            hour: hour,
            minute: minute,
            weekdays: weekdays,
            quietHoursStart: reminder.quietHoursStart,
            quietHoursEnd: reminder.quietHoursEnd,
          );
        }
      } else {
        await NotificationService.cancelHabit(habit.habitId);
      }
    }
  }
}

final reminderCoordinatorProvider = Provider<ReminderCoordinator>((ref) {
  return ReminderCoordinator(ref.watch(dbProvider), ref);
});
