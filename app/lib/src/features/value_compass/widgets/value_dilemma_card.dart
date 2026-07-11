import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/value_dilemma.dart';

class ValueDilemmaCard extends StatelessWidget {
  final ValueDilemma dilemma;
  final int index;
  final int total;
  final Function(String option, String valueTag, String? reason) onSelected;

  const ValueDilemmaCard({
    super.key,
    required this.dilemma,
    required this.index,
    required this.total,
    required this.onSelected,
  });

  Future<void> _handleSelection(
    BuildContext context,
    String option,
    String valueTag,
  ) async {
    unawaited(HapticFeedback.selectionClick());

    // Ask if user wants to add optional reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _ReasonDialog(
        selectedOption: option,
        optionLabel: option == 'A'
            ? dilemma.optionALabel
            : option == 'B'
            ? dilemma.optionBLabel
            : 'Keduanya Penting',
      ),
    );

    if (context.mounted) {
      onSelected(option, valueTag, reason);
    }
  }

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
              onPressed: () => unawaited(
                  _handleSelection(context, 'A', dilemma.optionAValueTag)),
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
              onPressed: () => unawaited(
                  _handleSelection(context, 'B', dilemma.optionBValueTag)),
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
            // "Both Important" Button
            OutlinedButton(
              onPressed: () => unawaited(_handleSelection(context, 'Both', '')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                side: BorderSide(color: Colors.teal.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '⚖️ Keduanya Penting / Tergantung Konteks',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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

class _ReasonDialog extends StatefulWidget {
  final String selectedOption;
  final String optionLabel;

  const _ReasonDialog({
    required this.selectedOption,
    required this.optionLabel,
  });

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Alasan Pilihan (Opsional)'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Anda memilih: "${widget.optionLabel}"',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ingin menambahkan alasan mengapa Anda memilih ini? (Opsional)',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Misal: Karena saat ini saya fokus pada...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Lewati'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.pop(context, text.isEmpty ? null : text);
          },
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}
