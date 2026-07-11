import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 2. AFFINITY MAPPING WORKSPACE
// ==========================================
class AffinityMappingWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const AffinityMappingWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<AffinityMappingWorkspace> createState() =>
      _AffinityMappingWorkspaceState();
}


class _AffinityMappingWorkspaceState
    extends ConsumerState<AffinityMappingWorkspace> {
  final List<Map<String, dynamic>> _items = [];
  final List<String> _groups = ['Grup A', 'Grup B', 'Grup C'];

  final TextEditingController _inputController = TextEditingController();

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add({'text': text, 'group': _groups[0]});
        _inputController.clear();
      });
      _notifyChanges();
    }
  }

  void _changeGroup(int index, String group) {
    setState(() {
      _items[index]['group'] = group;
    });
    _notifyChanges();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _notifyChanges();
  }

  void _renameGroup(int index) {
    final controller = TextEditingController(text: _groups[index]);
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DaojiText.resolve(DaojiTextKey.affinityRenameGroup, vocabularyLevel),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: DaojiText.resolve(
              DaojiTextKey.mindDumpEditLabel,
              vocabularyLevel,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                final old = _groups[index];
                setState(() {
                  _groups[index] = v;
                  for (final item in _items) {
                    if (item['group'] == old) item['group'] = v;
                  }
                });
                _notifyChanges();
              }
              Navigator.pop(ctx);
            },
            child: Text(
              DaojiText.resolve(DaojiTextKey.systemSave, vocabularyLevel),
            ),
          ),
        ],
      ),
    );
  }

  void _addGroup() {
    setState(() {
      _groups.add('Grup ${String.fromCharCode(65 + _groups.length)}');
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final buffer = StringBuffer();
    buffer.writeln(
      DaojiText.resolve(DaojiTextKey.affinityGroupHeader, vocabularyLevel),
    );
    for (final group in _groups) {
      buffer.writeln('[$group]:');
      final matched = _items.where((item) => item['group'] == group).toList();
      if (matched.isEmpty) {
        buffer.writeln(
          '  ${DaojiText.resolve(DaojiTextKey.affinityGroupEmpty, vocabularyLevel)}',
        );
      } else {
        for (final item in matched) {
          buffer.writeln('  - ${item['text']}');
        }
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.affinityTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.affinityAddLabel,
              vocabularyLevel,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.affinityHint,
              vocabularyLevel,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.affinityAddLabel,
                vocabularyLevel,
              ),
              onPressed: _addItem,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _addItem(),
        ),
        const SizedBox(height: 12),
        // Group management row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _addGroup,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                DaojiText.resolve(
                  DaojiTextKey.affinityAddGroup,
                  vocabularyLevel,
                ),
                style: const TextStyle(fontSize: 11),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.label_outline_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  DaojiText.resolve(
                    DaojiTextKey.affinityEmptyMessage,
                    vocabularyLevel,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final activeGroup = item['group'] as String;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['text'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: activeGroup,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        underline: const SizedBox(),
                        items: [
                          ..._groups.map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          ),
                          DropdownMenuItem(
                            value: '__rename__',
                            child: Text(
                              DaojiText.resolve(
                                DaojiTextKey.affinityRenameOption,
                                vocabularyLevel,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == '__rename__') {
                            final gIdx = _groups.indexOf(activeGroup);
                            if (gIdx >= 0) _renameGroup(gIdx);
                          } else if (val != null) {
                            _changeGroup(index, val);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeItem(index),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ==========================================
// 3. FIVE WHYS WORKSPACE (WHY CHAIN)
// ==========================================
