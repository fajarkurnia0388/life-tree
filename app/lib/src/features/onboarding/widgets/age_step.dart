import 'package:flutter/material.dart';

class AgeStep extends StatelessWidget {
  final String selectedAgeBand;
  final ValueChanged<String> onAgeBandSelected;

  const AgeStep({
    super.key,
    required this.selectedAgeBand,
    required this.onAgeBandSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ageBands = ['Under 18', '18-24', '25-35', '36-45', '46+'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Berapa usia Anda?',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Kami menyesuaikan lingkungan dukungan berdasarkan rentang usia Anda.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...ageBands.map((band) {
          final isSelected = selectedAgeBand == band;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'Pilih kelompok usia $band',
              child: OutlinedButton(
                onPressed: () => onAgeBandSelected(band),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                    width: isSelected ? 2 : 1,
                  ),
                  backgroundColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  band,
                  style: TextStyle(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
