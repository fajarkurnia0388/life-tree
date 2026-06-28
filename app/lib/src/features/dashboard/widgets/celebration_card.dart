import 'package:flutter/material.dart';

/// Card widget untuk Celebration State (semua habit selesai)
class CelebrationCard extends StatelessWidget {
  const CelebrationCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            const Text('🌳✨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Hari ini milikmu. Pohonmu sedang tumbuh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua kebiasaan terjadwal untuk hari ini telah selesai dilingkari.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
