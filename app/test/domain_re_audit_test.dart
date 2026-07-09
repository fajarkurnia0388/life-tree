import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/features/profile/widgets/domain_re_audit_dialog.dart';
import 'package:daoji/src/data/local_db/database.dart';

void main() {
  testWidgets('DomainReAuditDialog renders and interacts correctly', (tester) async {
    final now = DateTime.now();
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // Insert profile with 'mortal' vocabulary level
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: 'test-user',
            ageBand: '18-24',
            vocabularyLevel: const drift.Value('mortal'),
            latestDomainScores: const drift.Value(
              '{"Tubuh":6.0,"Keuangan":5.0,"Hubungan":5.0,"Emosi":5.0,"Karir":5.0,"Rekreasi":5.0}',
            ),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final profile = (await db.select(db.userProfiles).get()).first;

    Map<String, double>? dialogResult;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    dialogResult = await showDialog<Map<String, double>>(
                      context: context,
                      builder: (context) => DomainReAuditDialog(profile: profile),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Open the dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify dialog title is rendered for 'mortal' level
    expect(find.text('Perbarui Penilaian Domain'), findsOneWidget);

    // Find sliders
    final sliders = find.byType(Slider);
    expect(sliders, findsNWidgets(6));

    // Tap save button (resolves to 'Save')
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify result is returned and contains initial or edited scores
    expect(dialogResult, isNotNull);
    expect(dialogResult!['Tubuh'], 6.0);

    await db.close();
  });
}
