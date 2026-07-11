import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 3. SCAMPER ACCORDION WORKSPACE
// ==========================================
class ScamperWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const ScamperWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<ScamperWorkspace> createState() => _ScamperWorkspaceState();
}


class _ScamperWorkspaceState extends ConsumerState<ScamperWorkspace> {
  final List<Map<String, dynamic>> _panels = const [
    {
      'key': 'S',
      'nameKey': DaojiTextKey.scamperSubstituteName,
      'hintKey': DaojiTextKey.scamperSubstituteHint,
    },
    {
      'key': 'C',
      'nameKey': DaojiTextKey.scamperCombineName,
      'hintKey': DaojiTextKey.scamperCombineHint,
    },
    {
      'key': 'A',
      'nameKey': DaojiTextKey.scamperAdaptName,
      'hintKey': DaojiTextKey.scamperAdaptHint,
    },
    {
      'key': 'M',
      'nameKey': DaojiTextKey.scamperModifyName,
      'hintKey': DaojiTextKey.scamperModifyHint,
    },
    {
      'key': 'P',
      'nameKey': DaojiTextKey.scamperPutUseName,
      'hintKey': DaojiTextKey.scamperPutUseHint,
    },
    {
      'key': 'E',
      'nameKey': DaojiTextKey.scamperEliminateName,
      'hintKey': DaojiTextKey.scamperEliminateHint,
    },
    {
      'key': 'R',
      'nameKey': DaojiTextKey.scamperReverseName,
      'hintKey': DaojiTextKey.scamperReverseHint,
    },
  ];

  int _expandedIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _panels.length; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final title = DaojiText.resolve(DaojiTextKey.scamperTitle, vocabularyLevel);
    final buffer = StringBuffer();
    buffer.writeln('$title:');
    for (int i = 0; i < _panels.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        final name = DaojiText.resolve(_panels[i]['nameKey'] as DaojiTextKey, vocabularyLevel);
        buffer.writeln('- [${_panels[i]['key']}] $name: $text');
      }
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
          DaojiText.resolve(DaojiTextKey.scamperTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        ...List.generate(_panels.length, (index) {
          final p = _panels[index];
          final isExpanded = index == _expandedIndex;
          final panelName = DaojiText.resolve(p['nameKey'] as DaojiTextKey, vocabularyLevel);
          final panelHint = DaojiText.resolve(p['hintKey'] as DaojiTextKey, vocabularyLevel);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isExpanded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: isExpanded ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        p['key']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isExpanded
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    panelName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? -1 : index;
                    });
                  },
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          panelHint,
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _controllers[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: DaojiText.resolve(DaojiTextKey.scamperPlaceholder, vocabularyLevel),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
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
// 4. SWOT MATRIX WORKSPACE (2x2 GRID)
// ==========================================
