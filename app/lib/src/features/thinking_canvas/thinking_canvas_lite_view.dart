import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
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
    extends ConsumerState<ThinkingCanvasLiteView>
    with TickerProviderStateMixin {
  final TextEditingController _freewritingController =
      TextEditingController();
  bool _draftBannerExpanded = false;

  late AnimationController _saveIndicatorController;
  late Animation<double> _saveIndicatorOpacity;

  @override
  void initState() {
    super.initState();
    _saveIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _saveIndicatorOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _saveIndicatorController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _freewritingController.dispose();
    _saveIndicatorController.dispose();
    super.dispose();
  }

  void _showSaveIndicator() {
    _saveIndicatorController.reset();
    _saveIndicatorController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final canvasState = ref.watch(thinkingCanvasProvider);
    final hasActiveMethod = canvasState.selectedMethod != null;

    // Listen for save state changes to trigger indicator
    ref.listen<ThinkingCanvasState>(thinkingCanvasProvider, (prev, next) {
      if (prev?.isSaving == true && next.isSaving == false) {
        _showSaveIndicator();
      }
    });

    return PopScope(
      canPop: !hasActiveMethod,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && hasActiveMethod) {
          _confirmSaveAndClearCanvas();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: hasActiveMethod
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _confirmSaveAndClearCanvas,
                )
              : null,
          title: Text(
            hasActiveMethod
                ? _getMethodDisplayName(canvasState.selectedMethod!)
                : DaojiText.resolve(
                    DaojiTextKey.thinkingCanvasTitle, vocabularyLevel),
          ),
          actions: [
            if (hasActiveMethod && canvasState.hasContent)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: AnimatedBuilder(
                  animation: _saveIndicatorOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: canvasState.lastSavedAt != null
                          ? _saveIndicatorOpacity.value
                          : 0.0,
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      canvasState.lastSavedLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
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
      ),
    );
  }

  String _getMethodDisplayName(String key) {
    const names = {
      'MindDump': 'Mind Dump 🧠',
      'Freewriting': 'Freewriting ✍️',
      'MindMapping': 'Mind Map 🗺️',
      'MindDumpCluster': 'Mind Dump + Cluster',
      'Brainstorming': 'Brainstorming 🚀',
      'ReverseBrainstorming': 'Reverse Brainstorming',
      'WorstPossibleIdea': 'Worst Possible Idea 😈',
      'SCAMPER': 'SCAMPER 🔠',
      'RandomWord': 'Random Word 🔤',
      'RoleStorming': 'Role Storming 🎭',
      'Starbursting': 'Starbursting ⭐',
      'LotusBlossom': 'Lotus Blossom 🌸',
      'MorphologicalAnalysis': 'Morphological 🎰',
      'QuestionStorming': 'Question Storming',
      '5Whys': '5 Whys',
      'SWOT': 'SWOT Analysis',
      'AffinityMapping': 'Affinity Mapping',
      'FirstPrinciples': 'First Principles',
      'Scoring': 'Skoring Ide',
      'Validation': 'Validasi 48 Jam',
      'SixThinkingHats': 'Six Thinking Hats 🎩',
      'DisneyStrategy': 'Disney Strategy',
      'DoubleDiamond': 'Double Diamond 💎',
      'PMI': 'PMI Analysis',
    };
    return names[key] ?? key;
  }

  void _confirmSaveAndClearCanvas() {
    final state = ref.read(thinkingCanvasProvider);
    if (state.selectedMethod != null && state.hasContent) {
      HapticFeedback.mediumImpact();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Simpan Sesi?'),
          content: const Text(
            'Anda memiliki konten yang belum disimpan secara permanen. '
            'Apa yang ingin Anda lakukan?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Discard without saving
                ref.read(thinkingCanvasProvider.notifier).clearCanvas();
              },
              child: const Text('Buang', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Go back without saving
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveAndClearCanvas();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    } else {
      ref.read(thinkingCanvasProvider.notifier).clearCanvas();
    }
  }

  void _saveAndClearCanvas() {
    final state = ref.read(thinkingCanvasProvider);
    if (state.selectedMethod != null) {
      _persistSession(state);
    }
    ref.read(thinkingCanvasProvider.notifier).clearCanvas();
  }

  Future<void> _persistSession(ThinkingCanvasState state) async {
    try {
      final db = ref.read(dbProvider);
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) return;
      final userId = profiles.first.userId;

      final method = state.selectedMethod ?? 'Unknown';
      final content = state.currentDraftContent;
      // Only save if there's meaningful content
      if (content.trim().isEmpty) return;
      await db.into(db.thinkingCanvasSessions).insert(
            ThinkingCanvasSessionsCompanion.insert(
              sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: userId,
              methodKey: method,
              rawNotes: drift.Value(content),
              createdAt: DateTime.now(),
            ),
          );
    } catch (_) {
      // Silent fail — non-critical
    }
  }

  void _showSessionHistory(BuildContext context) {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final theme = Theme.of(context);
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
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DaojiText.resolve(
                                DaojiTextKey
                                    .thinkingCanvasSessionHistoryTitle,
                                vocabularyLevel,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: sessions.isEmpty
                            ? EmptyStateWidget(
                                icon: Icons.history_rounded,
                                title: 'Belum Ada Sesi',
                                message:
                                    'Semua sesi eksplorasi ide terstruktur Anda akan tercatat di sini.',
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: sessions.length,
                                itemBuilder: (context, i) {
                                  final s = sessions[i];
                                  final methodColor = _getMethodColor(
                                    s.methodKey,
                                  );
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: Material(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      elevation: 0,
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        onTap: () async {
                                          Navigator.pop(context);

                                          // Show loading dialog
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (dialogContext) =>
                                                Center(
                                              child: Card(
                                                margin:
                                                    const EdgeInsets.all(40),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(24),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const CircularProgressIndicator(),
                                                      const SizedBox(
                                                          height: 16),
                                                      const Text(
                                                          'Memuat sesi...'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );

                                          // Small delay to ensure UI updates
                                          await Future.delayed(
                                            const Duration(milliseconds: 100),
                                          );

                                          // Load session
                                          setState(() {
                                            _draftBannerExpanded = true;
                                            if (s.methodKey ==
                                                'Freewriting') {
                                              _freewritingController.text =
                                                  s.rawNotes ?? '';
                                            }
                                          });
                                          ref
                                              .read(thinkingCanvasProvider
                                                  .notifier)
                                              .loadSession(s);

                                          // Close loading dialog
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: theme.colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.08),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 42,
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: methodColor
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                ),
                                                child: Icon(
                                                  _getMethodIcon(s.methodKey),
                                                  color: methodColor,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      s.topic ??
                                                          _getMethodDisplayName(
                                                              s.methodKey),
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: methodColor
                                                                .withValues(
                                                                    alpha:
                                                                        0.08),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: Text(
                                                            s.methodKey,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  methodColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          '${s.createdAt.day}/${s.createdAt.month}/${s.createdAt.year}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.5),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (s.rawNotes != null &&
                                                        s.rawNotes!
                                                            .trim()
                                                            .isNotEmpty) ...[
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        s.rawNotes!
                                                            .trim()
                                                            .split('\n')
                                                            .first,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.4),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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

  Color _getMethodColor(String methodKey) {
    switch (methodKey) {
      case 'MindDump':
      case 'MindDumpCluster':
        return Colors.teal;
      case 'Freewriting':
        return Colors.deepPurple;
      case 'MindMapping':
        return Colors.indigo;
      case 'Brainstorming':
      case 'ReverseBrainstorming':
      case 'WorstPossibleIdea':
        return Colors.orange;
      case 'SCAMPER':
        return Colors.pink;
      case 'SixThinkingHats':
        return Colors.blue;
      case 'SWOT':
        return Colors.green;
      case '5Whys':
        return Colors.amber.shade800;
      case 'LotusBlossom':
        return Colors.purple;
      case 'MorphologicalAnalysis':
        return Colors.cyan;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getMethodIcon(String methodKey) {
    switch (methodKey) {
      case 'MindDump':
      case 'MindDumpCluster':
        return Icons.psychology_rounded;
      case 'Freewriting':
        return Icons.edit_note_rounded;
      case 'MindMapping':
        return Icons.account_tree_rounded;
      case 'Brainstorming':
      case 'ReverseBrainstorming':
      case 'WorstPossibleIdea':
        return Icons.lightbulb_rounded;
      case 'SCAMPER':
        return Icons.transform_rounded;
      case 'SixThinkingHats':
        return Icons.hotel_class_rounded;
      case 'SWOT':
        return Icons.grid_view_rounded;
      case '5Whys':
        return Icons.help_rounded;
      case 'LotusBlossom':
        return Icons.local_florist_rounded;
      case 'MorphologicalAnalysis':
        return Icons.casino_rounded;
      default:
        return Icons.insights_rounded;
    }
  }

  // ============================================
  // MOOD-BASED METHOD SELECTION
  // ============================================
  Widget _buildMethodSelection(
    BuildContext context,
    ThemeData theme,
    DaojiVocabularyLevel level,
    ThinkingCanvasState state,
  ) {
    final selectedMood = state.selectedMood;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mood selection header
          _buildMoodPrompt(theme, level, selectedMood),
          const SizedBox(height: 24),

          // Quick methods (always visible)
          Text(
            'Mulai Cepat',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickMethodCards(theme, level, state),
          const SizedBox(height: 24),

          // Recent methods (if any)
          if (state.recentMethods.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'Terakhir Digunakan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.recentMethods.map((key) {
                return ActionChip(
                  avatar: Icon(
                    _getMethodIcon(key),
                    size: 16,
                    color: _getMethodColor(key),
                  ),
                  label: Text(
                    _getMethodDisplayName(key),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(thinkingCanvasProvider.notifier)
                        .setMethod(key);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // View all button
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => MethodPickerBottomSheet(
                currentMethodKey: state.selectedMethod ?? '',
                isPremiumUser: true,
                favoriteMethods: state.favoriteMethods,
                onToggleFavorite: (key) => ref
                    .read(thinkingCanvasProvider.notifier)
                    .toggleFavorite(key),
                onSelected: (method) => ref
                    .read(thinkingCanvasProvider.notifier)
                    .setMethod(method),
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

  Widget _buildMoodPrompt(
    ThemeData theme,
    DaojiVocabularyLevel level,
    String? selectedMood,
  ) {
    final moods = [
      {
        'key': 'overwhelmed',
        'label': '🤯 Pusing',
        'subtitle': 'Pikiran penuh & cemas',
        'color': Colors.teal,
        'methods': ['MindDump', 'Freewriting', 'MindDumpCluster'],
      },
      {
        'key': 'creative',
        'label': '💡 Kreatif',
        'subtitle': 'Eksplorasi ide baru',
        'color': Colors.orange,
        'methods': [
          'Brainstorming',
          'MindMapping',
          'SCAMPER',
          'LotusBlossom',
          'MorphologicalAnalysis'
        ],
      },
      {
        'key': 'analytical',
        'label': '🔍 Analitis',
        'subtitle': 'Urai masalah dalam',
        'color': Colors.blue,
        'methods': ['5Whys', 'SWOT', 'AffinityMapping', 'FirstPrinciples'],
      },
      {
        'key': 'deciding',
        'label': '⚖️ Memutuskan',
        'subtitle': 'Pilihan terbaik',
        'color': Colors.purple,
        'methods': [
          'SixThinkingHats',
          'DisneyStrategy',
          'Scoring',
          'Validation'
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apa yang Anda rasakan saat ini?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih suasana hati untuk rekomendasi metode',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: moods.map((mood) {
            final isSelected = selectedMood == mood['key'];
            final moodColor = mood['color'] as Color;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: isSelected
                      ? moodColor.withValues(alpha: 0.15)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (isSelected) {
                        // Deselect mood properly — set to null via clearMood
                        ref
                            .read(thinkingCanvasProvider.notifier)
                            .clearMood();
                      } else {
                        ref
                            .read(thinkingCanvasProvider.notifier)
                            .setMood(mood['key'] as String);
                      }
                    },
                    child: Container(
                      height: 72,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? moodColor
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.08),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood['label'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? moodColor
                                  : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              color: isSelected
                                  ? moodColor.withValues(alpha: 0.8)
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Mood-based recommendations
        if (selectedMood != null) ...[
          const SizedBox(height: 16),
          _buildMoodRecommendations(theme, level, moods, selectedMood),
        ],
      ],
    );
  }

  Widget _buildMoodRecommendations(
    ThemeData theme,
    DaojiVocabularyLevel level,
    List<Map<String, dynamic>> moods,
    String selectedMood,
  ) {
    // Find matching mood safely — avoid firstWhere type issues with Map<String, dynamic>
    final moodIndex = moods.indexWhere((m) => m['key'] == selectedMood);
    if (moodIndex < 0) return const SizedBox.shrink();
    final mood = moods[moodIndex];
    final methods = mood['methods'] as List;
    final moodColor = mood['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Rekomendasi untuk Anda',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: moodColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: methods.map((methodKey) {
            return ActionChip(
              avatar: Icon(
                _getMethodIcon(methodKey),
                size: 16,
                color: moodColor,
              ),
              label: Text(
                _getMethodDisplayName(methodKey),
                style: const TextStyle(fontSize: 12),
              ),
              side: BorderSide(
                color: moodColor.withValues(alpha: 0.3),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(thinkingCanvasProvider.notifier).setMethod(methodKey);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickMethodCards(
    ThemeData theme,
    DaojiVocabularyLevel level,
    ThinkingCanvasState state,
  ) {
    final quickMethods = [
      {
        'key': 'MindDump',
        'name': 'Mind Dump',
        'emoji': '🧠',
        'desc': 'Tuangkan seluruh beban pikiran tanpa hambatan.',
        'icon': Icons.psychology_rounded,
        'color': Colors.teal,
      },
      {
        'key': 'Freewriting',
        'name': 'Freewriting',
        'emoji': '✍️',
        'desc': 'Tulis cepat tanpa jeda dengan timer fokus.',
        'icon': Icons.edit_note_rounded,
        'color': Colors.deepPurple,
      },
      {
        'key': 'MindMapping',
        'name': 'Mind Map',
        'emoji': '🗺️',
        'desc': 'Petakan hubungan ide secara visual.',
        'icon': Icons.account_tree_rounded,
        'color': Colors.indigo,
      },
    ];

    return Row(
      children: quickMethods.map((m) {
        final mColor = m['color'] as Color;
        final isFavorite =
            state.favoriteMethods.contains(m['key']);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              height: 180,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: mColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                color: mColor.withValues(alpha: 0.04),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(thinkingCanvasProvider.notifier)
                            .setMethod(m['key'] as String);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: mColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                m['icon'] as IconData,
                                color: mColor,
                                size: 22,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${m['emoji']} ${m['name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
                    // Favorite button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite
                              ? Colors.red
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                        ),
                        onPressed: () {
                          ref
                              .read(thinkingCanvasProvider.notifier)
                              .toggleFavorite(m['key'] as String);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: isFavorite
                            ? 'Hapus dari favorit'
                            : 'Tambah ke favorit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================
  // DRAFT BANNER (FIXED THEMING)
  // ============================================
  Widget _buildDraftBanner(BuildContext context, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: _draftBannerExpanded,
        onExpansionChanged: (val) {
          setState(() {
            _draftBannerExpanded = val;
          });
        },
        leading: Icon(
          Icons.history_edu_rounded,
          color: theme.colorScheme.secondary,
        ),
        title: Text(
          'Draf Konten Sesi Sebelumnya',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Gunakan ini sebagai referensi atau salin isinya.',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20),
          tooltip: 'Salin ke Clipboard',
          onPressed: () {
            HapticFeedback.lightImpact();
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Konten berhasil disalin ke clipboard!'),
                backgroundColor: theme.colorScheme.primary,
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
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface.withValues(alpha: 0.6)
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
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

  // ============================================
  // ACTIVE CANVAS (IMPROVED)
  // ============================================
  Widget _buildActiveCanvas(
    BuildContext context,
    ThemeData theme,
    ThinkingCanvasState state,
  ) {
    final hasDraft = state.currentDraftContent.trim().isNotEmpty;
    final methodColor = _getMethodColor(state.selectedMethod!);

    return Stack(
      children: [
        Column(
          children: [
            // Method context bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: methodColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getMethodIcon(state.selectedMethod!),
                    size: 18,
                    color: methodColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getMethodDisplayName(state.selectedMethod!),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: methodColor,
                      ),
                    ),
                  ),
                  // Favorite toggle
                  IconButton(
                    icon: Icon(
                      ref
                              .read(thinkingCanvasProvider.notifier)
                              .isFavorite(state.selectedMethod!)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color: ref
                              .read(thinkingCanvasProvider.notifier)
                              .isFavorite(state.selectedMethod!)
                          ? Colors.red
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                    ),
                    onPressed: () {
                      ref
                          .read(thinkingCanvasProvider.notifier)
                          .toggleFavorite(state.selectedMethod!);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    tooltip: 'Favorit',
                  ),
                  // Auto-save indicator
                  if (state.isSaving)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: methodColor,
                      ),
                    ),
                ],
              ),
            ),
            if (hasDraft) _buildDraftBanner(context, state.currentDraftContent),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                child: _getWorkspaceForMethod(state.selectedMethod!),
              ),
            ),
          ],
        ),

        // Improved bottom action bar
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Save & close button (prominent)
              Expanded(
                child: FilledButton.icon(
                  onPressed: _confirmSaveAndClearCanvas,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Simpan & Selesai'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Switch method button
              FloatingActionButton.small(
                heroTag: 'switch_method',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _confirmSaveAndClearCanvas();
                },
                tooltip: 'Ganti Metode',
                child: const Icon(Icons.swap_horiz_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onWorkspaceChanged(String content) {
    ref.read(thinkingCanvasProvider.notifier).updateDraft(content);
  }

  Widget _getWorkspaceForMethod(String method) {
    switch (method) {
      // --- Workspace dengan widget khusus ---
      case 'Freewriting':
        return FreewritingWorkspace(controller: _freewritingController);

      case 'MindMapping':
        return MindMapCanvasView(initialNodes: const [], onSaved: (_) {});

      case 'LotusBlossom':
        return LotusBlossomWorkspace(onChanged: _onWorkspaceChanged);

      case 'MorphologicalAnalysis':
        return MorphologicalWorkspace(
          isPremiumUser: true,
          onPremiumLocked: () {},
          onChanged: _onWorkspaceChanged,
        );

      // Synthesis workspaces
      case 'MindDump':
      case 'MindDumpCluster':
        return MindDumpWorkspace(onChanged: _onWorkspaceChanged);

      case 'AffinityMapping':
        return AffinityMappingWorkspace(onChanged: _onWorkspaceChanged);

      case '5Whys':
        return FiveWhysWorkspace(onChanged: _onWorkspaceChanged);

      case 'FirstPrinciples':
        return FirstPrinciplesWorkspace(onChanged: _onWorkspaceChanged);

      case 'DoubleDiamond':
        return DoubleDiamondWorkspace(onChanged: _onWorkspaceChanged);

      case 'Validation':
      case 'Scoring':
        return ValidationWorkspace(onChanged: _onWorkspaceChanged);

      // Decision workspaces
      case 'SixThinkingHats':
        return SixThinkingHatsWorkspace(onChanged: _onWorkspaceChanged);

      case 'DisneyStrategy':
        return DisneyStrategyWorkspace(onChanged: _onWorkspaceChanged);

      case 'SCAMPER':
        return ScamperWorkspace(onChanged: _onWorkspaceChanged);

      case 'SWOT':
        return SwotMatrixWorkspace(onChanged: _onWorkspaceChanged);

      case 'Starbursting':
        return StarburstingWorkspace(onChanged: _onWorkspaceChanged);

      // Brainstorm workspaces
      case 'Brainstorming':
      case 'ReverseBrainstorming':
      case 'WorstPossibleIdea':
        return RapidBrainstormWorkspace(onChanged: _onWorkspaceChanged);

      case 'QuestionStorming':
        return QuestionStormWorkspace(onChanged: _onWorkspaceChanged);

      case 'RandomWord':
        return RandomWordWorkspace(onChanged: _onWorkspaceChanged);

      case 'RoleStorming':
        return RoleStormingWorkspace(
          isPremiumUser: true,
          onPremiumLocked: () {},
          onChanged: _onWorkspaceChanged,
        );

      // Fallback untuk metode tanpa workspace khusus (PMI, dll.)
      default:
        return _GenericThinkingWorkspace(
          title: method,
          onChanged: _onWorkspaceChanged,
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
          fillColor: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
