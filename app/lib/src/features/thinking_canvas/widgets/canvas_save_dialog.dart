import 'package:flutter/material.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';

/// Dialog to confirm saving or discarding canvas session.
class CanvasSaveDialog extends StatelessWidget {
  final DaojiVocabularyLevel vocabularyLevel;
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  const CanvasSaveDialog({
    required this.vocabularyLevel,
    required this.onDiscard,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String t(DaojiTextKey key) => DaojiText.resolve(key, vocabularyLevel);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(t(DaojiTextKey.thinkingCanvasSaveSessionTitle)),
      content: Text(t(DaojiTextKey.thinkingCanvasSaveSessionBody)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDiscard();
          },
          child: Text(
            t(DaojiTextKey.thinkingCanvasDiscard),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t(DaojiTextKey.systemCancel)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onSave();
          },
          child: Text(t(DaojiTextKey.systemSave)),
        ),
      ],
    );
  }
}
