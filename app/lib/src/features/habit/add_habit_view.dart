import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;

class AddHabitView extends ConsumerStatefulWidget {
  const AddHabitView({super.key});

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

  // For weekly scheduling (comma-separated days, 1=Monday, 7=Sunday)
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(dbProvider);
    final now = DateTime.now();

    // Get user id
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final habitId = const Uuid().v4();
    
    // Validate canopy capacity soft check
    final activeHabits = await (db.select(db.habits)
          ..where((tbl) => tbl.status.equals('Active') & tbl.deletedAt.isNull()))
        .get();
    
    final currentLoad = activeHabits.fold<int>(0, (sum, h) => sum + h.initiationFriction + h.energyCost);
    final nextLoad = currentLoad + _initiationFriction + _energyCost;
    final maxCapacity = profiles.first.canopyLoadCapacity;

    if (nextLoad > maxCapacity) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Beban Canopy Terlampaui'),
            content: Text(
              'Total beban kapasitas harian Anda adalah $maxCapacity poin. '
              'Menambahkan habit ini akan meningkatkan beban menjadi $nextLoad poin. '
              '\n\nLifeTree menyarankan untuk menjaga beban di bawah batas agar tidak kelelahan. Tetap lanjutkan?'
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

    final newHabit = HabitsCompanion.insert(
      habitId: habitId,
      userId: userId,
      domainTag: drift.Value(_domainTag),
      title: _titleController.text.trim(),
      status: const drift.Value('Active'),
      frequency: drift.Value(_frequency),
      scheduledDays: drift.Value(scheduledDaysStr),
      initiationFriction: drift.Value(_initiationFriction),
      originalFriction: drift.Value(_initiationFriction),
      energyCost: drift.Value(_energyCost),
      impactScore: drift.Value(_impactScore),
      mvaDurationMin: drift.Value(_mvaDurationMin),
      createdAt: now,
      goalTag: drift.Value(_goalTagController.text.trim().isEmpty ? null : _goalTagController.text.trim()),
    );

    // Save reminder preferences as default
    final reminder = ReminderPreferencesCompanion.insert(
      habitId: habitId,
    );

    await db.into(db.habits).insert(newHabit);
    await db.into(db.reminderPreferences).insert(reminder);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebiasaan Baru'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Buat Kebiasaan Baru 🌱',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'LifeTree membantu Anda membangun kebiasaan secara perlahan tanpa memicu rasa bersalah.',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onBackground.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),

