import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local_db/database.dart';
import '../services/habit_crud_service.dart';

/// Data class holding loaded habit state for editing.
class LoadedHabitData {
  final Habit habit;
  final ReminderPreference? reminder;

  const LoadedHabitData({
    required this.habit,
    this.reminder,
  });
}

/// Handles loading habit data for edit mode.
class HabitLoadHandler {
  final WidgetRef ref;

  HabitLoadHandler(this.ref);

  /// Load habit detail by ID for editing.
  Future<LoadedHabitData?> loadHabitForEdit(String habitId) async {
    final detail = await ref
        .read(habitCrudServiceProvider)
        .getHabitDetail(habitId);
    
    if (detail == null) return null;
    
    return LoadedHabitData(
      habit: detail.habit,
      reminder: detail.reminder,
    );
  }
}
