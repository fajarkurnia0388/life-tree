import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/animations/dialog_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../data/local_db/database.dart';
import '../../cultivation/cultivation_provider.dart';
import '../../cultivation/cultivation_strings.dart';
import '../dashboard_provider.dart';
import '../services/dashboard_action_service.dart';
import '../../../core/services/notification_service.dart';

/// Widget untuk menampilkan daftar kebiasaan hari ini
class HabitListSection extends ConsumerWidget {
  const HabitListSection({
    super.key,
    required this.habitsWithLogs,
    required this.selectedDomainFilter,
    required this.onDomainReset,
    required this.onHabitToggle,
    required this.onFrictionIntervention,
    required this.activeActionOfTheDay,
    this.isRecoveryActive = false,
  });

  final List<HabitWithLog> habitsWithLogs;
  final String selectedDomainFilter;
  final VoidCallback onDomainReset;
  final Function(BuildContext, Habit, HabitLog?) onHabitToggle;
  final Function(BuildContext, Habit) onFrictionIntervention;
  final Habit? activeActionOfTheDay;
  final bool isRecoveryActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              CultivationStrings.habitListTitle(languageLevel),
              style: theme.textTheme.titleLarge,
            ),
            if (selectedDomainFilter != 'Semua')
              TextButton.icon(
                onPressed: onDomainReset,
                icon: const Icon(Icons.clear, size: 14),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: DomainColors.forDomain(selectedDomainFilter),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (habitsWithLogs.isEmpty)
          const EmptyStateWidget(
            icon: Icons.favorite_border,
            title: 'Belum Ada Kebiasaan',
            message: 'Mulai bangun kebiasaan positif untuk domain ini',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habitsWithLogs.length,
            itemBuilder: (context, index) {
              final item = habitsWithLogs[index];
              final isAction =
                  activeActionOfTheDay?.habitId == item.habit.habitId;
              return _buildHabitItemTile(context, ref, theme, item, isAction);
            },
          ),
      ],
    );
  }

  Widget _buildHabitItemTile(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    HabitWithLog item,
    bool isAction,
  ) {
    final isDone = item.log?.status == HabitStatus.done;
    final domainColor = DomainColors.forDomain(item.habit.domainTag);
    final paused = isRecoveryActive && !isDone;
    final beban = item.habit.initiationFriction + item.habit.energyCost;
    final semanticsLabel = paused
        ? 'Kebiasaan ${item.habit.title}, dijeda untuk mode istirahat'
        : 'Kebiasaan ${item.habit.title}, ${isDone ? 'selesai' : 'belum selesai'}, beban $beban poin';

    return Semantics(
      label: semanticsLabel,
      button: !paused,
      child: Dismissible(
        key: Key(item.habit.habitId),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showAnimatedDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Hapus Kebiasaan?'),
                content: Text('Yakin ingin menghapus "${item.habit.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Hapus'),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) async {
          final deletedHabit = item.habit;

          await ref
              .read(dashboardActionServiceProvider)
              .deleteHabit(item.habit.habitId);
          await NotificationService.cancelHabit(item.habit.habitId);
          ref.invalidate(dashboardDataProvider);

          // Show undo snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kebiasaan "${deletedHabit.title}" dihapus'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async {
                    await ref
                        .read(dashboardActionServiceProvider)
                        .restoreHabit(deletedHabit.habitId);
                    ref.invalidate(dashboardDataProvider);
                  },
                ),
              ),
            );
          }
        },
        child: Opacity(
          opacity: paused ? 0.55 : 1.0,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDone
                    ? domainColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: isDone ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: (isDone || paused)
                  ? null
                  : () => onHabitToggle(context, item.habit, item.log),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? domainColor : Colors.transparent,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : Icon(
                                paused
                                    ? Icons.ac_unit_rounded
                                    : Icons.circle_outlined,
                                size: 18,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.habit.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isAction
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isDone
                                  ? theme.colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    )
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: domainColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.habit.domainTag ?? 'Tubuh',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: domainColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Beban: ${beban}pt',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              if (item.habit.lifetimeDoneCount > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '✓ ${item.habit.lifetimeDoneCount}x',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDone
                                        ? domainColor
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                    fontWeight: isDone
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (paused) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        constraints: const BoxConstraints(minHeight: 44),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.06,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⏸ Dijeda',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else if (!isDone && item.log == null) ...[
                      OutlinedButton(
                        onPressed: () =>
                            onFrictionIntervention(context, item.habit),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(64, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Tidak Sanggup',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      onPressed: () => context.push(
                        '/add-habit?habitId=${item.habit.habitId}',
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      tooltip: 'Edit Kebiasaan',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
