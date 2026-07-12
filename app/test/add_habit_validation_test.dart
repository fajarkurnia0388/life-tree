import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/core/theme/form_theme.dart';
import 'package:daoji/src/features/habit/widgets/habit_form_fields_widget.dart';
import 'package:daoji/src/core/i18n/daoji_vocabulary_level.dart';

void main() {
  group('AppFormTheme.habitTitleValidator', () {
    test('rejects empty title', () {
      expect(
        AppFormTheme.habitTitleValidator(null),
        'Judul kebiasaan tidak boleh kosong',
      );
      expect(
        AppFormTheme.habitTitleValidator(''),
        'Judul kebiasaan tidak boleh kosong',
      );
      expect(
        AppFormTheme.habitTitleValidator('   '),
        'Judul kebiasaan tidak boleh kosong',
      );
    });

    test('rejects title shorter than 3 characters', () {
      expect(
        AppFormTheme.habitTitleValidator('ab'),
        'Judul minimal 3 karakter',
      );
    });

    test('rejects title longer than 50 characters', () {
      final long = 'a' * 51;
      expect(
        AppFormTheme.habitTitleValidator(long),
        'Judul maksimal 50 karakter',
      );
    });

    test('accepts valid title', () {
      expect(AppFormTheme.habitTitleValidator('Jalan kaki'), isNull);
      expect(AppFormTheme.habitTitleValidator('Min'), isNull);
      expect(AppFormTheme.habitTitleValidator('a' * 50), isNull);
    });
  });

  group('HabitFormFieldsWidget validation UI', () {
    testWidgets('shows empty-title error after interaction', (tester) async {
      final titleController = TextEditingController();
      final goalController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: HabitFormFieldsWidget(
                domainTag: 'Tubuh',
                domainTags: const ['Tubuh', 'Keuangan'],
                onDomainTagChanged: (_) {},
                titleController: titleController,
                goalTagController: goalController,
                vocabularyLevel: DaojiVocabularyLevel.earth,
                habitsFuture: Future.value(const []),
                stackedToHabitId: null,
                onStackedToHabitIdChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Trigger onUserInteraction validation with empty value.
      await tester.enterText(find.byType(TextFormField).first, 'x');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.pump();

      expect(find.text('Judul kebiasaan tidak boleh kosong'), findsOneWidget);

      titleController.dispose();
      goalController.dispose();
    });

    testWidgets('shows min-length error for short title', (tester) async {
      final titleController = TextEditingController();
      final goalController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: HabitFormFieldsWidget(
                domainTag: 'Tubuh',
                domainTags: const ['Tubuh'],
                onDomainTagChanged: (_) {},
                titleController: titleController,
                goalTagController: goalController,
                vocabularyLevel: DaojiVocabularyLevel.earth,
                habitsFuture: Future.value(const []),
                stackedToHabitId: null,
                onStackedToHabitIdChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'ab');
      await tester.pump();

      expect(find.text('Judul minimal 3 karakter'), findsOneWidget);

      titleController.dispose();
      goalController.dispose();
    });
  });
}
