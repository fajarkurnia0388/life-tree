import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cultivation_constants.dart';
import '../cultivation_provider.dart';

/// Shows progress through the current realm.
///
/// Phase 0 uses cumulative days as a simple progress signal. Later phases can
/// replace this with the full multi-signal realm progress calculation.
///
/// Anti-aggressive: Shows realm name instead of numeric rank to avoid competitive feel.
class CultivationProgressBar extends ConsumerWidget {
  const CultivationProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cultivationAsync = ref.watch(cultivationProvider);
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);

    return cultivationAsync.when(
      data: (cultivation) {
        final progress = _calculateRealmProgress(
          cultivation.realm,
          cultivation.cumulativeDays,
        );

        final realmInfo = CultivationConstants.realmForLevel(cultivation.realm);
        final realmLabel = _getRealmLabel(realmInfo, languageLevel);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    realmLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _getRealmLabel(
    CultivationRealm realm,
    CultivationLanguageLevel level,
  ) {
    return switch (level) {
      CultivationLanguageLevel.plain => realm.indonesianName,
      CultivationLanguageLevel.hybrid => realm.name,
      CultivationLanguageLevel.full => '${realm.name} (${realm.chineseName})',
    };
  }

  double _calculateRealmProgress(int realm, int cumulativeDays) {
    const thresholds = [0, 37, 110, 219, 365, 511, 621, 694, 730];
    if (realm >= 8) return 1.0;

    final currentThreshold = thresholds[realm - 1];
    final nextThreshold = thresholds[realm];
    final span = nextThreshold - currentThreshold;
    final progressDays = cumulativeDays - currentThreshold;

    return (progressDays / span).clamp(0.0, 1.0);
  }
}
