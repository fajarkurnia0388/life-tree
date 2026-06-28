import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../data/local_db/database.dart';
import '../dashboard_provider.dart';

/// Card widget untuk Action of the Day
class ActionOfTheDayCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final domainColor = _getDomainColor(habit.domainTag);
    final isDark = theme.brightness == Brightness.dark;
    final isRecovery = data.season == 'Recovery';

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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: domainColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'ACTION OF THE DAY',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                if (isRecovery) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '⏸ DIJEDA',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () => _showWhyDialog(context, domainColor),
                  icon: Icon(Icons.info_outline, color: domainColor),
                  iconSize: 20,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                  tooltip: 'Mengapa kebiasaan ini dipilih',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              habit.title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  avatar: Text(_getDomainEmoji(habit.domainTag ?? 'Tubuh')),
                  label: Text(habit.domainTag ?? 'Tubuh'),
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Beban: ${habit.initiationFriction + habit.energyCost} Poin',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isRecovery ? null : onDonePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: domainColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(88, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tandai Selesai'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: isRecovery ? null : onNotCapablePressed,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                  child: const Text('Tidak Sanggup', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isRecovery) {
      return Opacity(
        opacity: 0.55,
        child: card,
      );
    }
    return card;
  }

  Color _getDomainColor(String? domain) {
    switch (domain) {
      case 'Tubuh': return const Color(0xFF6B8E78);
      case 'Keuangan': return const Color(0xFFC29B38);
      case 'Hubungan': return const Color(0xFFC78585);
      case 'Emosi': return const Color(0xFF8595C7);
      case 'Karir': return const Color(0xFF6CA8B5);
      case 'Rekreasi': return const Color(0xFFD49E6A);
      default: return const Color(0xFF6B8E78);
    }
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
    } catch (_) {}
    return 5.0;
  }

  void _showWhyDialog(BuildContext context, Color domainColor) {
    final domain = habit.domainTag ?? 'Tubuh';
    final domainScore = _domainScoreFor(domain);
    final domainDeficit = 10.0 - domainScore;
    final load = habit.initiationFriction + habit.energyCost;
    final priority = (domainDeficit * habit.impactScore) / (load > 0 ? load : 1);

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
              const Expanded(child: Text('Kenapa ini dipilih?')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dipilih karena domain $domain sedang rendah '
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
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  String _getDomainEmoji(String domain) {
    switch (domain) {
      case 'Tubuh': return '🏃';
      case 'Keuangan': return '💰';
      case 'Hubungan': return '🤝';
      case 'Emosi': return '🧠';
      case 'Karir': return '📚';
      case 'Rekreasi': return '🎮';
      default: return '🌱';
    }
  }
}
