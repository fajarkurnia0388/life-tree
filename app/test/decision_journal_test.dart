import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/decision_journal/decision_journal_view.dart';

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

  test('Decision journal stream provider watches entries correctly', () async {
    final now = DateTime.now();

    // 1. Add decision entry
    await db.into(db.decisionEntries).insert(
          DecisionEntriesCompanion.insert(
            decisionId: 'decision-1',
            userId: 'user-1',
            title: 'Beli laptop baru',
            description: 'Apakah harus beli Macbook Pro?',
            options: '["Macbook Pro", "Asus ROG"]',
            assumptions: '["Macbook awet", "ROG kuat game"]',
            expectations: 'Macbook awet 5 tahun',
            reviewPeriodDays: const drift.Value(90),
            decisionDate: now,
            reviewDate: now.add(const Duration(days: 90)),
            isReviewed: const drift.Value(false),
          ),
        );

    // 2. Read stream
    final list = await container.read(decisionListProvider.future);
    expect(list.length, 1);
    expect(list.first.title, 'Beli laptop baru');
  });

  test('Decision entry confidenceScore stores and retrieves correctly', () async {
    final now = DateTime.now();

    await db.into(db.decisionEntries).insert(
          DecisionEntriesCompanion.insert(
            decisionId: 'decision-2',
            userId: 'user-1',
            title: 'Keputusan Karir',
            description: 'Apakah pindah divisi?',
            options: '["Pindah", "Tetap"]',
            assumptions: '["Divisi baru seru"]',
            expectations: 'Karir berkembang',
            reviewPeriodDays: const drift.Value(90),
            decisionDate: now,
            reviewDate: now.add(const Duration(days: 90)),
            isReviewed: const drift.Value(false),
            confidenceScore: const drift.Value(75),
          ),
        );

    final list = await container.read(decisionListProvider.future);
    final careerDecision = list.firstWhere((d) => d.decisionId == 'decision-2');
    expect(careerDecision.confidenceScore, 75);
  });
}
