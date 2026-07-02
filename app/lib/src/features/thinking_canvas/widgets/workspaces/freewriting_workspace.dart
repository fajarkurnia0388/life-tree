import 'dart:async';
import 'package:flutter/material.dart';

// ==========================================
// 1. FREEWRITING WORKSPACE (PULSATING GLOW)
// ==========================================
class FreewritingWorkspace extends StatefulWidget {
  final TextEditingController controller;
  const FreewritingWorkspace({super.key, required this.controller});

  @override
  State<FreewritingWorkspace> createState() => _FreewritingWorkspaceState();
}

class _FreewritingWorkspaceState extends State<FreewritingWorkspace>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  Timer? _inactivityTimer;

  int _selectedDurationMinutes = 5;
  int _secondsRemaining = 300;
  bool _timerActive = false;
  bool _inactivityAlert = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 0.04, end: 0.24).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _countdownTimer?.cancel();
    _inactivityTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_timerActive && widget.controller.text.isNotEmpty) {
      _startTimer();
    }
    _resetInactivityTimer();
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

      _inactivityTimer = Timer(const Duration(seconds: 3), () {
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Waktu Habis! 🎉'),
          content: const Text(
            'Selamat! Sesi menulis bebas (Freewriting) tanpa henti selesai.\n\n'
            'Kembali ke kertas coretan untuk menyeleksi poin terbaik.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
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
    final double progress = _timerActive
        ? (_secondsRemaining / (_selectedDurationMinutes * 60))
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '4. Sesi Freewriting Tanpa Henti',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
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
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                TextFormField(
                  controller: widget.controller,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText:
                        'Mulai menulis apa saja di sini, jangan biarkan jari Anda berhenti mengetik...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Tuliskan pemikiran Freewriting Anda';
                    }
                    return null;
                  },
                ),
                if (_inactivityAlert)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(
                                alpha: _pulseAnimation.value,
                              ),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Card(
                            color: Colors.red.withValues(alpha: 0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                '🚨 JANGAN BERHENTI MENULIS! Alirkan pikiran...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
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
