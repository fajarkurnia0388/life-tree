import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 2. QUESTION STORM WORKSPACE (QUESTION LIST & STARS & ACTIONS)
// ==========================================
class QuestionStormWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const QuestionStormWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<QuestionStormWorkspace> createState() => _QuestionStormWorkspaceState();
}

class _QuestionStormWorkspaceState extends ConsumerState<QuestionStormWorkspace> {
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _inputController = TextEditingController();
  final Map<String, String> _questionActions = {}; // keyed by question text

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Question Storming List:');
    for (var q in _questions) {
      final isStarred = q['starred'] == true;
      final star = isStarred ? ' ⭐️ (PRIORITAS)' : '';
      buffer.writeln('- ${q['text']}$star');
      if (isStarred) {
        final action = _questionActions[q['text']] ?? '';
        if (action.trim().isNotEmpty) {
          buffer.writeln('  ↳ Tindak Lanjut: ${action.trim()}');
        }
      }
    }
    widget.onChanged(buffer.toString());
  }

  void _submitQuestion() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _questions.add({'text': text, 'starred': false});
      });
      _inputController.clear();
      _notifyChanges();
    }
  }

  void _toggleStar(int index) {
    final currentStarredCount = _questions
        .where((q) => q['starred'] == true)
        .length;
    final isCurrentlyStarred = _questions[index]['starred'] == true;

    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);

    if (!isCurrentlyStarred && currentStarredCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DaojiText.resolve(
              DaojiTextKey.questionStormMaxPriority,
              vocabularyLevel,
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _questions[index]['starred'] = !isCurrentlyStarred;
    });
    _notifyChanges();
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
    final starredCount = _questions.where((q) => q['starred'] == true).length;
    final starredQuestions = _questions.where((q) => q['starred'] == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(
            DaojiTextKey.questionStormTitle,
            vocabularyLevel,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.questionStormHint,
              vocabularyLevel,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.questionStormHint,
              vocabularyLevel,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.questionStormAddTooltip,
                vocabularyLevel,
              ),
              onPressed: _submitQuestion,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _submitQuestion(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DaojiText.resolve(
                DaojiTextKey.questionStormStats,
                vocabularyLevel,
                params: {'total': _questions.length, 'starred': starredCount},
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final q = _questions[index];
            final isStarred = q['starred'] == true;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isStarred
                      ? Colors.amber
                      : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  width: isStarred ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(q['text'], style: const TextStyle(fontSize: 13)),
                trailing: GestureDetector(
                  onTap: () => _toggleStar(index),
                  child: AnimatedScale(
                    scale: isStarred ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.bounceOut,
                    child: Icon(
                      isStarred
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isStarred ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                dense: true,
              ),
            );
          },
        ),
        if (starredQuestions.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Rencana Aksi / Jawaban Pertanyaan Prioritas:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...starredQuestions.map((q) {
            final text = q['text'] as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                initialValue: _questionActions[text] ?? '',
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Tindak lanjut: "$text"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  _questionActions[text] = val;
                  _notifyChanges();
                },
              ),
            );
          }),
        ]
      ],
    );
  }
}
