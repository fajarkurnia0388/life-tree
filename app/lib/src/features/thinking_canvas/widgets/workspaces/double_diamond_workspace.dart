import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';


class _DoubleDiamondPhaseDefinition {
  final DaojiTextKey title;
  final DaojiTextKey label;
  final DaojiTextKey hint;
  final String tabLabel;

  const _DoubleDiamondPhaseDefinition({
    required this.title,
    required this.label,
    required this.hint,
    required this.tabLabel,
  });
}

class DoubleDiamondWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const DoubleDiamondWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<DoubleDiamondWorkspace> createState() =>
      _DoubleDiamondWorkspaceState();
}


class _DoubleDiamondWorkspaceState
    extends ConsumerState<DoubleDiamondWorkspace> {
  int _activeTab = 0;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<_DoubleDiamondPhaseDefinition> _phases = const [
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDiscoverTitle,
      label: DaojiTextKey.doubleDiamondPhaseDiscoverLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDiscoverHint,
      tabLabel: 'Discover',
    ),
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDefineTitle,
      label: DaojiTextKey.doubleDiamondPhaseDefineLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDefineHint,
      tabLabel: 'Define',
    ),
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDevelopTitle,
      label: DaojiTextKey.doubleDiamondPhaseDevelopLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDevelopHint,
      tabLabel: 'Develop',
    ),
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDeliverTitle,
      label: DaojiTextKey.doubleDiamondPhaseDeliverLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDeliverHint,
      tabLabel: 'Deliver',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
    final buffer = StringBuffer();
    buffer.writeln('Proses Kerangka Kerja Double Diamond:');
    buffer.writeln('- DISCOVER: ${_controllers[0].text.trim()}');
    buffer.writeln('- DEFINE: ${_controllers[1].text.trim()}');
    buffer.writeln('- DEVELOP: ${_controllers[2].text.trim()}');
    buffer.writeln('- DELIVER: ${_controllers[3].text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final phase = _phases[_activeTab];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.doubleDiamondTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(4, (index) {
            final isActive = index == _activeTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    _phases[index].tabLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DaojiText.resolve(phase.title, vocabularyLevel)} — ${DaojiText.resolve(phase.label, vocabularyLevel)}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DaojiText.resolve(phase.hint, vocabularyLevel),
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[_activeTab],
          maxLines: 4,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.doubleDiamondNoteLabel,
              vocabularyLevel,
              params: {
                'phase': phase.tabLabel,
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return DaojiText.resolve(
                DaojiTextKey.doubleDiamondValidatorMessage,
                vocabularyLevel,
              );
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ==========================================
// 6. VALIDATION WORKSPACE (SCORECARD)
// ==========================================
