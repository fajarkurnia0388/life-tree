import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../marketplace_service.dart';

class MarketplaceTemplateCard extends StatelessWidget {
  final PublicTemplate template;
  final VoidCallback onRate;
  final VoidCallback onDownload;

  const MarketplaceTemplateCard({
    super.key,
    required this.template,
    required this.onRate,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    template.domainTag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      template.averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' (${template.ratingsCount})',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              template.title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Oleh: ${template.creatorPenName}',
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
            Row(
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
                      'MVA: ${template.mvaDuration}m',
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
                      'Beban: ${template.friction + template.energy} Poin',
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
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onRate,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Beri Rating', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(88, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Gunakan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
