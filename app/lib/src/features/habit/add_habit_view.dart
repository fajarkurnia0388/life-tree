import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'widgets/habit_templates.dart';

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

  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(dbProvider);
    final now = DateTime.now();

    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final habitId = const Uuid().v4();
    
    final activeHabits = await (db.select(db.habits)
          ..where((tbl) => tbl.status.equals('Active') & tbl.deletedAt.isNull()))
        .get();
    
    final currentLoad = activeHabits.fold<int>(0, (sum, h) => sum + h.initiationFriction + h.energyCost);
    final nextLoad = currentLoad + _initiationFriction + _energyCost;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebiasaan Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Marketplace Kebiasaan',
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
                'Buat Kebiasaan Baru 🌱',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'LifeTree membantu Anda membangun kebiasaan secara perlahan tanpa memicu rasa bersalah.',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),

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
              const SizedBox(height: 8),

              if (_showTemplates) ...[
                // Category Tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'].map((tag) {
                      final isSelected = _domainTag == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(tag),
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
                        margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      t.description,
                                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('🚀 $t.friction   ⚡ $t.energy', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                      Text('⏱️ ${t.mvaDuration}m', style: TextStyle(fontSize: 9, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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

              const Text('Kategori Kebiasaan', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _domainTag,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi']
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
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
                decoration: InputDecoration(
                  labelText: 'Nama Kebiasaan',
                  hintText: 'Misal: Jalan kaki pagi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama kebiasaan tidak boleh kosong' : null,
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
                    final dayNum = index + 1;
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

              _buildSliderSection(
                title: '🚀 Seberapa susah memulai?',
                helperText: 'Contoh: olahraga ke gym = susah (4-5), baca 1 halaman = mudah (1-2)',
                value: _initiationFriction,
                minLabel: 'Sangat Mudah',
                maxLabel: 'Sangat Susah',
                onChanged: (val) => setState(() => _initiationFriction = val),
              ),

              _buildSliderSection(
                title: '⚡ Seberapa menguras energi?',
                helperText: 'Contoh: lari 30 menit = banyak energi (4-5), nulis jurnal = sedikit (1-2)',
                value: _energyCost,
                minLabel: 'Sedikit Energi',
                maxLabel: 'Banyak Energi',
                onChanged: (val) => setState(() => _energyCost = val),
              ),

              _buildSliderSection(
                title: '🎯 Seberapa besar dampaknya?',
                helperText: 'Contoh: olahraga rutin = dampak besar (5), minum vitamin = menengah (3)',
                value: _impactScore,
                minLabel: 'Dampak Kecil',
                maxLabel: 'Dampak Besar',
                onChanged: (val) => setState(() => _impactScore = val),
              ),

              _buildSliderSection(
                title: '⏱️ Durasi minimum (menit)',
                helperText: 'MVA: Minimum Viable Action — durasi terpendek agar tetap "valid dilakukan"',
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
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(88, 52),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(helperText, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
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
                Text(minLabel, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                Text(maxLabel, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
