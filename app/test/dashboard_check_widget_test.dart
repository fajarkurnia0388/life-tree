import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/dashboard/widgets/tree_season_overlays.dart';
import 'package:daoji/src/features/habit/services/habit_log_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late HabitLogService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [dbProvider.overrideWithValue(db)],
    );
    service = container.read(habitLogServiceProvider);
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  Future<Habit> createHabit(String habitId) async {
    final now = DateTime.now();
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: habitId,
            userId: 'user-dashboard-check',
            title: 'Minum air',
            createdAt: now,
          ),
        );
    return (await (db.select(db.habits)
              ..where((t) => t.habitId.equals(habitId)))
            .get())
        .first;
  }

  group('Dashboard check path (markDone)', () {
    test('markDone creates Done log for today', () async {
      final habit = await createHabit('habit-check-1');
      final today = DateTime.now();

      await service.markDone(habit: habit, date: today);

      final todayStart = DateTime(today.year, today.month, today.day);
      final logs = await (db.select(db.habitLogs)
            ..where((t) => t.habitId.equals('habit-check-1')))
          .get();
      final todayLogs =
          logs.where((l) => l.date == todayStart).toList();

      expect(todayLogs, hasLength(1));
      expect(todayLogs.first.status, 'Done');
    });

    test('second markDone is idempotent for lifetime count', () async {
      final habit = await createHabit('habit-check-2');
      final today = DateTime.now();

      await service.markDone(habit: habit, date: today);
      final afterFirst = (await (db.select(db.habits)
                ..where((t) => t.habitId.equals('habit-check-2')))
              .get())
          .first;

      await service.markDone(habit: afterFirst, date: today);
      final afterSecond = (await (db.select(db.habits)
                ..where((t) => t.habitId.equals('habit-check-2')))
              .get())
          .first;

      expect(afterSecond.lifetimeDoneCount, 1);
    });
  });

  group('Tree seasonal overlays', () {
    testWidgets('QuietIntegrationOverlay builds', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 180,
              child: QuietIntegrationOverlay(),
            ),
          ),
        ),
      );

      expect(find.byType(QuietIntegrationOverlay), findsOneWidget);
    });

    testWidgets('TribulationAuraWidget and SnowOverlayWidget build', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: TribulationAuraWidget()),
                  Positioned.fill(child: SnowOverlayWidget()),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TribulationAuraWidget), findsOneWidget);
      expect(find.byType(SnowOverlayWidget), findsOneWidget);

      // Allow animation controllers to tick once.
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
