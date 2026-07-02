import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/value_compass/services/value_compass_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ValueCompassService service;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );
    service = container.read(valueCompassServiceProvider);

    // Seed a user profile first so we can update it
    await db.into(db.userProfiles).insert(
      UserProfilesCompanion.insert(
        userId: 'user-123',
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

  group('ValueCompassService Tests', () {
    test('recordBinaryResponse stores response and updates userProfile score tally', () async {
      await service.recordBinaryResponse(
        userId: 'user-123',
        dilemmaKey: 'stabilitas_vs_kebebasan_01',
        chosenOptionLabel: 'A',
        chosenValueTag: 'Stabilitas',
      );

      final profile = await (db.select(db.userProfiles)..where((tbl) => tbl.userId.equals('user-123'))).getSingle();
      expect(profile.revealedValueScores, isNotNull);

      final Map<String, dynamic> tally = jsonDecode(profile.revealedValueScores!);
      expect(tally['Stabilitas'], 1);
      expect(profile.revealedValueLastUpdatedAt, isNotNull);
    });

    test('recordOpenResponse stores open text response but does not update score tally', () async {
      await service.recordOpenResponse(
        userId: 'user-123',
        dilemmaKey: 'open_no_judgment_01',
        text: 'Melakukan meditasi 1 jam',
      );

      final profile = await (db.select(db.userProfiles)..where((tbl) => tbl.userId.equals('user-123'))).getSingle();
      expect(profile.revealedValueScores, isNull);

      final count = await db.select(db.valueDilemmaResponses).get();
      expect(count.length, 1);
      expect(count.first.openTextResponse, 'Melakukan meditasi 1 jam');
    });

    test('getTopRevealedValues returns empty list when response count is below minResponses', () async {
      // Record 4 responses (below minResponses = 5)
      for (int i = 0; i < 4; i++) {
        await service.recordBinaryResponse(
          userId: 'user-123',
          dilemmaKey: 'dilemma_$i',
          chosenOptionLabel: 'A',
          chosenValueTag: 'Stabilitas',
        );
      }

      final profile = await (db.select(db.userProfiles)..where((tbl) => tbl.userId.equals('user-123'))).getSingle();
      final topValues = await service.getTopRevealedValues(profile: profile, minResponses: 5);
      expect(topValues, isEmpty);
    });

    test('getTopRevealedValues returns top-N ordered values when count is at or above minResponses', () async {
      // Record 3 Kebebasan, 2 Stabilitas, 1 Kejujuran (Total 6 responses >= 5)
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd1', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd2', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd3', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd4', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd5', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd6', chosenOptionLabel: 'A', chosenValueTag: 'Kejujuran');

      final profile = await (db.select(db.userProfiles)..where((tbl) => tbl.userId.equals('user-123'))).getSingle();
      final topValues = await service.getTopRevealedValues(profile: profile, topN: 2, minResponses: 5);

      expect(topValues.length, 2);
      expect(topValues[0], 'Kebebasan');
      expect(topValues[1], 'Stabilitas');
    });

    test('getTopRevealedValues performs alphabetical tie-break for equal score values', () async {
      // 3 Stabilitas, 3 Kebebasan (Total 6 responses >= 5)
      // Alphabetical order: Kebebasan < Stabilitas
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd1', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd2', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd3', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd4', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd5', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd6', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');

      final profile = await (db.select(db.userProfiles)..where((tbl) => tbl.userId.equals('user-123'))).getSingle();
      final topValues = await service.getTopRevealedValues(profile: profile, topN: 2, minResponses: 5);

      expect(topValues[0], 'Kebebasan'); // K comes before S
      expect(topValues[1], 'Stabilitas');
    });

    test('soft-deleted responses are ignored in tally calculations', () async {
      // Insert 5 responses
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd1', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd2', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd3', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd4', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd5', chosenOptionLabel: 'B', chosenValueTag: 'Kebebasan');

      // Soft delete one Kebebasan
      await (db.update(db.valueDilemmaResponses)..where((tbl) => tbl.dilemmaKey.equals('d3')))
          .write(ValueDilemmaResponsesCompanion(deletedAt: drift.Value(DateTime.now())));

      // Trigger recalculation of tally
      // (ValueCompassService recalculates full tally inside private _recomputeRevealedValues,
      // so we call recordBinaryResponse or we can manually run update)
      await service.recordBinaryResponse(userId: 'user-123', dilemmaKey: 'd6', chosenOptionLabel: 'A', chosenValueTag: 'Stabilitas');

      final profile = await (db.select(db.userProfiles)..where((tbl) => tbl.userId.equals('user-123'))).getSingle();
      final Map<String, dynamic> tally = jsonDecode(profile.revealedValueScores!);

      // Stabilitas should be 3, Kebebasan should be 2 (since d3 is soft-deleted)
      expect(tally['Stabilitas'], 3);
      expect(tally['Kebebasan'], 2);
    });
  });
}
