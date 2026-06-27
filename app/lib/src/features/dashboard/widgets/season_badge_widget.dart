import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/theme/theme.dart';
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';
import '../dashboard_provider.dart';

/// Displays the current season badge (Growth / Recovery / Dormant).
class SeasonBadgeWidget extends ConsumerWidget {
  final String season;
  const SeasonBadgeWidget({super.key, required this.season});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color badgeColor;
    String label;
    IconData icon;
    String message;

    switch (season) {
      case 'Recovery':
        badgeColor = CalmTheme.secondaryBlue;
        label = 'Musim Istirahat (Recovery Mode)';
        icon = Icons.ac_unit_rounded;
        message = 'Notifikasi dijeda. Anda sedang memulihkan energi.';
        break;
      case 'Dormant':
        badgeColor = Colors.blueGrey;
        label = 'Musim Hening (Dormant Mode)';
        icon = Icons.blur_on_rounded;
        message = 'Lama tidak aktif. Waktunya mengevaluasi kebiasaan.';
        break;
      default:
        badgeColor = CalmTheme.primarySage;
        label = 'Musim Tumbuh (Growth Mode)';
        icon = Icons.wb_sunny_outlined;
        message = 'Laju pertumbuhan normal.';
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
                    style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                  const SizedBox(height: 2),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            if (season == 'Recovery')
              TextButton(
                onPressed: () => _endRecoveryMode(ref),
                child: const Text('Akhiri', style: TextStyle(fontWeight: FontWeight.bold)),
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
      await (db.update(db.userProfiles)
            ..where((tbl) => tbl.userId.equals(profiles.first.userId)))
          .write(UserProfilesCompanion(supportMode: const drift.Value('Normal')));
      ref.invalidate(dashboardDataProvider);
    }
  }
}
