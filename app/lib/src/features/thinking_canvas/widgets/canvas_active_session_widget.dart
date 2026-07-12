import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/theme/app_spacing.dart';
import '../thinking_canvas_state.dart';
import 'canvas_draft_banner_widget.dart';
import 'method_visuals.dart';
import 'specialized_workspace_widgets.dart';

/// Active thinking session shell: context bar, draft, guide, workspace, save bar.
class CanvasActiveSessionWidget extends ConsumerWidget {
  final ThinkingCanvasState state;
  final DaojiVocabularyLevel vocabularyLevel;
  final bool draftBannerExpanded;
  final ValueChanged<bool> onDraftExpansionChanged;
  final String Function(String) methodDisplayName;
  final Widget workspace;
  final VoidCallback onSaveAndFinish;

  const CanvasActiveSessionWidget({
    super.key,
    required this.state,
    required this.vocabularyLevel,
    required this.draftBannerExpanded,
    required this.onDraftExpansionChanged,
    required this.methodDisplayName,
    required this.workspace,
    required this.onSaveAndFinish,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final methodKey = state.selectedMethod!;
    final hasDraft = state.currentDraftContent.trim().isNotEmpty;
    final methodColor = ThinkingMethodVisuals.colorFor(
      methodKey,
      theme.colorScheme,
    );

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: methodColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: methodColor.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(
                ThinkingMethodVisuals.iconFor(methodKey),
                size: 16,
                color: methodColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  methodDisplayName(methodKey),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: methodColor,
                  ),
                ),
              ),
              WorkspaceExportButton(
                content: state.currentDraftContent,
                methodName: methodDisplayName(methodKey),
              ),
              IconButton(
                icon: Icon(
                  ref
                          .read(thinkingCanvasProvider.notifier)
                          .isFavorite(methodKey)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 16,
                  color: ref
                          .read(thinkingCanvasProvider.notifier)
                          .isFavorite(methodKey)
                      ? Colors.red
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onPressed: () => ref
                    .read(thinkingCanvasProvider.notifier)
                    .toggleFavorite(methodKey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              if (state.isSaving)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: methodColor,
                  ),
                ),
            ],
          ),
        ),
        if (hasDraft)
          CanvasDraftBannerWidget(
            content: state.currentDraftContent,
            initiallyExpanded: draftBannerExpanded,
            onExpansionChanged: onDraftExpansionChanged,
          ),
        WorkspaceGuideSection(methodKey: methodKey),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              100,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(methodKey),
                child: workspace,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: FilledButton.icon(
              onPressed: onSaveAndFinish,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                DaojiText.resolve(
                  DaojiTextKey.thinkingCanvasSaveAndFinish,
                  vocabularyLevel,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
