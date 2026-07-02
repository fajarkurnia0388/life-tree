import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/value_dilemma.dart';

class ValueDilemmaCard extends StatelessWidget {
  final ValueDilemma dilemma;
  final int index;
  final int total;
  final Function(String option, String valueTag) onSelected;

  const ValueDilemmaCard({
    super.key,
    required this.dilemma,
    required this.index,
    required this.total,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dilema Pilihan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '${index + 1} / $total',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (index + 1) / total,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: theme.colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            // Dilemma Prompt
            Text(
              dilemma.prompt,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Option A Button
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onSelected('A', dilemma.optionAValueTag);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: isDark ? 0.3 : 0.6),
                foregroundColor: theme.colorScheme.onSurface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ),
              child: Text(
                dilemma.optionALabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Option B Button
            ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onSelected('B', dilemma.optionBValueTag);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: isDark ? 0.3 : 0.6),
                foregroundColor: theme.colorScheme.onSurface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ),
              child: Text(
                dilemma.optionBLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
