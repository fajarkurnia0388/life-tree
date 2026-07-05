import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/domain/app_constants.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/theme/form_theme.dart';
import '../../core/theme/button_theme.dart';
import '../../core/animations/dialog_animations.dart';
import '../../data/local_db/database.dart';
import '../cultivation/cultivation_provider.dart';
import '../cultivation/cultivation_strings.dart';
import '../dashboard/dashboard_provider.dart';
import 'widgets/habit_templates.dart';
import '../../core/services/notification_service.dart';

class EditHabitView extends ConsumerStatefulWidget {
  final String habitId;

  const EditHabitView({super.key, required this.habitId});

  @override
  ConsumerState<EditHabitView> createState() => _EditHabitViewState();
}

class _EditHabitViewState extends ConsumerState<EditHabitView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalTagController = TextEditingController();

  int _initiationFriction = 3;
  int _energyCost = 3;
  int _impactScore = 3;
  int _mvaDurationMin = 2;
  bool _showTemplates = false;
  String _frequency = 'Daily';
  late String _domainTag;

  static const List<String> _domainTags = [
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi',
  ];

  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  Habit? _existingHabit;

  @override
  void initState() {
    super.initState();
    _domainTag = 'Tubuh';
    _loadHabitForEdit();
  }

  Future<void> _loadHabitForEdit() async {
    final db = ref.read(dbProvider);
    final habit = await (db.select(
      db.habits,
    )..where((tbl) => tbl.habitId.equals(widget.habitId))).getSingleOrNull();
    
    if (habit != null && mounted) {
      setState(() {
        _existingHabit = habit;
        _titleController.text = habit.title;
        _goalTagController.text = habit.goalTag ?? '';
        _initiationFriction = habit.initiationFriction;
        _energyCost = habit.energyCost;
        _impactScore = habit.impactScore;
        _mvaDurationMin = habit.mvaDurationMin;
        _frequency = habit.frequency;
        _domainTag = habit.domainTag ?? 'Tubuh';

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
    final proceed = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) {
        final languageLevel = ref.read(cultivationLanguageLevelProvider);
        return AlertDialog(
          title: Text('Hapus ${CultivationStrings.habitLabel(languageLevel)}'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kebiasaan ini? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: AppButtonStyles.secondary(context),
              child: const Text('Batal'),
            ),
            TextButton(
              style: AppButtonStyles.text(context),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (proceed != true) return;

    final db = ref.read(dbProvider);
    await (db.update(db.habits)
          ..where((tbl) => tbl.habitId.equals(widget.habitId)))
        .write(HabitsCompanion(deletedAt: drift.Value(DateTime.now())));

    ref.invalidate(dashboardDataProvider);
    if (mounted) context.pop();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(dbProvider);
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final activeHabits = await (db.select(db.habits)..where(
          (tbl) => tbl.userId.equals(userId) & tbl.status.equals(HabitStatus.active) & tbl.deletedAt.isNull(),
        )).get();

    final currentLoad = activeHabits.fold<int>(0, (sum, h) => sum + h.initiationFriction + h.energyCost);
    int nextLoad = currentLoad - (_existingHabit?.initiationFriction ?? 0) - (_existingHabit?.energyCost ?? 0) + _initiationFriction + _energyCost;
    final maxCapacity = profiles.first.canopyLoadCapacity;

    if (nextLoad > maxCapacity) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Beban Canopy Terlampaui'),
          content: Text('Beban akan menjadi $nextLoad / $maxCapacity. Lanjutkan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lanjut')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final scheduledDaysStr = _frequency == 'Daily' ? null : (_selectedDays.isEmpty ? '1' : _selectedDays.join(','));

    await (db.update(db.habits)..where((tbl) => tbl.habitId.equals(widget.habitId))).write(
      HabitsCompanion(
        domainTag: drift.Value(_domainTag),
        title: drift.Value(_titleController.text.trim()),
        frequency: drift.Value(_frequency),
        scheduledDays: drift.Value(scheduledDaysStr),
        initiationFriction: drift.Value(_initiationFriction),
        energyCost: drift.Value(_energyCost),
        impactScore: drift.Value(_impactScore),
        mvaDurationMin: drift.Value(_mvaDurationMin),
        goalTag: drift.Value(_goalTagController.text.trim().isEmpty ? null : _goalTagController.text.trim()),
      ),
    );

    // Reschedule Notification with updated title
    await NotificationService.scheduleDaily(
      id: widget.habitId.hashCode.abs() % 100000,
      title: 'Waktunya: ${_titleController.text.trim()}',
      body: 'Jaga konsistensi pertumbuhanmu hari ini 🌱',
      hour: 8,
      minute: 0,
    );

    ref.invalidate(dashboardDataProvider);
    if (mounted) context.pop();
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
        title: Text('Edit ${CultivationStrings.habitLabel(languageLevel)}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit ${CultivationStrings.habitLabel(languageLevel)} ✏️',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Text(DaojiText.resolve(DaojiTextKey.habitCategory, vocabularyLevel), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _domainTag,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: _domainTags.map((val) => DropdownMenuItem(value: val, child: Text(DaojiText.domainLabel(val, vocabularyLevel, short: true)))).toList(),
                onChanged: (val) => setState(() => _domainTag = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: AppFormTheme.inputDecoration(labelText: DaojiText.resolve(DaojiTextKey.habitNameLabel, vocabularyLevel)),
                validator: AppFormTheme.habitTitleValidator,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _goalTagController,
                decoration: AppFormTheme.inputDecoration(labelText: 'Goal Tag'),
              ),
              const SizedBox(height: 24),
              SegmentedButton<String>(
                segments: const [ButtonSegment(value: 'Daily', label: Text('Daily')), ButtonSegment(value: 'Weekly', label: Text('Weekly'))],
                selected: {_frequency},
                onSelectionChanged: (selection) => setState(() => _frequency = selection.first),
              ),
              if (_frequency == 'Weekly') ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1;
                    return FilterChip(
                      label: Text('Day $dayNum'),
                      selected: _selectedDays.contains(dayNum),
                      onSelected: (selected) {
                        setState(() {
                          selected ? _selectedDays.add(dayNum) : _selectedDays.remove(dayNum);
                          _selectedDays.sort();
                        });
                      },
                    );
                  }),
                ),
              ],
              const SizedBox(height: 16),
              _buildSlider('Friction', _initiationFriction, (val) => setState(() => _initiationFriction = val)),
              _buildSlider('Energy', _energyCost, (val) => setState(() => _energyCost = val)),
              _buildSlider('Impact', _impactScore, (val) => setState(() => _impactScore = val)),
              _buildSlider('MVA (min)', _mvaDurationMin, (val) => setState(() => _mvaDurationMin = val), maxVal: 30),
              const SizedBox(height: 32),
              ElevatedButton(
                style: AppButtonStyles.primary(context),
                onPressed: _saveHabit,
                child: Text(DaojiText.resolve(DaojiTextKey.habitEdit, vocabularyLevel)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _deleteHabit,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete Habit', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String title, int value, ValueChanged<int> onChanged, {int maxVal = 5}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(value: value.toDouble(), min: 1, max: maxVal.toDouble(), divisions: maxVal - 1, onChanged: (val) => onChanged(val.toInt())),
      ],
    );
  }
}
