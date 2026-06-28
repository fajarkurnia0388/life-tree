import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;

// Stream provider to automatically watch decisions in database
final decisionListProvider = StreamProvider<List<DecisionEntry>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.decisionEntries)
        ..orderBy([(tbl) => drift.OrderingTerm(expression: tbl.decisionDate, mode: drift.OrderingMode.desc)]))
      .watch();
});

class DecisionJournalView extends ConsumerStatefulWidget {
  const DecisionJournalView({super.key});

  @override
  ConsumerState<DecisionJournalView> createState() => _DecisionJournalViewState();
}

class _DecisionJournalViewState extends ConsumerState<DecisionJournalView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateDecisionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _CreateDecisionSheet();
      },
    ).then((_) {
      ref.invalidate(decisionListProvider);
    });
  }

  void _showReviewDecisionDialog(BuildContext context, DecisionEntry decision) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ReviewDecisionSheet(decision: decision);
      },
    ).then((_) {
      ref.invalidate(decisionListProvider);
      ref.invalidate(dashboardDataProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decisionsAsync = ref.watch(decisionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision Journal ⚖️'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Menunggu Review'),
            Tab(text: 'Sudah Ditinjau'),
          ],
        ),
      ),
      body: decisionsAsync.when(
        data: (decisions) {
          final pending = decisions.where((d) => !d.isReviewed).toList();
          final reviewed = decisions.where((d) => d.isReviewed).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDecisionList(context, pending, isPending: true),
              _buildDecisionList(context, reviewed, isPending: false),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat jurnal: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDecisionDialog(context),
        label: const Text('Catat Keputusan'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildDecisionList(BuildContext context, List<DecisionEntry> list, {required bool isPending}) {
    final theme = Theme.of(context);

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPending ? '⚖️✨' : '📝✅',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                isPending
                    ? 'Tidak ada keputusan yang menunggu review.'
                    : 'Belum ada keputusan yang selesai ditinjau.',
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final d = list[index];
        final isOverdue = !d.isReviewed && DateTime.now().isAfter(d.reviewDate);

        // Parse JSON options & assumptions
        List<String> options = [];
        List<String> assumptions = [];
        try {
          options = List<String>.from(jsonDecode(d.options));
          assumptions = List<String>.from(jsonDecode(d.assumptions));
        } catch (_) {}

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isOverdue
                  ? theme.colorScheme.error.withValues(alpha: 0.4)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
              width: isOverdue ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        d.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'JATUH TEMPO REVIEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  d.description,
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                const Divider(height: 24),
                
                // Options choice
                if (options.length >= 2) ...[
                  const Text('Pilihan yang Dipertimbangkan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('⚖️ Opsi A: ${options[0]}', style: const TextStyle(fontSize: 12)),
                  Text('⚖️ Opsi B: ${options[1]}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                ],

                // Assumptions
                if (assumptions.isNotEmpty) ...[
                  const Text('Asumsi/Keyakinan Utama:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  ...assumptions.map((asm) => Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 2.0),
                        child: Text('• $asm', style: const TextStyle(fontSize: 12)),
                      )),
                  const SizedBox(height: 12),
                ],

                // Expectations
                const Text('Ekspektasi Hasil:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(d.expectations, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),

                // Review date & info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Keputusan: ${_formatDate(d.decisionDate)}',
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                        Text(
                          'Tanggal Review: ${_formatDate(d.reviewDate)} (${d.reviewPeriodDays} hari)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    if (isPending)
                      ElevatedButton(
                        onPressed: () => _showReviewDecisionDialog(context, d),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOverdue ? theme.colorScheme.error : theme.colorScheme.primary,
                          foregroundColor: isOverdue ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(100, 36),
                        ),
                        child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),

                // If reviewed, show reflections
                if (!isPending && d.reviewReflection != null) ...[
                  const Divider(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('📝', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Hasil & Refleksi 90 Hari:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.reviewReflection!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Bottom sheet for creating a decision
class _CreateDecisionSheet extends ConsumerStatefulWidget {
  const _CreateDecisionSheet();

  @override
  ConsumerState<_CreateDecisionSheet> createState() => _CreateDecisionSheetState();
}

class _CreateDecisionSheetState extends ConsumerState<_CreateDecisionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _expectationsController = TextEditingController();
  final List<TextEditingController> _assumptionsControllers = [];

  bool _isSaving = false;
  int _reviewPeriodDays = 90;

  @override
  void initState() {
    super.initState();
    // Start with 2 assumption fields
    _assumptionsControllers.add(TextEditingController(text: 'Pilihan ini akan menghemat energi harian saya'));
    _assumptionsControllers.add(TextEditingController(text: 'Hasil positif akan terlihat dalam waktu singkat'));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _optAController.dispose();
    _optBController.dispose();
    _expectationsController.dispose();
    for (var c in _assumptionsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addAssumptionField() {
    setState(() {
      _assumptionsControllers.add(TextEditingController());
    });
  }

  void _removeAssumptionField(int index) {
    setState(() {
      _assumptionsControllers[index].dispose();
      _assumptionsControllers.removeAt(index);
    });
  }

  void _loadTemplate(String type) {
    setState(() {
      for (var c in _assumptionsControllers) {
        c.dispose();
      }
      _assumptionsControllers.clear();

      if (type == 'mobil') {
        _titleController.text = 'Beli Mobil vs Taksi Online';
        _descController.text = 'Menimbang kebutuhan transportasi untuk mobilitas harian ke kantor.';
        _optAController.text = 'Beli Mobil Pribadi';
        _optBController.text = 'Langganan Taksi Online';
        _expectationsController.text = 'Mengurangi kelelahan perjalanan harian dan pengeluaran tetap bulanan di bawah Rp 3 Juta.';
        _assumptionsControllers.addAll([
          TextEditingController(text: 'Menggunakan mobil pribadi menghemat waktu perjalanan harian'),
          TextEditingController(text: 'Biaya maintenance mobil pribadi lebih rendah dibanding pengeluaran taksi'),
          TextEditingController(text: 'Mobil pribadi memberikan kenyamanan lebih tinggi'),
        ]);
        _reviewPeriodDays = 30; // tactical
      } else if (type == 'bootcamp') {
        _titleController.text = 'Coding Bootcamp vs Belajar Otodidak';
        _descController.text = 'Menimbang cara belajar software engineering untuk transisi karir.';
        _optAController.text = 'Ikut Coding Bootcamp';
        _optBController.text = 'Belajar Otodidak';
        _expectationsController.text = 'Mendapatkan pekerjaan pertama sebagai developer dalam waktu 6 bulan.';
        _assumptionsControllers.addAll([
          TextEditingController(text: 'Bootcamp memberikan kurikulum terstruktur dan networking cepat'),
          TextEditingController(text: 'Biaya bootcamp yang mahal sebanding dengan waktu dapat kerja'),
          TextEditingController(text: 'Belajar otodidak butuh waktu 2x lebih lama'),
        ]);
        _reviewPeriodDays = 90; // strategic
      }
    });
  }

  Future<void> _saveDecision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final db = ref.read(dbProvider);

    try {
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception('Profil pengguna tidak ditemukan');
      final userId = profiles.first.userId;

      final now = DateTime.now();
      final reviewDate = now.add(Duration(days: _reviewPeriodDays));

      final optionsList = [_optAController.text.trim(), _optBController.text.trim()];
      final assumptionsList = _assumptionsControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await db.into(db.decisionEntries).insert(
            DecisionEntriesCompanion.insert(
              decisionId: const Uuid().v4(),
              userId: userId,
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              options: jsonEncode(optionsList),
              assumptions: jsonEncode(assumptionsList),
              expectations: _expectationsController.text.trim(),
              decisionDate: now,
              reviewDate: reviewDate,
              reviewPeriodDays: drift.Value(_reviewPeriodDays),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Keputusan berhasil dicatat! Review dijadwalkan dalam $_reviewPeriodDays hari.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan keputusan: $e'), backgroundColor: Colors.red),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catat Keputusan Baru ⚖️',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Quick mock templates
              const Text('Gunakan Contoh Template:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.directions_car_rounded, size: 14),
                    label: const Text('Beli Mobil vs Taksi 🚗', style: TextStyle(fontSize: 10)),
                    onPressed: () => _loadTemplate('mobil'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.code_rounded, size: 14),
                    label: const Text('Bootcamp vs Otodidak 💻', style: TextStyle(fontSize: 10)),
                    onPressed: () => _loadTemplate('bootcamp'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Keputusan',
                  hintText: 'Misal: Membeli mobil baru atau langganan taksi online',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Harap isi judul keputusan' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Konteks & Deskripsi',
                  hintText: 'Tuliskan detail latar belakang kenapa keputusan ini sulit...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Harap isi deskripsi konteks' : null,
              ),
              const SizedBox(height: 16),

              // Option A & B
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _optAController,
                      decoration: InputDecoration(
                        labelText: 'Opsi A',
                        hintText: 'Misal: Beli Mobil',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Isi Opsi A' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _optBController,
                      decoration: InputDecoration(
                        labelText: 'Opsi B',
                        hintText: 'Misal: Taksi Online',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Isi Opsi B' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Assumptions list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Asumsi & Keyakinan Utama:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  TextButton.icon(
                    onPressed: _addAssumptionField,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah Asumsi', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...List.generate(_assumptionsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _assumptionsControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Asumsi ${index + 1}',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Harap isi asumsi' : null,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeAssumptionField(index),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Review Period Days Selection
              const Text(
                'Tenggat Waktu Peninjauan (Review Period):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 Hari (Tes)')),
                  ButtonSegment(value: 30, label: Text('30 Hari (Taktis)')),
                  ButtonSegment(value: 90, label: Text('90 Hari (Strategis)')),
                ],
                selected: {_reviewPeriodDays},
                onSelectionChanged: (selection) {
                  setState(() {
                    _reviewPeriodDays = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Expectations
              TextFormField(
                controller: _expectationsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Ekspektasi Hasil Akhir (Hasil 90 Hari)',
                  hintText: 'Misal: Saya berharap bisa menghemat Rp 1.5jt per bulan dan tidak lelah menyetir...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Harap isi ekspektasi Anda' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveDecision,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(88, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Keputusan & Mulai 90 Hari',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom sheet for reviewing a decision
class _ReviewDecisionSheet extends StatefulWidget {
  final DecisionEntry decision;

  const _ReviewDecisionSheet({required this.decision});

  @override
  State<_ReviewDecisionSheet> createState() => _ReviewDecisionSheetState();
}

class _ReviewDecisionSheetState extends State<_ReviewDecisionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reflectionController = TextEditingController();
  bool _isSaving = false;

  Future<void> _submitReview(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final db = ref.read(dbProvider);

    try {
      await (db.update(db.decisionEntries)..where((tbl) => tbl.decisionId.equals(widget.decision.decisionId)))
          .write(
        DecisionEntriesCompanion(
          isReviewed: const drift.Value(true),
          reviewReflection: drift.Value(_reflectionController.text.trim()),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review keputusan berhasil disimpan! Terima kasih telah berefleksi.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan review: $e'), backgroundColor: Colors.red),
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

    // Parse options & assumptions
    List<String> options = [];
    List<String> assumptions = [];
    try {
      options = List<String>.from(jsonDecode(widget.decision.options));
      assumptions = List<String>.from(jsonDecode(widget.decision.assumptions));
    } catch (_) {}

    return Consumer(
      builder: (context, ref, child) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Review Hasil Keputusan 📝',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Recap Info
                  Text(
                    widget.decision.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.decision.description,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 12),

                  if (options.length >= 2) ...[
                    Text('Pilihan: Opsi A (${options[0]}) vs Opsi B (${options[1]})', style: const TextStyle(fontSize: 11)),
                  ],
                  const SizedBox(height: 12),

                  // Recall Assumptions
                  if (assumptions.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ingat kembali asumsi awal Anda:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          ...assumptions.map((asm) => Text('• $asm', style: const TextStyle(fontSize: 11))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Expectations comparison
                  Text(
                    'Ekspektasi awal: "${widget.decision.expectations}"',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),

                  // Reflection field
                  TextFormField(
                    controller: _reflectionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Refleksi Nyata (Setelah 90 Hari)',
                      hintText: 'Bagaimana realitas sebenarnya? Apakah asumsi awal Anda terbukti benar? Opsi mana yang akhirnya Anda pilih, dan apakah ekspektasi Anda tercapai?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Harap isi catatan refleksi hasil nyata' : null,
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => _submitReview(ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(88, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan & Selesaikan Peninjauan',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
