import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_level.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/widgets/loading_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../data/local_db/database.dart';
import 'domain/thinking_method.dart';
import 'widgets/method_picker_bottom_sheet.dart';
import 'widgets/mind_map_canvas_view.dart';
import 'widgets/specialized_workspace_widgets.dart';
import 'widgets/thinking_canvas_onboarding_dialog.dart';
import 'widgets/workspaces/brainstorm_workspaces.dart';
import 'widgets/workspaces/decision_workspaces.dart';
import 'widgets/workspaces/freewriting_workspace.dart';
import 'widgets/workspaces/lotus_blossom_workspace.dart';
import 'widgets/workspaces/morphological_workspace.dart';
import 'widgets/workspaces/synthesis_workspaces.dart';
import 'thinking_canvas_state.dart';
import 'thinking_canvas_draft_service.dart';

class ThinkingCanvasLiteView extends ConsumerStatefulWidget {
  const ThinkingCanvasLiteView({super.key});

  @override
  ConsumerState<ThinkingCanvasLiteView> createState() =>
      _ThinkingCanvasLiteViewState();
}

class _ThinkingCanvasLiteViewState
    extends ConsumerState<ThinkingCanvasLiteView> {
  final TextEditingController _freewritingController = TextEditingController();
  String _workspaceDraftText = '';

  @override
  void dispose() {
    _freewritingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final canvasState = ref.watch(thinkingCanvasProvider);
    final draftService = ref.read(thinkingCanvasDraftServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DaojiText.resolve(DaojiTextKey.thinkingCanvasTitle, vocabularyLevel),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: DaojiText.resolve(
              DaojiTextKey.thinkingCanvasHistory,
              vocabularyLevel,
            ),
            onPressed: () => _showSessionHistory(context),
          ),
        ],
      ),
      body: canvasState.selectedMethod == null
          ? _buildMethodSelection(context, theme, vocabularyLevel, canvasState)
          : _buildActiveCanvas(context, theme, canvasState),
    );
  }

  void _showSessionHistory(BuildContext context) {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final db = ref.read(dbProvider);
        return FutureBuilder<List<ThinkingCanvasSession>>(
          future:
              (db.select(db.thinkingCanvasSessions)
                    ..orderBy([
                      (tbl) => drift.OrderingTerm(
                        expression: tbl.createdAt,
                        mode: drift.OrderingMode.desc,
                      ),
                    ])
                    ..limit(20))
                  .get(),
          builder: (context, snapshot) {
            final sessions = snapshot.data ?? [];
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        DaojiText.resolve(
                          DaojiTextKey.thinkingCanvasSessionHistoryTitle,
                          vocabularyLevel,
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: sessions.length,
                          itemBuilder: (context, i) {
                            final s = sessions[i];
                            return ListTile(
                              leading: const Icon(Icons.insights_rounded),
                              title: Text(
                                s.topic ?? s.methodKey,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${s.methodKey} • ${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}',
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                ref.read(thinkingCanvasProvider.notifier).loadSession(s);
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
          },
        );
      },
    );
  }

  Widget _buildMethodSelection(
    BuildContext context,
    ThemeData theme,
    DaojiVocabularyLevel level,
    ThinkingCanvasState state,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            DaojiText.resolve(DaojiTextKey.methodPickerTitle, level),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => MethodPickerBottomSheet(
                currentMethodKey: state.selectedMethod ?? '',
                isPremiumUser: true,
                onSelected: (method) =>
                    ref.read(thinkingCanvasProvider.notifier).setMethod(method),
              ),
            ),
            child: Text(
              DaojiText.resolve(
                DaojiTextKey.thinkingCanvasOpenMethodCatalog,
                level,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCanvas(
    BuildContext context,
    ThemeData theme,
    ThinkingCanvasState state,
  ) {
    return Stack(
      children: [
        _getWorkspaceForMethod(state.selectedMethod!),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () =>
                ref.read(thinkingCanvasProvider.notifier).clearCanvas(),
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  Widget _getWorkspaceForMethod(String method) {
    if (method.toLowerCase().contains('freewriting')) {
      return FreewritingWorkspace(controller: _freewritingController);
    }
    if (method.toLowerCase().contains('mindmapping')) {
      return MindMapCanvasView(initialNodes: const [], onSaved: (_) {});
    }
    if (method.toLowerCase().contains('lotus')) {
      return LotusBlossomWorkspace(
        onChanged: (text) => _workspaceDraftText = text,
      );
    }
    if (method.toLowerCase().contains('morphological')) {
      return MorphologicalWorkspace(
        isPremiumUser: true,
        onPremiumLocked: () {},
        onChanged: (text) => _workspaceDraftText = text,
      );
    }
    return _GenericThinkingWorkspace(
      title: method,
      onChanged: (text) => _workspaceDraftText = text,
    );
  }
}

class _GenericThinkingWorkspace extends ConsumerWidget {
  final String title;
  final ValueChanged<String> onChanged;

  const _GenericThinkingWorkspace({
    required this.title,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
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
        ),
      ),
    );
  }
}
