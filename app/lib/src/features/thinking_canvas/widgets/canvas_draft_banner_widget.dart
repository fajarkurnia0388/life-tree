import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Expandable banner showing previous session draft content.
class CanvasDraftBannerWidget extends StatelessWidget {
  final String content;
  final bool initiallyExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const CanvasDraftBannerWidget({
    super.key,
    required this.content,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        onExpansionChanged: onExpansionChanged,
        leading: Icon(
          Icons.history_edu_rounded,
          color: theme.colorScheme.secondary,
        ),
        title: Text(
          'Draf Sesi Sebelumnya',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Gunakan sebagai referensi atau salin isinya.',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, size: 18),
          tooltip: 'Salin ke Clipboard',
          onPressed: () {
            HapticFeedback.lightImpact();
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Disalin ke clipboard!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                content,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
