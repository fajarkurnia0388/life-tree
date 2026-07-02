import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cultivation_constants.dart';
import '../cultivation_strings.dart';
import '../cultivation_provider.dart';

/// Displays the user's current cultivation realm as a badge.
///
/// Shows realm level and name with appropriate styling based on language level.
/// Phase 0: Basic text display. Phase 2 will add visual polish.
class CultivationBadge extends ConsumerWidget {
  const CultivationBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cultivationAsync = ref.watch(cultivationProvider);
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);

    return cultivationAsync.when(
      data: (cultivation) {
        final realmInfo = CultivationConstants.realmForLevel(cultivation.realm);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${cultivation.realm}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 6),
              Text(
                _getRealmDisplayName(realmInfo, languageLevel),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _getRealmDisplayName(
    CultivationRealm realm,
    CultivationLanguageLevel level,
  ) {
    return switch (level) {
      CultivationLanguageLevel.plain => realm.indonesianName,
      CultivationLanguageLevel.hybrid => realm.name,
      CultivationLanguageLevel.full => '${realm.name} (${realm.chineseName})',
    };
  }
}
