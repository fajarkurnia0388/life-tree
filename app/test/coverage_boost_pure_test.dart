import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/core/domain/tree_skin_config.dart';
import 'package:daoji/src/core/domain/app_constants.dart';
import 'package:daoji/src/core/theme/form_theme.dart';
import 'package:daoji/src/features/dashboard/services/canopy_load_service.dart';

void main() {
  group('CanopyLoadService', () {
    test('isLowWellBeing thresholds', () {
      expect(CanopyLoadService.isLowWellBeing(49), isTrue);
      expect(CanopyLoadService.isLowWellBeing(50), isFalse);
      expect(CanopyLoadService.isLowWellBeing(0), isTrue);
      expect(CanopyLoadService.isLowWellBeing(100), isFalse);
    });

    test('calculateDynamicCapacity floors at 30% and clamps', () {
      // base 10, who5 0 → 10 * 0.3 = 3
      expect(
        CanopyLoadService.calculateDynamicCapacity(
          who5Percentage: 0,
          baseCapacity: 10,
        ),
        3,
      );
      // full wellbeing → base
      expect(
        CanopyLoadService.calculateDynamicCapacity(
          who5Percentage: 100,
          baseCapacity: 10,
        ),
        10,
      );
      // never below 1
      expect(
        CanopyLoadService.calculateDynamicCapacity(
          who5Percentage: 0,
          baseCapacity: 1,
        ),
        1,
      );
      // clamp who5 over 100
      expect(
        CanopyLoadService.calculateDynamicCapacity(
          who5Percentage: 150,
          baseCapacity: 10,
        ),
        10,
      );
    });

    test('isOverloaded', () {
      expect(
        CanopyLoadService.isOverloaded(
          currentLoad: 5,
          additionalLoad: 3,
          dynamicCapacity: 7,
        ),
        isTrue,
      );
      expect(
        CanopyLoadService.isOverloaded(
          currentLoad: 5,
          additionalLoad: 2,
          dynamicCapacity: 7,
        ),
        isFalse,
      );
    });
  });

  group('TreeSkinConfig.getProgress', () {
    test('recovery always full', () {
      expect(TreeSkinConfig.getProgress(0, Season.recovery), 1.0);
    });

    test('clamps cumulative days', () {
      expect(TreeSkinConfig.getProgress(0, Season.growth), 0.0);
      expect(TreeSkinConfig.getProgress(45, Season.growth), 0.5);
      expect(TreeSkinConfig.getProgress(90, Season.growth), 1.0);
      expect(TreeSkinConfig.getProgress(120, Season.growth), 1.0);
    });
  });

  group('AppFormTheme validators', () {
    test('requiredFieldValidator', () {
      expect(AppFormTheme.requiredFieldValidator(null, 'Nama'), isNotNull);
      expect(AppFormTheme.requiredFieldValidator('  ', 'Nama'), isNotNull);
      expect(AppFormTheme.requiredFieldValidator('ok', 'Nama'), isNull);
    });

    test('minLengthValidator', () {
      expect(AppFormTheme.minLengthValidator('ab', 'Nama', 3), isNotNull);
      expect(AppFormTheme.minLengthValidator('abc', 'Nama', 3), isNull);
    });

    test('maxLengthValidator', () {
      expect(AppFormTheme.maxLengthValidator('abcd', 'Nama', 3), isNotNull);
      expect(AppFormTheme.maxLengthValidator('ab', 'Nama', 3), isNull);
      expect(AppFormTheme.maxLengthValidator(null, 'Nama', 3), isNull);
    });

    test('emailValidator', () {
      expect(AppFormTheme.emailValidator(null), isNotNull);
      expect(AppFormTheme.emailValidator('not-an-email'), isNotNull);
      expect(AppFormTheme.emailValidator('a@b.co'), isNull);
    });

    test('optionalTextValidator', () {
      expect(AppFormTheme.optionalTextValidator(null), isNull);
      expect(AppFormTheme.optionalTextValidator(''), isNull);
      expect(
        AppFormTheme.optionalTextValidator('a' * 11, maxLength: 10),
        isNotNull,
      );
      expect(
        AppFormTheme.optionalTextValidator('short', maxLength: 10),
        isNull,
      );
    });
  });
}
