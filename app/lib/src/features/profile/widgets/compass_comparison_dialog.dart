import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';
import '../../dashboard/dashboard_provider.dart';

class CompassComparisonResult {
  final List<String> aligned;       // muncul di kedua sisi
  final List<String> declaredOnly;  // hanya di Versi Dipilih
  final List<String> revealedOnly;  // hanya di Versi Tersirat

  const CompassComparisonResult({
    required this.aligned,
    required this.declaredOnly,
    required this.revealedOnly,
  });
}

CompassComparisonResult compareCompass({
  required List<String> declaredValues,
  required List<String> revealedValues,
}) {
  // Normalize string for case-insensitive comparison, but return original casing
  final declaredSet = declaredValues.map((v) => v.trim()).toSet();
  final revealedSet = revealedValues.map((v) => v.trim()).toSet();

  return CompassComparisonResult(
    aligned: declaredSet.intersection(revealedSet).toList(),
    declaredOnly: declaredSet.difference(revealedSet).toList(),
    revealedOnly: revealedSet.difference(declaredSet).toList(),
  );
}

class CompassComparisonDialog extends ConsumerWidget {
  final UserProfile profile;
  final List<String> declaredValues;
  final List<String> revealedValues;

  const CompassComparisonDialog({
    super.key,
    required this.profile,
    required this.declaredValues,
    required this.revealedValues,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final comparison = compareCompass(
      declaredValues: declaredValues,
      revealedValues: revealedValues,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(Icons.compare_arrows_rounded, color: Colors.teal),
          const SizedBox(width: 10),
          Text(
            'Perbandingan Kompas',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Berikut adalah perbandingan antara nilai-nilai pilihan sadarmu (Dipilih) dengan pola yang muncul dari tindakan kecilmu (Tersirat).',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),

              // 1. Aligned
              _buildSection(
                context,
                ref,
                title: 'Selaras ✅',
                desc: 'Nilai-nilai ini konsisten antara yang kamu pilih dan yang tercermin dari tindakanmu.',
                values: comparison.aligned,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // 2. Declared Only
              _buildSection(
                context,
                ref,
                title: 'Baru di Niat 🌱',
                desc: 'Kamu memilih ini sebagai nilai penting, tapi pola pilihanmu belum banyak mencerminkannya. Wajar — nilai butuh waktu untuk terlihat dalam tindakan kecil.',
                values: comparison.declaredOnly,
                color: Colors.amber[800]!,
              ),
              const SizedBox(height: 16),

              // 3. Revealed Only
              _buildSection(
                context,
                ref,
                title: 'Pola yang Muncul 🔍',
                desc: 'Pilihanmu menunjukkan kecenderungan ke arah ini, meski belum kamu tuliskan sebagai nilai inti. Mungkin ini layak dipertimbangkan?',
                values: comparison.revealedOnly,
                color: theme.colorScheme.primary,
                trailingBuilder: (val) {
                  return IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    tooltip: 'Tambahkan ke Versi Dipilih',
                    onPressed: () => _addValueToDeclared(context, ref, val),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String desc,
    required List<String> values,
    required Color color,
    Widget Function(String)? trailingBuilder,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
          ),
          const SizedBox(height: 4),
          // ANTI-GUILT: jangan gunakan kata menghakimi di sini
          Text(
            desc,
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 10),
          if (values.isEmpty)
            Text(
              'Belum ada nilai di kategori ini.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: values.map((v) {
                return Chip(
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: color.withValues(alpha: 0.1),
                  side: BorderSide(color: color.withValues(alpha: 0.2)),
                  label: Text(v, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                  deleteIcon: trailingBuilder != null ? trailingBuilder(v) : null,
                  onDeleted: trailingBuilder != null ? () => _addValueToDeclared(context, ref, v) : null,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _addValueToDeclared(BuildContext context, WidgetRef ref, String value) async {
    final currentDeclared = List<String>.from(declaredValues);
    if (currentDeclared.contains(value)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nilai "$value" sudah ada di Versi Dipilih.'), backgroundColor: Colors.amber[800]),
      );
      return;
    }

    if (currentDeclared.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kompas Dipilih sudah penuh (maksimal 3 nilai). Silakan edit manual untuk menggantinya.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    currentDeclared.add(value);
    final db = ref.read(dbProvider);

    try {
      await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
          .write(UserProfilesCompanion(coreValues: drift.Value(jsonEncode(currentDeclared))));
      ref.invalidate(dashboardDataProvider);

      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nilai "$value" berhasil ditambahkan ke Versi Dipilih!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
