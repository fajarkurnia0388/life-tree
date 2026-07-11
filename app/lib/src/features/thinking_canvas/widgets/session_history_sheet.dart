import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../../../data/local_db/database.dart';
import '../thinking_canvas_draft_service.dart';
import 'method_visuals.dart';

/// Reactive session history bottom sheet (Drift stream via [thinkingCanvasHistoryProvider]).
class ThinkingCanvasSessionHistorySheet extends ConsumerWidget {
  const ThinkingCanvasSessionHistorySheet({
    super.key,
    required this.onSessionSelected,
    required this.methodDisplayName,
  });

  /// Called after the sheet is closed and loading UI is shown by the parent.
  final Future<void> Function(ThinkingCanvasSession session) onSessionSelected;

  final String Function(String methodKey) methodDisplayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final historyAsync = ref.watch(thinkingCanvasHistoryProvider);

    String t(DaojiTextKey key) => DaojiText.resolve(key, vocabularyLevel);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.35,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t(DaojiTextKey.thinkingCanvasSessionHistoryTitle),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    historyAsync.maybeWhen(
                      data: (sessions) => sessions.isEmpty
                          ? const SizedBox.shrink()
                          : TextButton(
                              onPressed: () => _confirmDeleteAll(
                                context,
                                ref,
                                vocabularyLevel,
                              ),
                              child: Text(
                                t(DaojiTextKey.thinkingCanvasDeleteAllAction),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: historyAsync.when(
                  loading: () => LoadingStateWidget(
                    message: t(DaojiTextKey.thinkingCanvasLoadingSession),
                  ),
                  error: (e, _) => ErrorStateWidget(
                    message: t(DaojiTextKey.systemRetry),
                    error: e.toString(),
                    onRetry: () => ref.invalidate(thinkingCanvasHistoryProvider),
                  ),
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.history_rounded,
                        title: t(DaojiTextKey.thinkingCanvasNoSessionsTitle),
                        message: t(DaojiTextKey.thinkingCanvasNoSessionsBody),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sessions.length,
                      itemBuilder: (context, i) {
                        final s = sessions[i];
                        final methodColor = ThinkingMethodVisuals.colorFor(
                          s.methodKey,
                          theme.colorScheme,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey(s.sessionId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_rounded,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(
                                        t(DaojiTextKey.thinkingCanvasDeleteSession),
                                      ),
                                      content: Text(
                                        'Sesi "${s.topic ?? methodDisplayName(s.methodKey)}" '
                                        'akan dihapus dari riwayat.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(
                                            t(DaojiTextKey.systemCancel),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(
                                            t(DaojiTextKey.systemDelete),
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) {
                              unawaited(
                                ref
                                    .read(thinkingCanvasDraftServiceProvider)
                                    .softDeleteSession(s.sessionId),
                              );
                            },
                            child: Material(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await onSessionSelected(s);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: methodColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          ThinkingMethodVisuals.iconFor(
                                            s.methodKey,
                                          ),
                                          color: methodColor,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.topic ??
                                                  methodDisplayName(s.methodKey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 1,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: methodColor
                                                        .withValues(alpha: 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    s.methodKey,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: methodColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withValues(alpha: 0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.2),
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAll(
    BuildContext context,
    WidgetRef ref,
    DaojiVocabularyLevel vocabularyLevel,
  ) async {
    final theme = Theme.of(context);
    String t(DaojiTextKey key) => DaojiText.resolve(key, vocabularyLevel);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t(DaojiTextKey.thinkingCanvasDeleteAllHistory)),
        content: Text(t(DaojiTextKey.thinkingCanvasDeleteAllHistoryBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t(DaojiTextKey.systemCancel)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t(DaojiTextKey.systemDelete),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(thinkingCanvasDraftServiceProvider).softDeleteAllHistory();
      // Stream updates automatically; keep sheet open so user sees empty state.
    }
  }
}

/// Shows [ThinkingCanvasSessionHistorySheet] as a modal bottom sheet.
Future<void> showThinkingCanvasSessionHistory({
  required BuildContext context,
  required Future<void> Function(ThinkingCanvasSession session) onSessionSelected,
  required String Function(String methodKey) methodDisplayName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ThinkingCanvasSessionHistorySheet(
      onSessionSelected: onSessionSelected,
      methodDisplayName: methodDisplayName,
    ),
  );
}
