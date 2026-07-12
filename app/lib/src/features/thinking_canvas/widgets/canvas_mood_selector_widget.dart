import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../domain/thinking_method.dart';
import '../thinking_canvas_state.dart';
import 'method_visuals.dart';

/// Mood prompt chips + recommended methods for Thinking Canvas home.
class CanvasMoodSelectorWidget extends ConsumerWidget {
  final DaojiVocabularyLevel vocabularyLevel;
  final String? selectedMood;

  const CanvasMoodSelectorWidget({
    super.key,
    required this.vocabularyLevel,
    required this.selectedMood,
  });

  static final List<Map<String, dynamic>> moods = [
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
        'Brainstorming',
        'MindMapping',
        'SCAMPER',
        'LotusBlossom',
        'MorphologicalAnalysis',
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
        'SixThinkingHats',
        'DisneyStrategy',
        'Scoring',
        'Validation',
      ],
    },
  ];

  static final Map<String, ThinkingMethod> _methodsByKey = {
    for (final method in ThinkingMethod.allMethods) method.key: method,
  };

  String _methodDisplayName(String key) => _methodsByKey[key]?.name ?? key;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DaojiText.resolve(
            DaojiTextKey.thinkingCanvasMoodPrompt,
            vocabularyLevel,
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DaojiText.resolve(
            DaojiTextKey.thinkingCanvasMoodPromptSubtitle,
            vocabularyLevel,
          ),
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
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? moodColor
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.08,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? moodColor
                                  : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mood['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? moodColor.withValues(alpha: 0.8)
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
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
        if (selectedMood != null) ...[
          const SizedBox(height: 16),
          _MoodRecommendations(
            vocabularyLevel: vocabularyLevel,
            selectedMood: selectedMood!,
            methodDisplayName: _methodDisplayName,
          ),
        ],
      ],
    );
  }
}

class _MoodRecommendations extends ConsumerWidget {
  final DaojiVocabularyLevel vocabularyLevel;
  final String selectedMood;
  final String Function(String) methodDisplayName;

  const _MoodRecommendations({
    required this.vocabularyLevel,
    required this.selectedMood,
    required this.methodDisplayName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final moodIndex = CanvasMoodSelectorWidget.moods.indexWhere(
      (m) => m['key'] == selectedMood,
    );
    if (moodIndex < 0) return const SizedBox.shrink();
    final mood = CanvasMoodSelectorWidget.moods[moodIndex];
    final methods = mood['methods'] as List;
    final moodColor = mood['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              DaojiText.resolve(
                DaojiTextKey.thinkingCanvasRecommendations,
                vocabularyLevel,
              ),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: moodColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: methods.map((methodKey) {
            final key = methodKey as String;
            return ActionChip(
              avatar: Icon(
                ThinkingMethodVisuals.iconFor(key),
                size: 14,
                color: moodColor,
              ),
              label: Text(
                methodDisplayName(key),
                style: const TextStyle(fontSize: 11),
              ),
              side: BorderSide(color: moodColor.withValues(alpha: 0.3)),
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(thinkingCanvasProvider.notifier).setMethod(key);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
