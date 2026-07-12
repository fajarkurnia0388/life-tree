import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/services/snackbar_service.dart';
import '../../../data/local_db/database.dart';
import '../../cultivation/cultivation_strings.dart';
import '../../cultivation/cultivation_constants.dart';
import '../../dashboard/dashboard_provider.dart';
import '../services/habit_crud_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/providers/user_profile_provider.dart';

/// Handles habit save/update logic extracted from AddHabitView.
class HabitSaveHandler {
  final WidgetRef ref;
  final BuildContext context;

  HabitSaveHandler(this.ref, this.context);

  /// Validate capacity and show warning dialog if needed.
  Future<bool> _checkCapacity({
    required bool isEditing,
    required Habit? existingHabit,
    required int initiationFriction,
    required int energyCost,
    required List<Habit> activeHabits,
    required DaojiVocabularyLevel vocabularyLevel,
    required CultivationLanguageLevel languageLevel,
  }) async {
    final currentLoad = activeHabits.fold<int>(
      0,
      (sum, h) => sum + h.initiationFriction + h.energyCost,
    );

    int nextLoad = currentLoad;
    if (isEditing && existingHabit != null) {
      nextLoad = currentLoad -
          (existingHabit.initiationFriction + existingHabit.energyCost) +
          initiationFriction +
          energyCost;
    } else {
      nextLoad = currentLoad + initiationFriction + energyCost;
    }

    final profile = await ref.read(userProfileProvider.future);
    final maxCapacity = profile?.canopyLoadCapacity ?? 10;

    if (nextLoad > maxCapacity) {
      if (!context.mounted) return false;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              DaojiText.resolve(
                DaojiTextKey.habitCapacityWarning,
                vocabularyLevel,
              ),
            ),
            content: Text(
              DaojiText.resolve(
                DaojiTextKey.habitCapacityWarningBody,
                vocabularyLevel,
                params: {
                  'maxCapacity': maxCapacity,
                  'nextLoad': nextLoad,
                  'label': CultivationStrings.habitLabel(
                    languageLevel,
                  ).toLowerCase(),
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  DaojiText.resolve(
                    DaojiTextKey.actionUnderstand,
                    vocabularyLevel,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return proceed == true;
    }
    return true;
  }

  /// Sync reminder with notification service.
  Future<void> _syncReminder(
    String habitId,
    bool reminderEnabled,
    String reminderTime,
    String frequency,
    Set<int> selectedDays,
    String quietHoursStart,
    String quietHoursEnd,
    String habitTitle,
    DaojiVocabularyLevel vocabularyLevel,
  ) async {
    if (!reminderEnabled) {
      await NotificationService.cancelHabit(habitId);
      return;
    }

    final parts = reminderTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    await NotificationService.scheduleHabitReminder(
      habitId: habitId,
      title: DaojiText.resolve(
        DaojiTextKey.habitReminderTitle,
        vocabularyLevel,
        params: {'title': habitTitle},
      ),
      body: DaojiText.resolve(DaojiTextKey.habitReminderBody, vocabularyLevel),
      hour: hour,
      minute: minute,
      weekdays: frequency == HabitFrequency.daily ? const {} : selectedDays,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );
  }

  /// Save or update habit with full validation.
  Future<bool> saveHabit({
    required GlobalKey<FormState> formKey,
    required bool isEditing,
    required Habit? existingHabit,
    required String userId,
    required String domainTag,
    required String title,
    required String goalTag,
    required int initiationFriction,
    required int energyCost,
    required int impactScore,
    required int mvaDurationMin,
    required String frequency,
    required Set<int> selectedDays,
    required String? stackedToHabitId,
    required bool reminderEnabled,
    required String reminderTime,
    required String quietHoursStart,
    required String quietHoursEnd,
    required DaojiVocabularyLevel vocabularyLevel,
    required CultivationLanguageLevel languageLevel,
  }) async {
    if (!formKey.currentState!.validate()) return false;

    final now = DateTime.now();

    final activeHabits = await ref
        .read(habitCrudServiceProvider)
        .getActiveHabits(userId);

    // --- Anti-Guilt Protection: block NEW habit creation during low well-being ---
    if (!isEditing) {
      final dashboardAsync = ref.read(dashboardDataProvider);
      final isLowWellBeing =
          dashboardAsync.whenOrNull(data: (d) => d.isLowWellBeing) ?? false;
      if (isLowWellBeing) {
        if (!context.mounted) return false;
        SnackBarService.showInfo(
          context,
          DaojiText.resolve(DaojiTextKey.marketRestPrompt, vocabularyLevel),
        );
        return false;
      }
    }

    // Check capacity
    final capacityOk = await _checkCapacity(
      isEditing: isEditing,
      existingHabit: existingHabit,
      initiationFriction: initiationFriction,
      energyCost: energyCost,
      activeHabits: activeHabits,
      vocabularyLevel: vocabularyLevel,
      languageLevel: languageLevel,
    );
    if (!capacityOk) return false;

    final scheduledDaysStr = frequency == 'Daily'
        ? null
        : selectedDays.isEmpty
            ? '1'
            : selectedDays.join(',');

    if (isEditing && existingHabit != null) {
      final habitId = existingHabit.habitId;
      await ref.read(habitCrudServiceProvider).updateHabit(
            habitId: habitId,
            domainTag: domainTag,
            title: title.trim(),
            frequency: frequency,
            scheduledDays: scheduledDaysStr,
            initiationFriction: initiationFriction,
            energyCost: energyCost,
            impactScore: impactScore,
            mvaDurationMin: mvaDurationMin,
            stackedToHabitId: stackedToHabitId,
            goalTag: goalTag.trim().isEmpty ? null : goalTag.trim(),
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime,
            quietHoursStart: quietHoursStart,
            quietHoursEnd: quietHoursEnd,
          );

      try {
        if (reminderEnabled) {
          final hasPermission = await NotificationService.requestPermission();
          if (!hasPermission && context.mounted) {
            SnackBarService.showWarning(
              context,
              'Izin notifikasi ditolak. Pengingat tidak akan aktif.',
            );
          }
        }
        await _syncReminder(
          habitId,
          reminderEnabled,
          reminderTime,
          frequency,
          selectedDays,
          quietHoursStart,
          quietHoursEnd,
          title,
          vocabularyLevel,
        );
      } catch (e) {
        if (context.mounted) {
          SnackBarService.showWarning(
            context,
            'Kebiasaan tersimpan, tapi pengingat gagal diaktifkan: $e',
          );
        }
      }
    } else {
      final habitId = const Uuid().v4();
      final newHabit = HabitsCompanion.insert(
        habitId: habitId,
        userId: userId,
        domainTag: drift.Value(domainTag),
        title: title.trim(),
        status: const drift.Value(HabitStatus.active),
        frequency: drift.Value(frequency),
        scheduledDays: drift.Value(scheduledDaysStr),
        initiationFriction: drift.Value(initiationFriction),
        originalFriction: drift.Value(initiationFriction),
        energyCost: drift.Value(energyCost),
        impactScore: drift.Value(impactScore),
        mvaDurationMin: drift.Value(mvaDurationMin),
        stackedToHabitId: drift.Value(stackedToHabitId),
        createdAt: now,
        goalTag: drift.Value(
          goalTag.trim().isEmpty ? null : goalTag.trim(),
        ),
      );

      final reminder = ReminderPreferencesCompanion(
        habitId: drift.Value(habitId),
        reminderEnabled: drift.Value(reminderEnabled),
        reminderTime: drift.Value(reminderTime),
        quietHoursStart: drift.Value(quietHoursStart),
        quietHoursEnd: drift.Value(quietHoursEnd),
      );

      await ref
          .read(habitCrudServiceProvider)
          .createHabit(newHabit: newHabit, reminder: reminder);

      try {
        if (reminderEnabled) {
          final hasPermission = await NotificationService.requestPermission();
          if (!hasPermission && context.mounted) {
            SnackBarService.showWarning(
              context,
              'Izin notifikasi ditolak. Pengingat tidak akan aktif.',
            );
          }
        }
        await _syncReminder(
          habitId,
          reminderEnabled,
          reminderTime,
          frequency,
          selectedDays,
          quietHoursStart,
          quietHoursEnd,
          title,
          vocabularyLevel,
        );
      } catch (e) {
        if (context.mounted) {
          SnackBarService.showWarning(
            context,
            'Kebiasaan tersimpan, tapi pengingat gagal diaktifkan: $e',
          );
        }
      }
    }

    ref.invalidate(dashboardDataProvider);
    return true;
  }
}
