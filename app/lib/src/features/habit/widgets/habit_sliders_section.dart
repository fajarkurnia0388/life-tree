import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../data/local_db/database.dart';

class HabitSlidersSection extends ConsumerWidget {
  final int initiationFriction;
  final int energyCost;
  final int impactScore;
  final int mvaDurationMin;
  final ValueChanged<int> onFrictionChanged;
  final ValueChanged<int> onEnergyChanged;
  final ValueChanged<int> onImpactChanged;
  final ValueChanged<int> onDurationChanged;
  final Future<List<Habit>> habitsFuture;
  final bool isEditing;
  final Habit? existingHabit;

  const HabitSlidersSection({
    super.key,
    required this.initiationFriction,
    required this.energyCost,
    required this.impactScore,
    required this.mvaDurationMin,
    required this.onFrictionChanged,
    required this.onEnergyChanged,
    required this.onImpactChanged,
    required this.onDurationChanged,
    required this.habitsFuture,
    required this.isEditing,
    this.existingHabit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSlider(
          context: context,
          title: '🚀 ${DaojiText.resolve(DaojiTextKey.habitFriction, vocabularyLevel)}',
          helperText: 'Contoh: olahraga ke gym = susah (4-5), baca 1 halaman = mudah (1-2)',
          value: initiationFriction,
          minLabel: 'Sangat Mudah',
          maxLabel: 'Sangat Susah',
          onChanged: onFrictionChanged,
        ),
        _buildSlider(
          context: context,
          title: '⚡ ${DaojiText.resolve(DaojiTextKey.habitEnergy, vocabularyLevel)}',
          helperText: 'Contoh: lari 30 menit = banyak energi (4-5), nulis jurnal = sedikit (1-2)',
          value: energyCost,
          minLabel: 'Sedikit Energi',
          maxLabel: 'Banyak Energi',
          onChanged: onEnergyChanged,
        ),
        _buildSlider(
          context: context,
          title: '🎯 ${DaojiText.resolve(DaojiTextKey.habitImpact, vocabularyLevel)}',
          helperText: 'Contoh: olahraga rutin = dampak besar (5), minum vitamin = menengah (3)',
          value: impactScore,
          minLabel: 'Dampak Kecil',
          maxLabel: 'Dampak Besar',
          onChanged: onImpactChanged,
        ),
        _buildSlider(
          context: context,
          title: '⏱️ ${DaojiText.resolve(DaojiTextKey.habitMva, vocabularyLevel)} (menit)',
          helperText: 'MVA: Minimum Viable Action — durasi terpendek agar tetap "valid dilakukan"',
          value: mvaDurationMin,
          minLabel: '1 menit',
          maxLabel: '30 menit',
          minVal: 1,
          maxVal: 30,
          divisions: 29,
          unit: ' menit',
          onChanged: onDurationChanged,
        ),
        const SizedBox(height: 20),
        ref.watch(userProfileProvider).when(
              data: (profile) {
                final maxCapacity = profile?.canopyLoadCapacity ?? 10;
                return FutureBuilder<List<Habit>>(
                  future: habitsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final activeHabits = snapshot.data!;
                    final currentLoad = activeHabits.fold<int>(
                      0,
                      (sum, h) => sum + h.initiationFriction + h.energyCost,
                    );
                    int nextLoad = currentLoad;
                    if (isEditing && existingHabit != null) {
                      nextLoad = currentLoad -
                          (existingHabit!.initiationFriction +
                              existingHabit!.energyCost) +
                          initiationFriction +
                          energyCost;
                    } else {
                      nextLoad = currentLoad + initiationFriction + energyCost;
                    }

                    final isOverloaded = nextLoad > maxCapacity;
                    final textColor = isOverloaded
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary;
                    final iconColor = isOverloaded
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary;
                    final bgColor = isOverloaded
                        ? theme.colorScheme.error.withOpacity(0.08)
                        : theme.colorScheme.primary.withOpacity(0.08);

                    return Card(
                      elevation: 0,
                      color: bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isOverloaded
                              ? theme.colorScheme.error.withOpacity(0.3)
                              : theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              isOverloaded
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline,
                              color: iconColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DaojiText.resolve(
                                      DaojiTextKey.habitCanopyLoadStatus,
                                      vocabularyLevel,
                                      params: {
                                        'load': nextLoad.toString(),
                                        'capacity': maxCapacity.toString(),
                                      },
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isOverloaded
                                        ? 'Melebihi kapasitas harian! Pertimbangkan menurunkan tingkat kesulitan/energi.'
                                        : 'Beban kanopi Anda berada dalam batas aman dan seimbang.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
            ),
      ],
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String title,
    required String helperText,
    required int value,
    required String minLabel,
    required String maxLabel,
    int minVal = 1,
    int maxVal = 5,
    int divisions = 4,
    String unit = '',
    required ValueChanged<int> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: minVal.toDouble(),
                  max: maxVal.toDouble(),
                  divisions: divisions,
                  onChanged: (val) => onChanged(val.round()),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$value$unit',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
                Text(
                  maxLabel,
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
