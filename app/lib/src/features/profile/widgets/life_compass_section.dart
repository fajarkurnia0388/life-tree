import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/local_db/database.dart';

class LifeCompassSection extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const LifeCompassSection({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<String> values = [];
    try {
      final jsonStr = profile.coreValues;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        values = List<String>.from(jsonDecode(jsonStr));
      }
    } catch (_) {}

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.explore_rounded, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Kompas Hidup 🧭', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  tooltip: 'Ubah Kompas Hidup',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tiga nilai inti hidup Anda yang menuntun arah kebiasaan dan keseimbangan harian:',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            if (values.isEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.add),
                  label: const Text('Tentukan Nilai Inti'),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: values.map((v) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        v,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
