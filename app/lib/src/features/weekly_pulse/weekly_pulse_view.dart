import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;

class WeeklyPulseView extends ConsumerStatefulWidget {
  const WeeklyPulseView({super.key});

  @override
  ConsumerState<WeeklyPulseView> createState() => _WeeklyPulseViewState();
}

class _WeeklyPulseViewState extends ConsumerState<WeeklyPulseView> {
  final List<int?> _answers = List.filled(5, null);
  final _reflectionController = TextEditingController();
  bool _isSaving = false;

  final List<String> _questions = [
    'Saya merasa ceria dan bersemangat',
    'Saya merasa tenang dan rileks',
    'Saya merasa aktif dan penuh vitalitas',
    'Saya bangun tidur dengan perasaan segar dan istirahat yang cukup',
    'Kehidupan sehari-hari saya dipenuhi dengan hal-hal yang menarik bagi saya'
  ];

  final List<Map<String, dynamic>> _options = [
    {'value': 5, 'label': 'Sepanjang waktu'},
    {'value': 4, 'label': 'Sebagian besar waktu'},
    {'value': 3, 'label': 'Lebih dari separuh waktu'},
    {'value': 2, 'label': 'Kurang dari separuh waktu'},
    {'value': 1, 'label': 'Sesekali'},
    {'value': 0, 'label': 'Tidak pernah'},
  ];

  Future<void> _submitPulse() async {
    if (_answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap jawab semua 5 pertanyaan sebelum mengirim.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final db = ref.read(dbProvider);

    try {
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception('Profil pengguna tidak ditemukan');
      final userId = profiles.first.userId;

      // 1. Calculate WHO-5 scores
      final totalRawScore = _answers.reduce((value, element) => value! + element!)!;
      // Map 0-25 range to SQLite 1-10 range for score column constraint
      final mappedScore = (totalRawScore / 2.5).round().clamp(1, 10);
      final percentage = totalRawScore * 4; // 0-100%

      // 2. Prepare JSON reflection text
      final metadata = {
        'raw_total': totalRawScore,
        'percentage': percentage,
        'answers': _answers,
        'user_reflection': _reflectionController.text.trim(),
      };

      // 3. Write into database
      final now = DateTime.now();
      final mondayOffset = now.weekday - DateTime.monday;
      final weekStartDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: mondayOffset));

      await db.into(db.weeklyPulses).insert(
            WeeklyPulsesCompanion.insert(
              pulseId: const Uuid().v4(),
              userId: userId,
              domainTag: 'WHO-5',
              score: mappedScore,
              reflectionText: drift.Value(jsonEncode(metadata)),
              weekStartDate: weekStartDate,
            ),
          );

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        // Show wellness review prompt if WHO-5 is low (< 50%)
        final isLowMood = percentage < 50;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isLowMood ? 'Refleksi Diri 🌱' : 'Luar Biasa! ✨'),
              content: Text(
                isLowMood
                    ? 'Skor kesejahteraan emosional Anda berada di angka $percentage%. Minggu ini mungkin terasa berat. Beristirahatlah sejenak dan pertimbangkan untuk mengaktifkan Recovery Mode.'
                    : 'Skor kesejahteraan emosional Anda sangat baik ($percentage%). Pertahankan konsistensi pertumbuhan pohon Anda minggu depan!',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    context.go('/'); // Back to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Kembali ke Dashboard'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan Weekly Pulse: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Pulse Check'),
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyimpan hasil refleksi mingguan...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Heading card
                  Card(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'WHO-5 Well-Being Index 📋',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Jawablah sejujur mungkin berdasarkan apa yang Anda rasakan selama 2 minggu terakhir.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Questions list
                  ...List.generate(_questions.length, (qIndex) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pertanyaan ${qIndex + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _questions[qIndex],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Divider(height: 24),
                            // Options columns
                            Column(
                              children: _options.map((opt) {
                                final isSelected = _answers[qIndex] == opt['value'];
                                return RadioListTile<int>(
                                  value: opt['value'] as int,
                                  groupValue: _answers[qIndex],
                                  onChanged: (val) {
                                    setState(() {
                                      _answers[qIndex] = val;
                                    });
                                  },
                                  title: Text(
                                    opt['label'] as String,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  dense: true,
                                  activeColor: theme.colorScheme.primary,
                                  selected: isSelected,
                                  contentPadding: EdgeInsets.zero,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Subjective Reflection textarea
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Refleksi Diri (Opsional) ✍️',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _reflectionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Tuliskan catatan refleksi mingguan Anda, apa hambatan terbesar Anda, atau hal yang paling disyukuri...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _submitPulse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(88, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Kirim Evaluasi Mingguan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
