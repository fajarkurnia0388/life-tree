import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';
import '../dashboard_provider.dart';

/// Displays the current season badge (Growth / Recovery / Dormant).
class SeasonBadgeWidget extends ConsumerWidget {
  final String season;
  final DateTime? recoveryEndDate;
  const SeasonBadgeWidget({
    super.key,
    required this.season,
    this.recoveryEndDate,
  });

  /// Whole days remaining until recovery ends (>= 0). Returns null when unknown.
  int? get _recoveryDaysLeft {
    if (recoveryEndDate == null) return null;
    final now = DateTime.now();
    final endDay = DateTime(
      recoveryEndDate!.year,
      recoveryEndDate!.month,
      recoveryEndDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final diff = endDay.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    Color badgeColor;
    String label;
    IconData icon;
    String message;

    switch (season) {
      case Season.recovery:
        badgeColor = CalmTheme.secondaryBlue;
        final daysLeft = _recoveryDaysLeft;
        final recoveryLabel = DaojiText.resolve(
          DaojiTextKey.stateRecovery,
          vocabularyLevel,
        );
        label = daysLeft != null
            ? '$recoveryLabel ($daysLeft hari lagi)'
            : recoveryLabel;
        icon = Icons.ac_unit_rounded;
        message = DaojiText.resolve(
          DaojiTextKey.stateRecoveryDescription,
          vocabularyLevel,
        );
        break;
      case Season.dormant:
        badgeColor = Colors.blueGrey;
        label = DaojiText.resolve(DaojiTextKey.stateDormant, vocabularyLevel);
        icon = Icons.blur_on_rounded;
        message = DaojiText.resolve(
          DaojiTextKey.stateDormantDescription,
          vocabularyLevel,
        );
        break;
      default:
        badgeColor = CalmTheme.primarySage;
        label = DaojiText.resolve(DaojiTextKey.stateGrowth, vocabularyLevel);
        icon = Icons.wb_sunny_outlined;
        message = DaojiText.resolve(
          DaojiTextKey.stateGrowthDescription,
          vocabularyLevel,
        );
    }

    return Card(
      color: badgeColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: badgeColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: badgeColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            if (season == Season.recovery)
              TextButton(
                onPressed: () => _endRecoveryMode(ref),
                style: TextButton.styleFrom(minimumSize: const Size(64, 44)),
                child: const Text(
                  'Akhiri',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _endRecoveryMode(WidgetRef ref) async {
    final db = ref.read(dbProvider);
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isNotEmpty) {
      await (db.update(
        db.userProfiles,
      )..where((tbl) => tbl.userId.equals(profiles.first.userId))).write(
        const UserProfilesCompanion(
          supportMode: drift.Value('Normal'),
          recoveryEndDate: drift.Value(null),
        ),
      );
      ref.invalidate(dashboardDataProvider);
    }
  }
}
