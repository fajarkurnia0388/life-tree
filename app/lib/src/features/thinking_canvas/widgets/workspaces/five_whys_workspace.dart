import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 3. FIVE WHYS WORKSPACE (WHY CHAIN)
// ==========================================
class FiveWhysWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const FiveWhysWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<FiveWhysWorkspace> createState() => _FiveWhysWorkspaceState();
}


class _FiveWhysWorkspaceState extends ConsumerState<FiveWhysWorkspace> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final TextEditingController _rootCauseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
    _rootCauseController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _rootCauseController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final title = DaojiText.resolve(DaojiTextKey.fiveWhysTitle, vocabularyLevel);
    final buffer = StringBuffer();
    buffer.writeln('$title:');
    for (int i = 0; i < 5; i++) {
      buffer.writeln('Why ${i + 1}: ${_controllers[i].text.trim()}');
    }
    final root = _rootCauseController.text.trim();
    if (root.isNotEmpty) {
      buffer.writeln('Akar penyebab sejati: $root');
    }
    widget.onChanged(buffer.toString());
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.fiveWhysTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.1 + (index * 0.1),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (index < 4)
                    Container(
                      width: 2,
                      height: 40,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _controllers[index],
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: index == 0
                        ? DaojiText.resolve(
                            DaojiTextKey.fiveWhysFirstLabel,
                            vocabularyLevel,
                          )
                        : DaojiText.resolve(
                            DaojiTextKey.fiveWhysOtherLabel,
                            vocabularyLevel,
                            params: {'index': index + 1},
                          ),

                    hintText: DaojiText.resolve(
                      DaojiTextKey.fiveWhysHint,
                      vocabularyLevel,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return DaojiText.resolve(
                        DaojiTextKey.fiveWhysValidatorMessage,
                        vocabularyLevel,
                      );
                    }
                    return null;
                  },
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Akar penyebab sejati',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rootCauseController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText:
                      'Setelah 5 Why, ringkas akar masalah yang paling dalam…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 4. FIRST PRINCIPLES WORKSPACE (LADDER)
// ==========================================
