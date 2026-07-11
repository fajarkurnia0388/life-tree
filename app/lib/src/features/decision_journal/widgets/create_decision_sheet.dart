import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../services/decision_journal_service.dart';
import '../../../core/theme/button_theme.dart';

class CreateDecisionSheet extends ConsumerStatefulWidget {
  const CreateDecisionSheet({super.key});

  @override
  ConsumerState<CreateDecisionSheet> createState() =>
      _CreateDecisionSheetState();
}

class _CreateDecisionSheetState extends ConsumerState<CreateDecisionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _optAController = TextEditingController();
  final _optBController = TextEditingController();
  final _expectationsController = TextEditingController();
  final List<TextEditingController> _assumptionsControllers = [];

  bool _isSaving = false;
  int _reviewPeriodDays = 90;
  int _confidenceScore = 80;

  @override
  void initState() {
    super.initState();
    _assumptionsControllers.add(
      TextEditingController(
        text: 'Pilihan ini akan menghemat energi harian saya',
      ),
    );
    _assumptionsControllers.add(
      TextEditingController(
        text: 'Hasil positif akan terlihat dalam waktu singkat',
      ),
    );
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
        _descController.text =
            'Menimbang kebutuhan transportasi untuk mobilitas harian ke kantor.';
        _optAController.text = 'Beli Mobil Pribadi';
        _optBController.text = 'Langganan Taksi Online';
        _expectationsController.text =
            'Mengurangi kelelahan perjalanan harian dan pengeluaran tetap bulanan di bawah Rp 3 Juta.';
        _assumptionsControllers.addAll([
          TextEditingController(
            text: 'Menggunakan mobil pribadi menghemat waktu perjalanan harian',
          ),
          TextEditingController(
            text:
                'Biaya maintenance mobil pribadi lebih rendah dibanding pengeluaran taksi',
          ),
          TextEditingController(
            text: 'Mobil pribadi memberikan kenyamanan lebih tinggi',
          ),
        ]);
        _reviewPeriodDays = 30;
      } else if (type == 'bootcamp') {
        _titleController.text = 'Coding Bootcamp vs Belajar Otodidak';
        _descController.text =
            'Menimbang cara belajar software engineering untuk transisi karir.';
        _optAController.text = 'Ikut Coding Bootcamp';
        _optBController.text = 'Belajar Otodidak';
        _expectationsController.text =
            'Mendapatkan pekerjaan pertama sebagai developer dalam waktu 6 bulan.';
        _assumptionsControllers.addAll([
          TextEditingController(
            text:
                'Bootcamp memberikan kurikulum terstruktur dan networking cepat',
          ),
          TextEditingController(
            text:
                'Biaya bootcamp yang mahal sebanding dengan waktu dapat kerja',
          ),
          TextEditingController(
            text: 'Belajar otodidak butuh waktu 2x lebih lama',
          ),
        ]);
        _reviewPeriodDays = 90;
      }
    });
  }

  Future<void> _saveDecision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) throw Exception('Profil pengguna tidak ditemukan');

      final now = DateTime.now();
      final reviewDate = now.add(Duration(days: _reviewPeriodDays));

      final optionsList = [
        _optAController.text.trim(),
        _optBController.text.trim(),
      ];
      final assumptionsList = _assumptionsControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await ref.read(decisionJournalServiceProvider).createDecisionEntry(
            userId: userId,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            options: jsonEncode(optionsList),
            assumptions: jsonEncode(assumptionsList),
            expectations: _expectationsController.text.trim(),
            reviewDate: reviewDate,
            reviewPeriodDays: _reviewPeriodDays,
            confidenceScore: _confidenceScore,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Keputusan berhasil dicatat! Review dijadwalkan dalam $_reviewPeriodDays hari.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan keputusan: $e'),
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
                    tooltip: 'Tutup',
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Gunakan Contoh Template:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.directions_car_rounded, size: 14),
                    label: const Text(
                      'Beli Mobil vs Taksi 🚗',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => _loadTemplate('mobil'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.code_rounded, size: 14),
                    label: const Text(
                      'Bootcamp vs Otodidak 💻',
                      style: TextStyle(fontSize: 10),
                    ),
                    onPressed: () => _loadTemplate('bootcamp'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Judul Keputusan',
                  hintText:
                      'Misal: Membeli mobil baru atau langganan taksi online',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Harap isi judul keputusan'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Konteks & Deskripsi',
                  hintText:
                      'Tuliskan detail latar belakang kenapa keputusan ini sulit...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Harap isi deskripsi konteks'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _optAController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Opsi A',
                        hintText: 'Misal: Beli Mobil',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Isi Opsi A' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _optBController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Opsi B',
                        hintText: 'Misal: Taksi Online',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Isi Opsi B' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                    label: const Text(
                      'Tambah Asumsi',
                      style: TextStyle(fontSize: 12),
                    ),
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            hintText: 'Asumsi ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Harap isi asumsi'
                              : null,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeAssumptionField(index),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'Hapus asumsi',
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tingkat Keyakinan (Confidence Level):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    '$_confidenceScore%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _confidenceScore.toDouble(),
                min: 0.0,
                max: 100.0,
                divisions: 20,
                label: '$_confidenceScore%',
                onChanged: (val) {
                  setState(() {
                    _confidenceScore = val.round();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expectationsController,
                maxLines: 2,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Ekspektasi Hasil Akhir (Hasil 90 Hari)',
                  hintText:
                      'Misal: Saya berharap bisa menghemat Rp 1.5jt per bulan dan tidak lelah menyetir...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Harap isi ekspektasi Anda'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: AppButtonStyles.primary(context),
                onPressed: _isSaving ? null : _saveDecision,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Keputusan & Mulai 90 Hari',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
