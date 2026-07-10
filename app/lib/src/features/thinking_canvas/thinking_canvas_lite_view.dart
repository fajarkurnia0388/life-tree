import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_level.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/local_db/database.dart';
import 'widgets/method_picker_bottom_sheet.dart';
import 'widgets/mind_map_canvas_view.dart';
import 'widgets/specialized_workspace_widgets.dart';
import 'thinking_canvas_state.dart';

class ThinkingCanvasLiteView extends ConsumerStatefulWidget {
  const ThinkingCanvasLiteView({super.key});

  @override
  ConsumerState<ThinkingCanvasLiteView> createState() =>
      _ThinkingCanvasLiteViewState();
}

class _ThinkingCanvasLiteViewState
    extends ConsumerState<ThinkingCanvasLiteView> {
  final TextEditingController _freewritingController = TextEditingController();

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
                        child: sessions.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.history_rounded,
                                title: 'Belum Ada Sesi',
                                message: 'Semua sesi eksplorasi ide terstruktur Anda akan tercatat di sini.',
                              )
                            : ListView.builder(
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
                                    onTap: () async {
                                      Navigator.pop(context);
                                      
                                      // Show loading dialog
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (dialogContext) => Center(
                                          child: Card(
                                            margin: const EdgeInsets.all(40),
                                            child: Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const CircularProgressIndicator(),
                                                  const SizedBox(height: 16),
                                                  const Text('Memuat sesi...'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                      
                                      // Small delay to ensure UI updates
                                      await Future.delayed(const Duration(milliseconds: 100));
                                      
                                      // Load session
                                      ref.read(thinkingCanvasProvider.notifier).loadSession(s);
                                      
                                      // Close loading dialog
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
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
    final quickMethods = [
      {
        'key': 'MindDump',
        'name': 'Mind Dump 🧠',
        'desc': 'Tuangkan seluruh beban pikiran, kecemasan, dan ide tanpa hambatan.',
        'icon': Icons.psychology_rounded,
        'color': Colors.teal,
      },
      {
        'key': 'Brainstorming',
        'name': 'Classic Brainstorm 💡',
        'desc': 'Kumpulkan ide liar sebanyak mungkin dalam waktu singkat.',
        'icon': Icons.lightbulb_outline_rounded,
        'color': Colors.amber,
      },
      {
        'key': 'SixThinkingHats',
        'name': 'Six Thinking Hats 🎩',
        'desc': 'Evaluasi ide terstruktur dari 6 sudut pandang kognitif.',
        'icon': Icons.palette_rounded,
        'color': Colors.blue,
      },
      {
        'key': '5Whys',
        'name': '5 Whys 🔍',
        'desc': 'Gali sebab-akibat hingga ke akar permasalahan terdalam.',
        'icon': Icons.help_outline_rounded,
        'color': Colors.purple,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Glassmorphic Banner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    size: 36,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DaojiText.resolve(DaojiTextKey.thinkingCanvasTitle, level),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gunakan metode analitis dan kreatif terstruktur untuk mengurai kerumitan dan menemukan solusi jernih.',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            DaojiText.resolve(DaojiTextKey.methodPickerTitle, level),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Grid layout for quick start
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: quickMethods.length,
            itemBuilder: (context, index) {
              final m = quickMethods[index];
              final mColor = m['color'] as Color;
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: InkWell(
                  onTap: () => ref
                      .read(thinkingCanvasProvider.notifier)
                      .setMethod(m['key'] as String),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: mColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            m['icon'] as IconData,
                            color: mColor,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          m['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m['desc'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // View all button
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => MethodPickerBottomSheet(
                currentMethodKey: state.selectedMethod ?? '',
                isPremiumUser: true,
                onSelected: (method) =>
                    ref.read(thinkingCanvasProvider.notifier).setMethod(method),
              ),
            ),
            icon: const Icon(Icons.apps_rounded, size: 18),
            label: Text(
              DaojiText.resolve(
                DaojiTextKey.thinkingCanvasOpenMethodCatalog,
                level,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
    switch (method) {
      // --- Workspace dengan widget khusus ---
      case 'Freewriting':
        return FreewritingWorkspace(controller: _freewritingController);

      case 'MindMapping':
        return MindMapCanvasView(initialNodes: const [], onSaved: (_) {});

      case 'LotusBlossom':
        return LotusBlossomWorkspace(onChanged: (_) {});

      case 'MorphologicalAnalysis':
        return MorphologicalWorkspace(
          isPremiumUser: true,
          onPremiumLocked: () {},
          onChanged: (_) {},
        );

      // Synthesis workspaces
      case 'MindDump':
      case 'MindDumpCluster':
        return MindDumpWorkspace(onChanged: (_) {});

      case 'AffinityMapping':
        return AffinityMappingWorkspace(onChanged: (_) {});

      case '5Whys':
        return FiveWhysWorkspace(onChanged: (_) {});

      case 'FirstPrinciples':
        return FirstPrinciplesWorkspace(onChanged: (_) {});

      case 'DoubleDiamond':
        return DoubleDiamondWorkspace(onChanged: (_) {});

      case 'Validation':
      case 'Scoring':
        return ValidationWorkspace(onChanged: (_) {});

      // Decision workspaces
      case 'SixThinkingHats':
        return SixThinkingHatsWorkspace(onChanged: (_) {});

      case 'DisneyStrategy':
        return DisneyStrategyWorkspace(onChanged: (_) {});

      case 'SCAMPER':
        return ScamperWorkspace(onChanged: (_) {});

      case 'SWOT':
        return SwotMatrixWorkspace(onChanged: (_) {});

      case 'Starbursting':
        return StarburstingWorkspace(onChanged: (_) {});

      // Brainstorm workspaces
      case 'Brainstorming':
      case 'ReverseBrainstorming':
      case 'WorstPossibleIdea':
        return RapidBrainstormWorkspace(onChanged: (_) {});

      case 'QuestionStorming':
        return QuestionStormWorkspace(onChanged: (_) {});

      case 'RandomWord':
        return RandomWordWorkspace(onChanged: (_) {});

      case 'RoleStorming':
        return RoleStormingWorkspace(
          isPremiumUser: true,
          onPremiumLocked: () {},
          onChanged: (_) {},
        );

      // Fallback untuk metode tanpa workspace khusus (PMI, dll.)
      default:
        return _GenericThinkingWorkspace(
          title: method,
          onChanged: (_) {},
        );
    }
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
