import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:life_tree/src/core/providers/db_provider.dart';
import 'package:life_tree/src/data/local_db/database.dart';
import 'package:life_tree/src/features/decision_journal/decision_journal_view.dart';

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
}
