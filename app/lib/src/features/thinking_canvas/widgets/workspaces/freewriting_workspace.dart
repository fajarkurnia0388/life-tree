import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 1. FREEWRITING WORKSPACE (IMPROVED UX)
// ==========================================
class FreewritingWorkspace extends ConsumerStatefulWidget {
  final TextEditingController controller;
  const FreewritingWorkspace({super.key, required this.controller});

  @override
  ConsumerState<FreewritingWorkspace> createState() =>
      _FreewritingWorkspaceState();
}

class _FreewritingWorkspaceState extends ConsumerState<FreewritingWorkspace>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  Timer? _inactivityTimer;

  int _selectedDurationMinutes = 5;
  int _secondsRemaining = 300;
  bool _timerActive = false;
  bool _inactivityAlert = false;
  int _wordCount = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateWordCount();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _countdownTimer?.cancel();
    _inactivityTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = widget.controller.text.trim();
    _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
  }

  void _onTextChanged() {
    if (!_timerActive && widget.controller.text.isNotEmpty) {
      _startTimer();
    }
    _resetInactivityTimer();
    _updateWordCount();
    setState(() {});
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _timerActive = true;
      _secondsRemaining = _selectedDurationMinutes * 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        setState(() {
          _secondsRemaining = 0;
          _timerActive = false;
          _inactivityAlert = false;
        });
        _countdownTimer?.cancel();
        _inactivityTimer?.cancel();
        _pulseController.stop();
        _showTimeFinishedDialog();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (mounted && _timerActive) {
      setState(() {
        _inactivityAlert = false;
      });
      _pulseController.stop();
      _pulseController.value = 0.0;

      // Increased from 3s to 8s for gentler nudge
      _inactivityTimer = Timer(const Duration(seconds: 8), () {
        if (mounted && _timerActive) {
          setState(() {
            _inactivityAlert = true;
          });
          _pulseController.repeat(reverse: true);
        }
      });
    }
  }

  void _showTimeFinishedDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Text('🎉'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DaojiText.resolve(
                    DaojiTextKey.freewritingTimeFinishedTitle,
                    ref.read(daojiVocabularyLevelValueProvider),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DaojiText.resolve(
                  DaojiTextKey.freewritingTimeFinishedContent,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      '$_wordCount',
                      'Kata',
                    ),
                    _buildStatItem(
                      context,
                      _formatTime(_selectedDurationMinutes * 60),
                      'Durasi',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                DaojiText.resolve(
                  DaojiTextKey.freewritingContinueButton,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final double progress = _timerActive
        ? (_secondsRemaining / (_selectedDurationMinutes * 60))
        : 1.0;

    final isUrgent = _timerActive && _secondsRemaining < 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Timer & Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DaojiText.resolve(DaojiTextKey.freewritingTitle, vocabularyLevel),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
                // Word count badge
                if (_wordCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.text_fields_rounded,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_wordCount kata',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                if (!_timerActive)
                  DropdownButton<int>(
                    value: _selectedDurationMinutes,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 Menit')),
                      DropdownMenuItem(value: 5, child: Text('5 Menit')),
                      DropdownMenuItem(value: 10, child: Text('10 Menit')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDurationMinutes = val;
                          _secondsRemaining = val * 60;
                        });
                      }
                    },
                  )
                else ...[
                  // Circular progress timer
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          color: isUrgent ? Colors.redAccent : null,
                        ),
                        Text(
                          _formatTime(_secondsRemaining),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUrgent
                                ? Colors.redAccent
                                : theme.colorScheme.primary,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUrgent
                          ? Colors.redAccent
                          : theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Writing area with gentle inactivity nudge
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                TextFormField(
                  controller: widget.controller,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: DaojiText.resolve(
                      DaojiTextKey.freewritingHint,
                      vocabularyLevel,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                  ),
                ),
                // Gentle inactivity nudge — bottom bar, not blocking overlay
                if (_inactivityAlert)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, _) {
                          return Opacity(
                            opacity: 0.6 + (_pulseAnimation.value * 0.4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DaojiText.resolve(
                                        DaojiTextKey
                                            .freewritingInactivityAlert,
                                        vocabularyLevel,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
