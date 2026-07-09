import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../core/theme/button_theme.dart';
import '../../../data/local_db/database.dart';
import '../dashboard_provider.dart';
import 'breathing_ritual_overlay.dart';

/// Card widget untuk Action of the Day
class ActionOfTheDayCard extends ConsumerWidget {
  const ActionOfTheDayCard({
    super.key,
    required this.habit,
    required this.data,
    required this.onDonePressed,
    required this.onNotCapablePressed,
  });

  final Habit habit;
  final DashboardData data;
  final VoidCallback onDonePressed;
  final VoidCallback onNotCapablePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final domainColor = DomainColors.forDomain(habit.domainTag);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRecovery = data.season == Season.recovery;

    final card = Card(
      color: domainColor.withValues(alpha: isDark ? 0.08 : 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: domainColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: domainColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DaojiText.resolve(
                          DaojiTextKey.actionTitle,
                          vocabularyLevel,
                        ).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRecovery) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DaojiText.resolve(DaojiTextKey.actionPaused, vocabularyLevel),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                if ((habit.initiationFriction) >= 4) ...[
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      BreathingRitualOverlay.show(
                        context,
                        onComplete: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pikiran Anda sekarang lebih tenang. Siap melangkah 🌱'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.self_improvement_rounded, color: domainColor),
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Latihan pernapasan penenang',
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  onPressed: () => _showWhyDialog(
                    context,
                    domainColor,
                    vocabularyLevel,
                  ),
                  icon: Icon(Icons.info_outline, color: domainColor),
                  iconSize: 20,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: DaojiText.resolve(DaojiTextKey.actionWhyTooltip, vocabularyLevel),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(habit.title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              DaojiText.resolve(DaojiTextKey.actionSubtitle, vocabularyLevel),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  avatar: Text(_getDomainEmoji(habit.domainTag ?? 'Tubuh')),
                  label: Text(
                    DaojiText.domainLabel(
                      habit.domainTag,
                      vocabularyLevel,
                      short: true,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Beban: ${habit.initiationFriction + habit.energyCost} Poin',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isRecovery ? null : () {
                      HapticFeedback.mediumImpact();
                      onDonePressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: domainColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(88, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      DaojiText.resolve(DaojiTextKey.actionDone, vocabularyLevel),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: isRecovery ? null : () {
                    HapticFeedback.lightImpact();
                    onNotCapablePressed();
                  },
                  style: AppButtonStyles.habitSecondary(context).copyWith(
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.redAccent, width: 1),
                    ),
                  ),
                  child: Text(
                    DaojiText.resolve(
                      DaojiTextKey.actionNotCapable,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isRecovery) {
      return Opacity(opacity: 0.55, child: card);
    }
    return card;
  }

  /// Parses the user's latest domain scores safely and returns the score
  /// for the given domain. Defaults to 5.0 when missing or unparseable.
  double _domainScoreFor(String domain) {
    final raw = data.profile.latestDomainScores;
    if (raw == null) return 5.0;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final value = decoded[domain];
        if (value is num) return value.toDouble();
      }
    } catch (e, stackTrace) {
      ErrorHandlerService().logError(
        e,
        stackTrace,
        context: 'ActionOfTheDayCard._domainScoreFor',
      );
    }
    return 5.0;
  }

  void _showWhyDialog(
    BuildContext context,
    Color domainColor,
    vocabularyLevel,
  ) {
    final domain = habit.domainTag ?? 'Tubuh';
    final domainLabel = DaojiText.domainLabel(domain, vocabularyLevel);
    final domainScore = _domainScoreFor(domain);
    final domainDeficit = 10.0 - domainScore;
    final load = habit.initiationFriction + habit.energyCost;
    final priority =
        (domainDeficit * habit.impactScore) / (load > 0 ? load : 1);

    final domainScoreText = domainScore == domainScore.roundToDouble()
        ? domainScore.toStringAsFixed(0)
        : domainScore.toStringAsFixed(1);

    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: domainColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DaojiText.resolve(DaojiTextKey.actionWhyTitle, vocabularyLevel),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dipilih karena $domainLabel sedang rendah '
                '(skor $domainScoreText/10), dampak tinggi '
                '(impact ${habit.impactScore}/5), dan beban ringan ($load poin).',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Skor prioritas = (defisit domain × dampak) ÷ beban = '
                '${priority.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                DaojiText.resolve(DaojiTextKey.actionUnderstand, vocabularyLevel),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDomainEmoji(String domain) {
    switch (domain) {
      case 'Tubuh':
        return '🏃';
      case 'Keuangan':
        return '💰';
      case 'Hubungan':
        return '🤝';
      case 'Emosi':
        return '🧠';
      case 'Karir':
        return '📚';
      case 'Rekreasi':
        return '🎮';
      default:
        return '🌱';
    }
  }
}
