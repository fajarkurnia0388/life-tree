import 'package:flutter/material.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/theme/form_theme.dart';
import '../../../data/local_db/database.dart';

/// Form fields section for habit creation/editing.
/// Includes domain dropdown, title, goal, and routine stacking.
class HabitFormFieldsWidget extends StatelessWidget {
  final String domainTag;
  final List<String> domainTags;
  final ValueChanged<String> onDomainTagChanged;
  final TextEditingController titleController;
  final TextEditingController goalTagController;
  final DaojiVocabularyLevel vocabularyLevel;
  final Future<List<Habit>> habitsFuture;
  final String? currentHabitId;
  final String? stackedToHabitId;
  final ValueChanged<String?> onStackedToHabitIdChanged;

  const HabitFormFieldsWidget({
    super.key,
    required this.domainTag,
    required this.domainTags,
    required this.onDomainTagChanged,
    required this.titleController,
    required this.goalTagController,
    required this.vocabularyLevel,
    required this.habitsFuture,
    this.currentHabitId,
    required this.stackedToHabitId,
    required this.onStackedToHabitIdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.habitCategory, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(domainTag),
          initialValue: domainTag,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: domainTags
              .map(
                (val) => DropdownMenuItem(
                  value: val,
                  child: Text(
                    DaojiText.domainLabel(
                      val,
                      vocabularyLevel,
                      short: true,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              onDomainTagChanged(val);
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: titleController,
          decoration: AppFormTheme.inputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.habitNameLabel,
              vocabularyLevel,
            ),
            hintText: 'Misal: Jalan kaki pagi',
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: AppFormTheme.habitTitleValidator,
        ),
        const SizedBox(height: 20),
        Text(
          '${DaojiText.resolve(DaojiTextKey.habitGoalLabel, vocabularyLevel)} (Opsional) 🎯',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: goalTagController,
          decoration: AppFormTheme.inputDecoration(
            labelText: 'Nama Target / Goal',
            hintText: 'Misal: Menurunkan berat badan 5kg',
            prefixIcon: const Icon(Icons.track_changes_rounded),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) =>
              AppFormTheme.optionalTextValidator(v, maxLength: 100),
        ),
        const SizedBox(height: 20),
        const Text(
          'Routine Stacking (Jangkar Kebiasaan) ☕',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Habit>>(
          future: habitsFuture,
          builder: (context, snapshot) {
            final habits = snapshot.data ?? [];
            final validHabits = habits
                .where((h) => h.habitId != currentHabitId)
                .toList();

            return DropdownButtonFormField<String?>(
              initialValue: stackedToHabitId,
              decoration: AppFormTheme.inputDecoration(
                labelText: 'Pilih Kebiasaan Pemicu',
                hintText: 'Dilakukan segera setelah...',
                prefixIcon: const Icon(Icons.link_rounded),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tanpa Stacking (Mulai Mandiri)'),
                ),
                ...validHabits.map(
                  (h) => DropdownMenuItem<String?>(
                    value: h.habitId,
                    child: Text('Setelah selesai "${h.title}"'),
                  ),
                ),
              ],
              onChanged: (val) {
                onStackedToHabitIdChanged(val);
              },
            );
          },
        ),
      ],
    );
  }
}