              // Use Templates Section Header (with collapse/expand toggle)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gunakan Template Kebiasaan (Opsional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  IconButton(
                    icon: Icon(
                      _showTemplates
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: _showTemplates ? 'Sembunyikan Template' : 'Tampilkan Template',
                    onPressed: () {
                      setState(() {
                        _showTemplates = !_showTemplates;
                      });
                    },
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _showTemplates
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 115,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _bodyHabitTemplates.length,
                              itemBuilder: (context, index) {
                                final t = _bodyHabitTemplates[index];
                                final isSelected = _titleController.text == t.title;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _titleController.text = t.title;
                                      _initiationFriction = t.friction;
                                      _energyCost = t.energy;
                                      _impactScore = t.impact;
                                      _mvaDurationMin = t.mvaDuration;
                                    });
                                  },
                                  child: Container(
                                    width: 220,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.04),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onBackground.withOpacity(0.08),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.6)),
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'MVA: ${t.mvaDuration}m',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Beban: ${t.friction + t.energy}pt',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Nama Kebiasaan',
                  hintText: 'Misal: Olahraga ringan pagi hari',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harap masukkan nama kebiasaan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('Domain Kehidupan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _domainTag,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Tubuh', child: Text('Tubuh (Body) 🏃')),
                  DropdownMenuItem(value: 'Keuangan', child: Text('Keuangan (Finance) 💰')),
                  DropdownMenuItem(value: 'Hubungan', child: Text('Hubungan (Relations) 🤝')),
                  DropdownMenuItem(value: 'Emosi', child: Text('Emosi (Emotion) 🧠')),
                  DropdownMenuItem(value: 'Karir', child: Text('Karir/Belajar (Career) 📚')),
                  DropdownMenuItem(value: 'Rekreasi', child: Text('Rekreasi (Recreation) 🎮')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _domainTag = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              const Text('Target / Goal yang Terkait (Opsional) 🎯', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _goalTagController,
                decoration: InputDecoration(
                  labelText: 'Nama Target / Goal',
                  hintText: 'Misal: Menurunkan berat badan 5kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.track_changes_rounded),
                ),
              ),
              const SizedBox(height: 24),

              // Frequency
              const Text('Frekuensi Rutinitas', style: TextStyle(fontWeight: FontWeight.bold)),
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
                const Text('Pilih Hari Penjadwalan:', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1; // 1=Mon, 7=Sun
                    final daysAbbr = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
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

              // Initiation Friction
              _buildSliderSection(
                title: 'Hambatan Memulai (Initiation Friction)',
                value: _initiationFriction,
                minLabel: 'Mudah sekali',
                maxLabel: 'Sangat malas/Sulit',
                onChanged: (val) => setState(() => _initiationFriction = val),
              ),

              // Energy Cost
              _buildSliderSection(
                title: 'Kebutuhan Energi (Energy Cost)',
                value: _energyCost,
                minLabel: 'Ringan',
                maxLabel: 'Sangat Lelah',
                onChanged: (val) => setState(() => _energyCost = val),
              ),

              // Impact Score
              _buildSliderSection(
                title: 'Tingkat Kepentingan (Impact Score)',
                value: _impactScore,
                minLabel: 'Tambahan',
                maxLabel: 'Sangat Penting',
                onChanged: (val) => setState(() => _impactScore = val),
              ),

              // MVA Duration Min
              _buildSliderSection(
                title: 'Durasi Target Minimum (MVA Duration)',
                value: _mvaDurationMin,
                minLabel: '1 Menit',
                maxLabel: '15 Menit',
                minVal: 1,
                maxVal: 15,
                divisions: 14,
                unit: ' Menit',
                onChanged: (val) => setState(() => _mvaDurationMin = val),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(88, 52), // WCAG touch target
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Kebiasaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                Text(minLabel, style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.6))),
                Text(maxLabel, style: TextStyle(fontSize: 11, color: theme.colorScheme.onBackground.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HabitTemplate {
  final String title;
  final int friction;
  final int energy;
  final int impact;
  final int mvaDuration;
  final String description;

  const HabitTemplate({
    required this.title,
    required this.friction,
    required this.energy,
    required this.impact,
    required this.mvaDuration,
    required this.description,
  });
}

const List<HabitTemplate> _bodyHabitTemplates = [
  HabitTemplate(
    title: 'Minum segelas air hangat pagi',
    friction: 1,
    energy: 1,
    impact: 4,
    mvaDuration: 1,
    description: 'Rehidrasi instan untuk merangsang metabolisme tubuh.',
  ),
  HabitTemplate(
    title: 'Peregangan leher & pundak',
    friction: 1,
    energy: 2,
    impact: 3,
    mvaDuration: 2,
    description: 'Melepaskan otot kaku setelah duduk atau bekerja.',
  ),
  HabitTemplate(
    title: 'Plank statis 1 menit',
    friction: 2,
    energy: 3,
    impact: 4,
    mvaDuration: 1,
    description: 'Latihan core singkat untuk stabilitas tulang belakang.',
  ),
  HabitTemplate(
    title: 'Jalan kaki santai 10 menit',
    friction: 2,
    energy: 3,
    impact: 5,
    mvaDuration: 5,
    description: 'Sirkulasi darah & udara segar di luar ruangan.',
  ),
  HabitTemplate(
    title: 'Jeda mata 20-20-20 rule',
    friction: 1,
    energy: 1,
    impact: 3,
    mvaDuration: 1,
    description: 'Jeda mata melihat jauh mengurangi screen fatigue.',
  ),
  HabitTemplate(
    title: 'Pernapasan 4-7-8 sebelum tidur',
    friction: 1,
    energy: 1,
    impact: 5,
    mvaDuration: 3,
    description: 'Latihan pernapasan rileks untuk kualitas tidur nyenyak.',
  ),
];
