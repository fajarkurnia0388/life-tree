import 'package:flutter/material.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../thinking_canvas_state.dart';

/// AppBar for Thinking Canvas with animated save indicator.
class CanvasAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool hasActiveMethod;
  final ThinkingCanvasState canvasState;
  final DaojiVocabularyLevel vocabularyLevel;
  final String Function(String key) getMethodDisplayName;
  final VoidCallback onBack;
  final VoidCallback onShowHistory;
  final Animation<double> saveIndicatorOpacity;

  const CanvasAppBarWidget({
    required this.hasActiveMethod,
    required this.canvasState,
    required this.vocabularyLevel,
    required this.getMethodDisplayName,
    required this.onBack,
    required this.onShowHistory,
    required this.saveIndicatorOpacity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: hasActiveMethod
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            )
          : null,
      title: Text(
        hasActiveMethod
            ? getMethodDisplayName(canvasState.selectedMethod!)
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
              animation: saveIndicatorOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: canvasState.lastSavedAt != null
                      ? saveIndicatorOpacity.value
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
          onPressed: onShowHistory,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
