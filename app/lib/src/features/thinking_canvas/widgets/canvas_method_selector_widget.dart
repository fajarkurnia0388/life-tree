import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/thinking_method.dart';
import '../thinking_canvas_state.dart';
import 'canvas_mood_selector_widget.dart';
import 'method_picker_bottom_sheet.dart';
import 'method_visuals.dart';

/// Home screen for choosing a thinking method (mood, quick start, recents).
class CanvasMethodSelectorWidget extends ConsumerWidget {
  final DaojiVocabularyLevel vocabularyLevel;
  final ThinkingCanvasState state;
  final VoidCallback onShowOnboarding;

  const CanvasMethodSelectorWidget({
    super.key,
    required this.vocabularyLevel,
    required this.state,
    required this.onShowOnboarding,
  });

  static final Map<String, ThinkingMethod> _methodsByKey = {
    for (final method in ThinkingMethod.allMethods) method.key: method,
  };

  String _methodDisplayName(String key) => _methodsByKey[key]?.name ?? key;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMood = state.selectedMood;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CanvasMoodSelectorWidget(
            vocabularyLevel: vocabularyLevel,
            selectedMood: selectedMood,
          ),
          const SizedBox(height: 24),
          Text(
            DaojiText.resolve(
              DaojiTextKey.thinkingCanvasQuickStart,
              vocabularyLevel,
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _QuickMethodCards(state: state),
          const SizedBox(height: 24),
          if (state.recentMethods.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 6),
                Text(
                  DaojiText.resolve(
                    DaojiTextKey.thinkingCanvasRecentlyUsed,
                    vocabularyLevel,
                  ),
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
                  avatar: Icon(
                    ThinkingMethodVisuals.iconFor(key),
                    size: 14,
                    color: ThinkingMethodVisuals.colorFor(
                      key,
                      theme.colorScheme,
                    ),
                  ),
                  label: Text(
                    _methodDisplayName(key),
                    style: const TextStyle(fontSize: 11),
                  ),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => MethodPickerBottomSheet(
                currentMethodKey: state.selectedMethod ?? '',
                favoriteMethods: state.favoriteMethods,
                onToggleFavorite: (key) => ref
                    .read(thinkingCanvasProvider.notifier)
                    .toggleFavorite(key),
                onSelected: (method) =>
                    ref.read(thinkingCanvasProvider.notifier).setMethod(method),
              ),
            ),
            icon: const Icon(Icons.apps_rounded, size: 18),
            label: Text(
              DaojiText.resolve(
                DaojiTextKey.thinkingCanvasOpenMethodCatalog,
                vocabularyLevel,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onShowOnboarding,
            icon: const Icon(Icons.help_outline_rounded, size: 16),
            label: Text(
              DaojiText.resolve(
                DaojiTextKey.thinkingCanvasShowGuideAgain,
                vocabularyLevel,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickMethodCards extends ConsumerWidget {
  final ThinkingCanvasState state;

  const _QuickMethodCards({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quickMethods = [
      {
        'key': 'MindDump',
        'name': 'Mind Dump',
        'emoji': '🧠',
        'desc': 'Tuangkan beban pikiran tanpa hambatan.',
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
                              child: Icon(
                                m['icon'] as IconData,
                                color: mColor,
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${m['emoji']} ${m['name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['desc'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 14,
                          color: isFavorite
                              ? Colors.red
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                        ),
                        onPressed: () => ref
                            .read(thinkingCanvasProvider.notifier)
                            .toggleFavorite(m['key'] as String),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
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
}
