import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/animations/dialog_animations.dart';
import '../../../core/theme/button_theme.dart';
import '../../../data/local_db/database.dart';
import '../../cultivation/cultivation_strings.dart';
import '../../cultivation/cultivation_constants.dart';
import '../../dashboard/dashboard_provider.dart';
import '../services/habit_crud_service.dart';
import '../../../core/services/notification_service.dart';

/// Handles habit deletion logic extracted from AddHabitView.
class HabitDeleteHandler {
  final WidgetRef ref;
  final BuildContext context;

  HabitDeleteHandler(this.ref, this.context);

  /// Delete habit with confirmation dialog.
  Future<void> deleteHabit({
    required Habit existingHabit,
    required DaojiVocabularyLevel vocabularyLevel,
    required CultivationLanguageLevel languageLevel,
  }) async {
    final proceed = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${DaojiText.resolve(DaojiTextKey.habitDelete, vocabularyLevel)} ${CultivationStrings.habitLabel(languageLevel)}',
          ),
          content: Text(
            DaojiText.resolve(
              DaojiTextKey.habitDeleteConfirm,
              vocabularyLevel,
              params: {
                'label': CultivationStrings.habitLabel(
                  languageLevel,
                ).toLowerCase(),
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: AppButtonStyles.secondary(context),
              child: Text(
                DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
              ),
            ),
            TextButton(
              style: AppButtonStyles.text(context),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                DaojiText.resolve(DaojiTextKey.systemDelete, vocabularyLevel),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (proceed != true) return;

    await ref
        .read(habitCrudServiceProvider)
        .deleteHabit(existingHabit.habitId);

    await NotificationService.cancelHabit(existingHabit.habitId);

    ref.invalidate(dashboardDataProvider);

    if (context.mounted) {
      context.pop();
    }
  }
}
