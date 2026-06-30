import 'package:flutter/material.dart';
import '../domain/value_dilemma.dart';

class ValueOpenQuestionCard extends StatefulWidget {
  final OpenValueQuestion question;
  final int index;
  final int total;
  final Function(String text) onSubmitted;

  const ValueOpenQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.onSubmitted,
  });

  @override
  State<ValueOpenQuestionCard> createState() => _ValueOpenQuestionCardState();
}

class _ValueOpenQuestionCardState extends State<ValueOpenQuestionCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pertanyaan Reflektif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '${widget.index + 1} / ${widget.total}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (widget.index + 1) / widget.total,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
            const SizedBox(height: 32),
            // Prompt
            Text(
              widget.question.prompt,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // TextField
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                minLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tulis refleksimu di sini... (opsional)',
                  hintStyle: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _controller.clear();
                      widget.onSubmitted('');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Lewati'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onSubmitted(_controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Lanjut'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
