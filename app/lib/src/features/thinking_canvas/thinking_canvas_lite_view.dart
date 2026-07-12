import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/services/snackbar_service.dart';
import 'domain/thinking_method.dart';
import 'widgets/canvas_active_session_widget.dart';
import 'widgets/canvas_method_selector_widget.dart';
import 'widgets/canvas_workspace_body.dart';
import 'widgets/thinking_canvas_onboarding_dialog.dart';
import 'thinking_canvas_state.dart';
import 'widgets/session_history_sheet.dart';

class ThinkingCanvasLiteView extends ConsumerStatefulWidget {
  const ThinkingCanvasLiteView({super.key});

  @override
  ConsumerState<ThinkingCanvasLiteView> createState() =>
      _ThinkingCanvasLiteViewState();
}

class _ThinkingCanvasLiteViewState extends ConsumerState<ThinkingCanvasLiteView>
    with TickerProviderStateMixin {
  final TextEditingController _freewritingController = TextEditingController();
  bool _draftBannerExpanded = false;
  static final Map<String, ThinkingMethod> _methodsByKey = {
    for (final method in ThinkingMethod.allMethods) method.key: method,
  };

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
      CurvedAnimation(parent: _saveIndicatorController, curve: Curves.easeOut),
    );

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
                    DaojiTextKey.thinkingCanvasTitle,
                    vocabularyLevel,
                  ),
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
            ? CanvasMethodSelectorWidget(
                vocabularyLevel: vocabularyLevel,
                state: canvasState,
                onShowOnboarding: _showOnboardingDialog,
              )
            : CanvasActiveSessionWidget(
                state: canvasState,
                vocabularyLevel: vocabularyLevel,
                draftBannerExpanded: _draftBannerExpanded,
                onDraftExpansionChanged: (val) =>
                    setState(() => _draftBannerExpanded = val),
                methodDisplayName: _getMethodDisplayName,
                workspace: CanvasWorkspaceBody(
                  method: canvasState.selectedMethod!,
                  freewritingController: _freewritingController,
                ),
                onSaveAndFinish: _confirmSaveAndClearCanvas,
              ),
      ),
    );
  }

  String _getMethodDisplayName(String key) {
    return _methodsByKey[key]?.name ?? key;
  }

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
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Gagal menyimpan sesi. Silakan coba lagi.',
        );
      }
      return;
    }
    notifier.clearCanvas();
  }

  void _showSessionHistory(BuildContext context) {
    showThinkingCanvasSessionHistory(
      context: context,
      methodDisplayName: _getMethodDisplayName,
      onSessionSelected: (s) async {
        if (!mounted) return;
        final level = ref.read(daojiVocabularyLevelValueProvider);
        BuildContext? dialogContext;
        unawaited(
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              dialogContext = ctx;
              return Center(
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
              );
            },
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        setState(() {
          _draftBannerExpanded = true;
          if (s.methodKey == 'Freewriting') {
            _freewritingController.text = s.rawNotes ?? '';
          }
        });
        ref.read(thinkingCanvasProvider.notifier).loadSession(s);
        if (dialogContext != null && dialogContext!.mounted) {
          Navigator.of(dialogContext!).pop();
        }
      },
    );
  }
}
