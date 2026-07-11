import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';

/// Reverse brainstorming: generate failure modes, then invert each into fixes.
class ReverseBrainstormWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  const ReverseBrainstormWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
  });

  @override
  ConsumerState<ReverseBrainstormWorkspace> createState() =>
      _ReverseBrainstormWorkspaceState();
}

class _ReverseBrainstormWorkspaceState
    extends ConsumerState<ReverseBrainstormWorkspace>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final List<String> _worsen = [];
  final List<String> _invert = [];
  final TextEditingController _worsenInput = TextEditingController();
  final TextEditingController _invertInput = TextEditingController();
  final TextEditingController _summary = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        final worsen = data['worsen'] as List<dynamic>?;
        if (worsen != null) _worsen.addAll(worsen.map((e) => e.toString()));
        final invert = data['invert'] as List<dynamic>?;
        if (invert != null) _invert.addAll(invert.map((e) => e.toString()));
        final summary = data['summary'] as String?;
        if (summary != null) _summary.text = summary;
      } catch (_) {}
    }
    _summary.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _worsenInput.dispose();
    _invertInput.dispose();
    _summary.removeListener(_notifyChanges);
    _summary.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Reverse Brainstorming:');
    buffer.writeln('--- Cara memperburuk ---');
    for (var i = 0; i < _worsen.length; i++) {
      buffer.writeln('${i + 1}. ${_worsen[i]}');
    }
    buffer.writeln('--- Inversi → solusi ---');
    for (var i = 0; i < _invert.length; i++) {
      buffer.writeln('${i + 1}. ${_invert[i]}');
    }
    final s = _summary.text.trim();
    if (s.isNotEmpty) {
      buffer.writeln('--- Kesimpulan ---');
      buffer.writeln(s);
    }
    widget.onChanged(buffer.toString());
    widget.onStructuredOutput?.call(jsonEncode({
      'worsen': _worsen,
      'invert': _invert,
      'summary': _summary.text.trim(),
    }));
  }

  void _addWorsen() {
    final t = _worsenInput.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _worsen.add(t);
      _worsenInput.clear();
    });
    _notifyChanges();
  }

  void _addInvert() {
    final t = _invertInput.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _invert.add(t);
      _invertInput.clear();
    });
    _notifyChanges();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Reverse Brainstorming',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Dulu: bagaimana cara membuat masalah LEBIH parah? '
            'Lalu: balikkan tiap poin menjadi pencegahan atau solusi.',
            style: TextStyle(fontSize: 12, height: 1.35),
          ),
        ),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Perburuk'),
            Tab(text: 'Inversi'),
          ],
        ),
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _tabs,
            children: [
              _listPane(
                theme,
                input: _worsenInput,
                onAdd: _addWorsen,
                items: _worsen,
                onRemove: (i) {
                  setState(() => _worsen.removeAt(i));
                  _notifyChanges();
                },
                label: 'Cara memperburuk…',
              ),
              _listPane(
                theme,
                input: _invertInput,
                onAdd: _addInvert,
                items: _invert,
                onRemove: (i) {
                  setState(() => _invert.removeAt(i));
                  _notifyChanges();
                },
                label: 'Solusi hasil inversi…',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _summary,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Kesimpulan: solusi terbaik',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _listPane(
    ThemeData theme, {
    required TextEditingController input,
    required VoidCallback onAdd,
    required List<String> items,
    required void Function(int) onRemove,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          TextField(
            controller: input,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_rounded),
                onPressed: onAdd,
              ),
            ),
            onSubmitted: (_) => onAdd(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                return ListTile(
                  dense: true,
                  title: Text(items[i], style: const TextStyle(fontSize: 13)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => onRemove(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
