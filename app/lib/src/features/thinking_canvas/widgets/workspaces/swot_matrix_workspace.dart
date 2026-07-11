import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 4. SWOT MATRIX WORKSPACE (2x2 GRID)
// ==========================================
class SwotMatrixWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  const SwotMatrixWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
  });

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
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        for (final key in ['S', 'W', 'O', 'T']) {
          final value = data[key] as String?;
          if (value != null && value.isNotEmpty) {
            _controllers[key]?.text = value;
          }
        }
      } catch (_) {}
    }
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
    widget.onStructuredOutput?.call(jsonEncode({
      'S': _controllers['S']!.text.trim(),
      'W': _controllers['W']!.text.trim(),
      'O': _controllers['O']!.text.trim(),
      'T': _controllers['T']!.text.trim(),
    }));
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
