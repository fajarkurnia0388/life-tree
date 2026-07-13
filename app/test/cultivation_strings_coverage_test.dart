import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/features/cultivation/cultivation_constants.dart';
import 'package:daoji/src/features/cultivation/cultivation_strings.dart';
import 'package:daoji/src/features/dashboard/dashboard_selection.dart';

void main() {
  group('CultivationStrings all levels non-empty', () {
    final levels = CultivationLanguageLevel.values;

    test('dashboard and season labels', () {
      for (final level in levels) {
        expect(CultivationStrings.dashboardTitle(level), isNotEmpty);
        expect(CultivationStrings.realmDisplay(level, 'Foundation', 12), contains('12'));
        expect(CultivationStrings.seasonRecovery(level), isNotEmpty);
        expect(CultivationStrings.seasonGrowth(level), isNotEmpty);
        expect(CultivationStrings.seasonDormant(level), isNotEmpty);
        expect(CultivationStrings.seasonTribulation(level), isNotEmpty);
        expect(CultivationStrings.seasonQuietIntegration(level), isNotEmpty);
      }
    });

    test('action of the day + habits', () {
      for (final level in levels) {
        expect(CultivationStrings.actionOfTheDayTitle(level), isNotEmpty);
        expect(CultivationStrings.actionOfTheDaySubtitle(level), isNotEmpty);
        expect(CultivationStrings.actionCompleted(level), isNotEmpty);
        expect(CultivationStrings.habitLabel(level), isNotEmpty);
        expect(CultivationStrings.habitListTitle(level), isNotEmpty);
        expect(CultivationStrings.addHabit(level), isNotEmpty);
      }
    });

    test('friction + journal + growth map', () {
      for (final level in levels) {
        expect(CultivationStrings.frictionInterventionTitle(level), isNotEmpty);
        expect(CultivationStrings.frictionOptionTime(level), isNotEmpty);
        expect(CultivationStrings.frictionOptionEnergy(level), isNotEmpty);
        expect(CultivationStrings.frictionOptionForgot(level), isNotEmpty);
        expect(CultivationStrings.journalTitle(level), isNotEmpty);
        expect(CultivationStrings.journalLite(level), isNotEmpty);
        expect(CultivationStrings.journalDeep(level), isNotEmpty);
        expect(CultivationStrings.journalMoodPrompt(level), isNotEmpty);
        expect(CultivationStrings.growthMapRoot(level), isNotEmpty);
        expect(CultivationStrings.growthMapBranch(level), isNotEmpty);
        expect(CultivationStrings.growthMapLeaf(level), isNotEmpty);
        expect(CultivationStrings.growthMapFlower(level), isNotEmpty);
        expect(CultivationStrings.growthMapFruit(level), isNotEmpty);
      }
    });

    test('canopy pulse compass marketplace recovery', () {
      for (final level in levels) {
        expect(CultivationStrings.canopyLoadTitle(level), isNotEmpty);
        expect(CultivationStrings.canopyLoadOverload(level), isNotEmpty);
        expect(CultivationStrings.weeklyPulseTitle(level), isNotEmpty);
        expect(CultivationStrings.lifeCompassTitle(level), isNotEmpty);
        expect(CultivationStrings.valueMirrorTitle(level), isNotEmpty);
        expect(CultivationStrings.decisionJournalTitle(level), isNotEmpty);
        expect(CultivationStrings.marketplaceTitle(level), isNotEmpty);
        expect(CultivationStrings.recoveryModeTitle(level), isNotEmpty);
        expect(CultivationStrings.recoveryModeDescription(level), isNotEmpty);
        expect(CultivationStrings.safetyCardTitle(level), contains('Safety'));
        expect(CultivationStrings.settingsLanguageLevelTitle(level), isNotEmpty);
        expect(CultivationStrings.languageLevelPlain(level), isNotEmpty);
        expect(CultivationStrings.languageLevelHybrid(level), isNotEmpty);
        expect(CultivationStrings.languageLevelFull(level), isNotEmpty);
        expect(CultivationStrings.radarChartTitle(level), isNotEmpty);
        expect(CultivationStrings.statusPanelTitle(level), isNotEmpty);
        expect(CultivationStrings.realmLabel(level), isNotEmpty);
        expect(CultivationStrings.seasonLabel(level), isNotEmpty);
        expect(CultivationStrings.dominantPathLabel(level), isNotEmpty);
      }
    });

    test('palaceName for every path and level', () {
      for (final path in CultivationPath.values) {
        for (final level in levels) {
          expect(CultivationStrings.palaceName(path, level), isNotEmpty);
        }
      }
    });
  });

  group('dashboard_selection pure helpers', () {
    test('parseDomainScoresJson', () {
      expect(parseDomainScoresJson(null), isEmpty);
      expect(parseDomainScoresJson(''), isEmpty);
      expect(parseDomainScoresJson('{bad'), isEmpty);
      expect(parseDomainScoresJson('{"Tubuh": 7}'), {'Tubuh': 7});
    });

    test('computeBalanceIndex', () {
      expect(computeBalanceIndex({}), 0.5);
      expect(computeBalanceIndex({'a': 'x'}), 0.5);
      expect(computeBalanceIndex({'a': 10, 'b': 0}), 0.5);
      expect(computeBalanceIndex({'a': 8, 'b': 6}), closeTo(0.7, 0.001));
    });

    test('filterHabitsByDomain empty filter returns all', () {
      expect(filterHabitsByDomain(const [], 'Semua'), isEmpty);
      expect(filterHabitsByDomain(const [], '  '), isEmpty);
    });

    test('resolveActiveActionOfTheDay uses global when Semua', () {
      expect(
        resolveActiveActionOfTheDay(
          domainFilter: 'Semua',
          globalActionOfTheDay: null,
          filteredHabits: const [],
          domainScores: const {},
        ),
        isNull,
      );
    });
  });
}
