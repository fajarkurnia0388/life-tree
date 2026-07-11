import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 5. STARBURSTING WORKSPACE (6-POINT STAR)
// ==========================================
class StarburstingWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const StarburstingWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<StarburstingWorkspace> createState() => _StarburstingWorkspaceState();
}


class _StarburstingWorkspaceState extends ConsumerState<StarburstingWorkspace> {
  final List<Map<String, dynamic>> _points = const [
    {
      'key': 'WHO',
      'questionKey': DaojiTextKey.starburstingWhoQuestion,
    },
    {
      'key': 'WHAT',
      'questionKey': DaojiTextKey.starburstingWhatQuestion,
    },
    {
      'key': 'WHERE',
      'questionKey': DaojiTextKey.starburstingWhereQuestion,
    },
    {
      'key': 'WHEN',
      'questionKey': DaojiTextKey.starburstingWhenQuestion,
    },
    {
      'key': 'WHY',
      'questionKey': DaojiTextKey.starburstingWhyQuestion,
    },
    {
      'key': 'HOW',
      'questionKey': DaojiTextKey.starburstingHowQuestion,
    },
  ];

  int _selectedPointIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _points.length; i++) {
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
    final title = DaojiText.resolve(DaojiTextKey.starburstingTitle, vocabularyLevel);
    final buffer = StringBuffer();
    buffer.writeln('$title:');
    for (int i = 0; i < _points.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        final q = DaojiText.resolve(_points[i]['questionKey'] as DaojiTextKey, vocabularyLevel);
        buffer.writeln('- [${_points[i]['key']}] $q: $text');
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final activePoint = _points[_selectedPointIndex];
    final activeQuestion = DaojiText.resolve(activePoint['questionKey'] as DaojiTextKey, vocabularyLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.starburstingTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1.6,
          children: List.generate(_points.length, (index) {
            final p = _points[index];
            final isSelected = index == _selectedPointIndex;

            return GestureDetector(
              onTap: () => setState(() => _selectedPointIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    p['key']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
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
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fokus Pertanyaan ${activePoint['key']}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activeQuestion,
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
          controller: _controllers[_selectedPointIndex],
          maxLines: 3,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.starburstingLabel,
              vocabularyLevel,
              params: {'key': activePoint['key']},
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.starburstingHint,
              vocabularyLevel,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
