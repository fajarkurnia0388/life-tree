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

class AddHabitView extends ConsumerStatefulWidget {
  final String? habitId;
  const AddHabitView({super.key, this.habitId});

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
  String _domainTag = 'Tubuh';

  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];

  bool _isEditing = false;
  Habit? _existingHabit;

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadHabitForEdit();
    }
  }

  Future<void> _loadHabitForEdit() async {
    final db = ref.read(dbProvider);
    final habit = await (db.select(
      db.habits,
    )..where((tbl) => tbl.habitId.equals(widget.habitId!))).getSingleOrNull();
    if (habit != null && mounted) {
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
        return AlertDialog(
          title: Text('Hapus ${CultivationStrings.habitLabel(languageLevel)}'),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${CultivationStrings.habitLabel(languageLevel).toLowerCase()} ini? Tindakan ini tidak dapat dibatalkan.',
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
    final now = DateTime.now();

    await (db.update(db.habits)
          ..where((tbl) => tbl.habitId.equals(_existingHabit!.habitId)))
        .write(HabitsCompanion(deletedAt: drift.Value(now)));

    ref.invalidate(dashboardDataProvider);

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(dbProvider);
    final now = DateTime.now();

    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final activeHabits =
        await (db.select(db.habits)..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.status.equals(HabitStatus.active) &
                  tbl.deletedAt.isNull(),
            ))
            .get();

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

    final maxCapacity = profiles.first.canopyLoadCapacity;

    if (nextLoad > maxCapacity) {
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Beban Canopy Terlampaui'),
            content: Text(
              'Total beban kapasitas harian Anda adalah $maxCapacity poin. '
              'Menambahkan/mengubah habit ini akan meningkatkan beban menjadi $nextLoad poin. '
              '\n\nDaoji menyarankan untuk menjaga beban di bawah batas agar tidak kelelahan. Tetap lanjutkan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Tetap Lanjutkan'),
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
      await (db.update(
        db.habits,
      )..where((tbl) => tbl.habitId.equals(widget.habitId!))).write(
        HabitsCompanion(
          domainTag: drift.Value(_domainTag),
          title: drift.Value(_titleController.text.trim()),
          frequency: drift.Value(_frequency),
          scheduledDays: drift.Value(scheduledDaysStr),
          initiationFriction: drift.Value(_initiationFriction),
          energyCost: drift.Value(_energyCost),
          impactScore: drift.Value(_impactScore),
          mvaDurationMin: drift.Value(_mvaDurationMin),
          goalTag: drift.Value(
            _goalTagController.text.trim().isEmpty
                ? null
                : _goalTagController.text.trim(),
          ),
        ),
      );
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
        createdAt: now,
        goalTag: drift.Value(
          _goalTagController.text.trim().isEmpty
              ? null
              : _goalTagController.text.trim(),
        ),
      );

      final reminder = ReminderPreferencesCompanion.insert(habitId: habitId);

      await db.into(db.habits).insert(newHabit);
      await db.into(db.reminderPreferences).insert(reminder);
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
                    children:
                        [
                          'Tubuh',
                          'Keuangan',
                          'Hubungan',
                          'Emosi',
                          'Karir',
                          'Rekreasi',
                        ].map((tag) {
                          final isSelected = _domainTag == tag;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(DaojiText.domainLabel(tag, vocabularyLevel, short: true)),
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
                items:
                    [
                          'Tubuh',
                          'Keuangan',
                          'Hubungan',
                          'Emosi',
                          'Karir',
                          'Rekreasi',
                        ]
                        .map(
                          (val) =>
                              DropdownMenuItem(
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
                  labelText: DaojiText.resolve(DaojiTextKey.habitNameLabel, vocabularyLevel),
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

              _buildSliderSection(
                title: '🚀 ${DaojiText.resolve(DaojiTextKey.habitFriction, vocabularyLevel)}',
                helperText:
                    'Contoh: olahraga ke gym = susah (4-5), baca 1 halaman = mudah (1-2)',
                value: _initiationFriction,
                minLabel: 'Sangat Mudah',
                maxLabel: 'Sangat Susah',
                onChanged: (val) => setState(() => _initiationFriction = val),
              ),

              _buildSliderSection(
                title: '⚡ ${DaojiText.resolve(DaojiTextKey.habitEnergy, vocabularyLevel)}',
                helperText:
                    'Contoh: lari 30 menit = banyak energi (4-5), nulis jurnal = sedikit (1-2)',
                value: _energyCost,
                minLabel: 'Sedikit Energi',
                maxLabel: 'Banyak Energi',
                onChanged: (val) => setState(() => _energyCost = val),
              ),

              _buildSliderSection(
                title: '🎯 ${DaojiText.resolve(DaojiTextKey.habitImpact, vocabularyLevel)}',
                helperText:
                    'Contoh: olahraga rutin = dampak besar (5), minum vitamin = menengah (3)',
                value: _impactScore,
                minLabel: 'Dampak Kecil',
                maxLabel: 'Dampak Besar',
                onChanged: (val) => setState(() => _impactScore = val),
              ),

              _buildSliderSection(
                title: '⏱️ ${DaojiText.resolve(DaojiTextKey.habitMva, vocabularyLevel)} (menit)',
                helperText:
                    'MVA: Minimum Viable Action — durasi terpendek agar tetap "valid dilakukan"',
                value: _mvaDurationMin,
                minLabel: '1 menit',
                maxLabel: '30 menit',
                minVal: 1,
                maxVal: 30,
                divisions: 29,
                unit: ' menit',
                onChanged: (val) => setState(() => _mvaDurationMin = val),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                style: AppButtonStyles.primary(context),
                onPressed: _saveHabit,
                child: Text(
                  _isEditing
                      ? DaojiText.resolve(DaojiTextKey.habitEdit, vocabularyLevel)
                      : DaojiText.resolve(DaojiTextKey.habitSave, vocabularyLevel),
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
                  label: const Text(
                    'Hapus Kebiasaan',
                    style: TextStyle(
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

  Widget _buildSliderSection({
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) => onChanged(val.toInt()),
                ),
              ),
              Text(
                '$value$unit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  maxLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
