import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../data/local_db/database.dart';

/// Review sheet for decision entries.
///
/// Implements two key cognitive-debiasing features from gemini.md:
/// 1. **24-hour lock**: Prediction and confidence fields freeze 24 hours after
///    the decision was created, preventing unconscious hindsight modification.
/// 2. **Split-screen layout**: The left panel shows the immutable past prediction
///    (clearly locked), while the right panel provides the reflection form for
///    honest outcome analysis. The visual contrast helps users recognise cognitive
///    biases objectively.
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

  /// True when the decision was created > 24 hours ago.
  /// Locks the prediction panel to prevent hindsight-bias modifications.
  bool get _isPredictionLocked =>
      DateTime.now().difference(widget.decision.decisionDate).inHours >= 24;

  Future<void> _submitReview(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final db = ref.read(dbProvider);

    try {
      await (db.update(db.decisionEntries)
            ..where((tbl) => tbl.decisionId.equals(widget.decision.decisionId)))
          .write(
            DecisionEntriesCompanion(
              isReviewed: const drift.Value(true),
              reviewReflection: drift.Value(_reflectionController.text.trim()),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Review keputusan berhasil disimpan! Terima kasih telah berefleksi.',
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
            content: Text('Gagal menyimpan review: $e'),
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
                  // ── Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Review Hasil Keputusan 📝',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
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

                  // ── Split-screen: Past Prediction (left) | Reflection (right) ──
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── LEFT PANEL: Immutable past prediction ──
                        Expanded(
                          child: _buildPastPredictionPanel(
                            theme,
                            options: options,
                            assumptions: assumptions,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // ── RIGHT PANEL: Reflection form ──
                        Expanded(
                          child: _buildReflectionPanel(theme, ref),
                        ),
                      ],
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

  /// Left panel: displays the original decision context, frozen in time.
  Widget _buildPastPredictionPanel(
    ThemeData theme, {
    required List<String> options,
    required List<String> assumptions,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lock indicator
          Row(
            children: [
              Icon(
                _isPredictionLocked ? Icons.lock_outline : Icons.lock_open_outlined,
                size: 14,
                color: _isPredictionLocked
                    ? theme.colorScheme.primary.withValues(alpha: 0.7)
                    : Colors.amber,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _isPredictionLocked ? 'Prediksi Terkunci' : 'Prediksi (belum dikunci)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isPredictionLocked
                        ? theme.colorScheme.primary.withValues(alpha: 0.7)
                        : Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.decision.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            widget.decision.description,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (options.length >= 2) ...[
            const SizedBox(height: 8),
            Text(
              'A: ${options[0]}',
              style: const TextStyle(fontSize: 11),
            ),
            Text(
              'B: ${options[1]}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
          if (assumptions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Asumsi awal:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            ...assumptions.map(
              (asm) => Text('• $asm', style: const TextStyle(fontSize: 11)),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '"${widget.decision.expectations}"',
            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
          ),
          if (widget.decision.confidenceScore != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Keyakinan Awal: ${widget.decision.confidenceScore}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
          if (_isPredictionLocked) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Data di atas tidak dapat diubah.\nIni melindungi Anda dari bias retrospeksi.',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Right panel: the reflection form for honest outcome analysis.
  Widget _buildReflectionPanel(ThemeData theme, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Analisis Bias & Refleksi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bandingkan dengan prediksi di kiri.\nApakah ada bias konfirmasi atau optimisme berlebih?',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextFormField(
            controller: _reflectionController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText:
                  'Bagaimana realitas sebenarnya?\nApakah asumsi awal terbukti?\nApakah ekspektasi tercapai?',
              hintStyle: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Isi catatan refleksi hasil nyata' : null,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _isSaving ? null : () => _submitReview(ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Simpan Refleksi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
