import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';
import 'step_progress_indicator.dart';

// ==========================================
// 2. DISNEY STRATEGY WORKSPACE (THREE ROOMS)
// ==========================================
class DisneyStrategyWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  const DisneyStrategyWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
  });

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
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        const keys = ['dreamer', 'realist', 'critic'];
        for (int i = 0; i < keys.length; i++) {
          final value = data[keys[i]] as String?;
          if (value != null) {
            _controllers[i] = TextEditingController(text: value);
          }
        }
      } catch (_) {}
    }
    for (int i = 0; i < 3; i++) {
      _controllers.putIfAbsent(i, () => TextEditingController());
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
    widget.onStructuredOutput?.call(jsonEncode({
      'dreamer': _controllers[0]!.text.trim(),
      'realist': _controllers[1]!.text.trim(),
      'critic': _controllers[2]!.text.trim(),
    }));
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
