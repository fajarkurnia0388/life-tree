import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/local_db/database.dart';
import '../../core/providers/db_provider.dart';

/// State for the Thinking Canvas.
class ThinkingCanvasState {
  final String? selectedMethod;
  final List<Map<String, dynamic>> mindMapNodes;
  final List<Map<String, dynamic>> scoringItems;
  final String currentDraftContent;
  final bool isSaving;

  ThinkingCanvasState({
    this.selectedMethod,
    this.mindMapNodes = const [],
    this.scoringItems = const [],
    this.currentDraftContent = '',
    this.isSaving = false,
  });

  ThinkingCanvasState copyWith({
    String? selectedMethod,
    List<Map<String, dynamic>>? mindMapNodes,
    List<Map<String, dynamic>>? scoringItems,
    String? currentDraftContent,
    bool? isSaving,
  }) {
    return ThinkingCanvasState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      mindMapNodes: mindMapNodes ?? this.mindMapNodes,
      scoringItems: scoringItems ?? this.scoringItems,
      currentDraftContent: currentDraftContent ?? this.currentDraftContent,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// Controller for Thinking Canvas state and logic.
class ThinkingCanvasController extends StateNotifier<ThinkingCanvasState> {
  final AppDatabase db;
  ThinkingCanvasController(this.db) : super(ThinkingCanvasState());

  void setMethod(String method) {
    state = state.copyWith(selectedMethod: method);
  }

  void loadSession(ThinkingCanvasSession session) {
    state = ThinkingCanvasState(
      selectedMethod: session.methodKey,
      currentDraftContent: session.rawNotes ?? '',
    );
  }

  void updateDraft(String content) {
    state = state.copyWith(currentDraftContent: content);
    _autoSave(content);
  }

  Future<void> _autoSave(String content) async {
    state = state.copyWith(isSaving: true);
    // Draft saving logic moved here from view
    // Implement DB call to update thinking_canvas_drafts
    state = state.copyWith(isSaving: false);
  }

  void clearCanvas() {
    state = ThinkingCanvasState();
  }
}

final thinkingCanvasProvider = StateNotifierProvider<ThinkingCanvasController, ThinkingCanvasState>((ref) {
  return ThinkingCanvasController(ref.watch(dbProvider));
});
