import 'package:flutter/material.dart';

class AuditStep extends StatelessWidget {
  final bool devMode;
  final double bodyScore;
  final ValueChanged<double> onBodyScoreChanged;
  final Map<String, double> auditScores;
  final Function(String, double) onAuditScoreChanged;

  const AuditStep({
    super.key,
    required this.devMode,
    required this.bodyScore,
    required this.onBodyScoreChanged,
    required this.auditScores,
    required this.onAuditScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (devMode) {
      final domains = ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
      final domainEmojis = {
        'Tubuh': '🏃',
        'Keuangan': '💰',
        'Hubungan': '🤝',
        'Emosi': '🧠',
        'Karir': '📚',
        'Rekreasi': '🎮',
      };
      final domainDescriptions = {
        'Tubuh': 'Kondisi fisik & energi Anda hari ini',
        'Keuangan': 'Kestabilan & kenyamanan finansial Anda',
        'Hubungan': 'Kualitas relasi sosial & keluarga',
        'Emosi': 'Kedamaian batin & kontrol kecemasan',
        'Karir': 'Perkembangan karir & rencana belajar',
        'Rekreasi': 'Kepuasan waktu istirahat & hobi',
      };

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Evaluasi Awal (Life Audit)',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Evaluasi 6 area kehidupan utama Anda untuk menyesuaikan visualisasi awal Pohon Pertumbuhan Anda.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...domains.map((domain) {
              final score = auditScores[domain]!;
              final emoji = domainEmojis[domain]!;
              final desc = domainDescriptions[domain]!;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  domain,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  desc,
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            score.toInt().toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: score,
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        onChanged: (val) => onAuditScoreChanged(domain, val),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 (Krisis)', style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                            Text('5 (Cukup)', style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                            Text('10 (Sempurna)', style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Evaluasi Awal (Life Audit)',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('🏃', style: TextStyle(fontSize: 32)),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Domain Fokus Pertama: Tubuh',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Bagaimana kondisi fisik & energi Anda hari ini?',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '1 = Sangat lelah/Sakit, 10 = Bugar/Sangat berenergi',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          bodyScore.toInt().toString(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Slider(
          value: bodyScore,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          onChanged: onBodyScoreChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 (Krisis)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              Text('5 (Cukup)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              Text('10 (Sempurna)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ],
    );
  }
}
