import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../data/local_db/database.dart';

class ReviewDecisionSheet extends StatefulWidget {
  final DecisionEntry decision;

  const ReviewDecisionSheet({super.key, required this.decision});

  @override
  State<ReviewDecisionSheet> createState() => _ReviewDecisionSheetState();
}

class _ReviewDecisionSheetState extends State<ReviewDecisionSheet> {
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

    List<String> options = [];
    List<String> assumptions = [];
    try {
      options = List<String>.from(jsonDecode(widget.decision.options));
      assumptions = List<String>.from(jsonDecode(widget.decision.assumptions));
    } catch (e, stackTrace) {
      ErrorHandlerService().logError(
        e,
        stackTrace,
        context: 'ReviewDecisionSheet.parseDecisionData',
      );
    }

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
                  Text(
                    'Ekspektasi awal: "${widget.decision.expectations}"',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
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
