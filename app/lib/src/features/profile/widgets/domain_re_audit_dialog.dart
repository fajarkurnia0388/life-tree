import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/providers/db_provider.dart';
import '../../../core/theme/button_theme.dart';
import '../../../data/local_db/database.dart';
import '../../dashboard/dashboard_provider.dart';

class DomainReAuditDialog extends StatelessWidget {
  final UserProfile profile;

  const DomainReAuditDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controllers = {
      'Tubuh': TextEditingController(text: '5.0'),
      'Keuangan': TextEditingController(text: '5.0'),
      'Hubungan': TextEditingController(text: '5.0'),
      'Emosi': TextEditingController(text: '5.0'),
      'Karir': TextEditingController(text: '5.0'),
      'Rekreasi': TextEditingController(text: '5.0'),
    };

    // Pre-fill with existing scores
    if (profile.latestDomainScores != null) {
      try {
        final Map<String, dynamic> scores = jsonDecode(profile.latestDomainScores!);
        scores.forEach((key, val) {
          if (controllers.containsKey(key)) {
            controllers[key]!.text = val.toString();
          }
        });
      } catch (_) {}
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Perbarui Penilaian Domain'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: controllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: entry.value,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: AppButtonStyles.primary(context),
          onPressed: () {
            final newScores = controllers.map((k, v) => MapEntry(k, double.tryParse(v.text) ?? 5.0));
            Navigator.pop(context, newScores);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
