import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cultivation_constants.dart';
import '../cultivation_strings.dart';
import '../cultivation_provider.dart';

/// Comprehensive status panel showing all 4 cultivation sumbu.
///
/// Phase 0: Basic informational display.
/// Phase 2: Add visual enhancements (icons, colors, animations).
class CultivationStatusPanel extends ConsumerWidget {
  const CultivationStatusPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cultivationAsync = ref.watch(cultivationProvider);
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);

    return cultivationAsync.when(
      data: (cultivation) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Cultivation Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Realm
                _buildSection(
                  context,
                  icon: Icons.trending_up,
                  label: 'Realm',
                  value: '${cultivation.realm} - ${cultivation.realmName}',
                ),
                const SizedBox(height: 12),

                // Season/State
                _buildSection(
                  context,
                  icon: _getSeasonIcon(cultivation.season),
                  label: 'Season',
                  value: _getSeasonName(cultivation.season, languageLevel),
                ),
                const SizedBox(height: 12),

                // Qi Level
                _buildSection(
                  context,
                  icon: Icons.energy_savings_leaf,
                  label: CultivationStrings.canopyLoadTitle(languageLevel),
                  value: '${(cultivation.qiLevel * 100).toStringAsFixed(0)}%',
                  trailing: _buildQiIndicator(context, cultivation.qiLevel),
                ),
                const SizedBox(height: 12),

                // Palaces
                Text(
                  'Six Palace Resonance',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _buildPalaceScores(context, cultivation, languageLevel),
                const SizedBox(height: 12),

                // Dominant Path (if detected)
                if (cultivation.dominantPath != null) ...[
                  _buildSection(
                    context,
                    icon: Icons.explore,
                    label: 'Dominant Path',
                    value: CultivationConstants.pathInfo(
                      cultivation.dominantPath!,
                    ).name,
                  ),
                  const SizedBox(height: 12),
                ],

                // Dao Heart
                if (cultivation.daoHeart != null &&
                    cultivation.daoHeart!.isNotEmpty) ...[
                  _buildSection(
                    context,
                    icon: Icons.favorite,
                    label: CultivationStrings.lifeCompassTitle(languageLevel),
                    value: cultivation.daoHeart!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildPalaceScores(
    BuildContext context,
    cultivation,
    CultivationLanguageLevel languageLevel,
  ) {
    return Column(
      children: CultivationPalace.values.map((palace) {
        final score = cultivation.palaceScores[palace] ?? 5.0;
        final palaceInfo = CultivationConstants.palaceInfo(palace);

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  CultivationStrings.palaceName(palace, languageLevel),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: score / 10.0,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  score.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQiIndicator(BuildContext context, double qiLevel) {
    Color color;
    if (qiLevel >= 0.7) {
      color = Colors.green;
    } else if (qiLevel >= 0.4) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  IconData _getSeasonIcon(CultivationSeason season) {
    return switch (season) {
      CultivationSeason.growth => Icons.trending_up,
      CultivationSeason.recovery => Icons.spa,
      CultivationSeason.dormant => Icons.bedtime,
      CultivationSeason.tribulation => Icons.warning_amber,
      CultivationSeason.quietIntegration => Icons.nightlight,
    };
  }

  String _getSeasonName(
    CultivationSeason season,
    CultivationLanguageLevel level,
  ) {
    return switch (season) {
      CultivationSeason.growth => CultivationStrings.seasonGrowth(level),
      CultivationSeason.recovery => CultivationStrings.seasonRecovery(level),
      CultivationSeason.dormant => CultivationStrings.seasonDormant(level),
      CultivationSeason.tribulation => CultivationStrings.seasonTribulation(
        level,
      ),
      CultivationSeason.quietIntegration =>
        CultivationStrings.seasonQuietIntegration(level),
    };
  }
}
