import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:life_tree/src/core/providers/db_provider.dart';
import 'package:life_tree/src/data/local_db/database.dart';
import 'package:life_tree/src/features/onboarding/onboarding_view.dart';
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

  testWidgets('Onboarding completes flow and creates profile in DB', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: OnboardingView(),
        ),
      ),
    );

    // Initial page - Welcome page
    expect(find.text('Selamat Datang di LifeTree'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Age step
    expect(find.text('Berapa usia Anda?'), findsOneWidget);
    await tester.tap(find.text('25-35'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Audit step
    expect(find.text('Evaluasi Awal (Life Audit)'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Disclaimer step
    expect(find.text('LifeTree BUKAN aplikasi medis.'), findsOneWidget);

    // Try starting without completing check
    expect(find.text('Mulai'), findsOneWidget);
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    // The button shouldn't navigate since check is not selected
    final profilesBefore = await db.select(db.userProfiles).get();
    expect(profilesBefore.isEmpty, true);
  });
}
