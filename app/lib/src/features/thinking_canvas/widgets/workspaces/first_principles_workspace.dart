import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 4. FIRST PRINCIPLES WORKSPACE (LADDER)
// ==========================================
class FirstPrinciplesWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  const FirstPrinciplesWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
  });

  @override
  ConsumerState<FirstPrinciplesWorkspace> createState() =>
      _FirstPrinciplesWorkspaceState();
}


class _FirstPrinciplesWorkspaceState
    extends ConsumerState<FirstPrinciplesWorkspace> {
  final List<TextEditingController> _controllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<DaojiTextKey> _steps = const [
    DaojiTextKey.firstPrinciplesStepOldAssumption,
    DaojiTextKey.firstPrinciplesStepFact,
    DaojiTextKey.firstPrinciplesStepConstruction,
  ];

  @override
  void initState() {
    super.initState();
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        final steps = data['steps'] as List<dynamic>?;
        if (steps != null) {
          for (int i = 0; i < steps.length && i < 3; i++) {
            _controllers[i].text = steps[i] as String? ?? '';
          }
        }
      } catch (_) {}
    }
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final title = DaojiText.resolve(DaojiTextKey.firstPrinciplesTitle, vocabularyLevel);
    final step1 = DaojiText.resolve(DaojiTextKey.firstPrinciplesStepOldAssumption, vocabularyLevel);
    final step2 = DaojiText.resolve(DaojiTextKey.firstPrinciplesStepFact, vocabularyLevel);
    final step3 = DaojiText.resolve(DaojiTextKey.firstPrinciplesStepConstruction, vocabularyLevel);
    
    final buffer = StringBuffer();
    buffer.writeln('$title:');
    buffer.writeln('- $step1: ${_controllers[0].text.trim()}');
    buffer.writeln('- $step2: ${_controllers[1].text.trim()}');
    buffer.writeln('- $step3: ${_controllers[2].text.trim()}');
    widget.onChanged(buffer.toString());
    widget.onStructuredOutput?.call(jsonEncode({
      'steps': _controllers.map((c) => c.text.trim()).toList(),
    }));
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.firstPrinciplesTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          final isLast = index == 2;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLast
                  ? theme.colorScheme.primary.withValues(alpha: 0.04)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLast
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: isLast ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DaojiText.resolve(_steps[index], vocabularyLevel),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLast
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers[index],
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: DaojiText.resolve(
                      DaojiTextKey.firstPrinciplesHint,
                      vocabularyLevel,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return DaojiText.resolve(
                        DaojiTextKey.firstPrinciplesValidatorMessage,
                        vocabularyLevel,
                      );
                    }
                    return null;
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================
// 5. DOUBLE DIAMOND WORKSPACE
// ==========================================


// ==========================================
// 5. DOUBLE DIAMOND WORKSPACE
// ==========================================
