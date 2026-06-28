import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import 'package:drift/drift.dart' as drift;

class JournalLiteView extends ConsumerStatefulWidget {
  const JournalLiteView({super.key});

  @override
  ConsumerState<JournalLiteView> createState() => _JournalLiteViewState();
}

class _JournalLiteViewState extends ConsumerState<JournalLiteView> {
  final _formKey = GlobalKey<FormState>();
  final _keywordController = TextEditingController();
  final _q1Controller = TextEditingController();
  final _q2Controller = TextEditingController();
  final _q3Controller = TextEditingController();
  
  int _selectedMood = 3; // Default 3 (Biasa Saja)
  bool _showDeepReflection = false;

  // P2-04: Mood historical context (last 7 days)
  int? _yesterdayMood;
  double? _avg7DayMood;
  // 7 ints (oldest -> newest = today), 0 means no entry that day.
  List<int> _last7DayMoods = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingEntry();
      _loadMoodContext();
    });
  }

  /// P2-04: Query the last 7 days of this user's journal entries and compute
  /// yesterday's mood, the 7-day average, and a per-day series for the sparkline.
  Future<void> _loadMoodContext() async {
    final db = ref.read(dbProvider);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    // Window covers the last 7 calendar days, inclusive of today.
    final windowStart = todayStart.subtract(const Duration(days: 6));

    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final entries = await (db.select(db.journalEntries)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.deletedAt.isNull() &
              tbl.date.isBiggerOrEqualValue(windowStart)))
        .get();

    // Map normalized day -> moodScore for quick lookup.
    final moodByDate = <DateTime, int>{};
    for (final e in entries) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      moodByDate[d] = e.moodScore;
    }

    // Build the 7-day series from oldest (windowStart) to newest (today).
    final series = <int>[];
    for (int i = 0; i < 7; i++) {
      final day = windowStart.add(Duration(days: i));
      series.add(moodByDate[day] ?? 0);
    }

    final recorded = series.where((s) => s > 0).toList();
    final avg = recorded.isEmpty
        ? null
        : recorded.reduce((a, b) => a + b) / recorded.length;

    if (mounted) {
      setState(() {
        _yesterdayMood = moodByDate[yesterdayStart];
        _avg7DayMood = avg;
        _last7DayMoods = series;
      });
    }
  }

  String _emojiForScore(int score) {
    final match = _moods.firstWhere(
      (m) => m['score'] == score,
      orElse: () => _moods[2],
    );
    return match['emoji'] as String;
  }

  /// P2-04: Context line + sparkline summarizing the last 7 days of mood.
  Widget _buildMoodContext(ThemeData theme) {
    final hasData = _last7DayMoods.any((s) => s > 0);

    if (!hasData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Belum ada data mood minggu ini.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final parts = <String>[];
    if (_yesterdayMood != null) {
      parts.add('Kemarin: ${_emojiForScore(_yesterdayMood!)} ($_yesterdayMood)');
    }
    if (_avg7DayMood != null) {
      parts.add('Rata-rata 7 hari: ${_avg7DayMood!.toStringAsFixed(1)}');
    }
    final contextLine = parts.join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (contextLine.isNotEmpty)
            Text(
              contextLine,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 8),
          _buildSparkline(theme),
        ],
      ),
    );
  }

  /// P2-04: Lightweight inline sparkline (mini bars) of the last 7 days.
  Widget _buildSparkline(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return Semantics(
      label: 'Tren mood 7 hari terakhir: '
          '${_last7DayMoods.map((s) => s == 0 ? 'tidak ada data' : '$s').join(', ')}',
      child: SizedBox(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _last7DayMoods.map((score) {
            // Score 1-5 maps to a proportional height; 0 = no data (faint stub).
            final ratio = score == 0 ? 0.0 : score / 5.0;
            final barHeight = 4 + (ratio * 24); // 4..28 logical px
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: score == 0
                        ? primary.withValues(alpha: 0.15)
                        : primary.withValues(alpha: 0.35 + ratio * 0.45),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _loadExistingEntry() async {
    final db = ref.read(dbProvider);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final existing = await (db.select(db.journalEntries)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.date.equals(todayStart)))
        .get();

    if (existing.isNotEmpty && mounted) {
      final entry = existing.first;
      setState(() {
        _selectedMood = entry.moodScore;
        _keywordController.text = entry.keyword ?? '';
        _showDeepReflection = entry.entryType == 'Deep';
        if (entry.entryType == 'Deep' && entry.textContent != null) {
          final parts = entry.textContent!.split('\n\nRespons: ');
          if (parts.length == 2) {
            _q1Controller.text = parts[0].replaceAll('Pikiran: ', '');
            _q2Controller.text = parts[1];
          } else {
            _q1Controller.text = entry.textContent!;
          }
          _q3Controller.text = entry.gratitudeText ?? '';
        }
      });
    }
  }

  final List<Map<String, dynamic>> _moods = [
    {'score': 1, 'emoji': '😢', 'label': 'Sangat Buruk'},
    {'score': 2, 'emoji': '🙁', 'label': 'Buruk'},
    {'score': 3, 'emoji': '😐', 'label': 'Biasa Saja'},
    {'score': 4, 'emoji': '🙂', 'label': 'Baik'},
    {'score': 5, 'emoji': '😀', 'label': 'Sangat Baik'},
  ];

  Future<void> _saveJournalEntry() async {
    if (!_formKey.currentState!.validate()) return;
 
    final db = ref.read(dbProvider);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
 
    // Get user id
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;
 
    final entryId = const Uuid().v4();
 
    final keywordText = _keywordController.text.trim();
    
    // Deep reflection fields mapping
    final String? textContent = _showDeepReflection
        ? 'Pikiran: ${_q1Controller.text.trim()}\n\nRespons: ${_q2Controller.text.trim()}'
        : null;
    final String? gratitudeText = _showDeepReflection
        ? _q3Controller.text.trim()
        : null;
    final String entryType = _showDeepReflection ? 'Deep' : 'Lite';
 
    // Check if entry already exists for today
    final existing = await (db.select(db.journalEntries)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.date.equals(todayStart)))
        .get();
 
    if (existing.isNotEmpty) {
      // Update existing
      await (db.update(db.journalEntries)
            ..where((tbl) => tbl.entryId.equals(existing.first.entryId)))
          .write(JournalEntriesCompanion(
            moodScore: drift.Value(_selectedMood),
            keyword: drift.Value(keywordText.isEmpty ? null : keywordText),
            textContent: drift.Value(textContent),
            gratitudeText: drift.Value(gratitudeText),
            entryType: drift.Value(entryType),
          ));
    } else {
      // Insert new
      await db.into(db.journalEntries).insert(
            JournalEntriesCompanion.insert(
              entryId: entryId,
              userId: userId,
              date: todayStart,
              moodScore: _selectedMood,
              keyword: drift.Value(keywordText.isEmpty ? null : keywordText),
              textContent: drift.Value(textContent),
              gratitudeText: drift.Value(gratitudeText),
              entryType: drift.Value(entryType),
              createdAt: now,
            ),
          );
    }

    // Trigger low mood warning if mood_score <= 2 for exactly 3 consecutive days
    // We check hari ini (H-0), kemarin (H-1), dan 2 hari lalu (H-2) secara ketat.
    final now2 = DateTime.now();
    final dayH0 = DateTime(now2.year, now2.month, now2.day);
    final dayH1 = dayH0.subtract(const Duration(days: 1));
    final dayH2 = dayH0.subtract(const Duration(days: 2));

    final consecutiveEntries = await (db.select(db.journalEntries)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.date.isIn([dayH0, dayH1, dayH2])))
        .get();

    // Build a map from date -> moodScore for quick lookup
    final moodByDate = {
      for (final e in consecutiveEntries) e.date: e.moodScore,
    };

    // All 3 consecutive days must have an entry AND moodScore <= 2
    final hasConsecutiveLowMood = moodByDate.containsKey(dayH0) &&
        moodByDate.containsKey(dayH1) &&
        moodByDate.containsKey(dayH2) &&
        moodByDate[dayH0]! <= 2 &&
        moodByDate[dayH1]! <= 2 &&
        moodByDate[dayH2]! <= 2;

    if (hasConsecutiveLowMood) {
      _showLowMoodWarning();
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jurnal harian berhasil disimpan!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  void _showLowMoodWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('💡 Pesan Dukungan Diri'),
          content: const Text(
            'Kami mendeteksi suasana hati Anda kurang baik selama beberapa hari terakhir. '
            'Ingatlah untuk tidak menekan diri Anda terlalu keras. Anda selalu bisa beristirahat. '
            '\n\nJika membutuhkan teman berbicara atau bantuan psikologis profesional, silakan kunjungi Safety Card di pojok kanan atas layar utama.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (mounted) {
                  context.pop(); // Go back to dashboard
                }
              },
              child: const Text('Mengerti'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) {
                  context.pushReplacement('/safety');
                }
              },
              child: const Text('Buka Safety Card'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _q1Controller.dispose();
    _q2Controller.dispose();
    _q3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Lite'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bagaimana perasaan Anda hari ini?',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // P2-04: Mood historical context + sparkline
              _buildMoodContext(theme),
              const SizedBox(height: 16),

              // Mood Emojis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _moods.map((mood) {
                  final score = mood['score'] as int;
                  final isSelected = _selectedMood == score;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: 'Mood: ${mood['label']}',
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMood = score;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood['emoji'] as String,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood['label'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Keyword Tag field
              const Text(
                '1 Kata Kunci Hari Ini (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _keywordController,
                decoration: InputDecoration(
                  hintText: 'Misal: bersyukur, lelah, produktif, santai',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.tag_rounded),
                ),
                maxLength: 20,
              ),
              const SizedBox(height: 16),

              // Switch for Deep Reflection
              SwitchListTile(
                value: _showDeepReflection,
                onChanged: (val) {
                  setState(() {
                    _showDeepReflection = val;
                  });
                },
                title: const Text('Refleksi Mendalam (Opsional) ✍️'),
                subtitle: const Text('Jawab 3 pertanyaan reflektif untuk kesehatan emosional.'),
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),

              if (_showDeepReflection) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apa yang paling menyita pikiran Anda hari ini?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _q1Controller,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Tuliskan unek-unek atau fokus pikiran Anda...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (v) => _showDeepReflection && (v == null || v.trim().isEmpty) ? 'Harap isi kolom ini' : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Bagaimana Anda merespons hal tersebut?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _q2Controller,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Tindakan atau sikap mental yang Anda ambil...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (v) => _showDeepReflection && (v == null || v.trim().isEmpty) ? 'Harap isi kolom ini' : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Tuliskan 1 hal kecil yang Anda syukuri hari ini.',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            'Kesehatan 🍎',
                            'Cuaca Cerah ☀️',
                            'Keluarga 🏠',
                            'Makanan Enak 🍲',
                            'Istirahat Cukup 🛌',
                          ].map((s) {
                            return ActionChip(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              label: Text(s, style: const TextStyle(fontSize: 10)),
                              onPressed: () {
                                final current = _q3Controller.text.trim();
                                if (current.isEmpty) {
                                  _q3Controller.text = s;
                                } else {
                                  _q3Controller.text = '$current, $s';
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _q3Controller,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Misal: Secangkir kopi hangat, senyum rekan kerja...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (v) => _showDeepReflection && (v == null || v.trim().isEmpty) ? 'Harap isi kolom ini' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Save Button
              ElevatedButton(
                onPressed: _saveJournalEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(88, 52), // WCAG touch target
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Jurnal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
