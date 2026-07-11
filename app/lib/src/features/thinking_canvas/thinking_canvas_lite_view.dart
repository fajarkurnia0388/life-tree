import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_level.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import 'domain/thinking_method.dart';
import 'domain/mind_map_model.dart';
import 'widgets/method_picker_bottom_sheet.dart';
import 'widgets/specialized_workspace_widgets.dart';
import 'widgets/thinking_canvas_onboarding_dialog.dart';
import 'thinking_canvas_state.dart';
import 'widgets/method_visuals.dart';
import 'widgets/session_history_sheet.dart';

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

    // Show onboarding on first visit
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(thinkingCanvasProvider.notifier);
      await notifier.restoreDraftIfAny();
      final state = ref.read(thinkingCanvasProvider);
      if (!state.hasSeenOnboarding) {
        _showOnboardingDialog();
      }
    });
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

  void _showOnboardingDialog() {
    final canvasNotifier = ref.read(thinkingCanvasProvider.notifier);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ThinkingCanvasOnboardingDialog(
        initialDontShowAgain: false,
        onMethodSelected: (method) {
          canvasNotifier.setMethod(method);
        },
        onDontShowAgainChanged: (val) {
          if (val) canvasNotifier.markOnboardingSeen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final canvasState = ref.watch(thinkingCanvasProvider);
    final hasActiveMethod = canvasState.selectedMethod != null;

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
            : _buildActiveCanvas(context, theme, canvasState, vocabularyLevel),
      ),
    );
  }

  // ============================================
  // METHOD DISPLAY HELPERS
  // ============================================
  String _getMethodDisplayName(String key) {
    return _findMethod(key)?.name ?? key;
  }

  ThinkingMethod? _findMethod(String key) {
    try {
      return ThinkingMethod.allMethods.firstWhere((m) => m.key == key);
    } catch (_) {
      return null;
    }
  }

  Color _getMethodColor(String methodKey) {
    return ThinkingMethodVisuals.colorFor(methodKey, Theme.of(context).colorScheme);
  }


  IconData _getMethodIcon(String methodKey) {
    return ThinkingMethodVisuals.iconFor(methodKey);
  }


  // ============================================
  // SAVE / PERSIST LOGIC
  // ============================================
  void _confirmSaveAndClearCanvas() {
    final state = ref.read(thinkingCanvasProvider);
    final level = ref.read(daojiVocabularyLevelValueProvider);
    String t(DaojiTextKey key) => DaojiText.resolve(key, level);
    if (state.selectedMethod != null && state.hasContent) {
      HapticFeedback.mediumImpact();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(t(DaojiTextKey.thinkingCanvasSaveSessionTitle)),
          content: Text(t(DaojiTextKey.thinkingCanvasSaveSessionBody)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(thinkingCanvasProvider.notifier).clearCanvas();
              },
              child: Text(
                t(DaojiTextKey.thinkingCanvasDiscard),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t(DaojiTextKey.systemCancel)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveAndClearCanvas();
              },
              child: Text(t(DaojiTextKey.systemSave)),
            ),
          ],
        ),
      );
    } else {
      ref.read(thinkingCanvasProvider.notifier).clearCanvas();
    }
  }

  Future<void> _saveAndClearCanvas() async {
    final notifier = ref.read(thinkingCanvasProvider.notifier);
    try {
      await notifier.commitToHistory();
    } catch (_) {
      // Non-fatal; still clear canvas so user is not stuck
    }
    notifier.clearCanvas();
  }

  // ============================================
  // SESSION HISTORY (reactive stream)
  void _showSessionHistory(BuildContext context) {
    showThinkingCanvasSessionHistory(
      context: context,
      methodDisplayName: _getMethodDisplayName,
      onSessionSelected: (s) async {
        if (!mounted) return;
        final level = ref.read(daojiVocabularyLevelValueProvider);
        unawaited(showDialog(
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
                    Text(
                      DaojiText.resolve(
                        DaojiTextKey.thinkingCanvasLoadingSession,
                        level,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        setState(() {
          _draftBannerExpanded = true;
          if (s.methodKey == 'Freewriting') {
            _freewritingController.text = s.rawNotes ?? '';
          }
        });
        ref.read(thinkingCanvasProvider.notifier).loadSession(s);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMoodPrompt(theme, level, selectedMood),
          const SizedBox(height: 24),
          Text(
            DaojiText.resolve(DaojiTextKey.thinkingCanvasQuickStart, level),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickMethodCards(theme, level, state),
          const SizedBox(height: 24),
          if (state.recentMethods.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text(
                  DaojiText.resolve(DaojiTextKey.thinkingCanvasRecentlyUsed, level),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                  avatar: Icon(_getMethodIcon(key), size: 14,
                      color: _getMethodColor(key)),
                  label: Text(_getMethodDisplayName(key),
                      style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref.read(thinkingCanvasProvider.notifier).setMethod(key);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
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
            label: Text(DaojiText.resolve(
                DaojiTextKey.thinkingCanvasOpenMethodCatalog, level)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          // Info: onboarding available
          TextButton.icon(
            onPressed: _showOnboardingDialog,
            icon: const Icon(Icons.help_outline_rounded, size: 16),
            label: Text(
              DaojiText.resolve(DaojiTextKey.thinkingCanvasShowGuideAgain, level),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPrompt(ThemeData theme, DaojiVocabularyLevel level,
      String? selectedMood) {
    final moods = [
      {
        'key': 'overwhelmed',
        'label': '🤯 Pusing',
        'subtitle': 'Pikiran penuh',
        'color': Colors.teal,
        'methods': ['MindDump', 'Freewriting', 'MindDumpCluster'],
      },
      {
        'key': 'creative',
        'label': '💡 Kreatif',
        'subtitle': 'Eksplorasi ide',
        'color': Colors.orange,
        'methods': [
          'Brainstorming', 'MindMapping', 'SCAMPER',
          'LotusBlossom', 'MorphologicalAnalysis'
        ],
      },
      {
        'key': 'analytical',
        'label': '🔍 Analitis',
        'subtitle': 'Urai masalah',
        'color': Colors.blue,
        'methods': ['5Whys', 'SWOT', 'AffinityMapping', 'FirstPrinciples'],
      },
      {
        'key': 'deciding',
        'label': '⚖️ Memutuskan',
        'subtitle': 'Pilihan terbaik',
        'color': Colors.purple,
        'methods': [
          'SixThinkingHats', 'DisneyStrategy', 'Scoring', 'Validation'
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DaojiText.resolve(DaojiTextKey.thinkingCanvasMoodPrompt, level),
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(DaojiText.resolve(DaojiTextKey.thinkingCanvasMoodPromptSubtitle, level),
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            )),
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
                        ref.read(thinkingCanvasProvider.notifier).clearMood();
                      } else {
                        ref
                            .read(thinkingCanvasProvider.notifier)
                            .setMood(mood['key'] as String);
                      }
                    },
                    child: Container(
                      height: 68,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
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
                          Text(mood['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? moodColor
                                    : theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 2),
                          Text(mood['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? moodColor.withValues(alpha: 0.8)
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedMood != null) ...[
          const SizedBox(height: 16),
          _buildMoodRecommendations(theme, moods, selectedMood, level),
        ],
      ],
    );
  }

  Widget _buildMoodRecommendations(
      ThemeData theme,
      List<Map<String, dynamic>> moods,
      String selectedMood,
      DaojiVocabularyLevel level) {
    final moodIndex = moods.indexWhere((m) => m['key'] == selectedMood);
    if (moodIndex < 0) return const SizedBox.shrink();
    final mood = moods[moodIndex];
    final methods = mood['methods'] as List;
    final moodColor = mood['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
              width: 3, height: 14,
              decoration: BoxDecoration(
                  color: moodColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(DaojiText.resolve(DaojiTextKey.thinkingCanvasRecommendations, level),
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: moodColor)),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: methods.map((methodKey) {
            return ActionChip(
              avatar: Icon(_getMethodIcon(methodKey), size: 14,
                  color: moodColor),
              label: Text(_getMethodDisplayName(methodKey),
                  style: const TextStyle(fontSize: 11)),
              side: BorderSide(color: moodColor.withValues(alpha: 0.3)),
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
      ThemeData theme, DaojiVocabularyLevel level, ThinkingCanvasState state) {
    final quickMethods = [
      {'key': 'MindDump', 'name': 'Mind Dump', 'emoji': '🧠',
       'desc': 'Tuangkan beban pikiran tanpa hambatan.',
       'icon': Icons.psychology_rounded, 'color': Colors.teal},
      {'key': 'Freewriting', 'name': 'Freewriting', 'emoji': '✍️',
       'desc': 'Tulis cepat tanpa jeda dengan timer fokus.',
       'icon': Icons.edit_note_rounded, 'color': Colors.deepPurple},
      {'key': 'MindMapping', 'name': 'Mind Map', 'emoji': '🗺️',
       'desc': 'Petakan hubungan ide secara visual.',
       'icon': Icons.account_tree_rounded, 'color': Colors.indigo},
    ];

    return Row(
      children: quickMethods.map((m) {
        final mColor = m['color'] as Color;
        final isFavorite = state.favoriteMethods.contains(m['key']);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              height: 170,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                      color: mColor.withValues(alpha: 0.2), width: 1.5),
                ),
                color: mColor.withValues(alpha: 0.04),
                child: Stack(children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(thinkingCanvasProvider.notifier)
                          .setMethod(m['key'] as String);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: mColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(m['icon'] as IconData,
                                color: mColor, size: 20),
                          ),
                          const Spacer(),
                          Text('${m['emoji']} ${m['name']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(m['desc'] as String,
                              style: TextStyle(fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6)),
                              maxLines: 3, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2, right: 2,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 14,
                        color: isFavorite ? Colors.red
                            : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      onPressed: () => ref
                          .read(thinkingCanvasProvider.notifier)
                          .toggleFavorite(m['key'] as String),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================
  // DRAFT BANNER
  // ============================================
  Widget _buildDraftBanner(BuildContext context, String content) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: _draftBannerExpanded,
        onExpansionChanged: (val) => setState(() => _draftBannerExpanded = val),
        leading: Icon(Icons.history_edu_rounded,
            color: theme.colorScheme.secondary),
        title: Text('Draf Sesi Sebelumnya',
            style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold)),
        subtitle: Text('Gunakan sebagai referensi atau salin isinya.',
            style: TextStyle(fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, size: 18),
          tooltip: 'Salin ke Clipboard',
          onPressed: () {
            HapticFeedback.lightImpact();
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Disalin ke clipboard!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(content,
                  style: TextStyle(
                    fontFamily: 'monospace', fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACTIVE CANVAS (with guide + export)
  // ============================================
  Widget _buildActiveCanvas(
      BuildContext context,
      ThemeData theme,
      ThinkingCanvasState state,
      DaojiVocabularyLevel level) {
    final hasDraft = state.currentDraftContent.trim().isNotEmpty;
    final methodColor = _getMethodColor(state.selectedMethod!);

    return Column(
      children: [
        // Method context bar
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
              Icon(_getMethodIcon(state.selectedMethod!), size: 16,
                  color: methodColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_getMethodDisplayName(state.selectedMethod!),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12,
                        color: methodColor)),
              ),
              // Export button
              WorkspaceExportButton(
                content: state.currentDraftContent,
                methodName: _getMethodDisplayName(state.selectedMethod!),
              ),
              // Favorite toggle
              IconButton(
                icon: Icon(
                  ref.read(thinkingCanvasProvider.notifier)
                          .isFavorite(state.selectedMethod!)
                      ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 16,
                  color: ref.read(thinkingCanvasProvider.notifier)
                          .isFavorite(state.selectedMethod!)
                      ? Colors.red
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onPressed: () => ref
                    .read(thinkingCanvasProvider.notifier)
                    .toggleFavorite(state.selectedMethod!),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              if (state.isSaving)
                SizedBox(
                  width: 12, height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: methodColor),
                ),
            ],
          ),
        ),
        if (hasDraft) _buildDraftBanner(context, state.currentDraftContent),
        // Guide section
        WorkspaceGuideSection(methodKey: state.selectedMethod!),
        // Workspace content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(state.selectedMethod),
                child: _getWorkspaceForMethod(state.selectedMethod!),
              ),
            ),
          ),
        ),
        // Bottom action bar
        Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
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
              onPressed: _confirmSaveAndClearCanvas,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(DaojiText.resolve(DaojiTextKey.thinkingCanvasSaveAndFinish, level)),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onWorkspaceChanged(String content) {
    ref.read(thinkingCanvasProvider.notifier).updateDraft(content);
  }

  void _onStructuredOutput(String json) {
    ref.read(thinkingCanvasProvider.notifier).updateStructuredOutput(json);
  }

  String? get _restoredStructuredOutput =>
      ref.read(thinkingCanvasProvider).structuredOutput;

  Widget _getWorkspaceForMethod(String method) {
    final onSO = _onStructuredOutput;
    final initSO = _restoredStructuredOutput;
    switch (method) {
      case 'Freewriting':
        return FreewritingWorkspace(controller: _freewritingController);
      case 'MindMapping':
        return _MindMapInline(onChanged: _onWorkspaceChanged);
      case 'LotusBlossom':
        return LotusBlossomWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'MorphologicalAnalysis':
        return MorphologicalWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'MindDump':
      case 'MindDumpCluster':
        return MindDumpWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'AffinityMapping':
        return AffinityMappingWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case '5Whys':
        return FiveWhysWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'FirstPrinciples':
        return FirstPrinciplesWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'DoubleDiamond':
        return DoubleDiamondWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'Validation':
      case 'Scoring':
        return ValidationWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'SixThinkingHats':
        return SixThinkingHatsWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'DisneyStrategy':
        return DisneyStrategyWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'SCAMPER':
        return ScamperWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'SWOT':
        return SwotMatrixWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'Starbursting':
        return StarburstingWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'Brainstorming':
        return RapidBrainstormWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'ReverseBrainstorming':
        return ReverseBrainstormWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'WorstPossibleIdea':
        return WorstPossibleIdeaWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'QuestionStorming':
        return QuestionStormWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'RandomWord':
        return RandomWordWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      case 'RoleStorming':
        return RoleStormingWorkspace(
          onChanged: _onWorkspaceChanged,
          onStructuredOutput: onSO,
          initialStructuredOutput: initSO,
        );
      default:
        return _GenericThinkingWorkspace(
            title: method, onChanged: _onWorkspaceChanged);
    }
  }
}

/// Inline wrapper for Mind Map — opens as full screen and returns data
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
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
            ref.read(thinkingCanvasProvider.notifier).updateMindMapNodes(
                  result.map((n) => n.toJson()).toList(),
                );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_rounded,
                size: 40, color: theme.colorScheme.primary),
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
  const _GenericThinkingWorkspace({required this.title, required this.onChanged});

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
              DaojiTextKey.thinkingCanvasWorkspaceLabel, vocabularyLevel,
              params: {'title': title}),
          hintText: DaojiText.resolve(
              DaojiTextKey.thinkingCanvasWorkspaceHint, vocabularyLevel),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
