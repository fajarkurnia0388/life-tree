import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../cultivation/cultivation_provider.dart';
import '../cultivation/cultivation_strings.dart';
import '../dashboard/dashboard_provider.dart';
import '../../core/widgets/loading_state_widget.dart';

final _moodHistoryProvider = StreamProvider<List<JournalEntry>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.journalEntries)
        ..orderBy([
          (tbl) => drift.OrderingTerm(
            expression: tbl.date,
            mode: drift.OrderingMode.desc,
          ),
        ])
        ..limit(30))
      .watch();
});

final _decisionSummaryProvider = StreamProvider<Map<String, int>>((ref) {
  final db = ref.watch(dbProvider);
  return db.select(db.decisionEntries).watch().map((list) {
    final now = DateTime.now();
    final pending = list.where((d) => !d.isReviewed).length;
    final overdue = list
        .where((d) => !d.isReviewed && now.isAfter(d.reviewDate))
        .length;
    return {'pending': pending, 'overdue': overdue};
  });
});

final _todayMoodProvider = FutureProvider.autoDispose<int?>((ref) async {
  final db = ref.watch(dbProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final profiles = await db.select(db.userProfiles).get();
  if (profiles.isEmpty) return null;
  final existing =
      await (db.select(db.journalEntries)..where(
            (tbl) =>
                tbl.userId.equals(profiles.first.userId) &
                tbl.date.equals(todayStart),
          ))
          .get();
  return existing.isEmpty ? null : existing.first.moodScore;
});

class JournalDashboardTab extends ConsumerStatefulWidget {
  const JournalDashboardTab({super.key});

  @override
  ConsumerState<JournalDashboardTab> createState() =>
      _JournalDashboardTabState();
}

class _JournalDashboardTabState extends ConsumerState<JournalDashboardTab> {
  int? _selectedMoodOverride;

  final List<Map<String, dynamic>> _moods = [
    {'score': 1, 'emoji': '😢', 'label': 'Sangat Buruk'},
    {'score': 2, 'emoji': '🙁', 'label': 'Buruk'},
    {'score': 3, 'emoji': '😐', 'label': 'Biasa Saja'},
    {'score': 4, 'emoji': '🙂', 'label': 'Baik'},
    {'score': 5, 'emoji': '😀', 'label': 'Sangat Baik'},
  ];

  Future<void> _saveMood(int score) async {
    setState(() {
      _selectedMoodOverride = score;
    });

    final db = ref.read(dbProvider);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final existing =
        await (db.select(db.journalEntries)..where(
              (tbl) => tbl.userId.equals(userId) & tbl.date.equals(todayStart),
            ))
            .get();

    if (existing.isNotEmpty) {
      await (db.update(db.journalEntries)
            ..where((tbl) => tbl.entryId.equals(existing.first.entryId)))
          .write(JournalEntriesCompanion(moodScore: drift.Value(score)));
    } else {
      await db
          .into(db.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              entryId: const Uuid().v4(),
              userId: userId,
              date: todayStart,
              moodScore: score,
              entryType: const drift.Value('Lite'),
              createdAt: now,
            ),
          );
    }

    ref.invalidate(_todayMoodProvider);
    ref.invalidate(_moodHistoryProvider);
    ref.invalidate(dashboardDataProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mood berhasil disimpan: ${_moods.firstWhere((m) => m['score'] == score)['label']}',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: themeColorForMood(score),
        ),
      );
    }
  }

  Color themeColorForMood(int score) {
    switch (score) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.blueGrey;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);
    final moodHistoryAsync = ref.watch(_moodHistoryProvider);
    final decisionSummaryAsync = ref.watch(_decisionSummaryProvider);
    final todayMoodAsync = ref.watch(_todayMoodProvider);
    final currentMood = _selectedMoodOverride ?? todayMoodAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(CultivationStrings.journalTitle(languageLevel)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overdue Decision Alert Banner
            if (decisionSummaryAsync.valueOrNull?['overdue'] != null &&
                decisionSummaryAsync.valueOrNull!['overdue']! > 0) ...[
              Card(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '⚠️',
                            style: TextStyle(
                              fontSize: 32,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Review Jurnal Keputusan!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Beberapa keputusan sulit Anda telah melewati batas waktu. Mari luangkan waktu untuk meninjau hasilnya secara jujur.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => context.push('/decision-journal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              minimumSize: const Size(120, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Tinjau Sekarang',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 1. Mood Check-in Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bagaimana perasaan Anda hari ini?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _moods.map((m) {
                        final score = m['score'] as int;
                        final isSelected = currentMood == score;
                        return InkWell(
                          onTap: () => _saveMood(score),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    )
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  m['emoji'] as String,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/journal').then((_) {
                        ref.invalidate(_todayMoodProvider);
                        ref.invalidate(_moodHistoryProvider);
                      }),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: Text(
                        CultivationStrings.journalDeep(languageLevel),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Decision Journal Shortcut Card
            decisionSummaryAsync.when(
              data: (summary) {
                final pending = summary['pending'] ?? 0;
                final overdue = summary['overdue'] ?? 0;

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.balance_rounded,
                        color: Colors.amber,
                      ),
                    ),
                    title: Text(
                      '${CultivationStrings.decisionJournalTitle(languageLevel)} ⚖️',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        overdue > 0
                            ? 'Ada $overdue keputusan jatuh tempo untuk ditinjau!'
                            : '$pending keputusan aktif terdaftar.',
                        style: TextStyle(
                          fontSize: 12,
                          color: overdue > 0
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                          fontWeight: overdue > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/decision-journal'),
                  ),
                );
              },
              loading: () => SizedBox(
                height: 80,
                child: Center(child: LoadingStateWidget(message: 'Memuat keputusan...')),
              ),
              error: (_, _) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // 3. Mood History 30 Days Title
            Text(
              'Riwayat Mood & Refleksi Harian',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            moodHistoryAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Belum ada riwayat jurnal. Mulai catat mood pertama Anda hari ini! 🌱',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final dateStr =
                        '${item.date.day}/${item.date.month}/${item.date.year}';
                    final moodItem = _moods.firstWhere(
                      (m) => m['score'] == item.moodScore,
                      orElse: () => {'emoji': '😐', 'label': 'Biasa'},
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Text(
                          moodItem['emoji'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          item.keyword ?? moodItem['label'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.entryType == 'Deep'
                              ? 'Refleksi Mendalam • $dateStr'
                              : 'Lite Check-in • $dateStr',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        trailing: item.entryType == 'Deep'
                            ? Icon(
                                Icons.arrow_right_alt_rounded,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: item.entryType == 'Deep'
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Text('Refleksi $dateStr'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            'Mood: ${moodItem['emoji']} ${moodItem['label']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Divider(height: 20),
                                          if (item.textContent != null) ...[
                                            Text(
                                              item.textContent!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                          ],
                                          if (item.gratitudeText != null) ...[
                                            Text(
                                              'Gratitude: ${item.gratitudeText!}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Tutup'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => LoadingStateWidget(message: 'Memuat riwayat mood...'),
              error: (err, _) => Text('Gagal memuat riwayat: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
