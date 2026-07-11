import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/features/dashboard/dashboard_selection.dart';
import 'package:daoji/src/features/dashboard/dashboard_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/core/domain/app_constants.dart';

Habit _habit({
  required String id,
  required String title,
  String? domain,
  int impact = 3,
  int friction = 2,
  int energy = 2,
}) {
  final now = DateTime(2026, 1, 1);
  return Habit(
    habitId: id,
    userId: 'u1',
    title: title,
    domainTag: domain,
    status: HabitStatus.active,
    frequency: 'Daily',
    initiationFriction: friction,
    originalFriction: friction,
    energyCost: energy,
    impactScore: impact,
    lifetimeDoneCount: 0,
    weightedDoneScore: 0,
    mvaDurationMin: 2,
    createdAt: now,
  );
}

void main() {
  group('parseDomainScoresJson', () {
    test('returns empty for null/invalid', () {
      expect(parseDomainScoresJson(null), isEmpty);
      expect(parseDomainScoresJson(''), isEmpty);
      expect(parseDomainScoresJson('{not json'), isEmpty);
    });

    test('parses valid map', () {
      final m = parseDomainScoresJson('{"Tubuh": 4, "Emosi": 8}');
      expect(m['Tubuh'], 4);
      expect(m['Emosi'], 8);
    });
  });

  group('computeBalanceIndex', () {
    test('default empty is 0.5', () {
      expect(computeBalanceIndex({}), 0.5);
    });

    test('averages and scales by 10', () {
      expect(computeBalanceIndex({'a': 4, 'b': 6}), closeTo(0.5, 1e-9));
      expect(computeBalanceIndex({'a': 10}), closeTo(1.0, 1e-9));
    });
  });

  group('filterHabitsByDomain', () {
    final habits = [
      HabitWithLog(habit: _habit(id: '1', title: 'A', domain: 'Tubuh')),
      HabitWithLog(habit: _habit(id: '2', title: 'B', domain: 'Emosi')),
    ];

    test('Semua returns all', () {
      expect(filterHabitsByDomain(habits, 'Semua'), hasLength(2));
    });

    test('filters by domain', () {
      final f = filterHabitsByDomain(habits, 'Tubuh');
      expect(f, hasLength(1));
      expect(f.first.habit.habitId, '1');
    });
  });

  group('selectActionOfTheDay', () {
    test('picks higher priority among uncompleted', () {
      final scores = {'Tubuh': 2.0, 'Emosi': 9.0};
      final habits = [
        HabitWithLog(
          habit: _habit(
            id: 'low',
            title: 'Low domain',
            domain: 'Tubuh',
            impact: 5,
            friction: 1,
            energy: 1,
          ),
        ),
        HabitWithLog(
          habit: _habit(
            id: 'high',
            title: 'High domain',
            domain: 'Emosi',
            impact: 5,
            friction: 1,
            energy: 1,
          ),
        ),
      ];
      final best = selectActionOfTheDay(
        filteredHabits: habits,
        domainScores: scores,
      );
      expect(best?.habitId, 'low');
    });

    test('skips done habits', () {
      final scores = {'Tubuh': 1.0};
      final doneLog = HabitLog(
        logId: 'l1',
        habitId: 'done',
        date: DateTime(2026, 1, 1),
        status: HabitStatus.done,
      );
      final habits = [
        HabitWithLog(
          habit: _habit(id: 'done', title: 'Done', domain: 'Tubuh', impact: 5),
          log: doneLog,
        ),
        HabitWithLog(
          habit: _habit(id: 'open', title: 'Open', domain: 'Tubuh', impact: 2),
        ),
      ];
      final best = selectActionOfTheDay(
        filteredHabits: habits,
        domainScores: scores,
      );
      expect(best?.habitId, 'open');
    });
  });

  group('resolveActiveActionOfTheDay', () {
    test('Semua uses global', () {
      final global = _habit(id: 'g', title: 'Global', domain: 'Tubuh');
      final r = resolveActiveActionOfTheDay(
        domainFilter: 'Semua',
        globalActionOfTheDay: global,
        filteredHabits: const [],
        domainScores: const {},
      );
      expect(r?.habitId, 'g');
    });
  });
}
