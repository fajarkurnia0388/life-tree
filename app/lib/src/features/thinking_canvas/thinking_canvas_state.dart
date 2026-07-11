import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import '../../core/providers/db_provider.dart';

/// State for the Thinking Canvas.
class ThinkingCanvasState {
  final String? selectedMethod;
  final List<Map<String, dynamic>> mindMapNodes;
  final List<Map<String, dynamic>> scoringItems;
  final String currentDraftContent;
  final bool isSaving;
  final DateTime? lastSavedAt;
  final List<String> recentMethods;
  final List<String> favoriteMethods;
  final String? selectedMood;
  final bool hasSeenOnboarding;

  ThinkingCanvasState({
    this.selectedMethod,
    this.mindMapNodes = const [],
    this.scoringItems = const [],
    this.currentDraftContent = '',
    this.isSaving = false,
    this.lastSavedAt,
    this.recentMethods = const [],
    this.favoriteMethods = const [],
    this.selectedMood,
    this.hasSeenOnboarding = false,
  });

  ThinkingCanvasState copyWith({
    String? selectedMethod,
    List<Map<String, dynamic>>? mindMapNodes,
    List<Map<String, dynamic>>? scoringItems,
    String? currentDraftContent,
    bool? isSaving,
    DateTime? lastSavedAt,
    List<String>? recentMethods,
    List<String>? favoriteMethods,
    String? selectedMood,
    bool? hasSeenOnboarding,
    bool clearMood = false,
    bool clearMethod = false,
  }) {
    return ThinkingCanvasState(
      selectedMethod: clearMethod ? null : (selectedMethod ?? this.selectedMethod),
      mindMapNodes: mindMapNodes ?? this.mindMapNodes,
      scoringItems: scoringItems ?? this.scoringItems,
      currentDraftContent: currentDraftContent ?? this.currentDraftContent,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      recentMethods: recentMethods ?? this.recentMethods,
      favoriteMethods: favoriteMethods ?? this.favoriteMethods,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  /// Whether there is unsaved meaningful content
  bool get hasContent => currentDraftContent.trim().isNotEmpty;

  /// Time ago string for last save
  String get lastSavedLabel {
    if (lastSavedAt == null) return '';
    final diff = DateTime.now().difference(lastSavedAt!);
    if (diff.inSeconds < 5) return 'Baru disimpan';
    if (diff.inSeconds < 60) return '${diff.inSeconds}d lalu';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    return '${diff.inHours}j lalu';
  }
}

/// Controller for Thinking Canvas state and logic.
class ThinkingCanvasController extends StateNotifier<ThinkingCanvasState> {
  final AppDatabase db;
  ThinkingCanvasController(this.db) : super(ThinkingCanvasState());

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
  }

  void loadSession(ThinkingCanvasSession session) {
    state = ThinkingCanvasState(
      selectedMethod: session.methodKey,
      currentDraftContent: session.rawNotes ?? '',
      recentMethods: state.recentMethods,
      favoriteMethods: state.favoriteMethods,
      hasSeenOnboarding: state.hasSeenOnboarding,
    );
  }

  void updateDraft(String content) {
    state = state.copyWith(currentDraftContent: content);
    _autoSave(content);
  }

  void updateMindMapNodes(List<Map<String, dynamic>> nodes) {
    state = state.copyWith(mindMapNodes: nodes);
  }

  Future<void> _autoSave(String content) async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
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
  }

  /// Clear canvas but preserve favorites, recents, and onboarding status
  void clearCanvas() {
    state = ThinkingCanvasState(
      recentMethods: state.recentMethods,
      favoriteMethods: state.favoriteMethods,
      hasSeenOnboarding: state.hasSeenOnboarding,
    );
  }
}

final thinkingCanvasProvider = StateNotifierProvider<ThinkingCanvasController, ThinkingCanvasState>((ref) {
  return ThinkingCanvasController(ref.watch(dbProvider));
});
