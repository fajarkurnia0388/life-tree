import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/theme/button_theme.dart';
import '../../../data/local_db/database.dart';

import '../../../core/utils/profile_json_helpers.dart';

class DomainReAuditDialog extends ConsumerStatefulWidget {
  final UserProfile profile;

  const DomainReAuditDialog({super.key, required this.profile});

  @override
  ConsumerState<DomainReAuditDialog> createState() => _DomainReAuditDialogState();
}

class _DomainReAuditDialogState extends ConsumerState<DomainReAuditDialog> {
  final Map<String, TextEditingController> _controllers = {
    'Tubuh': TextEditingController(text: '5.0'),
    'Keuangan': TextEditingController(text: '5.0'),
    'Hubungan': TextEditingController(text: '5.0'),
    'Emosi': TextEditingController(text: '5.0'),
    'Karir': TextEditingController(text: '5.0'),
    'Rekreasi': TextEditingController(text: '5.0'),
  };

  @override
  void initState() {
    super.initState();

    // Pre-fill with existing scores
    final scores = widget.profile.parsedDomainScores;
    scores.forEach((key, val) {
      if (_controllers.containsKey(key)) {
        _controllers[key]!.text = val.toString();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        DaojiText.resolve(
          DaojiTextKey.profileDomainReauditTitle,
          vocabularyLevel,
        ),
      ),
      content: StatefulBuilder(
        builder: (context, setLocalState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _controllers.entries.map((entry) {
                final currentValue =
                    (double.tryParse(entry.value.text) ?? 5.0).clamp(1.0, 10.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currentValue.toStringAsFixed(1),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: currentValue,
                        min: 1.0,
                        max: 10.0,
                        divisions: 18,
                        onChanged: (val) {
                          setLocalState(() {
                            entry.value.text = val.toStringAsFixed(1);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
          ),
        ),
        ElevatedButton(
          style: AppButtonStyles.primary(context),
          onPressed: () {
            final newScores = _controllers.map(
              (k, v) => MapEntry(
                k,
                (double.tryParse(v.text) ?? 5.0).clamp(1.0, 10.0),
              ),
            );
            Navigator.pop(context, newScores);
          },
          child: Text(
            DaojiText.resolve(DaojiTextKey.systemSave, vocabularyLevel),
          ),
        ),
      ],
    );
  }
}
