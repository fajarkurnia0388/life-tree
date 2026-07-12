import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/value_compass/services/value_compass_service.dart';

/// Session-window behavior for Value Mirror (1-hour upsert window).
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ValueCompassService service;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    service = container.read(valueCompassServiceProvider);

    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: 'user-mirror',
            ageBand: '18-24',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  test('double answer in same session upserts single response', () async {
    await service.recordBinaryResponse(
      userId: 'user-mirror',
      dilemmaKey: 'dilemma_session_01',
      chosenOptionLabel: 'A',
      chosenValueTag: 'Stabilitas',
    );

    await service.recordBinaryResponse(
      userId: 'user-mirror',
      dilemmaKey: 'dilemma_session_01',
      chosenOptionLabel: 'B',
      chosenValueTag: 'Kebebasan',
    );

    final responses = await db.select(db.valueDilemmaResponses).get();
    expect(responses, hasLength(1));
    expect(responses.first.chosenOptionLabel, 'B');
    expect(responses.first.chosenValueTag, 'Kebebasan');

    final profile = await (db.select(db.userProfiles)
          ..where((t) => t.userId.equals('user-mirror')))
        .getSingle();
    // Full recompute keeps latest tags only once per active response.
    expect(profile.revealedValueScores?['Kebebasan'], 1);
    expect(profile.revealedValueScores?['Stabilitas'], isNull);
  });

  test('different dilemmas in same session create separate rows', () async {
    await service.recordBinaryResponse(
      userId: 'user-mirror',
      dilemmaKey: 'dilemma_a',
      chosenOptionLabel: 'A',
      chosenValueTag: 'Stabilitas',
    );
    await service.recordBinaryResponse(
      userId: 'user-mirror',
      dilemmaKey: 'dilemma_b',
      chosenOptionLabel: 'B',
      chosenValueTag: 'Kebebasan',
    );

    final responses = await db.select(db.valueDilemmaResponses).get();
    expect(responses, hasLength(2));
  });

  test('neutral response does not write value tag scores', () async {
    await service.recordNeutralResponse(
      userId: 'user-mirror',
      dilemmaKey: 'dilemma_neutral',
      neutralLabel: 'Both',
    );

    final profile = await (db.select(db.userProfiles)
          ..where((t) => t.userId.equals('user-mirror')))
        .getSingle();
    expect(profile.revealedValueScores, isNull);

    final responses = await db.select(db.valueDilemmaResponses).get();
    expect(responses, hasLength(1));
    expect(responses.first.chosenOptionLabel, 'Both');
    expect(responses.first.chosenValueTag, isNull);
  });
}
