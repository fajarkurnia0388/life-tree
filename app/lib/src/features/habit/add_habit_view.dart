import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/domain/app_constants.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_level.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/user_profile_provider.dart';
import 'services/habit_crud_service.dart';
import '../../core/services/snackbar_service.dart';
import '../../core/theme/form_theme.dart';
import '../../core/theme/button_theme.dart';
import '../../core/animations/dialog_animations.dart';
import '../../data/local_db/database.dart';
import '../cultivation/cultivation_provider.dart';
import '../cultivation/cultivation_strings.dart';
import '../dashboard/dashboard_provider.dart';
import '../../core/services/notification_service.dart';
import 'widgets/habit_templates.dart';
import 'widgets/habit_sliders_section.dart';

class AddHabitView extends ConsumerStatefulWidget {
  final String? habitId;
  final String? initialDomainTag;

  const AddHabitView({super.key, this.habitId, this.initialDomainTag});

  @override
  ConsumerState<AddHabitView> createState() => _AddHabitViewState();
}

class _AddHabitViewState extends ConsumerState<AddHabitView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalTagController = TextEditingController();

  int _initiationFriction = 3;
  int _energyCost = 3;
  int _impactScore = 3;
  int _mvaDurationMin = 2;
  bool _showTemplates = true;
  String _frequency = 'Daily';
  late String _domainTag;

  bool _reminderEnabled = true;
  String _reminderTime = '08:00';
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';

  static const List<String> _domainTags = [
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi',
  ];

  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];

  bool _isEditing = false;
  Habit? _existingHabit;
  String? _stackedToHabitId;
  late final Future<List<Habit>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _domainTag = _normalizedInitialDomainTag(widget.initialDomainTag);
    _habitsFuture = _loadActiveHabits();
    if (widget.habitId != null) {
      _loadHabitForEdit();
    }
  }

  Future<List<Habit>> _loadActiveHabits() async {
    final userId = await ref.read(currentUserIdProvider.future);
    if (userId == null) return <Habit>[];
    return await ref.read(habitCrudServiceProvider).getActiveHabits(userId);
  }

  String _normalizedInitialDomainTag(String? domainTag) {
    if (domainTag == null || domainTag.trim().isEmpty) return 'Tubuh';
    return _domainTags.contains(domainTag) ? domainTag : 'Tubuh';
  }

  Future<void> _loadHabitForEdit() async {
    final detail = await ref
        .read(habitCrudServiceProvider)
        .getHabitDetail(widget.habitId!);
    if (detail != null && mounted) {
      final habit = detail.habit;
      final reminder = detail.reminder;
      setState(() {
        _isEditing = true;
        _existingHabit = habit;
        _titleController.text = habit.title;
        _goalTagController.text = habit.goalTag ?? '';
        _initiationFriction = habit.initiationFriction;
        _energyCost = habit.energyCost;
        _impactScore = habit.impactScore;
        _mvaDurationMin = habit.mvaDurationMin;
        _frequency = habit.frequency;
        _domainTag = habit.domainTag ?? 'Tubuh';
        _showTemplates = false; // Hide templates in edit mode
        _stackedToHabitId = habit.stackedToHabitId;

        if (reminder != null) {
          _reminderEnabled = reminder.reminderEnabled;
          _reminderTime = reminder.reminderTime;
          _quietHoursStart = reminder.quietHoursStart;
          _quietHoursEnd = reminder.quietHoursEnd;
        }

        if (habit.scheduledDays != null) {
          _selectedDays.clear();
          _selectedDays.addAll(
            habit.scheduledDays!
                .split(',')
                .map((e) => int.tryParse(e.trim()))
                .whereType<int>(),
          );
        }
      });
    }
  }

  Future<void> _deleteHabit() async {
    if (_existingHabit == null) return;

    final proceed = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) {
        final languageLevel = ref.read(cultivationLanguageLevelProvider);
        final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
        return AlertDialog(
          title: Text(
            '${DaojiText.resolve(DaojiTextKey.habitDelete, vocabularyLevel)} ${CultivationStrings.habitLabel(languageLevel)}',
          ),
          content: Text(
            DaojiText.resolve(
              DaojiTextKey.habitDeleteConfirm,
              vocabularyLevel,
              params: {
                'label': CultivationStrings.habitLabel(
                  languageLevel,
                ).toLowerCase(),
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: AppButtonStyles.secondary(context),
              child: Text(
                DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
              ),
            ),
            TextButton(
              style: AppButtonStyles.text(context),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                DaojiText.resolve(DaojiTextKey.systemDelete, vocabularyLevel),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (proceed != true) return;

    await ref
        .read(habitCrudServiceProvider)
        .deleteHabit(_existingHabit!.habitId);

    await NotificationService.cancelHabit(_existingHabit!.habitId);

    ref.invalidate(dashboardDataProvider);

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _syncReminder(
    String habitId,
    DaojiVocabularyLevel vocabularyLevel,
  ) async {
    if (!_reminderEnabled) {
      await NotificationService.cancelHabit(habitId);
      return;
    }

    final parts = _reminderTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    await NotificationService.scheduleHabitReminder(
      habitId: habitId,
      title: DaojiText.resolve(
        DaojiTextKey.habitReminderTitle,
        vocabularyLevel,
        params: {'title': _titleController.text.trim()},
      ),
      body: DaojiText.resolve(DaojiTextKey.habitReminderBody, vocabularyLevel),
      hour: hour,
      minute: minute,
      weekdays: _frequency == HabitFrequency.daily
          ? const {}
          : _selectedDays.toSet(),
      quietHoursStart: _quietHoursStart,
      quietHoursEnd: _quietHoursEnd,
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final languageLevel = ref.read(cultivationLanguageLevelProvider);

    final userId = await ref.read(currentUserIdProvider.future);
    if (userId == null) return;

    final activeHabits = await ref
        .read(habitCrudServiceProvider)
        .getActiveHabits(userId);

    // --- Anti-Guilt Protection: block NEW habit creation during low well-being ---
    // Editing an existing habit is always allowed (preserving user agency).
    if (!_isEditing) {
      final dashboardAsync = ref.read(dashboardDataProvider);
      final isLowWellBeing =
          dashboardAsync.whenOrNull(data: (d) => d.isLowWellBeing) ?? false;
      if (isLowWellBeing) {
        if (!mounted) return;
        SnackBarService.showInfo(
          context,
          DaojiText.resolve(DaojiTextKey.marketRestPrompt, vocabularyLevel),
        );
        return;
      }
    }

    final currentLoad = activeHabits.fold<int>(
      0,
      (sum, h) => sum + h.initiationFriction + h.energyCost,
    );
    int nextLoad = currentLoad;
    if (_isEditing && _existingHabit != null) {
      nextLoad =
          currentLoad -
          (_existingHabit!.initiationFriction + _existingHabit!.energyCost) +
          _initiationFriction +
          _energyCost;
    } else {
      nextLoad = currentLoad + _initiationFriction + _energyCost;
    }

    final profile = await ref.read(userProfileProvider.future);
    final maxCapacity = profile?.canopyLoadCapacity ?? 10;

    if (nextLoad > maxCapacity) {
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              DaojiText.resolve(
                DaojiTextKey.habitCapacityWarning,
                vocabularyLevel,
              ),
            ),
            content: Text(
              DaojiText.resolve(
                DaojiTextKey.habitCapacityWarningBody,
                vocabularyLevel,
                params: {
                  'maxCapacity': maxCapacity,
                  'nextLoad': nextLoad,
                  'label': CultivationStrings.habitLabel(
                    languageLevel,
                  ).toLowerCase(),
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  DaojiText.resolve(
                    DaojiTextKey.actionUnderstand,
                    vocabularyLevel,
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (proceed != true) return;
    }

    final scheduledDaysStr = _frequency == 'Daily'
        ? null
        : _selectedDays.isEmpty
        ? '1'
        : _selectedDays.join(',');

    if (_isEditing && _existingHabit != null) {
      final habitId = _existingHabit!.habitId;
      await ref
          .read(habitCrudServiceProvider)
          .updateHabit(
            habitId: habitId,
            domainTag: _domainTag,
            title: _titleController.text.trim(),
            frequency: _frequency,
            scheduledDays: scheduledDaysStr,
            initiationFriction: _initiationFriction,
            energyCost: _energyCost,
            impactScore: _impactScore,
            mvaDurationMin: _mvaDurationMin,
            stackedToHabitId: _stackedToHabitId,
            goalTag: _goalTagController.text.trim().isEmpty
                ? null
                : _goalTagController.text.trim(),
            reminderEnabled: _reminderEnabled,
            reminderTime: _reminderTime,
            quietHoursStart: _quietHoursStart,
            quietHoursEnd: _quietHoursEnd,
          );

      try {
        if (_reminderEnabled) {
          final hasPermission = await NotificationService.requestPermission();
          if (!hasPermission && mounted) {
            SnackBarService.showWarning(
              context,
              'Izin notifikasi ditolak. Pengingat tidak akan aktif.',
            );
          }
        }
        await _syncReminder(habitId, vocabularyLevel);
      } catch (e) {
        if (mounted) {
          SnackBarService.showWarning(
            context,
            'Kebiasaan tersimpan, tapi pengingat gagal diaktifkan: $e',
          );
        }
      }
    } else {
      final habitId = const Uuid().v4();
      final newHabit = HabitsCompanion.insert(
        habitId: habitId,
        userId: userId,
        domainTag: drift.Value(_domainTag),
        title: _titleController.text.trim(),
        status: const drift.Value(HabitStatus.active),
        frequency: drift.Value(_frequency),
        scheduledDays: drift.Value(scheduledDaysStr),
        initiationFriction: drift.Value(_initiationFriction),
        originalFriction: drift.Value(_initiationFriction),
        energyCost: drift.Value(_energyCost),
        impactScore: drift.Value(_impactScore),
        mvaDurationMin: drift.Value(_mvaDurationMin),
        stackedToHabitId: drift.Value(_stackedToHabitId),
        createdAt: now,
        goalTag: drift.Value(
          _goalTagController.text.trim().isEmpty
              ? null
              : _goalTagController.text.trim(),
        ),
      );

      final reminder = ReminderPreferencesCompanion(
        habitId: drift.Value(habitId),
        reminderEnabled: drift.Value(_reminderEnabled),
        reminderTime: drift.Value(_reminderTime),
        quietHoursStart: drift.Value(_quietHoursStart),
        quietHoursEnd: drift.Value(_quietHoursEnd),
      );

      await ref
          .read(habitCrudServiceProvider)
          .createHabit(newHabit: newHabit, reminder: reminder);

      try {
        if (_reminderEnabled) {
          final hasPermission = await NotificationService.requestPermission();
          if (!hasPermission && mounted) {
            SnackBarService.showWarning(
              context,
              'Izin notifikasi ditolak. Pengingat tidak akan aktif.',
            );
          }
        }
        await _syncReminder(habitId, vocabularyLevel);
      } catch (e) {
        if (mounted) {
          SnackBarService.showWarning(
            context,
            'Kebiasaan tersimpan, tapi pengingat gagal diaktifkan: $e',
          );
        }
      }
    }

    ref.invalidate(dashboardDataProvider);

    if (mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalTagController.dispose();
    super.dispose();
  }

  List<HabitTemplate> get _activeTemplates {
    switch (_domainTag) {
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
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit ${CultivationStrings.habitLabel(languageLevel)}'
              : CultivationStrings.addHabit(languageLevel),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip:
                'Marketplace ${CultivationStrings.habitLabel(languageLevel)}',
            // Full-screen catalog mode; filters shared via marketplaceUiProvider.
            onPressed: () => context.push('/marketplace'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing
                    ? 'Edit ${CultivationStrings.habitLabel(languageLevel)} ✏️'
                    : '${CultivationStrings.addHabit(languageLevel)} 🌱',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Daoji membantu Anda membangun kebiasaan secara perlahan tanpa memicu rasa bersalah.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gunakan Template ${CultivationStrings.habitLabel(languageLevel)} (Opsional)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showTemplates
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: _showTemplates
                        ? 'Sembunyikan Template'
                        : 'Tampilkan Template',
                    onPressed: () {
                      setState(() {
                        _showTemplates = !_showTemplates;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_showTemplates) ...[
                // Category Tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _domainTags.map((tag) {
                      final isSelected = _domainTag == tag;
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
                              setState(() {
                                _domainTag = tag;
                              });
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
                            onTap: () {
                              setState(() {
                                _titleController.text = t.title;
                                _initiationFriction = t.friction;
                                _energyCost = t.energy;
                                _impactScore = t.impact;
                                _mvaDurationMin = t.mvaDuration;
                              });
                            },
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
                                        '� ${t.friction}   ⚡ ${t.energy}',
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

              Text(
                DaojiText.resolve(DaojiTextKey.habitCategory, vocabularyLevel),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_domainTag),
                initialValue: _domainTag,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _domainTags
                    .map(
                      (val) => DropdownMenuItem(
                        value: val,
                        child: Text(
                          DaojiText.domainLabel(
                            val,
                            vocabularyLevel,
                            short: true,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _domainTag = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: AppFormTheme.inputDecoration(
                  labelText: DaojiText.resolve(
                    DaojiTextKey.habitNameLabel,
                    vocabularyLevel,
                  ),
                  hintText: 'Misal: Jalan kaki pagi',
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: AppFormTheme.habitTitleValidator,
              ),
              const SizedBox(height: 20),

              Text(
                '${DaojiText.resolve(DaojiTextKey.habitGoalLabel, vocabularyLevel)} (Opsional) 🎯',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _goalTagController,
                decoration: AppFormTheme.inputDecoration(
                  labelText: 'Nama Target / Goal',
                  hintText: 'Misal: Menurunkan berat badan 5kg',
                  prefixIcon: const Icon(Icons.track_changes_rounded),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) =>
                    AppFormTheme.optionalTextValidator(v, maxLength: 100),
              ),
              const SizedBox(height: 20),

              const Text(
                'Routine Stacking (Jangkar Kebiasaan) ☕',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Habit>>(
                future: _habitsFuture,
                builder: (context, snapshot) {
                  final habits = snapshot.data ?? [];
                  final validHabits = habits
                      .where((h) => h.habitId != widget.habitId)
                      .toList();

                  return DropdownButtonFormField<String?>(
                    initialValue: _stackedToHabitId,
                    decoration: AppFormTheme.inputDecoration(
                      labelText: 'Pilih Kebiasaan Pemicu',
                      hintText: 'Dilakukan segera setelah...',
                      prefixIcon: const Icon(Icons.link_rounded),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tanpa Stacking (Mulai Mandiri)'),
                      ),
                      ...validHabits.map(
                        (h) => DropdownMenuItem<String?>(
                          value: h.habitId,
                          child: Text('Setelah selesai "${h.title}"'),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _stackedToHabitId = val;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              Text(
                DaojiText.resolve(DaojiTextKey.habitFrequency, vocabularyLevel),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Daily', label: Text('Setiap Hari')),
                  ButtonSegment(value: 'Weekly', label: Text('Pilih Hari')),
                ],
                selected: {_frequency},
                onSelectionChanged: (selection) {
                  setState(() {
                    _frequency = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_frequency == 'Weekly') ...[
                const Text(
                  'Pilih Hari Penjadwalan:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1;
                    final daysAbbr = [
                      'Sen',
                      'Sel',
                      'Rab',
                      'Kam',
                      'Jum',
                      'Sab',
                      'Min',
                    ];
                    final isSelected = _selectedDays.contains(dayNum);
                    return FilterChip(
                      label: Text(daysAbbr[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayNum);
                            _selectedDays.sort();
                          } else {
                            _selectedDays.remove(dayNum);
                          }
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],

              HabitSlidersSection(
                initiationFriction: _initiationFriction,
                energyCost: _energyCost,
                impactScore: _impactScore,
                mvaDurationMin: _mvaDurationMin,
                onFrictionChanged: (val) =>
                    setState(() => _initiationFriction = val),
                onEnergyChanged: (val) => setState(() => _energyCost = val),
                onImpactChanged: (val) => setState(() => _impactScore = val),
                onDurationChanged: (val) =>
                    setState(() => _mvaDurationMin = val),
                habitsFuture: _habitsFuture,
                isEditing: _isEditing,
                existingHabit: _existingHabit,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.notifications_active_outlined,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Pengingat Kebiasaan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Switch(
                            value: _reminderEnabled,
                            onChanged: (val) =>
                                setState(() => _reminderEnabled = val),
                          ),
                        ],
                      ),
                      if (_reminderEnabled) ...[
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Waktu Pengingat',
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _reminderTime,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final time = await _pickTime(
                              context,
                              _reminderTime,
                            );
                            if (time != null) {
                              setState(() => _reminderTime = time);
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Jam Sunyi Mulai (Quiet Start)',
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _quietHoursStart,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final time = await _pickTime(
                              context,
                              _quietHoursStart,
                            );
                            if (time != null) {
                              setState(() => _quietHoursStart = time);
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Jam Sunyi Selesai (Quiet End)',
                            style: TextStyle(fontSize: 14),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _quietHoursEnd,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final time = await _pickTime(
                              context,
                              _quietHoursEnd,
                            );
                            if (time != null) {
                              setState(() => _quietHoursEnd = time);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                style: AppButtonStyles.primary(context),
                onPressed: _saveHabit,
                child: Text(
                  _isEditing
                      ? DaojiText.resolve(
                          DaojiTextKey.habitEdit,
                          vocabularyLevel,
                        )
                      : DaojiText.resolve(
                          DaojiTextKey.habitSave,
                          vocabularyLevel,
                        ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _deleteHabit,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    DaojiText.resolve(
                      DaojiTextKey.habitDelete,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 52),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null) return null;
    final hourStr = picked.hour.toString().padLeft(2, '0');
    final minuteStr = picked.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}
