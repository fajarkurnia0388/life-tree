import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import '../../core/providers/db_provider.dart';
import 'thinking_canvas_draft_service.dart';

/// State for the Thinking Canvas.
class ThinkingCanvasState {
  final String? selectedMethod;
  final List<Map<String, dynamic>> mindMapNodes;
  final List<Map<String, dynamic>> scoringItems;
  final String currentDraftContent;
  final bool isSavingDraft;
  final DateTime? draftSavedAt;
  final DateTime? historyCommittedAt;
  final List<String> recentMethods;
  final List<String> favoriteMethods;
  final String? selectedMood;
  final bool hasSeenOnboarding;
  final bool prefsLoaded;
  final String? structuredOutput;

  ThinkingCanvasState({
    this.selectedMethod,
    this.mindMapNodes = const [],
    this.scoringItems = const [],
    this.currentDraftContent = '',
    this.isSavingDraft = false,
    this.draftSavedAt,
    this.historyCommittedAt,
    this.recentMethods = const [],
    this.favoriteMethods = const [],
    this.selectedMood,
    this.hasSeenOnboarding = false,
    this.prefsLoaded = false,
    this.structuredOutput,
  });

  ThinkingCanvasState copyWith({
    String? selectedMethod,
    List<Map<String, dynamic>>? mindMapNodes,
    List<Map<String, dynamic>>? scoringItems,
    String? currentDraftContent,
    bool? isSavingDraft,
    DateTime? draftSavedAt,
    DateTime? historyCommittedAt,
    List<String>? recentMethods,
    List<String>? favoriteMethods,
    String? selectedMood,
    bool? hasSeenOnboarding,
    bool? prefsLoaded,
    String? structuredOutput,
    bool clearMood = false,
    bool clearMethod = false,
    bool clearDraftSavedAt = false,
    bool clearHistoryCommittedAt = false,
  }) {
    return ThinkingCanvasState(
      selectedMethod:
          clearMethod ? null : (selectedMethod ?? this.selectedMethod),
      mindMapNodes: mindMapNodes ?? this.mindMapNodes,
      scoringItems: scoringItems ?? this.scoringItems,
      currentDraftContent: currentDraftContent ?? this.currentDraftContent,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      draftSavedAt:
          clearDraftSavedAt ? null : (draftSavedAt ?? this.draftSavedAt),
      historyCommittedAt: clearHistoryCommittedAt
          ? null
          : (historyCommittedAt ?? this.historyCommittedAt),
      recentMethods: recentMethods ?? this.recentMethods,
      favoriteMethods: favoriteMethods ?? this.favoriteMethods,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      prefsLoaded: prefsLoaded ?? this.prefsLoaded,
      structuredOutput: structuredOutput ?? this.structuredOutput,
    );
  }

  bool get hasContent => currentDraftContent.trim().isNotEmpty;

  /// Honest label: draft DB save only (not history commit).
  String get draftSavedLabel {
    if (draftSavedAt == null) return '';
    final diff = DateTime.now().difference(draftSavedAt!);
    if (diff.inSeconds < 5) return 'Draf tersimpan';
    if (diff.inSeconds < 60) return 'Draf ${diff.inSeconds}d lalu';
    if (diff.inMinutes < 60) return 'Draf ${diff.inMinutes}m lalu';
    return 'Draf ${diff.inHours}j lalu';
  }

  /// Back-compat for UI still reading lastSavedLabel.
  String get lastSavedLabel => draftSavedLabel;

  DateTime? get lastSavedAt => draftSavedAt;
  bool get isSaving => isSavingDraft;
}

/// Controller for Thinking Canvas state and logic.
///
/// Migrated from [StateNotifier] to Riverpod [Notifier] (manual, no codegen).
class ThinkingCanvasController extends Notifier<ThinkingCanvasState> {
  late final AppDatabase db;
  late final ThinkingCanvasDraftService draftService;
  Timer? _draftDebounce;
  bool _disposed = false;

  /// Stored as a special session row (methodKey) so we avoid clobbering coreValues.
  static const prefsMethodKey = '__canvas_prefs__';
  static const prefsSessionId = 'canvas_prefs_singleton';

  @override
  ThinkingCanvasState build() {
    db = ref.watch(dbProvider);
    draftService = ref.watch(thinkingCanvasDraftServiceProvider);
    ref.onDispose(() {
      _disposed = true;
      _draftDebounce?.cancel();
    });
    // Fire-and-forget prefs load after first frame of notifier lifetime.
    Future.microtask(_loadPrefs);
    return ThinkingCanvasState();
  }

