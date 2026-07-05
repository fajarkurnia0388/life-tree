import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/button_theme.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../models/marketplace_template_model.dart';

class MarketplaceTemplateCard extends ConsumerWidget {
  final MarketplaceTemplateModel template;
  final VoidCallback onRate;
  final VoidCallback onDownload;

  const MarketplaceTemplateCard({
    super.key,
    required this.template,
    required this.onRate,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    template.domainTag ??
                        (template.isHabit
                            ? DaojiText.resolve(
                                DaojiTextKey.habitLabel,
                                vocabularyLevel,
                              )
                            : DaojiText.resolve(
                                DaojiTextKey.reflectionMarketplace,
                                vocabularyLevel,
                              )),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      template.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' (${template.ratingsCount})',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (template.isCoreValue && template.coreValueMetadata != null)
                  Text(
                    template.coreValueMetadata!.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                if (template.isCoreValue && template.coreValueMetadata != null)
                  const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DaojiText.resolve(
                DaojiTextKey.marketByLabel,
                vocabularyLevel,
                params: {'author': template.creatorPenName},
              ),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            if (template.isHabit) _buildHabitMetadata(theme, vocabularyLevel),
            if (template.isCoreValue)
              _buildCoreValueMetadata(theme, vocabularyLevel),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onRate,
                  style: AppButtonStyles.secondary(context).copyWith(
                    minimumSize: WidgetStateProperty.all(const Size(88, 44)),
                  ),
                  child: Text(
                    DaojiText.resolve(
                      DaojiTextKey.marketRateButton,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onDownload,
                  style: AppButtonStyles.primary(context).copyWith(
                    minimumSize: WidgetStateProperty.all(const Size(88, 44)),
                  ),
                  child: Text(
                    DaojiText.resolve(
                      DaojiTextKey.marketUseButton,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitMetadata(
    ThemeData theme,
    DaojiVocabularyLevel vocabularyLevel,
  ) {
    final meta = template.habitMetadata;
    if (meta == null) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              '${DaojiText.resolve(DaojiTextKey.marketMvaPrefix, vocabularyLevel)} ${meta.mvaDuration}m',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.fitness_center_rounded,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Beban: ${meta.friction + meta.energy} Poin',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.download_rounded,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              '${template.downloadsCount}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoreValueMetadata(
    ThemeData theme,
    DaojiVocabularyLevel vocabularyLevel,
  ) {
    final meta = template.coreValueMetadata;
    if (meta == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (meta.whyItMatters.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: Colors.teal.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DaojiText.resolve(
                        DaojiTextKey.marketWhyItMatters,
                        vocabularyLevel,
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  meta.whyItMatters,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (meta.reflectionPrompt.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.question_answer_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  meta.reflectionPrompt,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (meta.relatedDomains.isNotEmpty)
              Wrap(
                spacing: 4,
                children: meta.relatedDomains.take(2).map((domain) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      domain,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            Row(
              children: [
                Icon(
                  Icons.download_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${template.downloadsCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
