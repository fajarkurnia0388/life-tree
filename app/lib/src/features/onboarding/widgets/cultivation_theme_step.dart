import 'package:flutter/material.dart';

/// Onboarding step for choosing whether cultivation terminology is enabled.
///
/// This keeps the immortal-cultivation theme opt-in/opt-out friendly so users
/// who are unfamiliar with xianxia/cultivation stories can stay with plain,
/// practical wording.
class CultivationThemeStep extends StatelessWidget {
  final bool cultivationThemeEnabled;
  final ValueChanged<bool> onChanged;

  const CultivationThemeStep({
    super.key,
    required this.cultivationThemeEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.auto_awesome, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Pilih gaya bahasa aplikasi',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Daoji bisa memakai bahasa sederhana, atau memakai nuansa kultivasi seperti “Qi”, “Realm”, dan “Dao”. Pilihan ini bisa diubah lagi di Settings.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          _ThemeChoiceCard(
            selected: !cultivationThemeEnabled,
            icon: Icons.lightbulb_outline,
            title: 'Bahasa sederhana',
            subtitle:
                'Istilah praktis seperti progres, istirahat, kapasitas, dan kebiasaan. Cocok jika kamu belum familiar dengan cerita kultivasi.',
            onTap: () => onChanged(false),
          ),
          const SizedBox(height: 12),
          _ThemeChoiceCard(
            selected: cultivationThemeEnabled,
            icon: Icons.terrain_outlined,
            title: 'Tema kultivasi immortal',
            subtitle:
                'Nuansa xianxia ringan seperti Qi, Realm, Dao, dan Seclusion. Tetap supportive, bukan kompetitif atau menghukum.',
            onTap: () => onChanged(true),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                cultivationThemeEnabled
                    ? 'Contoh: “Qi hari ini stabil. Kamu berada di fase Growth.”'
                    : 'Contoh: “Kapasitas hari ini stabil. Kamu berada di fase bertumbuh.”',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoiceCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ThemeChoiceCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.5);

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: selected ? 0.18 : 0.08,
                ),
                foregroundColor: theme.colorScheme.primary,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.45,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.72,
                        ),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