  Future<void> _loadPrefs() async {
    try {
      final row = await (db.select(db.thinkingCanvasSessions)
            ..where((t) => t.sessionId.equals(prefsSessionId))
            ..limit(1))
          .getSingleOrNull();
      if (row?.rawNotes != null && row!.rawNotes!.trim().isNotEmpty) {
        final map = jsonDecode(row.rawNotes!) as Map<String, dynamic>;
        state = state.copyWith(
          recentMethods: List<String>.from(map['recent'] as List? ?? const []),
          favoriteMethods:
              List<String>.from(map['favorites'] as List? ?? const []),
          hasSeenOnboarding: map['hasSeenOnboarding'] as bool? ?? false,
          prefsLoaded: true,
        );
      } else {
        state = state.copyWith(prefsLoaded: true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading canvas prefs: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = state.copyWith(prefsLoaded: true);
    }
  }

  Future<void> _persistPrefs() async {
    try {
      final profiles = await db.select(db.userProfiles).get();
      final userId = profiles.isEmpty ? 'local' : profiles.first.userId;
      final payload = jsonEncode({
        'recent': state.recentMethods,
        'favorites': state.favoriteMethods,
        'hasSeenOnboarding': state.hasSeenOnboarding,
      });
      await db.into(db.thinkingCanvasSessions).insertOnConflictUpdate(
            ThinkingCanvasSessionsCompanion.insert(
              sessionId: prefsSessionId,
              userId: userId,
              methodKey: prefsMethodKey,
              isDraft: const drift.Value(true),
              rawNotes: drift.Value(payload),
              paperSession: const drift.Value(false),
              createdAt: DateTime.fromMillisecondsSinceEpoch(0),
              deletedAt: const drift.Value(null),
            ),
          );
    } catch (e, stackTrace) {
      debugPrint('Error persisting canvas prefs: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void setMethod(String method) {
    state = state.copyWith(selectedMethod: method);
    _addToRecent(method);
  }

  void setMood(String mood) {
    if (mood.isEmpty) {
      state = state.copyWith(clearMood: true);
    } else {
      state = state.copyWith(selectedMood: mood);
    }
  }

  void clearMood() {
    state = state.copyWith(clearMood: true);
  }

  void markOnboardingSeen() {
    state = state.copyWith(hasSeenOnboarding: true);
    unawaited(_persistPrefs());
  }

  void loadSession(ThinkingCanvasSession session) {
    state = ThinkingCanvasState(
      selectedMethod: session.methodKey,
      currentDraftContent: session.rawNotes ?? '',
      structuredOutput: session.structuredOutput,
      recentMethods: state.recentMethods,
      favoriteMethods: state.favoriteMethods,
      hasSeenOnboarding: state.hasSeenOnboarding,
      prefsLoaded: state.prefsLoaded,
    );
  }

  void updateDraft(String content) {
    state = state.copyWith(currentDraftContent: content);
    _scheduleDraftSave(content);
  }

  void updateMindMapNodes(List<Map<String, dynamic>> nodes) {
    state = state.copyWith(mindMapNodes: nodes);
  }

  void updateStructuredOutput(String json) {
    state = state.copyWith(structuredOutput: json);
  }

  void _scheduleDraftSave(String content) {
    _draftDebounce?.cancel();
    if (content.trim().isEmpty || state.selectedMethod == null) return;

    state = state.copyWith(isSavingDraft: true);
    _draftDebounce = Timer(const Duration(milliseconds: 700), () async {
      try {
        await draftService.upsertDraft(
          methodKey: state.selectedMethod!,
          content: content,
          structuredOutput: state.structuredOutput,
        );
        if (_disposed) return;
        state = state.copyWith(
          isSavingDraft: false,
          draftSavedAt: DateTime.now(),
        );
      } catch (e, stackTrace) {
        debugPrint('Error saving draft: $e');
        debugPrintStack(stackTrace: stackTrace);
        if (_disposed) return;
        state = state.copyWith(isSavingDraft: false);
      }
    });
  }

  Future<void> commitToHistory() async {
    final method = state.selectedMethod;
    final content = state.currentDraftContent;
    if (method == null || content.trim().isEmpty) return;
    await draftService.commitSession(methodKey: method, content: content, structuredOutput: state.structuredOutput);
    if (_disposed) return;
    state = state.copyWith(
      historyCommittedAt: DateTime.now(),
      clearDraftSavedAt: true,
    );
  }

  Future<void> restoreDraftIfAny() async {
    final draft = await draftService.loadDraftSession();
    if (draft == null || _disposed) return;
    if (state.hasContent) return;
    // Ignore prefs singleton
    if (draft.methodKey == prefsMethodKey) return;
    state = state.copyWith(
      selectedMethod: draft.methodKey,
      currentDraftContent: draft.rawNotes ?? '',
      draftSavedAt: draft.createdAt,
    );
  }

  void toggleFavorite(String methodKey) {
    final current = List<String>.from(state.favoriteMethods);
    if (current.contains(methodKey)) {
      current.remove(methodKey);
    } else {
      current.insert(0, methodKey);
    }
    state = state.copyWith(favoriteMethods: current);
    unawaited(_persistPrefs());
  }

  bool isFavorite(String methodKey) {
    return state.favoriteMethods.contains(methodKey);
  }

  void _addToRecent(String method) {
    final current = List<String>.from(state.recentMethods);
    current.remove(method);
    current.insert(0, method);
    if (current.length > 5) current.removeLast();
    state = state.copyWith(recentMethods: current);
    unawaited(_persistPrefs());
  }

  /// Clear canvas but preserve favorites, recents, and onboarding status
  void clearCanvas() {
    _draftDebounce?.cancel();
    try {
      draftService.deleteDraft();
    } catch (e, stackTrace) {
      debugPrint('Failed to delete draft: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
    state = ThinkingCanvasState(
      recentMethods: state.recentMethods,
      favoriteMethods: state.favoriteMethods,
      hasSeenOnboarding: state.hasSeenOnboarding,
      prefsLoaded: state.prefsLoaded,
    );
  }

}

final thinkingCanvasProvider =
    NotifierProvider<ThinkingCanvasController, ThinkingCanvasState>(
  ThinkingCanvasController.new,
);
