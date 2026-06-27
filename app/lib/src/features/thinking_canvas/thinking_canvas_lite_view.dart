import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;

class ThinkingCanvasLiteView extends ConsumerStatefulWidget {
  const ThinkingCanvasLiteView({super.key});

  @override
  ConsumerState<ThinkingCanvasLiteView> createState() => _ThinkingCanvasLiteViewState();
}

class _ThinkingCanvasLiteViewState extends ConsumerState<ThinkingCanvasLiteView> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _summaryController = TextEditingController();
  final _actionController = TextEditingController();
  final _refController = TextEditingController();

  String _selectedMethod = 'MindDump';
  bool _addToHabits = false;

  final List<Map<String, String>> _methods = [
    {'key': 'MindDump', 'name': 'Mind Dump', 'desc': 'Keluarkan semua beban pikiran tanpa diedit.'},
    {'key': 'PMI', 'name': 'PMI (Plus, Minus, Interesting)', 'desc': 'Timbang keputusan berdasarkan kelebihan, kekurangan, dan poin menarik.'},
    {'key': 'ReverseBrainstorming', 'name': 'Reverse Brainstorming', 'desc': 'Pikirkan cara memperburuk masalah, lalu balikkan solusinya.'},
    {'key': 'Scoring', 'name': 'Skoring Ide', 'desc': 'Nilai opsi ide berdasarkan dampak & tingkat kesulitan.'},
    {'key': 'Validation', 'name': 'Validasi Asumsi', 'desc': 'Uji kebenaran asumsi Anda sebelum mengambil keputusan.'},
  ];

  Future<void> _saveCanvasSession() async {
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(dbProvider);
    final now = DateTime.now();

    // Get user id
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return;
    final userId = profiles.first.userId;

    final sessionId = const Uuid().v4();
    String? createdHabitId;

    final actionText = _actionController.text.trim();

    // If user checked "Add to Habits", insert a new habit in the Body domain
    if (_addToHabits && actionText.isNotEmpty) {
      createdHabitId = const Uuid().v4();
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: createdHabitId,
              userId: userId,
              domainTag: const drift.Value('Tubuh'),
              title: actionText,
              status: const drift.Value('Active'),
              frequency: const drift.Value('Daily'),
              initiationFriction: const drift.Value(2), // low friction default for next action steps
              originalFriction: const drift.Value(2),
              energyCost: const drift.Value(2),
              impactScore: const drift.Value(4),
              createdAt: now,
            ),
          );

      await db.into(db.reminderPreferences).insert(
            ReminderPreferencesCompanion.insert(habitId: createdHabitId),
          );
    }

    final newSession = ThinkingCanvasSessionsCompanion.insert(
      sessionId: sessionId,
      userId: userId,
      methodKey: _selectedMethod,
      topic: drift.Value(_topicController.text.trim().isEmpty ? null : _topicController.text.trim()),
      summaryText: drift.Value(_summaryController.text.trim().isEmpty ? null : _summaryController.text.trim()),
      nextAction: drift.Value(actionText.isEmpty ? null : actionText),
      paperArtifactRef: drift.Value(_refController.text.trim().isEmpty ? null : _refController.text.trim()),
      paperSession: const drift.Value(true),
      linkedHabitId: drift.Value(createdHabitId),
      createdAt: now,
    );

    await db.into(db.thinkingCanvasSessions).insert(newSession);

    ref.invalidate(dashboardDataProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi Thinking Canvas berhasil dicatat!'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUsage();
    });
  }

  Future<void> _checkFirstTimeUsage() async {
    final db = ref.read(dbProvider);
    final sessions = await db.select(db.thinkingCanvasSessions).get();
    if (sessions.isEmpty && mounted) {
      _showOnboardingGuide();
    }
  }

  void _showOnboardingGuide() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _ThinkingCanvasOnboardingDialog(
          onMethodSelected: (method) {
            setState(() {
              _selectedMethod = method;
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _summaryController.dispose();
    _actionController.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thinking Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Panduan Metode',
            onPressed: _showOnboardingGuide,
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
                'Urai Pikiran Anda di Kertas 📝',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Prinsip LifeTree: Paper-First. Tulislah coretan Anda di buku atau kertas asli terlebih dahulu untuk mengurangi screen fatigue.',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),

              // Method Selector
              const Text('1. Pilih Metode Berpikir', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMethod = val);
                },
                items: _methods.map((m) {
                  return DropdownMenuItem<String>(
                    value: m['key'],
                    child: Text(m['name']!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                _methods.firstWhere((m) => m['key'] == _selectedMethod)['desc']!,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: theme.colorScheme.onBackground.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),

              // Topic
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(
                  labelText: '2. Topik / Masalah yang Sedang Dipikirkan',
                  hintText: 'Misal: Memilih opsi karir baru atau mengurai burnout',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Paper Artifact Ref
              TextFormField(
                controller: _refController,
                decoration: InputDecoration(
                  labelText: '3. Referensi Kertas Fisik (Opsional)',
                  hintText: 'Misal: Buku Jurnal A hal. 14, Sticky note meja kerja',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                ),
              ),
              const SizedBox(height: 24),

              // Summary
              TextFormField(
                controller: _summaryController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: '4. Ringkasan Hasil Berpikir',
                  hintText: 'Tuliskan poin penting dari coretan kertas Anda di sini...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harap masukkan ringkasan hasil berpikir Anda';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Next Action
              TextFormField(
                controller: _actionController,
                decoration: InputDecoration(
                  labelText: '5. Satu Aksi Kecil Berikutnya (Next Small Step)',
                  hintText: 'Aksi sangat kecil, misal: Cari info kontak dokter olahraga',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harap tentukan satu aksi kecil berikutnya';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Checkbox to automatically add to habits
              Row(
                children: [
                  Checkbox(
                    value: _addToHabits,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      setState(() {
                        _addToHabits = val ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Masukkan aksi kecil ini ke daftar kebiasaan hari ini',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveCanvasSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(88, 52), // WCAG touch target
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Sesi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThinkingCanvasOnboardingDialog extends StatefulWidget {
  final ValueChanged<String> onMethodSelected;
  const _ThinkingCanvasOnboardingDialog({required this.onMethodSelected});

  @override
  State<_ThinkingCanvasOnboardingDialog> createState() => _ThinkingCanvasOnboardingDialogState();
}

class _ThinkingCanvasOnboardingDialogState extends State<_ThinkingCanvasOnboardingDialog> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  String _tempSelectedMethod = 'MindDump';

  final List<Map<String, String>> _steps = [
    {
      'title': '1. Ambil Kertas Fisik 📝',
      'desc': 'Prinsip LifeTree adalah Paper-First. Jauhkan layar Anda sejenak. Ambillah buku catatan, pulpen, atau kertas coretan kosong.',
    },
    {
      'title': '2. Pilih Metode Berpikir 🧠',
      'desc': 'Kami mendukung 5 metode kognitif: Mind Dump (menguras pikiran), PMI (skoring opsi), Reverse Brainstorming (membalik masalah), dan lainnya.',
    },
    {
      'title': '3. Corat-Coret Tanpa Gangguan ✍️',
      'desc': 'Tuliskan ide, buat bagan, buat mind map, atau corat-coret sesuka Anda secara offline. Kurangi screen fatigue dan ketegangan mental.',
    },
    {
      'title': '4. Ringkas & Aksi Kecil 🌳',
      'desc': 'Kembali ke aplikasi setelah selesai untuk mendokumentasikan intisari coretan Anda, serta pilih "Aksi Kecil Berikutnya" untuk langsung dikerjakan.',
    },
  ];

  Widget _buildInteractiveStateButton({
    required String label,
    required String methodKey,
    required ThemeData theme,
  }) {
    final isSelected = _tempSelectedMethod == methodKey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _tempSelectedMethod = methodKey;
          });
          widget.onMethodSelected(methodKey);
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          backgroundColor: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.12),
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 320,
        height: 420,
        child: Column(
          children: [
            Text(
              'Panduan: Thinking Canvas 💡',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        step['title']!,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (index == 1) ...[
                        const Text(
                          'Apa yang Anda rasakan saat ini?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildInteractiveStateButton(
                                  label: '🤯 Pikiran Penuh / Cemas',
                                  methodKey: 'MindDump',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '⚖️ Timbang Pilihan / Ragu',
                                  methodKey: 'PMI',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🧗 Buntu / Sulit Solusi',
                                  methodKey: 'ReverseBrainstorming',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '💡 Banyak Ide / Bingung',
                                  methodKey: 'Scoring',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🔍 Ingin Uji Asumsi',
                                  methodKey: 'Validation',
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          step['desc']!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Sebelumnya'),
                  )
                else
                  const SizedBox(width: 88),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _steps.length - 1) {
                      Navigator.pop(context);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(_currentPage == _steps.length - 1 ? 'Mengerti' : 'Lanjut'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
