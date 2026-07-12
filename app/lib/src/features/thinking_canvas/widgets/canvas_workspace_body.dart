import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/mind_map_model.dart';
import '../thinking_canvas_state.dart';
import '../workspace_registry.dart';
import 'specialized_workspace_widgets.dart';

/// Resolves the workspace body for a selected thinking method.
class CanvasWorkspaceBody extends ConsumerWidget {
  final String method;
  final TextEditingController freewritingController;

  const CanvasWorkspaceBody({
    super.key,
    required this.method,
    required this.freewritingController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onChanged(String content) {
      ref.read(thinkingCanvasProvider.notifier).updateDraft(content);
    }

    void onStructuredOutput(String json) {
      ref.read(thinkingCanvasProvider.notifier).updateStructuredOutput(json);
    }

    final restored = ref.read(thinkingCanvasProvider).structuredOutput;

    if (method == 'Freewriting') {
      return FreewritingWorkspace(controller: freewritingController);
    }
    if (method == 'MindMapping') {
      return _MindMapInline(onChanged: onChanged);
    }

    return ThinkingWorkspaceRegistry.build(
          method,
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: restored,
        ) ??
        _GenericThinkingWorkspace(title: method, onChanged: onChanged);
  }
}

class _MindMapInline extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const _MindMapInline({required this.onChanged});

  @override
  ConsumerState<_MindMapInline> createState() => _MindMapInlineState();
}

class _MindMapInlineState extends ConsumerState<_MindMapInline> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          unawaited(HapticFeedback.selectionClick());
          final canvasState = ref.read(thinkingCanvasProvider);
          final initial = canvasState.mindMapNodes
              .map((m) => MindMapNode.fromJson(m))
              .toList();
          final result = await context.push<List<MindMapNode>>(
            '/thinking-canvas/mind-map',
            extra: initial,
          );
          if (result != null && result.isNotEmpty) {
            final serialized =
                result.map((n) => '${n.text} (${n.id})').join('\n');
            widget.onChanged(serialized);
            ref
                .read(thinkingCanvasProvider.notifier)
                .updateMindMapNodes(result.map((n) => n.toJson()).toList());
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk untuk buka editor Mind Map',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Editor visual full-screen dengan drag & drop',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericThinkingWorkspace extends ConsumerWidget {
  final String title;
  final ValueChanged<String> onChanged;
  const _GenericThinkingWorkspace({
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        maxLines: 12,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: DaojiText.resolve(
            DaojiTextKey.thinkingCanvasWorkspaceLabel,
            vocabularyLevel,
            params: {'title': title},
          ),
          hintText: DaojiText.resolve(
            DaojiTextKey.thinkingCanvasWorkspaceHint,
            vocabularyLevel,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
        ),
      ),
    );
  }
}
