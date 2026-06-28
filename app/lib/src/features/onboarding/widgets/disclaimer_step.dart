import 'package:flutter/material.dart';

class DisclaimerStep extends StatelessWidget {
  final bool disclaimerAccepted;
  final ValueChanged<bool> onDisclaimerAcceptedChanged;
  final int readSecondsRemaining;
  final bool readGateElapsed;
  final bool? comprehensionCorrect;
  final ValueChanged<bool?> onComprehensionCorrectChanged;

  const DisclaimerStep({
    super.key,
    required this.disclaimerAccepted,
    required this.onDisclaimerAcceptedChanged,
    required this.readSecondsRemaining,
    required this.readGateElapsed,
    required this.comprehensionCorrect,
    required this.onComprehensionCorrectChanged,
  });

  bool get _canAcceptDisclaimer => readGateElapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LifeTree BUKAN aplikasi medis.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Luangkan waktu sebentar untuk membaca. Tidak perlu terburu-buru.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          _buildDisclaimerSection(
            theme,
            title: 'Apa itu LifeTree?',
            icon: Icons.spa_outlined,
            body:
                'LifeTree adalah jurnal orientasi diri dan pendamping kebiasaan '
                '(habit tracker) pribadi. Tujuannya membantumu berorientasi diri '
                'secara damai tanpa rasa bersalah — bukan untuk mendiagnosis '
                'atau merawat kondisi apa pun.',
          ),
          _buildDisclaimerSection(
            theme,
            title: 'Batasan Penting',
            icon: Icons.info_outline,
            body:
                'LifeTree BUKAN aplikasi medis atau alat diagnosis psikologis klinis. '
                'Kami tidak memberikan saran medis, diagnosis, maupun perawatan '
                'kesehatan mental secara profesional.\n\n'
                'Jika kamu mengalami kondisi krisis emosional atau membutuhkan '
                'bantuan segera, gunakan tombol Safety Card untuk melihat daftar '
                'kontak darurat layanan bantuan profesional (seperti SEJIWA 119 Ext 8).',
          ),
          _buildDisclaimerSection(
            theme,
            title: 'Privasi & Data',
            icon: Icons.lock_outline,
            body:
                'Aplikasi ini bekerja 100% secara offline-first pada perangkatmu '
                'untuk menjamin privasi penuh. Seluruh datamu disimpan secara lokal '
                'di perangkat ini.',
          ),
          const SizedBox(height: 16),

          _buildComprehensionCheck(theme),
          const SizedBox(height: 16),

          _buildAcceptanceRow(theme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required String body,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: theme.colorScheme.primary),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComprehensionCheck(ThemeData theme) {
    const options = <String>[
      'Pendamping kebiasaan (bukan medis)',
      'Alat diagnosis & perawatan medis',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sebelum lanjut, LifeTree adalah aplikasi...?',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final isCorrectOption = index == 0;
            final isSelected = comprehensionCorrect != null &&
                ((isCorrectOption && comprehensionCorrect == true) ||
                    (!isCorrectOption && comprehensionCorrect == false));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: 'Pilih jawaban: ${options[index]}',
                child: OutlinedButton(
                  onPressed: () => onComprehensionCorrectChanged(isCorrectOption),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    backgroundColor: isSelected
                        ? (isCorrectOption
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.redAccent.withValues(alpha: 0.08))
                        : Colors.transparent,
                    side: BorderSide(
                      color: isSelected
                          ? (isCorrectOption ? theme.colorScheme.primary : Colors.redAccent)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          isCorrectOption ? Icons.check_circle : Icons.cancel_outlined,
                          size: 20,
                          color: isCorrectOption ? theme.colorScheme.primary : Colors.redAccent,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (comprehensionCorrect == false) ...[
            const SizedBox(height: 8),
            Text(
              'Coba lagi ya — LifeTree hadir sebagai pendamping, bukan layanan medis.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcceptanceRow(ThemeData theme) {
    final enabled = _canAcceptDisclaimer;
    final countdownLabel = 'Baca dulu... (${readSecondsRemaining}s)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          checked: disclaimerAccepted,
          label: enabled
              ? 'Saya memahami dan menyetujui pernyataan keselamatan'
              : countdownLabel,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? () => onDisclaimerAcceptedChanged(!disclaimerAccepted) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Checkbox(
                      value: disclaimerAccepted,
                      activeColor: theme.colorScheme.primary,
                      onChanged: enabled ? (val) => onDisclaimerAcceptedChanged(val ?? false) : null,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Saya memahami dan menyetujui pernyataan keselamatan di atas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!enabled) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined,
                  size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Text(
                countdownLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
