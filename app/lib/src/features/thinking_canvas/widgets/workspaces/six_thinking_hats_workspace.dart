import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import 'step_progress_indicator.dart';

// ==========================================
// 1. SIX THINKING HATS WORKSPACE
// ==========================================
class SixThinkingHatsWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const SixThinkingHatsWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<SixThinkingHatsWorkspace> createState() =>
      _SixThinkingHatsWorkspaceState();
}


class _SixThinkingHatsWorkspaceState
    extends ConsumerState<SixThinkingHatsWorkspace> {
  final List<Map<String, dynamic>> _hats = const [
    {
      'color': Colors.white,
      'borderColor': Colors.black45,
      'textColor': Colors.black87,
      'nameKey': DaojiTextKey.sixThinkingHatsWhiteHatName,
      'labelKey': DaojiTextKey.sixThinkingHatsWhiteHatLabel,
      'hintKey': DaojiTextKey.sixThinkingHatsWhiteHatHint,
    },
    {
      'color': Colors.red,
      'borderColor': Colors.redAccent,
      'textColor': Colors.white,
      'nameKey': DaojiTextKey.sixThinkingHatsRedHatName,
      'labelKey': DaojiTextKey.sixThinkingHatsRedHatLabel,
      'hintKey': DaojiTextKey.sixThinkingHatsRedHatHint,
    },
    {
      'color': Colors.black,
      'borderColor': Colors.black,
      'textColor': Colors.white,
      'nameKey': DaojiTextKey.sixThinkingHatsBlackHatName,
      'labelKey': DaojiTextKey.sixThinkingHatsBlackHatLabel,
      'hintKey': DaojiTextKey.sixThinkingHatsBlackHatHint,
    },
    {
      'color': Colors.amber,
      'borderColor': Colors.amber,
      'textColor': Colors.black87,
      'nameKey': DaojiTextKey.sixThinkingHatsYellowHatName,
      'labelKey': DaojiTextKey.sixThinkingHatsYellowHatLabel,
      'hintKey': DaojiTextKey.sixThinkingHatsYellowHatHint,
    },
    {
      'color': Colors.green,
      'borderColor': Colors.green,
      'textColor': Colors.white,
      'nameKey': DaojiTextKey.sixThinkingHatsGreenHatName,
      'labelKey': DaojiTextKey.sixThinkingHatsGreenHatLabel,
      'hintKey': DaojiTextKey.sixThinkingHatsGreenHatHint,
    },
    {
      'color': Colors.blue,
      'borderColor': Colors.blue,
      'textColor': Colors.white,
      'nameKey': DaojiTextKey.sixThinkingHatsBlueHatName,
      'labelKey': DaojiTextKey.sixThinkingHatsBlueHatLabel,
      'hintKey': DaojiTextKey.sixThinkingHatsBlueHatHint,
    },
  ];


  int _selectedHatIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _hats.length; i++) {
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
    final title = DaojiText.resolve(DaojiTextKey.sixThinkingHatsTitle, vocabularyLevel);
    final buffer = StringBuffer();
    buffer.writeln('$title:');
    for (int i = 0; i < _hats.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        final name = DaojiText.resolve(_hats[i]['nameKey'] as DaojiTextKey, vocabularyLevel);
        final label = DaojiText.resolve(_hats[i]['labelKey'] as DaojiTextKey, vocabularyLevel);
        buffer.writeln('- $name ($label): $text');
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeHat = _hats[_selectedHatIndex];
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final activeName = DaojiText.resolve(activeHat['nameKey'] as DaojiTextKey, vocabularyLevel);
    final activeLabel = DaojiText.resolve(activeHat['labelKey'] as DaojiTextKey, vocabularyLevel);
    final activeHint = DaojiText.resolve(activeHat['hintKey'] as DaojiTextKey, vocabularyLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DaojiText.resolve(DaojiTextKey.sixThinkingHatsTitle, vocabularyLevel),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${_selectedHatIndex + 1}/6',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        StepProgressIndicator(
          currentStep: _selectedHatIndex,
          totalSteps: 6,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(_hats.length, (index) {
            final h = _hats[index];
            final isSelected = index == _selectedHatIndex;
            final labelStr = DaojiText.resolve(h['labelKey'] as DaojiTextKey, vocabularyLevel);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHatIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: h['color'] as Color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (h['borderColor'] as Color).withValues(alpha: 0.5),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: Text(
                  labelStr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: h['textColor'] as Color,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: (activeHat['color'] as Color).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (activeHat['borderColor'] as Color).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$activeName — $activeLabel:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: activeHat['color'] == Colors.white
                      ? Colors.black87
                      : activeHat['color'] as Color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activeHint,
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
          controller: _controllers[_selectedHatIndex],
          maxLines: 4,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.sixThinkingHatsNoteLabel,
              vocabularyLevel,
              params: {'name': activeName},
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.sixThinkingHatsNoteHint,
              vocabularyLevel,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 12),
        // Navigation buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_selectedHatIndex > 0)
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedHatIndex--);
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  DaojiText.resolve(_hats[_selectedHatIndex - 1]['labelKey'] as DaojiTextKey, vocabularyLevel),
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            if (_selectedHatIndex < _hats.length - 1)
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedHatIndex++);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(
                  DaojiText.resolve(_hats[_selectedHatIndex + 1]['labelKey'] as DaojiTextKey, vocabularyLevel),
                  style: const TextStyle(fontSize: 12),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

}

// ==========================================
// 2. DISNEY STRATEGY WORKSPACE (THREE ROOMS)
// ==========================================
