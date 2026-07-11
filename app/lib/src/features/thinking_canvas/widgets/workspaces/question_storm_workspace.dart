import 'package:flutter/material.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_level.dart';

// ==========================================
// 2. QUESTION STORM WORKSPACE (QUESTION LIST & STARS)
// ==========================================
class QuestionStormWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const QuestionStormWorkspace({super.key, required this.onChanged});

  @override
  State<QuestionStormWorkspace> createState() => _QuestionStormWorkspaceState();
}


class _QuestionStormWorkspaceState extends State<QuestionStormWorkspace> {
  final List<Map<String, dynamic>> _questions = [];
  final TextEditingController _inputController = TextEditingController();

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Question Storming List:');
    for (var q in _questions) {
      final star = q['starred'] == true ? ' ⭐️ (PRIORITAS)' : '';
      buffer.writeln('- ${q['text']}$star');
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

    if (!isCurrentlyStarred && currentStarredCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DaojiText.resolve(
              DaojiTextKey.questionStormMaxPriority,
              DaojiVocabularyLevel.mortal,
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
    final starredCount = _questions.where((q) => q['starred'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(
            DaojiTextKey.questionStormTitle,
            DaojiVocabularyLevel.mortal,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.questionStormHint,
              DaojiVocabularyLevel.mortal,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.questionStormHint,
              DaojiVocabularyLevel.mortal,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.questionStormAddTooltip,
                DaojiVocabularyLevel.mortal,
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
                DaojiVocabularyLevel.mortal,
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
      ],
    );
  }
}

// ==========================================
// 3. RANDOM WORD WORKSPACE
// ==========================================
