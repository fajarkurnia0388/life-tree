import 'package:flutter/material.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import 'habit_templates.dart';

class HabitTemplateSelectorWidget extends StatelessWidget {
  final bool showTemplates;
  final String selectedDomainTag;
  final List<String> domainTags;
  final DaojiVocabularyLevel vocabularyLevel;
  final String habitLabel;
  final VoidCallback onToggleTemplates;
  final ValueChanged<String> onDomainTagChanged;
  final void Function(HabitTemplate template) onTemplateSelected;

  const HabitTemplateSelectorWidget({
    super.key,
    required this.showTemplates,
    required this.selectedDomainTag,
    required this.domainTags,
    required this.vocabularyLevel,
    required this.habitLabel,
    required this.onToggleTemplates,
    required this.onDomainTagChanged,
    required this.onTemplateSelected,
  });

  List<HabitTemplate> get _activeTemplates {
    switch (selectedDomainTag) {
      case 'Tubuh':
        return bodyHabitTemplates;
      case 'Keuangan':
        return financeHabitTemplates;
      case 'Hubungan':
        return relationshipHabitTemplates;
      case 'Emosi':
        return emotionHabitTemplates;
      case 'Karir':
        return careerHabitTemplates;
      case 'Rekreasi':
        return recreationHabitTemplates;
      default:
        return bodyHabitTemplates;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gunakan Template $habitLabel (Opsional)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            IconButton(
              icon: Icon(
                showTemplates
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: theme.colorScheme.primary,
              ),
              tooltip: showTemplates
                  ? 'Sembunyikan Template'
                  : 'Tampilkan Template',
              onPressed: onToggleTemplates,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (showTemplates) ...[
          // Category Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: domainTags.map((tag) {
                final isSelected = selectedDomainTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      DaojiText.domainLabel(
                        tag,
                        vocabularyLevel,
                        short: true,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onDomainTagChanged(tag);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Grid/List of Templates
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _activeTemplates.length,
              itemBuilder: (context, index) {
                final t = _activeTemplates[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(
                    right: 12,
                    bottom: 8,
                    top: 4,
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onTemplateSelected(t),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                t.description,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '🧩 ${t.friction}   ⚡ ${t.energy}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '⏱️ ${t.mvaDuration}m',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
