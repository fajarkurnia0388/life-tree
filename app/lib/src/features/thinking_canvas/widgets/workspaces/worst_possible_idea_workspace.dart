import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import 'step_progress_indicator.dart';

/// Worst Possible Idea — three guided phases:
/// 1) dump bad ideas, 2) invert each into a smart seed, 3) concrete first action.
class WorstPossibleIdeaWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  const WorstPossibleIdeaWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
  });

  @override
  ConsumerState<WorstPossibleIdeaWorkspace> createState() =>
      _WorstPossibleIdeaWorkspaceState();
}

class _WorstPossibleIdeaWorkspaceState
    extends ConsumerState<WorstPossibleIdeaWorkspace> {
  int _phase = 0;

  final List<String> _badIdeas = [];
  final TextEditingController _badInput = TextEditingController();

  /// Parallel to [_badIdeas]: inversion / “smart seed” notes.
  final List<String> _inversions = [];

  final TextEditingController _actionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        final badIdeas = data['badIdeas'] as List<dynamic>?;
        if (badIdeas != null) _badIdeas.addAll(badIdeas.map((e) => e.toString()));
        final inversions = data['inversions'] as List<dynamic>?;
        if (inversions != null) _inversions.addAll(inversions.map((e) => e.toString()));
        final action = data['action'] as String?;
        if (action != null) _actionController.text = action;
        final phase = data['phase'] as int?;
        if (phase != null) _phase = phase;
      } catch (_) {}
    }
    _actionController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _badInput.dispose();
    _actionController.removeListener(_notifyChanges);
    _actionController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Worst Possible Idea:');
    buffer.writeln('--- Ide terburuk ---');
    for (var i = 0; i < _badIdeas.length; i++) {
      buffer.writeln('${i + 1}. ${_badIdeas[i]}');
      if (i < _inversions.length && _inversions[i].trim().isNotEmpty) {
        buffer.writeln('   → Inversi / solusi cerdas: ${_inversions[i].trim()}');
      }
    }
    final action = _actionController.text.trim();
    if (action.isNotEmpty) {
      buffer.writeln('--- Langkah konkret pertama ---');
      buffer.writeln(action);
    }
    widget.onChanged(buffer.toString());
    widget.onStructuredOutput?.call(jsonEncode({
      'badIdeas': _badIdeas,
      'inversions': _inversions,
      'action': _actionController.text.trim(),
      'phase': _phase,
    }));
  }

  void _addBadIdea() {
    final text = _badInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _badIdeas.add(text);
      _inversions.add('');
      _badInput.clear();
    });
    _notifyChanges();
  }

  void _removeBadIdea(int index) {
    setState(() {
      _badIdeas.removeAt(index);
      if (index < _inversions.length) _inversions.removeAt(index);
    });
    _notifyChanges();
  }

  void _setInversion(int index, String value) {
    if (index >= _inversions.length) return;
    setState(() => _inversions[index] = value);
    _notifyChanges();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Worst Possible Idea',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        StepProgressIndicator(currentStep: _phase, totalSteps: 3),
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (i) {
            final labels = ['Ide Buruk', 'Inversi', 'Aksi'];
            final active = i == _phase;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _phase = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: active
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        if (_phase == 0) _buildPhaseBadIdeas(theme),
        if (_phase == 1) _buildPhaseInversion(theme),
        if (_phase == 2) _buildPhaseAction(theme),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_phase > 0)
              TextButton(
                onPressed: () => setState(() => _phase--),
                child: const Text('← Sebelumnya'),
              ),
            const Spacer(),
            if (_phase < 2)
              FilledButton(
                onPressed: () => setState(() => _phase++),
                child: const Text('Lanjut →'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseBadIdeas(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Tuliskan ide paling buruk, konyol, atau merugikan. '
            'Jangan sensor — kuantitas dulu. Nanti kita balikkan.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onErrorContainer,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _badInput,
          decoration: InputDecoration(
            labelText: 'Tambah ide terburuk',
            hintText: 'Mis. biarkan user bingung tanpa onboarding…',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: _addBadIdea,
            ),
          ),
          onSubmitted: (_) => _addBadIdea(),
        ),
        const SizedBox(height: 8),
        if (_badIdeas.isEmpty)
          Text(
            'Belum ada ide buruk. Tambahkan minimal 1–3.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          )
        else
          ...List.generate(_badIdeas.length, (i) {
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.error.withValues(alpha: 0.15),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(_badIdeas[i], style: const TextStyle(fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => _removeBadIdea(i),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPhaseInversion(ThemeData theme) {
    if (_badIdeas.isEmpty) {
      return Text(
        'Isi ide buruk di fase 1 dulu, lalu kembali ke sini untuk membalikkannya.',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            'Pikirkan sebaliknya: apakah ada elemen kecil dari ide buruk '
            'tersebut yang bisa dimodifikasi menjadi solusi cerdas?',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.primary,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_badIdeas.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Buruk: ${_badIdeas[i]}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: i < _inversions.length ? _inversions[i] : '',
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Inversi / solusi cerdas',
                    hintText: 'Elemen mana yang dibalik menjadi kekuatan?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => _setInversion(i, v),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPhaseAction(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Dari inversi terbaik, apa satu langkah konkret pertama '
            'yang bisa Anda lakukan minggu ini?',
            style: TextStyle(fontSize: 12, height: 1.35),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _actionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Rencana aksi pertama',
            hintText: 'Mis. uji prototype 15 menit dengan 1 orang…',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
