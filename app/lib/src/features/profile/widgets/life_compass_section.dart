import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/error_handler_service.dart';
import '../../../data/local_db/database.dart';
import '../../cultivation/cultivation_provider.dart';
import '../../cultivation/cultivation_strings.dart';
import 'compass_comparison_dialog.dart';

class LifeCompassSection extends ConsumerWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const LifeCompassSection({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final languageLevel = ref.watch(cultivationLanguageLevelProvider);
    final isDark = theme.brightness == Brightness.dark;

    // 1. Parse declared values (Versi Dipilih)
    List<String> declaredValues = [];
    try {
      final jsonStr = profile.coreValues;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        declaredValues = List<String>.from(jsonDecode(jsonStr));
      }
    } catch (e, stackTrace) {
      ErrorHandlerService().logError(
        e,
        stackTrace,
        context: 'LifeCompassSection.parseDeclaredValues',
      );
    }

    // 2. Parse revealed values (Versi Tersirat)
    int totalResponses = 0;
    Map<String, int> revealedScores = {};
    if (profile.revealedValueScores != null) {
      try {
        final Map<String, dynamic> raw = jsonDecode(
          profile.revealedValueScores!,
        );
        raw.forEach((key, val) {
          revealedScores[key] = val as int;
          totalResponses += revealedScores[key]!;
        });
      } catch (e, stackTrace) {
        ErrorHandlerService().logError(
          e,
          stackTrace,
          context: 'LifeCompassSection.parseRevealedValues',
        );
      }
    }

    final hasEnoughData = totalResponses >= 5;
    List<String> revealedValues = [];
    if (hasEnoughData) {
      final sortedRevealed = revealedScores.entries.toList()
        ..sort((a, b) {
          final cmp = b.value.compareTo(a.value);
          if (cmp != 0) return cmp;
          return a.key.compareTo(b.key);
        });
      revealedValues = sortedRevealed.take(3).map((e) => e.key).toList();
    }

    final updateDateStr = profile.revealedValueLastUpdatedAt != null
        ? DateFormat('d MMM yyyy').format(profile.revealedValueLastUpdatedAt!)
        : '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.explore_rounded, color: Colors.teal, size: 24),
                const SizedBox(width: 10),
                Text(
                  '${CultivationStrings.lifeCompassTitle(languageLevel)} 🧭',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Dua sisi penuntun: yang kamu pilih secara sadar, dan yang tercermin secara tersirat dari tindakan kecilmu.',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),

            // --- Sub-blok: Versi Dipilih ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Versi Dipilih (Declared)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (declaredValues.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Belum ada nilai terpilih. Tentukan nilai intimu untuk memandu tujuan harian.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: declaredValues.map((v) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    child: Text(
                      v,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 16),

            // --- Sub-blok: Versi Tersirat ---
            Text(
              'Versi Tersirat (Revealed)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            if (!hasEnoughData)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Belum cukup data untuk membaca pola tersiratmu (butuh minimal 5 jawaban). Selesaikan sesi Cermin Nilai untuk mulai memetakan.',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/value-mirror'),
                    icon: const Icon(Icons.balance_rounded, size: 16),
                    label: Text(
                      '${CultivationStrings.valueMirrorTitle(languageLevel)} 🪞',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '🪞 Dari pilihan-pilihanmu di Value Mirror, nilai yang paling sering kamu prioritaskan secara tidak sadar adalah:',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: revealedValues.map((v) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(
                        alpha: isDark ? 0.12 : 0.06,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      v,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'Jika ada perbedaan antara nilai yang kamu nyatakan dan nilai yang terungkap, itu bukan kesalahan — melainkan undangan untuk refleksi lebih dalam.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Diperbarui dari $totalResponses refleksi · $updateDateStr',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // --- Tombol Perbandingan ---
            if (declaredValues.isNotEmpty && hasEnoughData) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CompassComparisonDialog(
                      profile: profile,
                      declaredValues: declaredValues,
                      revealedValues: revealedValues,
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                label: const Text('Lihat Perbandingan 🪞'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.teal),
                  foregroundColor: Colors.teal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
