import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// SHARED: Step Progress Indicator
// ==========================================
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activeColor ?? theme.colorScheme.primary;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color
                    : isCurrent
                        ? color.withValues(alpha: 0.5)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

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
class DisneyStrategyWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const DisneyStrategyWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<DisneyStrategyWorkspace> createState() =>
      _DisneyStrategyWorkspaceState();
}

class _DisneyStrategyWorkspaceState extends ConsumerState<DisneyStrategyWorkspace> {
  int _activeRoomIndex = 0;

  final List<Map<String, dynamic>> _rooms = const [
    {
      'titleKey': DaojiTextKey.disneyDreamerTitle,
      'tabKey': DaojiTextKey.disneyDreamerTab,
      'hintKey': DaojiTextKey.disneyDreamerHint,
      'labelKey': DaojiTextKey.disneyDreamerLabel,
      'gradientStart': '0xFF4F83CC',
      'gradientEnd': '0xFF96C0CE',
    },
    {
      'titleKey': DaojiTextKey.disneyRealistTitle,
      'tabKey': DaojiTextKey.disneyRealistTab,
      'hintKey': DaojiTextKey.disneyRealistHint,
      'labelKey': DaojiTextKey.disneyRealistLabel,
      'gradientStart': '0xFF5C8D89',
      'gradientEnd': '0xFF8FB9A8',
    },
    {
      'titleKey': DaojiTextKey.disneyCriticTitle,
      'tabKey': DaojiTextKey.disneyCriticTab,
      'hintKey': DaojiTextKey.disneyCriticHint,
      'labelKey': DaojiTextKey.disneyCriticLabel,
      'gradientStart': '0xFF7E8A97',
      'gradientEnd': '0xFFB2BEC3',
    },
  ];

  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
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
    final title = DaojiText.resolve(DaojiTextKey.disneyTitle, vocabularyLevel);
    final dreamerLabel = DaojiText.resolve(DaojiTextKey.disneyDreamerLabel, vocabularyLevel);
    final realistLabel = DaojiText.resolve(DaojiTextKey.disneyRealistLabel, vocabularyLevel);
    final criticLabel = DaojiText.resolve(DaojiTextKey.disneyCriticLabel, vocabularyLevel);

    final buffer = StringBuffer();
    buffer.writeln('$title:');
    buffer.writeln('- $dreamerLabel: ${_controllers[0]!.text.trim()}');
    buffer.writeln('- $realistLabel: ${_controllers[1]!.text.trim()}');
    buffer.writeln('- $criticLabel: ${_controllers[2]!.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final room = _rooms[_activeRoomIndex];
    final colorStart = Color(int.parse(room['gradientStart'] as String));
    final colorEnd = Color(int.parse(room['gradientEnd'] as String));
    final roomTitle = DaojiText.resolve(room['titleKey'] as DaojiTextKey, vocabularyLevel);
    final roomHint = DaojiText.resolve(room['hintKey'] as DaojiTextKey, vocabularyLevel);
    final roomLabel = DaojiText.resolve(room['labelKey'] as DaojiTextKey, vocabularyLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.disneyTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        StepProgressIndicator(
          currentStep: _activeRoomIndex,
          totalSteps: 3,
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (index) {
            final r = _rooms[index];
            final isActive = index == _activeRoomIndex;
            final tabText = DaojiText.resolve(r['tabKey'] as DaojiTextKey, vocabularyLevel);

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeRoomIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    tabText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
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
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colorStart, colorEnd]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                roomTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                roomHint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[_activeRoomIndex],
          maxLines: 5,
          decoration: InputDecoration(
            labelText: roomLabel,
            hintText: DaojiText.resolve(DaojiTextKey.disneyPlaceholder, vocabularyLevel),
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
class SwotMatrixWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const SwotMatrixWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<SwotMatrixWorkspace> createState() => _SwotMatrixWorkspaceState();
}

class _SwotMatrixWorkspaceState extends ConsumerState<SwotMatrixWorkspace> {
  final Map<String, TextEditingController> _controllers = {
    'S': TextEditingController(),
    'W': TextEditingController(),
    'O': TextEditingController(),
    'T': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _controllers.forEach((_, c) => c.addListener(_notifyChanges));
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.removeListener(_notifyChanges));
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final title = DaojiText.resolve(DaojiTextKey.swotTitle, vocabularyLevel);
    final strengthsLabel = DaojiText.resolve(DaojiTextKey.swotStrengthsLabel, vocabularyLevel);
    final weaknessesLabel = DaojiText.resolve(DaojiTextKey.swotWeaknessesLabel, vocabularyLevel);
    final opportunitiesLabel = DaojiText.resolve(DaojiTextKey.swotOpportunitiesLabel, vocabularyLevel);
    final threatsLabel = DaojiText.resolve(DaojiTextKey.swotThreatsLabel, vocabularyLevel);

    final buffer = StringBuffer();
    buffer.writeln('$title:');
    buffer.writeln('- $strengthsLabel: ${_controllers['S']!.text.trim()}');
    buffer.writeln('- $weaknessesLabel: ${_controllers['W']!.text.trim()}');
    buffer.writeln('- $opportunitiesLabel: ${_controllers['O']!.text.trim()}');
    buffer.writeln('- $threatsLabel: ${_controllers['T']!.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final strengthsLabel = DaojiText.resolve(DaojiTextKey.swotStrengthsLabel, vocabularyLevel);
    final weaknessesLabel = DaojiText.resolve(DaojiTextKey.swotWeaknessesLabel, vocabularyLevel);
    final opportunitiesLabel = DaojiText.resolve(DaojiTextKey.swotOpportunitiesLabel, vocabularyLevel);
    final threatsLabel = DaojiText.resolve(DaojiTextKey.swotThreatsLabel, vocabularyLevel);
    final placeholder = DaojiText.resolve(DaojiTextKey.swotPlaceholder, vocabularyLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.swotTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            _buildSwotBox(
              strengthsLabel,
              _controllers['S']!,
              Colors.green,
              theme,
              placeholder,
            ),
            _buildSwotBox(
              weaknessesLabel,
              _controllers['W']!,
              Colors.red,
              theme,
              placeholder,
            ),
            _buildSwotBox(
              opportunitiesLabel,
              _controllers['O']!,
              Colors.blue,
              theme,
              placeholder,
            ),
            _buildSwotBox(
              threatsLabel,
              _controllers['T']!,
              Colors.orange,
              theme,
              placeholder,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwotBox(
    String label,
    TextEditingController controller,
    Color accentColor,
    ThemeData theme,
    String placeholder,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: null,
              expands: true,
              style: TextStyle(fontSize: 11,
                  color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

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
