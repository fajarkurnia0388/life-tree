import 'package:flutter/material.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_level.dart';

// ==========================================
// 1. RAPID BRAINSTORM WORKSPACE (ANIMATED BUBBLES)
// ==========================================
class RapidBrainstormWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RapidBrainstormWorkspace({super.key, required this.onChanged});

  @override
  State<RapidBrainstormWorkspace> createState() =>
      _RapidBrainstormWorkspaceState();
}


class _RapidBrainstormWorkspaceState extends State<RapidBrainstormWorkspace> {
  final List<String> _ideas = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _inputController = TextEditingController();

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Hasil Brainstorming Cepat (Rapid Logger):');
    for (int i = 0; i < _ideas.length; i++) {
      buffer.writeln('${i + 1}. ${_ideas[i]}');
    }
    widget.onChanged(buffer.toString());
  }

  void _submitIdea() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _ideas.insert(0, text);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 350),
      );
      _inputController.clear();
      _notifyChanges();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(
            DaojiTextKey.rapidBrainstormTitle,
            DaojiVocabularyLevel.mortal,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.rapidBrainstormHint,
              DaojiVocabularyLevel.mortal,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.rapidBrainstormHint,
              DaojiVocabularyLevel.mortal,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.rapidBrainstormAddTooltip,
                DaojiVocabularyLevel.mortal,
              ),
              onPressed: _submitIdea,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _submitIdea(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DaojiText.resolve(
                DaojiTextKey.rapidBrainstormQuantity,
                DaojiVocabularyLevel.mortal,
                params: {'count': _ideas.length},
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            if (_ideas.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _ideas.clear();
                  });
                  _notifyChanges();
                },
                child: Text(
                  DaojiText.resolve(
                    DaojiTextKey.rapidBrainstormReset,
                    DaojiVocabularyLevel.mortal,
                  ),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 120,
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _ideas.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index, animation) {
              final idea = _ideas[index];
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.elasticOut,
                      ),
                    ),
                child: ScaleTransition(
                  scale: animation,
                    child: Container(
                    constraints: const BoxConstraints(maxWidth: 160),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 8.0,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            idea,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _ideas.removeAt(index);
                            });
                            _listKey.currentState?.removeItem(
                              index,
                              (context, animation) => Container(),
                            );
                            _notifyChanges();
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. QUESTION STORM WORKSPACE (QUESTION LIST & STARS)
// ==========================================
