import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/thinking_method.dart';

/// Reusable collapsible guide section for any workspace.
/// Shows steps and format from the ThinkingMethod definition.
class WorkspaceGuideSection extends StatefulWidget {
  final String methodKey;
  const WorkspaceGuideSection({super.key, required this.methodKey});

  @override
  State<WorkspaceGuideSection> createState() => _WorkspaceGuideSectionState();
}

class _WorkspaceGuideSectionState extends State<WorkspaceGuideSection> {
  bool _expanded = false;

  ThinkingMethod? _findMethod() {
    try {
      return ThinkingMethod.allMethods.firstWhere(
        (m) => m.key == widget.methodKey,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final method = _findMethod();
    if (method == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        dense: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(
          Icons.menu_book_rounded,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'Panduan Langkah',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          // Steps
          ...List.generate(method.steps.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      method.steps[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Format
          if (method.format.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_align_left_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      method.format,
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable export/share button for workspace content.
class WorkspaceExportButton extends StatelessWidget {
  final String content;
  final String methodName;

  const WorkspaceExportButton({
    super.key,
    required this.content,
    required this.methodName,
  });

  void _copyToClipboard(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hasil $methodName disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(
        Icons.ios_share_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      tooltip: 'Salin Hasil',
      onPressed: content.trim().isEmpty ? null : () => _copyToClipboard(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    );
  }
}
