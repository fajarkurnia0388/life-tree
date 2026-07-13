import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/user_profile_provider.dart';
import 'services/habit_crud_service.dart';
import '../../core/theme/button_theme.dart';
import '../../data/local_db/database.dart';
import '../cultivation/cultivation_provider.dart';
import '../cultivation/cultivation_strings.dart';
import 'widgets/habit_sliders_section.dart';
import 'widgets/habit_template_selector_widget.dart';
import 'widgets/habit_schedule_section_widget.dart';
import 'widgets/habit_reminder_section_widget.dart';
import 'widgets/habit_form_fields_widget.dart';
import 'add_habit/habit_save_handler.dart';
import 'add_habit/habit_delete_handler.dart';
import 'add_habit/habit_load_handler.dart';

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
    final handler = HabitLoadHandler(ref);
    final data = await handler.loadHabitForEdit(widget.habitId!);
    
    if (data != null && mounted) {
      final habit = data.habit;
      final reminder = data.reminder;
      
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
        _showTemplates = false;
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
    
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final languageLevel = ref.read(cultivationLanguageLevelProvider);
    
    final handler = HabitDeleteHandler(ref, context);
    await handler.deleteHabit(
      existingHabit: _existingHabit!,
      vocabularyLevel: vocabularyLevel,
      languageLevel: languageLevel,
    );
  }

  Future<void> _saveHabit() async {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final languageLevel = ref.read(cultivationLanguageLevelProvider);

    final userId = await ref.read(currentUserIdProvider.future);
    if (userId == null || !mounted) return;

    final handler = HabitSaveHandler(ref, context);
    final success = await handler.saveHabit(
      formKey: _formKey,
      isEditing: _isEditing,
      existingHabit: _existingHabit,
      userId: userId,
      domainTag: _domainTag,
      title: _titleController.text,
      goalTag: _goalTagController.text,
      initiationFriction: _initiationFriction,
      energyCost: _energyCost,
      impactScore: _impactScore,
      mvaDurationMin: _mvaDurationMin,
      frequency: _frequency,
      selectedDays: _selectedDays.toSet(),
      stackedToHabitId: _stackedToHabitId,
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderTime,
      quietHoursStart: _quietHoursStart,
      quietHoursEnd: _quietHoursEnd,
      vocabularyLevel: vocabularyLevel,
      languageLevel: languageLevel,
    );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalTagController.dispose();
    super.dispose();
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

              HabitTemplateSelectorWidget(
                showTemplates: _showTemplates,
                selectedDomainTag: _domainTag,
                domainTags: _domainTags,
                vocabularyLevel: vocabularyLevel,
                habitLabel: CultivationStrings.habitLabel(languageLevel),
                onToggleTemplates: () =>
                    setState(() => _showTemplates = !_showTemplates),
                onDomainTagChanged: (tag) => setState(() => _domainTag = tag),
                onTemplateSelected: (t) {
                  setState(() {
                    _titleController.text = t.title;
                    _initiationFriction = t.friction;
                    _energyCost = t.energy;
                    _impactScore = t.impact;
                    _mvaDurationMin = t.mvaDuration;
                  });
                },
              ),

              HabitFormFieldsWidget(
                domainTag: _domainTag,
                domainTags: _domainTags,
                onDomainTagChanged: (tag) => setState(() => _domainTag = tag),
                titleController: _titleController,
                goalTagController: _goalTagController,
                vocabularyLevel: vocabularyLevel,
                habitsFuture: _habitsFuture,
                currentHabitId: widget.habitId,
                stackedToHabitId: _stackedToHabitId,
                onStackedToHabitIdChanged: (val) => setState(() => _stackedToHabitId = val),
              ),
              const SizedBox(height: 24),

              HabitScheduleSectionWidget(
                frequency: _frequency,
                onFrequencyChanged: (val) => setState(() => _frequency = val),
                selectedDays: _selectedDays,
                vocabularyLevel: vocabularyLevel,
              ),

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

              HabitReminderSectionWidget(
                reminderEnabled: _reminderEnabled,
                onReminderEnabledChanged: (val) =>
                    setState(() => _reminderEnabled = val),
                reminderTime: _reminderTime,
                onReminderTimeChanged: (val) =>
                    setState(() => _reminderTime = val),
                quietHoursStart: _quietHoursStart,
                onQuietHoursStartChanged: (val) =>
                    setState(() => _quietHoursStart = val),
                quietHoursEnd: _quietHoursEnd,
                onQuietHoursEndChanged: (val) =>
                    setState(() => _quietHoursEnd = val),
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
}
