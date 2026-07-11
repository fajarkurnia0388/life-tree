import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 1. MIND DUMP WORKSPACE (STICKY NOTES)
// ==========================================
class MindDumpWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const MindDumpWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<MindDumpWorkspace> createState() => _MindDumpWorkspaceState();
}


class _MindDumpWorkspaceState extends ConsumerState<MindDumpWorkspace> {
  final List<String> _notes = [];
  final TextEditingController _inputController = TextEditingController();

  final List<Color> _stickyColors = const [
    Color(0xFFFFF9C4), // Yellow
    Color(0xFFFFCDD2), // Pink
    Color(0xFFC8E6C9), // Green
    Color(0xFFB3E5FC), // Blue
    Color(0xFFD1C4E9), // Purple
  ];

  void _addNote() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _notes.add(text);
        _inputController.clear();
      });
      _notifyChanges();
    }
  }

  void _removeNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _notifyChanges();
  }

  void _editNote(int index) {
    final controller = TextEditingController(text: _notes[index]);
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DaojiText.resolve(
            DaojiTextKey.mindDumpEditTitle,
            vocabularyLevel,
            params: {'index': index + 1},
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
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
                setState(() => _notes[index] = v);
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

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final buffer = StringBuffer();
    buffer.writeln(
      DaojiText.resolve(DaojiTextKey.mindDumpStickyHeader, vocabularyLevel),
    );
    for (int i = 0; i < _notes.length; i++) {
      buffer.writeln('- ${_notes[i]}');
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
          DaojiText.resolve(DaojiTextKey.mindDumpTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.mindDumpAddLabel,
              vocabularyLevel,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.mindDumpHint,
              vocabularyLevel,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.mindDumpAddLabel,
                vocabularyLevel,
              ),
              onPressed: _addNote,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _addNote(),
        ),
        const SizedBox(height: 12),
        if (_notes.isEmpty)
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
                const Icon(Icons.note_alt_outlined, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  DaojiText.resolve(
                    DaojiTextKey.mindDumpEmptyMessage,
                    vocabularyLevel,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final color = _stickyColors[index % _stickyColors.length];
              return GestureDetector(
                onTap: () => _editNote(index),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 3,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeNote(index),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _notes[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
// 2. AFFINITY MAPPING WORKSPACE
// ==========================================
