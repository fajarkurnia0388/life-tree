import 'package:flutter/material.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/services/app_sound_service.dart';

/// Card widget untuk Celebration State (semua habit selesai)
class CelebrationCard extends StatefulWidget {
  final int cumulativeDays;
  final DaojiVocabularyLevel vocabularyLevel;

  const CelebrationCard({
    super.key,
    required this.cumulativeDays,
    required this.vocabularyLevel,
  });

  @override
  State<CelebrationCard> createState() => _CelebrationCardState();
}

class _CelebrationCardState extends State<CelebrationCard> {
  @override
  void initState() {
    super.initState();
    AppSoundService.playTibetanChime();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Custom dynamic celebration messages based on cumulative days milestones
    final String emoji = _celebrationEmoji(widget.cumulativeDays);
    final String title = 'Hari ini milikmu. Pohonmu sedang tumbuh.';
    
    String subtitle = 'Semua kebiasaan terjadwal untuk hari ini telah selesai dilingkari.';
    if (widget.cumulativeDays > 0) {
      if (widget.cumulativeDays % 30 == 0) {
        subtitle = 'Luar biasa! Anda telah melangkah selama ${widget.cumulativeDays} hari. Pohon Anda beresonansi dengan kuat.';
      } else if (widget.cumulativeDays % 7 == 0) {
        subtitle = 'Satu minggu penuh pertumbuhan tercapai (Hari ke-${widget.cumulativeDays}). Terus pelihara lingkaran batin Anda.';
      } else {
        subtitle = 'Semua kebiasaan selesai pada Hari ke-${widget.cumulativeDays}. Pohon Anda tumbuh subur.';
      }
    }

    return Card(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0.7, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Text(emoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  String _celebrationEmoji(int days) {
    if (days <= 0) return '🌳✨';
    if (days % 30 == 0) return '👑🌳✨';
    if (days % 7 == 0) return '🌟🌳✨';
    return '🌳✨';
  }
}
