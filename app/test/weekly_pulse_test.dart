import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:life_tree/src/core/providers/db_provider.dart';
import 'package:life_tree/src/data/local_db/database.dart';
import 'package:life_tree/src/features/weekly_pulse/weekly_pulse_view.dart';
import 'package:flutter/material.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  testWidgets('WeeklyPulseView calculates WHO-5 scores and saves to DB', (tester) async {
    final userId = 'user-test-pulse';
    final now = DateTime.now();

    // 1. Populate user profiles
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '18-24',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 2. Build the WeeklyPulseView widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: WeeklyPulseView(),
        ),
      ),
    );

    // Initial page - Step 1
    expect(find.textContaining('Saya merasa ceria dan bersemangat'), findsOneWidget);

    // Tap 'Sepanjang waktu' (value 5) for all 5 questions
    for (int i = 0; i < 5; i++) {
      final option = find.text('Sepanjang waktu');
      expect(option, findsOneWidget);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    // Now we should be on the reflection text page
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Minggu yang luar biasa!');
    await tester.pumpAndSettle();

    // Tap Kirim
    final submitButton = find.text('Kirim');
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // 3. Verify database write
    final pulses = await db.select(db.weeklyPulses).get();
    expect(pulses.isNotEmpty, true);

    // Total raw score = 5 * 5 = 25.
    // Mapped score = (25 / 2.5).round() = 10.
    expect(pulses.first.score, 10);

    final reflection = jsonDecode(pulses.first.reflectionText!);
    expect(reflection['raw_total'], 25);
    expect(reflection['user_reflection'], 'Minggu yang luar biasa!');
  });
}
