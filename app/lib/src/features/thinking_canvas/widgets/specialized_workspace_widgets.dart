import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ==========================================
// 1. FREEWRITING WORKSPACE (TIMER & ALERTS)
// ==========================================
class FreewritingWorkspace extends StatefulWidget {
  final TextEditingController controller;
  const FreewritingWorkspace({super.key, required this.controller});

  @override
  State<FreewritingWorkspace> createState() => _FreewritingWorkspaceState();
}

class _FreewritingWorkspaceState extends State<FreewritingWorkspace> {
  Timer? _countdownTimer;
  Timer? _inactivityTimer;

  int _selectedDurationMinutes = 5;
  int _secondsRemaining = 300;
  bool _timerActive = false;
  bool _inactivityAlert = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _countdownTimer?.cancel();
    _inactivityTimer?.cancel();
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
        });
        _countdownTimer?.cancel();
        _inactivityTimer?.cancel();
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
      _inactivityTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _timerActive) {
          setState(() {
            _inactivityAlert = true;
          });
        }
      });
    }
  }

  void _showTimeFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Waktu Habis! 🎉'),
          content: const Text(
            'Selamat! Anda berhasil menyelesaikan sesi Freewriting tanpa henti.\n\n'
            'Sekarang baca kembali tulisan Anda, saring poin pentingnya, dan tentukan aksi berikutnya.'
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Lanjut'),
            )
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
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Timer: ${_formatTime(_secondsRemaining)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              controller: widget.controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Mulai menulis apa saja di sini, jangan biarkan jari Anda berhenti mengetik...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Tuliskan pemikiran Freewriting Anda';
                }
                return null;
              },
            ),
            if (_inactivityAlert)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: const Center(
                    child: Card(
                      color: Colors.red,
                      margin: EdgeInsets.all(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '🚨 JANGAN BERHENTI MENULIS! Alirkan pikiran Anda...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// 2. LOTUS BLOSSOM WORKSPACE (3x3 MATRIX)
// ==========================================
class LotusBlossomWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const LotusBlossomWorkspace({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<LotusBlossomWorkspace> createState() => _LotusBlossomWorkspaceState();
}

class _LotusBlossomWorkspaceState extends State<LotusBlossomWorkspace> {
  // We represent the 3x3 matrix as a List of 9 cells
  // Index 4 is the center (Core Topic)
  final List<String> _cells = List.filled(9, '');
  int _activePetalIndex = -1; // -1 means center grid, 0-8 means child grids

  // Secondary sub-grids for petals (A-H corresponds to indices 0,1,2,3, 5,6,7,8)
  final Map<int, List<String>> _subGrids = {};

  @override
  void initState() {
    super.initState();
    _cells[4] = 'Topik Utama';
    // Initialize sub grids
    for (int i = 0; i < 9; i++) {
      if (i != 4) {
        _subGrids[i] = List.filled(9, '');
      }
    }
    // Simple deserialization if provided
    _parseInitialValue();
  }

  void _parseInitialValue() {
    // If we have previous session value, we could decode it, otherwise we start clean
  }

  void _notifyChanges() {
    // Construct a simple plain text summary representing the blossom tree
    final buffer = StringBuffer();
    buffer.writeln('Lotus Blossom Grid:');
    buffer.writeln('Topik Pusat: ${_cells[4]}');
    for (int i = 0; i < 9; i++) {
      if (i != 4 && _cells[i].isNotEmpty) {
        buffer.writeln('  Petal ${i + 1} (${_cells[i]}):');
        final sub = _subGrids[i]!;
        for (int j = 0; j < 9; j++) {
          if (sub[j].isNotEmpty) {
            buffer.writeln('    - ${sub[j]}');
          }
        }
      }
    }
    widget.onChanged(buffer.toString());
  }

  void _editCell(int index, bool isSubGrid) {
    final currentText = isSubGrid ? _subGrids[_activePetalIndex]![index] : _cells[index];
    final controller = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isSubGrid ? 'Edit Cabang Ide' : (index == 4 ? 'Edit Topik Pusat' : 'Edit Petal Arah ${index + 1}')),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isSubGrid) {
                    _subGrids[_activePetalIndex]![index] = controller.text.trim();
                  } else {
                    _cells[index] = controller.text.trim();
                    // Copy to center of corresponding sub-grid
                    if (index != 4) {
                      _subGrids[index]![4] = controller.text.trim();
                    }
                  }
                });
                _notifyChanges();
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isViewingSubGrid = _activePetalIndex != -1;
    final activeGridList = isViewingSubGrid ? _subGrids[_activePetalIndex]! : _cells;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isViewingSubGrid
                  ? 'Matriks Cabang: "${_cells[_activePetalIndex]}"'
                  : '4. Matriks Lotus Blossom (Grid 3x3)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (isViewingSubGrid)
              TextButton.icon(
                onPressed: () => setState(() => _activePetalIndex = -1),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Kembali ke Pusat', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final text = activeGridList[index];
            final isCenterCell = index == 4;

            return InkWell(
              onTap: () {
                if (isViewingSubGrid) {
                  // Inside subgrid, can edit all 9 cells
                  _editCell(index, true);
                } else {
                  // On center grid, index 4 is root topic.
                  // Other indices (0,1,2,3,5,6,7,8) are petals that can expand
                  if (isCenterCell) {
                    _editCell(index, false);
                  } else {
                    if (text.isEmpty) {
                      _editCell(index, false);
                    } else {
                      // Tap again to expand petal to sub-grid
                      setState(() {
                        _activePetalIndex = index;
                      });
                    }
                  }
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCenterCell
                      ? theme.colorScheme.primary.withOpacity(0.15)
                      : (text.isNotEmpty
                          ? theme.colorScheme.primaryContainer.withOpacity(0.25)
                          : theme.colorScheme.onBackground.withOpacity(0.04)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCenterCell
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onBackground.withOpacity(0.12),
                    width: isCenterCell ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text.isEmpty
                            ? (isCenterCell ? 'Topik' : '+ Tambah')
                            : text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCenterCell ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isViewingSubGrid && !isCenterCell && text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        const Icon(Icons.zoom_in_rounded, size: 10, color: Colors.grey),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        const Text(
          '*Ketuk kotak petal yang sudah terisi untuk memperluas (zoom) ke sub-grid cabang.',
          style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ],
    );
  }
}

// ==========================================
// 3. MORPHOLOGICAL ANALYSIS WORKSPACE (TABLE + SPINNER)
// ==========================================
class MorphologicalWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const MorphologicalWorkspace({super.key, required this.onChanged});

  @override
  State<MorphologicalWorkspace> createState() => _MorphologicalWorkspaceState();
}

class _MorphologicalWorkspaceState extends State<MorphologicalWorkspace> {
  final List<String> _dimensions = ['Media', 'Bahan', 'Model Bisnis'];
  final Map<String, List<String>> _options = {
    'Media': ['Mobile App', 'Website', 'Buku Fisik', 'Kantung Belanja'],
    'Bahan': ['Kertas Daur Ulang', 'Daun Pisang', 'Bambu', 'Linen Rajutan'],
    'Model Bisnis': ['Berlangganan', 'Beli Putus', 'Sewa', 'Donasi'],
  };

  Map<String, String>? _spinResult;

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Morfologi (Kombinasi Variabel):');
    _options.forEach((dim, list) {
      buffer.writeln('- Dimensi $dim: ${list.join(", ")}');
    });
    if (_spinResult != null) {
      buffer.writeln('Kombinasi Hasil Putaran Dadu 🎲:');
      _spinResult!.forEach((key, val) {
        buffer.writeln('  * $key -> $val');
      });
    }
    widget.onChanged(buffer.toString());
  }

  void _spinCombinations() {
    final rng = Random();
    final result = <String, String>{};
    _options.forEach((dim, list) {
      if (list.isNotEmpty) {
        result[dim] = list[rng.nextInt(list.length)];
      }
    });
    setState(() {
      _spinResult = result;
    });
    _notifyChanges();
  }

  void _addOption(String dimension) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Tambah Opsi di "$dimension"'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _options[dimension]!.add(controller.text.trim());
                  });
                  _notifyChanges();
                }
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _addDimension() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Dimensi Baru'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Misal: Target Pengguna'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final dim = controller.text.trim();
                if (dim.isNotEmpty) {
                  setState(() {
                    _dimensions.add(dim);
                    _options[dim] = [];
                  });
                  _notifyChanges();
                }
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '4. Matriks Kombinasi Morfologi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              tooltip: 'Tambah Dimensi Baru',
              onPressed: _addDimension,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dimensions list cards
        ..._dimensions.map((dim) {
          final list = _options[dim] ?? [];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.08)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      InkWell(
                        onTap: () => _addOption(dim),
                        child: Text(
                          '+ Tambah Opsi',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: list.map((opt) {
                      return Chip(
                        label: Text(opt, style: const TextStyle(fontSize: 11)),
                        backgroundColor: theme.colorScheme.onBackground.withOpacity(0.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onDeleted: () {
                          setState(() {
                            _options[dim]!.remove(opt);
                          });
                          _notifyChanges();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // Spin combination trigger
        ElevatedButton.icon(
          onPressed: _spinCombinations,
          icon: const Icon(Icons.casino_rounded),
          label: const Text('Acak Kombinasi Ide 🎲'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          ),
        ),

        // Spin result display
        if (_spinResult != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Kombinasi Ide Acak Anda:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._spinResult!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Text('${entry.key}: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(entry.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ==========================================
// 4. RAPID BRAINSTORM WORKSPACE (CHIP LOGGER)
// ==========================================
class RapidBrainstormWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RapidBrainstormWorkspace({super.key, required this.onChanged});

  @override
  State<RapidBrainstormWorkspace> createState() => _RapidBrainstormWorkspaceState();
}

class _RapidBrainstormWorkspaceState extends State<RapidBrainstormWorkspace> {
  final List<String> _ideas = [];
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
      setState(() {
        _ideas.add(text);
      });
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
        const Text(
          '4. Logger Ide Cepat (Rapid Brainstorm)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // Text input field with enter to submit
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            hintText: 'Ketik ide baru di sini lalu tekan Enter 🚀...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: _submitIdea,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _submitIdea(),
        ),
        const SizedBox(height: 12),

        // Counter & list of ideas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kuantitas Ide: ${_ideas.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            if (_ideas.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _ideas.clear());
                  _notifyChanges();
                },
                child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: _ideas.map((idea) {
            return Chip(
              label: Text(idea, style: const TextStyle(fontSize: 11)),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.06),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onDeleted: () {
                setState(() {
                  _ideas.remove(idea);
                });
                _notifyChanges();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ==========================================
// 5. QUESTION STORM WORKSPACE (QUESTION LIST & STARS)
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
    buffer.writeln('Pertanyaan yang Berhasil Dihimpun (Question Storming):');
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
    // We only allow maximum of 3 starred questions to enforce prioritization
    final currentStarredCount = _questions.where((q) => q['starred'] == true).length;
    final isCurrentlyStarred = _questions[index]['starred'] == true;

    if (!isCurrentlyStarred && currentStarredCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal pilih 3 pertanyaan prioritas saja!')),
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
        const Text(
          '4. Logger Pertanyaan Kunci (Question Storming)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // Text input field
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            hintText: 'Ketik pertanyaan kritis Anda lalu tekan Enter...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: _submitQuestion,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _submitQuestion(),
        ),
        const SizedBox(height: 12),

        // Counter & helper
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pertanyaan: ${_questions.length} | Prioritas: $starredCount/3', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),

        // Questions list view
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
                  color: isStarred ? Colors.amber : theme.colorScheme.onBackground.withOpacity(0.08),
                  width: isStarred ? 2 : 1,
                ),
              ),
              child: ListTile(
                title: Text(q['text'], style: const TextStyle(fontSize: 13)),
                trailing: IconButton(
                  icon: Icon(
                    isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isStarred ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => _toggleStar(index),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                dense: true,
              ),
            );
          },
        ),
      ],
    );
  }
}
