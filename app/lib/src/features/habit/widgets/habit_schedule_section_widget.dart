import 'package:flutter/material.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';

class HabitScheduleSectionWidget extends StatefulWidget {
  final String frequency;
  final ValueChanged<String> onFrequencyChanged;
  final List<int> selectedDays;
  final DaojiVocabularyLevel vocabularyLevel;

  const HabitScheduleSectionWidget({
    super.key,
    required this.frequency,
    required this.onFrequencyChanged,
    required this.selectedDays,
    required this.vocabularyLevel,
  });

  @override
  State<HabitScheduleSectionWidget> createState() =>
      _HabitScheduleSectionWidgetState();
}

class _HabitScheduleSectionWidgetState
    extends State<HabitScheduleSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.habitFrequency, widget.vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Daily', label: Text('Setiap Hari')),
            ButtonSegment(value: 'Weekly', label: Text('Pilih Hari')),
          ],
          selected: {widget.frequency},
          onSelectionChanged: (selection) {
            widget.onFrequencyChanged(selection.first);
          },
        ),
        const SizedBox(height: 16),
        if (widget.frequency == 'Weekly') ...[
          const Text(
            'Pilih Hari Penjadwalan:',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final daysAbbr = [
                'Sen',
                'Sel',
                'Rab',
                'Kam',
                'Jum',
                'Sab',
                'Min',
              ];
              final isSelected = widget.selectedDays.contains(dayNum);
              return FilterChip(
                label: Text(daysAbbr[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      widget.selectedDays.add(dayNum);
                      widget.selectedDays.sort();
                    } else {
                      widget.selectedDays.remove(dayNum);
                    }
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
