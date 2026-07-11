import 'package:flutter/material.dart';
import '../cultivation_constants.dart';

/// Dialog for realm breakthrough milestones.
///
/// Phase 0 defines the reusable UI. Unlock logic is planned for Phase 3.
class RealmBreakthroughDialog extends StatelessWidget {
  const RealmBreakthroughDialog({super.key, required this.realm});

  final CultivationRealm realm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.auto_awesome),
      title: const Text('Realm Breakthrough'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${realm.name} (${realm.chineseName})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(realm.indonesianName),
          const SizedBox(height: 12),
          Text(
            realm.mindset,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}
