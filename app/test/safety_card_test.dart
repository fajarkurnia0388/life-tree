import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:life_tree/src/core/providers/db_provider.dart';
import 'package:life_tree/src/data/local_db/database.dart';
import 'package:life_tree/src/features/safety/safety_card_view.dart';
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

  testWidgets('SafetyCardView logs hotline CTA taps in database', (tester) async {
    final userId = 'user-test-safety';
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

    // 2. Build the SafetyCardView widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SafetyCardView(),
        ),
      ),
    );

    // 3. Find and tap a hotline button (the ElevatedButton containing 'Hubungi')
    final callButton = find.textContaining('Hubungi');
    expect(callButton, findsAtLeastNWidgets(1));

    await tester.tap(callButton.first);
    await tester.pumpAndSettle();

    // 4. Verify that a WellnessPromptLog was created
    final logs = await db.select(db.wellnessPromptLogs).get();
    expect(logs.isNotEmpty, true);
    expect(logs.first.userAction, 'Tapped_Hotline_CTA');
  });
}
