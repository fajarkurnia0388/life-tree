import 'dart:async';
import 'dart:math';
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

class _FreewritingWorkspaceState extends State<FreewritingWorkspace> with SingleTickerProviderStateMixin {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Waktu Habis! 🎉'),
          content: const Text(
            'Selamat! Sesi menulis bebas (Freewriting) tanpa henti selesai.\n\n'
            'Kembali ke kertas coretan untuk menyeleksi poin terbaik.'
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
    final double progress = _timerActive ? (_secondsRemaining / (_selectedDurationMinutes * 60)) : 1.0;

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
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
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
                ]
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
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(_pulseAnimation.value),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Card(
                            color: Colors.red.withOpacity(0.9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                '🚨 JANGAN BERHENTI MENULIS! Alirkan pikiran...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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

// ==========================================
// 2. RADIAL LOTUS BLOSSOM WORKSPACE
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
  final List<String> _cells = List.filled(9, '');
  int _activePetalIndex = -1; // -1 = center grid, 0-8 = sub grids
  final Map<int, List<String>> _subGrids = {};

  @override
  void initState() {
    super.initState();
    _cells[4] = 'Topik Utama';
    for (int i = 0; i < 9; i++) {
      if (i != 4) {
        _subGrids[i] = List.filled(9, '');
      }
    }
    _notifyChanges();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Lotus Blossom Radial Matrix:');
    buffer.writeln('Topik Pusat: ${_cells[4]}');
    for (int i = 0; i < 9; i++) {
      if (i != 4 && _cells[i].isNotEmpty) {
        buffer.writeln('  Cabang Kelopak ${i + 1} (${_cells[i]}):');
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
          title: Text(isSubGrid ? 'Edit Sub-Ide Kelopak' : (index == 4 ? 'Edit Topik Utama' : 'Edit Arah Gagasan')),
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

    // Radius of radial petals
    const double radialRadius = 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isViewingSubGrid ? 'Sub-Kelopak: "${_cells[_activePetalIndex]}"' : '4. Kelopak Radial Lotus Blossom',
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

        // Beautiful Radial Layout Canvas
        Container(
          height: 290,
          decoration: BoxDecoration(
            color: theme.colorScheme.onBackground.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.06)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double cx = constraints.maxWidth / 2;
              final double cy = constraints.maxHeight / 2;

              // Generate coordinate offsets for 8 outer nodes
              final Map<int, Offset> nodeOffsets = {};
              int radialCounter = 0;
              for (int i = 0; i < 9; i++) {
                if (i == 4) {
                  nodeOffsets[i] = Offset(cx, cy);
                } else {
                  final double angle = (radialCounter * 2 * pi / 8) - (pi / 2);
                  nodeOffsets[i] = Offset(
                    cx + cos(angle) * radialRadius,
                    cy + sin(angle) * radialRadius,
                  );
                  radialCounter++;
                }
              }

              return Stack(
                children: [
                  // Stems lines connecting center to petals
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LotusStemsPainter(
                        center: Offset(cx, cy),
                        offsets: nodeOffsets,
                        themeColor: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  ),

                  // Nodes render
                  ...nodeOffsets.entries.map((entry) {
                    final index = entry.key;
                    final pos = entry.value;
                    final isCenter = index == 4;
                    final text = isViewingSubGrid ? _subGrids[_activePetalIndex]![index] : _cells[index];

                    return Positioned(
                      left: pos.dx - 32,
                      top: pos.dy - 32,
                      child: GestureDetector(
                        onTap: () {
                          if (isViewingSubGrid) {
                            _editCell(index, true);
                          } else {
                            if (isCenter) {
                              _editCell(index, false);
                            } else {
                              if (text.isEmpty) {
                                _editCell(index, false);
                              } else {
                                setState(() {
                                  _activePetalIndex = index;
                                });
                              }
                            }
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isCenter
                                ? theme.colorScheme.primary
                                : (text.isNotEmpty
                                    ? theme.colorScheme.primaryContainer.withOpacity(0.85)
                                    : theme.colorScheme.onBackground.withOpacity(0.04)),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isCenter ? theme.colorScheme.primary : theme.colorScheme.onBackground)
                                    .withOpacity(0.12),
                                blurRadius: 6,
                              )
                            ],
                            border: Border.all(
                              color: isCenter ? Colors.white : theme.colorScheme.primary.withOpacity(0.3),
                              width: isCenter ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                text.isEmpty
                                    ? (isCenter ? 'Topic' : '+ Ide')
                                    : text,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isCenter
                                      ? theme.colorScheme.onPrimary
                                      : (text.isNotEmpty
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onBackground.withOpacity(0.6)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '*Kelopak berbentuk melingkar. Ketuk petal terisi untuk masuk ke sub-cabang ide.',
          style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ],
    );
  }
}

class _LotusStemsPainter extends CustomPainter {
  final Offset center;
  final Map<int, Offset> offsets;
  final Color themeColor;

  _LotusStemsPainter({
    required this.center,
    required this.offsets,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    offsets.forEach((index, pos) {
      if (index != 4) {
        // Draw elegant curve towards center
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..quadraticBezierTo(
            (center.dx + pos.dx) / 2 + 15,
            (center.dy + pos.dy) / 2 - 15,
            pos.dx,
            pos.dy,
          );
        canvas.drawPath(path, paint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant _LotusStemsPainter oldDelegate) => false;
}

class MorphologicalTemplate {
  final String title;
  final String description;
  final String category;
  final bool isPremium;
  final Map<String, List<String>> dimensions;

  const MorphologicalTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.isPremium,
    required this.dimensions,
  });

  static const List<MorphologicalTemplate> library = [
    MorphologicalTemplate(
      title: 'Inovasi Startup Tech',
      description: 'Ciptakan ide produk software dan SaaS digital baru.',
      category: 'Bisnis',
      isPremium: false,
      dimensions: {
        'Platform': ['Mobile App', 'SaaS Web', 'Chrome Extension', 'Telegram Bot'],
        'Model Bisnis': ['Freemium', 'Langganan Bulanan', 'Sponsor Iklan', 'Pay-per-use'],
        'Target Pasar': ['B2B Korporat', 'Pelajar Gen Z', 'Kreator Konten', 'UMKM Lokal'],
      },
    ),
    MorphologicalTemplate(
      title: 'Produk Eko-Fisik',
      description: 'Inovasi produk fisik ramah lingkungan dan sirkular.',
      category: 'Fisik',
      isPremium: false,
      dimensions: {
        'Kategori': ['Kemasan Makanan', 'Peralatan Dapur', 'Alat Tulis', 'Dekorasi Rumah'],
        'Bahan Organik': ['Bambu Serat', 'Pelepah Pisang', 'Karton Daur Ulang', 'Misilium Jamur'],
        'Distribusi': ['Shopify DTC', 'Pasar Tani Lokal', 'Grosir B2B', 'Langganan Box'],
      },
    ),
    MorphologicalTemplate(
      title: 'Game Indie Kreatif 🎮',
      description: 'Kombinasi mekanik dan gaya visual untuk game indie Anda.',
      category: 'Game',
      isPremium: true,
      dimensions: {
        'Genre': ['Roguelike', 'Cozy Puzzle', 'Deckbuilder', 'Metroidvania'],
        'Gaya Visual': ['Pixel Art Retro', 'Low Poly 3D', 'Hand-drawn 2D', 'Teks Naratif'],
        'Mekanik Kunci': ['Time Loop', 'Pembalikan Gravitasi', 'Memasak Kuliner', 'Card Battler'],
      },
    ),
    MorphologicalTemplate(
      title: 'Inovasi F&B / Kuliner 🍜',
      description: 'Eksplorasi resep dan konsep bisnis kuliner unik.',
      category: 'F&B',
      isPremium: true,
      dimensions: {
        'Jenis Kuliner': ['Mie Nusantara', 'Pastry Manis', 'Kopi Susu', 'Camilan Sehat'],
        'Bahan Utama': ['Tepung Singkong', 'Susu Gandum (Oat)', 'Gula Aren Organik', 'Matcha Uji'],
        'Konsep Saji': ['Drive-Thru Kontainer', 'Fine Dining Santai', 'Kemasan Bento Keranjang', 'Dapur Bersama'],
      },
    ),
    MorphologicalTemplate(
      title: 'Kampanye Edukasi Sosial 📣',
      description: 'Metode menyebarkan pesan positif ke masyarakat luas.',
      category: 'Sosial',
      isPremium: true,
      dimensions: {
        'Media': ['Video TikTok Pendek', 'Podcast Dialog', 'Infografis Instagram', 'Zine Cetak Mini'],
        'Target Usia': ['Anak SD-SMP', 'Remaja SMA', 'Keluarga Muda', 'Lansia Aktif'],
        'Topik Utama': ['Kesehatan Mental', 'Literasi Keuangan', 'Peduli Sampah Plastik', 'Gizi Sehat Stunting'],
      },
    ),
  ];
}

// ==========================================
// 3. MORPHOLOGICAL ANALYSIS WORKSPACE (SLOT MACHINE SPIN)
// ==========================================
class MorphologicalWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final bool isPremiumUser;
  final VoidCallback onPremiumLocked;

  const MorphologicalWorkspace({
    super.key,
    required this.onChanged,
    required this.isPremiumUser,
    required this.onPremiumLocked,
  });

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

  final Map<String, FixedExtentScrollController> _controllers = {};
  bool _isSpinning = false;
  Map<String, String>? _spinResult;

  @override
  void initState() {
    super.initState();
    for (var dim in _dimensions) {
      _controllers[dim] = FixedExtentScrollController();
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Morfologi Slot Machine:');
    _options.forEach((dim, list) {
      buffer.writeln('- Dimensi $dim: ${list.join(", ")}');
    });
    if (_spinResult != null) {
      buffer.writeln('Kombinasi Slot Terpilih 🎰:');
      _spinResult!.forEach((key, val) {
        buffer.writeln('  * $key -> $val');
      });
    }
    widget.onChanged(buffer.toString());
  }

  Future<void> _spinCombinations() async {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _spinResult = null;
    });

    final rng = Random();
    final result = <String, String>{};

    // Spin wheels with staggered offsets
    for (int i = 0; i < _dimensions.length; i++) {
      final dim = _dimensions[i];
      final opts = _options[dim] ?? [];
      if (opts.isEmpty) continue;

      final targetItem = rng.nextInt(opts.length);
      result[dim] = opts[targetItem];

      // Get current position safely
      int currentItem = 0;
      try {
        currentItem = _controllers[dim]!.selectedItem;
      } catch (_) {}

      // Spin at least 3-5 full rotations (e.g. 24, 36, 48 items)
      final int spinCycles = 24 + (i * 12);
      
      // Calculate target index that lands on targetItem modulo opts.length
      final int baseTarget = currentItem + spinCycles;
      final int remainderDiff = (targetItem - (baseTarget % opts.length) + opts.length) % opts.length;
      final int targetIndex = baseTarget + remainderDiff;

      _controllers[dim]!.animateToItem(
        targetIndex,
        duration: Duration(milliseconds: 1800 + i * 600), // Staggered stopping times (1.8s, 2.4s, 3.0s)
        curve: Curves.easeOutCirc, // Starts lightning fast, then decelerates heavily like a mechanical reel
      );
    }

    // Wait until the last wheel stops
    await Future.delayed(Duration(milliseconds: 1800 + (_dimensions.length - 1) * 600));

    if (mounted) {
      setState(() {
        _isSpinning = false;
        _spinResult = result;
      });
      _notifyChanges();
    }
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
          content: TextField(controller: controller, autofocus: true),
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
                    _controllers[dim] = FixedExtentScrollController();
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

  void _showTemplateMarketplace() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perpustakaan Dimensi 🛒',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Pilih dari set parameter siap-pakai untuk memancing kreativitas Anda secara instan!',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Library list
              Expanded(
                child: ListView.builder(
                  itemCount: MorphologicalTemplate.library.length,
                  itemBuilder: (context, index) {
                    final t = MorphologicalTemplate.library[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.onBackground.withOpacity(0.08),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Row(
                          children: [
                            Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.category,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                            ),
                            if (t.isPremium) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(t.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: t.dimensions.keys.map((k) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onBackground.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    k,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (t.isPremium && !widget.isPremiumUser) {
                            Navigator.pop(context);
                            widget.onPremiumLocked();
                            return;
                          }
                          // Apply template
                          setState(() {
                            // Dispose previous controllers
                            _controllers.forEach((_, c) => c.dispose());
                            _controllers.clear();

                            _dimensions.clear();
                            _options.clear();

                            t.dimensions.forEach((dim, opts) {
                              _dimensions.add(dim);
                              _options[dim] = List.from(opts);
                              _controllers[dim] = FixedExtentScrollController();
                            });
                            _spinResult = null;
                          });
                          _notifyChanges();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Template "${t.title}" berhasil diterapkan!'),
                              backgroundColor: theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
              '4. Slot Machine Kombinasi Morfologi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showTemplateMarketplace,
                  icon: const Icon(Icons.storefront_rounded, size: 16),
                  label: const Text('Marketplace', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: _addDimension,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Slot Machine Reels Layout
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: theme.colorScheme.onBackground.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.08), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            children: _dimensions.map((dim) {
              final opts = _options[dim] ?? [];
              final controller = _controllers[dim]!;

              return Expanded(
                child: Column(
                  children: [
                    // Column Title
                    Text(
                      dim.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Reel Box
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.black87, // Dark themed reel for absolute premium contrast
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.4), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Slot Wheel
                              if (opts.isNotEmpty)
                                ListWheelScrollView.useDelegate(
                                  controller: controller,
                                  itemExtent: 32,
                                  physics: const FixedExtentScrollPhysics(),
                                  childDelegate: ListWheelChildLoopingListDelegate(
                                    children: opts.map((opt) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            opt,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white, // Absolute high contrast text
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              else
                                const Center(
                                  child: Text('Kosong', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ),

                              // Glowing center indicator highlight
                              IgnorePointer(
                                child: Center(
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.15),
                                      border: Border.symmetric(
                                        horizontal: BorderSide(
                                          color: theme.colorScheme.primary.withOpacity(0.7),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Top fade gradient overlay
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 24,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.black, Colors.transparent],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom fade gradient overlay
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 24,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [Colors.black, Colors.transparent],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Spin Trigger
        ElevatedButton.icon(
          onPressed: _isSpinning ? null : _spinCombinations,
          icon: Icon(_isSpinning ? Icons.refresh_rounded : Icons.casino_rounded),
          label: Text(_isSpinning ? 'Sedang Memutar...' : 'Putar Dadu Acak 🎲'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
        ),
        const SizedBox(height: 12),

        // Dimensions editor list
        ..._dimensions.map((dim) {
          final list = _options[dim] ?? [];
          return Row(
            children: [
              Expanded(
                child: Text(
                  '$dim (${list.length} opsi)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => _addOption(dim),
                child: const Text('+ Opsi', style: TextStyle(fontSize: 11)),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ==========================================
// 4. RAPID BRAINSTORM WORKSPACE (ANIMATED BUBBLES)
// ==========================================
class RapidBrainstormWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RapidBrainstormWorkspace({super.key, required this.onChanged});

  @override
  State<RapidBrainstormWorkspace> createState() => _RapidBrainstormWorkspaceState();
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
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 350));
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kuantitas Ide: ${_ideas.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            if (_ideas.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _ideas.clear();
                  });
                  _notifyChanges();
                },
                child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
          ],
        ),
        const SizedBox(height: 4),

        // Animated Bubble tags display
        SizedBox(
          height: 120,
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _ideas.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index, animation) {
              final idea = _ideas[index];
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
                  CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                ),
                child: ScaleTransition(
                  scale: animation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(idea, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
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
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.grey),
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
                trailing: GestureDetector(
                  onTap: () => _toggleStar(index),
                  child: AnimatedScale(
                    scale: isStarred ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.bounceOut,
                    child: Icon(
                      isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isStarred ? Colors.amber : Colors.grey,
                    ),
                  ),
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

// ==========================================
// 6. RANDOM WORD WORKSPACE
// ==========================================
class RandomWordWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RandomWordWorkspace({super.key, required this.onChanged});

  @override
  State<RandomWordWorkspace> createState() => _RandomWordWorkspaceState();
}

class _RandomWordWorkspaceState extends State<RandomWordWorkspace> {
  final List<String> _words = const [
    'Jembatan', 'Awan', 'Kunci', 'Magnet', 'Kepompong', 'Lensa', 'Jaring', 'Kompas',
    'Cermin', 'Benih', 'Sarang', 'Jangkar', 'Roda', 'Lentera', 'Garam', 'Pahat',
    'Pasang', 'Surut', 'Rantai', 'Sayap', 'Pondasi', 'Katalis', 'Radar', 'Teropong',
    'Filter', 'Gema', 'Kristal', 'Saringan', 'Peta', 'Gembok'
  ];

  final Map<String, String> _wordHints = const {
    'Jembatan': 'Bagaimana Anda bisa menghubungkan dua area/ide yang sebelumnya terpisah?',
    'Awan': 'Bagaimana jika solusi Anda bisa diakses secara bebas, melayang, atau berubah bentuk?',
    'Kunci': 'Bagaimana cara membuka sumbat/hambatan terbesar dalam masalah Anda?',
    'Magnet': 'Bagaimana cara menarik orang, sumber daya, atau perhatian secara natural?',
    'Kepompong': 'Apakah solusi Anda membutuhkan fase proteksi atau transformasi tersembunyi terlebih dahulu?',
    'Lensa': 'Bagaimana cara memperbesar detail terkecil, atau melihat masalah dari sudut pandang makro?',
  };

  String? _currentWord;
  final TextEditingController _notesController = TextEditingController();

  void _generateWord() {
    final rng = Random();
    final word = _words[rng.nextInt(_words.length)];
    setState(() {
      _currentWord = word;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final hint = _wordHints[_currentWord] ?? 'Gunakan analogi kata ini untuk memecahkan hambatan berpikir Anda.';
    final buffer = StringBuffer();
    buffer.writeln('Asosiasi Kata Acak (Random Word):');
    if (_currentWord != null) {
      buffer.writeln('- Kata terpilih: $_currentWord');
      buffer.writeln('- Analogi pemicu: $hint');
    }
    buffer.writeln('- Catatan Ide: ${_notesController.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _notesController.removeListener(_notifyChanges);
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hint = _wordHints[_currentWord] ?? 'Gunakan analogi kata ini untuk memecahkan hambatan berpikir Anda.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Eksplorasi Asosiasi Kata Acak',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // Display Word Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              if (_currentWord != null) ...[
                Text(
                  _currentWord!,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ] else ...[
                const Icon(Icons.help_outline_rounded, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                const Text(
                  'Tekan tombol di bawah untuk menarik kata acak inspiratif!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _generateWord,
                icon: const Icon(Icons.casino_rounded),
                label: const Text('Dapatkan Kata Acak 🎲'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Notes field
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Bagaimana kata ini memicu ide baru Anda?',
            hintText: 'Tuliskan asosiasi atau analogi ide Anda di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 7. ROLE STORMING WORKSPACE
// ==========================================
class PersonaModel {
  final String name;
  final String mindset;
  final String avatar;
  final String detailedDescription;

  const PersonaModel({
    required this.name,
    required this.mindset,
    required this.avatar,
    required this.detailedDescription,
  });
}

class PersonaPackage {
  final String id;
  final String title;
  final String desc;
  final bool isPremium;
  final List<PersonaModel> personas;

  const PersonaPackage({
    required this.id,
    required this.title,
    required this.desc,
    required this.isPremium,
    required this.personas,
  });

  static const List<PersonaPackage> library = [
    PersonaPackage(
      id: 'universal',
      title: 'Universal Archetypes (Umum)',
      desc: 'Set tipe berpikir kognitif universal yang sangat praktis untuk memecahkan segala hambatan hidup.',
      isPremium: false,
      personas: [
        PersonaModel(
          name: 'Sang Empatis',
          mindset: 'Melihat dari kacamata perasaan orang lain yang terdampak. Bagaimana mengurangi gesekan emosional dan memberi kedamaian?',
          avatar: '🤝',
          detailedDescription: 'Sang Empatis menaruh perhatian penuh pada dimensi kemanusiaan, kenyamanan emosional, dan dampak sosial. Dia selalu memikirkan bagaimana perasaan orang yang menggunakan atau terkena dampak dari solusi ini.\n\n🛡️ Aturan Berpikir:\n- Utamakan keselamatan psikologis, kemudahan interaksi, dan inklusivitas.\n- Kurangi gesekan emosional (frustrasi, kebingungan, kecemasan) di setiap titik sentuh.\n\n❓ Pertanyaan Kunci:\n- Apakah solusi ini melukai perasaan atau mendiskriminasi seseorang?\n- Bagaimana kita bisa membangun kedekatan emosional dan empati dengan pengguna?\n- Bagaimana cara membuat pengguna merasa sangat dihargai dan aman sejak detik pertama?',
        ),
        PersonaModel(
          name: 'Sang Skeptis',
          mindset: 'Mencari asumsi yang salah, cacat logika, dan apa saja yang bisa berjalan buruk dari ide ini.',
          avatar: '🔎',
          detailedDescription: 'Sang Skeptis berperan sebagai Devil\'s Advocate (penentang ide). Tugas utamanya adalah meragukan segala hal, berasumsi bahwa rencana ini pasti gagal, dan mencari semua lubang atau cacat logika di dalamnya.\n\n🛡️ Aturan Berpikir:\n- Jangan menerima klaim atau asumsi tanpa bukti nyata.\n- Anggap kondisi terburuk (Murphy\'s Law) pasti akan terjadi jika dibiarkan tanpa mitigasi.\n\n❓ Pertanyaan Kunci:\n- Asumsi apa saja yang belum terbukti atau mengandung bias subjektif di sini?\n- Di mana letak kegagalan sistem paling fatal jika rencana ini dieksekusi hari ini?\n- Apa rencana cadangan kita jika server mati, pasar hancur, atau user membenci fitur ini?',
        ),
        PersonaModel(
          name: 'Sang Minimalis',
          mindset: 'Menerapkan prinsip Pareto 80/20. Solusi apa yang paling sederhana, membuang kompleksitas tak perlu?',
          avatar: '🍃',
          detailedDescription: 'Sang Minimalis menganut filosofi \'Less is More\' dan hukum Pareto 80/20. Dia membenci fitur berlebihan (feature creep), opsi yang membingungkan, dan kompleksitas alur kerja.\n\n🛡️ Aturan Berpikir:\n- Sederhanakan alur hingga ke titik yang tidak bisa dikurangi lagi tanpa merusak fungsi inti.\n- Pangkas 80% hal tidak krusial dan fokus 100% pada 20% inti yang mendatangkan nilai terbesar.\n\n❓ Pertanyaan Kunci:\n- Apa satu-satunya elemen paling bernilai dan esensial di dalam solusi ini?\n- Apa yang bisa kita hapus sepenuhnya tanpa mengurangi kegunaan utama?\n- Bagaimana cara agar solusi ini bekerja hanya dalam sekali klik atau langkah?',
        ),
        PersonaModel(
          name: 'Sang Futuris',
          mindset: 'Menganalisis dampak jangka panjang ke depan. Apa konsekuensinya dalam 10 hari, 10 bulan, dan 10 tahun (Prinsip 10/10/10)?',
          avatar: '⏳',
          detailedDescription: 'Sang Futuris memikirkan rantai efek jangka panjang (second-order effects). Dia tidak tertarik pada hasil instan hari ini saja, melainkan dampak kelangsungan di masa depan menggunakan aturan 10/10/10.\n\n🛡️ Aturan Berpikir:\n- Lihat konsekuensi dari konsekuensi (efek domino masa depan).\n- Pastikan solusi berkelanjutan dan tidak menciptakan utang teknis atau moral di kemudian hari.\n\n❓ Pertanyaan Kunci:\n- Apa akibat langsung keputusan ini dalam 10 hari ke depan?\n- Bagaimana keadaan dan tantangannya dalam 10 bulan mendatang?\n- Bagaimana posisi dan dampaknya dalam 10 tahun ke depan? Apakah ini berkelanjutan?',
        ),
      ],
    ),
    PersonaPackage(
      id: 'business',
      title: 'Bisnis & Produk 👑',
      desc: 'Set persona eksternal untuk menguji kelayakan pasar, profitabilitas, dan kenyamanan pengguna.',
      isPremium: true,
      personas: [
        PersonaModel(
          name: 'Pelanggan Cerewet',
          mindset: 'Mencari-cari keluhan penggunaan, kerepotan kecil, dan alasan mengapa ia enggan membayar solusi ini.',
          avatar: '🤬',
          detailedDescription: 'Pelanggan Cerewet mewakili pengguna akhir yang tidak sabaran, mudah bingung, mudah menyerah, dan sangat sensitif terhadap biaya atau waktu yang dihabiskan.\n\n🛡️ Aturan Berpikir:\n- Abaikan keindahan teknologi di belakang layar, fokus hanya pada kenyamanan instan.\n- Asumsikan pengguna memiliki waktu perhatian (attention span) yang sangat pendek dan malas membaca panduan.\n\n❓ Pertanyaan Kunci:\n- Mengapa saya harus repot-repot mendaftar dan menggunakan aplikasi ini?\n- Mengapa alur pendaftaran, pembayaran, atau navigasi ini sangat menyulitkan saya?\n- Jika ada masalah kecil, apakah saya langsung ingin menutup aplikasi ini?',
        ),
        PersonaModel(
          name: 'Investor Kejam',
          mindset: 'Menghitung efisiensi alokasi dana dan kelangsungan modal. Bagaimana cara solusi ini mencetak profit berlipat?',
          avatar: '💰',
          detailedDescription: 'Investor Kejam memandang ide murni dari kacamata angka, matematika bisnis, efisiensi alokasi modal, dan pengembalian investasi (ROI).\n\n🛡️ Aturan Berpikir:\n- Cari kejelasan model bisnis dan aliran pendapatan (monetisasi).\n- Tolak proyek idealis tanpa rencana skalabilitas ekonomi yang masuk akal.\n\n❓ Pertanyaan Kunci:\n- Berapa biaya akuisisi pengguna (CAC) dan nilai hidup pengguna (LTV)?\n- Kapan proyek ini mencapai titik impas (break-even point)?\n- Di mana potensi kebocoran anggaran terbesar yang harus dipangkas?',
        ),
        PersonaModel(
          name: 'Kompetitor Licik',
          mindset: 'Menganalisis cara pesaing akan meniru ide Anda, menyerang kelemahan Anda, atau mencuri audiens Anda.',
          avatar: '🦊',
          detailedDescription: 'Kompetitor Licik memikirkan bagaimana cara merebut pangsa pasar Anda, memplagiasi fitur Anda secara legal dengan biaya lebih murah, atau membalikkan keunggulan kompetitif Anda.\n\n🛡️ Aturan Berpikir:\n- Cari kelemahan pemasaran, operasional, atau hukum Anda.\n- Pikirkan cara memotong harga atau menawarkan fitur serupa secara gratis untuk merusak posisi Anda.\n\n❓ Pertanyaan Kunci:\n- Apa keunikan produk ini yang tidak bisa kami tiru dalam waktu 2 minggu?\n- Bagaimana cara merebut basis pengguna mereka dengan kampanye pemasaran tandingan?\n- Di mana letak celah geografis atau demografis yang mereka abaikan?',
        ),
      ],
    ),
    PersonaPackage(
      id: 'career',
      title: 'Karir & Self-Growth 👑',
      desc: 'Persona pendukung untuk memoles kualitas portofolio, masa depan karir, dan kebiasaan harian Anda.',
      isPremium: true,
      personas: [
        PersonaModel(
          name: 'Mentor Bijaksana',
          mindset: 'Nasihat objektif berumur panjang dari kacamata sosok guru spiritual atau panutan terpintar Anda.',
          avatar: '🦉',
          detailedDescription: 'Mentor Bijaksana mewakili kebijaksanaan jangka panjang, integritas diri, ketenangan emosional, dan kesehatan mental.\n\n🛡️ Aturan Berpikir:\n- Utamakan kedamaian hidup, kesehatan hubungan, dan prinsip etika.\n- Jauhi obsesi kepuasan instan dan kepanikan jangka pendek.\n\n❓ Pertanyaan Kunci:\n- Apakah keputusan ini selaras dengan nilai inti hidup Anda?\n- Nasihat apa yang akan diberikan versi diri Anda yang berumur 80 tahun?\n- Bagaimana keputusan ini berkontribusi pada warisan hidup Anda?',
        ),
        PersonaModel(
          name: 'Perekrut Kerja',
          mindset: 'Menilai apakah langkah/tindakan ini benar-benar bernilai tinggi di industri nyata atau hanya sekadar buang waktu.',
          avatar: '🎯',
          detailedDescription: 'Perekrut Kerja menilai segala tindakan dari kacamata nilai industri, kelayakan profesional, dan relevansi keahlian Anda di pasar kerja.\n\n🛡️ Aturan Berpikir:\n- Cari keahlian yang sedang diminati pasar tinggi.\n- Pastikan hasil kerja bisa diukur secara konkret untuk ditaruh di CV/Resume.\n\n❓ Pertanyaan Kunci:\n- Apakah mempelajari hal ini membuat portofolio Anda bernilai tinggi?\n- Bagaimana cara Anda mendemonstrasikan keahlian ini secara konkret kepada perekrut?',
        ),
        PersonaModel(
          name: 'Sahabat Jujur',
          mindset: 'Mengatakan kebenaran paling pahit secara telanjang tanpa polesan basa-basi demi menyadarkan Anda.',
          avatar: '💬',
          detailedDescription: 'Sahabat Jujur adalah orang terdekat yang tidak memiliki agenda selain menginginkan keselamatan dan keberhasilan sejati Anda.\n\n🛡️ Aturan Berpikir:\n- Katakan kebenaran pahit secara telanjang demi kebaikan jangka panjang.\n- Jangan biarkan teman Anda terjebak dalam angan-angan kosong (delusi).\n\n❓ Pertanyaan Kunci:\n- Apakah kamu benar-benar bekerja keras atau hanya sibuk mencari pembenaran?\n- Mengapa kamu terus mempertahankan proyek yang jelas-jelas tidak berhasil ini?',
        ),
      ],
    ),
    PersonaPackage(
      id: 'relationships',
      title: 'Hubungan & Konflik 👑',
      desc: 'Set persona netral untuk menengahi gesekan komunikasi dengan teman, pasangan, atau rekan tim.',
      isPremium: true,
      personas: [
        PersonaModel(
          name: 'Mediator Netral',
          mindset: 'Menyeimbangkan keadilan bagi kedua belah pihak. Bagaimana solusi jalan tengah (win-win) tanpa berat sebelah?',
          avatar: '⚖️',
          detailedDescription: 'Mediator Netral bertindak sebagai penengah yang adil di tengah konflik interpersonal.\n\n🛡️ Aturan Berpikir:\n- Dengarkan kedua belah pihak dengan empati seimbang.\n- Cari solusi kompromi (win-win) di mana kedua pihak tidak merasa dirugikan.\n\n❓ Pertanyaan Kunci:\n- Apa kebutuhan mendasar yang diinginkan oleh Pihak A?\n- Apa ketakutan terbesar dari Pihak B?\n- Bagaimana membuat kesepakatan tengah yang menjembatani perbedaan?',
        ),
        PersonaModel(
          name: 'Pasangan Terluka',
          mindset: 'Berempati penuh pada kerentanan emosional atau rasa diabaikan dari orang terdekat akibat keputusan Anda.',
          avatar: '💔',
          detailedDescription: 'Pasangan Terluka menyuarakan kerentanan perasaan, kebutuhan akan kehadiran fisik/emosional, dan dampak pengabaian dari keputusan Anda terhadap hubungan pribadi.\n\n🛡️ Aturan Berpikir:\n- Utamakan keharmonisan rumah tangga, keluarga, dan waktu bersama orang tercinta.\n- Ingatkan bahwa karir/bisnis bukanlah segalanya.\n\n❓ Pertanyaan Kunci:\n- Apakah kesibukan mengejar karir ini membuatku kehilangan kehadiranmu?\n- Mengapa keputusan penting ini tidak didiskusikan denganku terlebih dahulu?',
        ),
      ],
    ),
  ];
}

class RoleStormingWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final bool isPremiumUser;
  final VoidCallback onPremiumLocked;

  const RoleStormingWorkspace({
    super.key,
    required this.onChanged,
    required this.isPremiumUser,
    required this.onPremiumLocked,
  });

  @override
  State<RoleStormingWorkspace> createState() => _RoleStormingWorkspaceState();
}

class _RoleStormingWorkspaceState extends State<RoleStormingWorkspace> {
  PersonaPackage _activePackage = PersonaPackage.library[0];
  int _selectedPersonaIndex = 0;
  final TextEditingController _notesController = TextEditingController();

  void _notifyChanges() {
    if (_selectedPersonaIndex >= _activePackage.personas.length) {
      _selectedPersonaIndex = 0;
    }
    final persona = _activePackage.personas[_selectedPersonaIndex];
    final buffer = StringBuffer();
    buffer.writeln('Sudut Pandang Persona (Role Storming):');
    buffer.writeln('- Paket Aktif: ${_activePackage.title}');
    buffer.writeln('- Persona Aktif: ${persona.name} ${persona.avatar}');
    buffer.writeln('- Pola Pikir: ${persona.mindset}');
    buffer.writeln('- Catatan Ide Persona: ${_notesController.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _notesController.removeListener(_notifyChanges);
    _notesController.dispose();
    super.dispose();
  }

  void _openMarketplace() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.style_rounded, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Marketplace Paket Persona 🎭',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Text(
                    'Pilih paket sudut pandang kognitif untuk memancing gagasan kreatif secara instan.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: PersonaPackage.library.length,
                      itemBuilder: (context, index) {
                        final pkg = PersonaPackage.library[index];
                        final isCurrentlyActive = pkg.id == _activePackage.id;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isCurrentlyActive
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onBackground.withOpacity(0.08),
                              width: isCurrentlyActive ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: pkg.isPremium ? Colors.amber.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  pkg.personas.first.avatar,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              pkg.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            subtitle: Text(
                              pkg.desc,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            trailing: isCurrentlyActive
                                ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                                : pkg.isPremium
                                    ? const Icon(Icons.lock_rounded, color: Colors.amber, size: 20)
                                    : const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              if (pkg.isPremium && !widget.isPremiumUser) {
                                Navigator.pop(context);
                                widget.onPremiumLocked();
                                return;
                              }
                              setState(() {
                                _activePackage = pkg;
                                _selectedPersonaIndex = 0;
                              });
                              _notifyChanges();
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailedDescription(PersonaModel persona) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(persona.avatar, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  persona.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              persona.detailedDescription,
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final persona = _activePackage.personas[_selectedPersonaIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '4. Pilih Persona Berpikir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            TextButton.icon(
              onPressed: _openMarketplace,
              icon: const Icon(Icons.storefront_rounded, size: 16),
              label: const Text(
                'Marketplace',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Persona Selection List
        SizedBox(
          height: 65,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _activePackage.personas.length,
            itemBuilder: (context, index) {
              final p = _activePackage.personas[index];
              final isSelected = index == _selectedPersonaIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPersonaIndex = index;
                  });
                  _notifyChanges();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(p.avatar, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Profile Mindset Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mindset ${persona.name}:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  TextButton.icon(
                    onPressed: () => _showDetailedDescription(persona),
                    icon: const Icon(Icons.menu_book_rounded, size: 12),
                    label: const Text('Hayati Lebih Dalam 📖', style: TextStyle(fontSize: 10)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                persona.mindset,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Text input notes
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Bagaimana ${persona.name} menyelesaikan masalah ini?',
            hintText: 'Tuliskan analisis atau pemikiran dari sudut pandang ini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 8. SIX THINKING HATS WORKSPACE
// ==========================================
class SixThinkingHatsWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const SixThinkingHatsWorkspace({super.key, required this.onChanged});

  @override
  State<SixThinkingHatsWorkspace> createState() => _SixThinkingHatsWorkspaceState();
}

class _SixThinkingHatsWorkspaceState extends State<SixThinkingHatsWorkspace> {
  final List<Map<String, dynamic>> _hats = [
    {
      'color': Colors.white,
      'borderColor': Colors.black45,
      'textColor': Colors.black87,
      'name': 'Topi Putih',
      'label': 'Fakta & Data',
      'hint': 'Informasi apa saja yang kita miliki? Data apa yang masih kurang?',
    },
    {
      'color': Colors.red,
      'borderColor': Colors.redAccent,
      'textColor': Colors.white,
      'name': 'Topi Merah',
      'label': 'Firasat & Emosi',
      'hint': 'Bagaimana intuisi atau perasaan Anda melihat masalah ini tanpa logika?',
    },
    {
      'color': Colors.black,
      'borderColor': Colors.black,
      'textColor': Colors.white,
      'name': 'Topi Hitam',
      'label': 'Risiko & Kelemahan',
      'hint': 'Mengapa ide ini bisa gagal? Apa saja risiko/hambatan terburuknya?',
    },
    {
      'color': Colors.amber,
      'borderColor': Colors.amber,
      'textColor': Colors.black87,
      'name': 'Topi Kuning',
      'label': 'Manfaat & Harapan',
      'hint': 'Apa keuntungan dan nilai positif dari solusi ini? Mengapa ini berhasil?',
    },
    {
      'color': Colors.green,
      'borderColor': Colors.green,
      'textColor': Colors.white,
      'name': 'Topi Hijau',
      'label': 'Kreativitas & Opsi',
      'hint': 'Opsi alternatif apa lagi yang belum kita coba? Pikirkan solusi liar!',
    },
    {
      'color': Colors.blue,
      'borderColor': Colors.blue,
      'textColor': Colors.white,
      'name': 'Topi Biru',
      'label': 'Kontrol Proses',
      'hint': 'Apa kesimpulan akhir kita? Apa langkah selanjutnya yang harus diambil?',
    },
  ];

  int _selectedHatIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _hats.length; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Six Thinking Hats:');
    for (int i = 0; i < _hats.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln('- ${_hats[i]['name']} (${_hats[i]['label']}): $text');
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeHat = _hats[_selectedHatIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Analisis 6 Topi Berpikir (Six Hats)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),

        // Hats horizontal wrap
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(_hats.length, (index) {
            final h = _hats[index];
            final isSelected = index == _selectedHatIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHatIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: h['color'] as Color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : (h['borderColor'] as Color).withOpacity(0.5),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                ),
                child: Text(
                  h['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: h['textColor'] as Color,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Hat Instructions Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (activeHat['color'] as Color).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (activeHat['borderColor'] as Color).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${activeHat['name']} — ${activeHat['label']}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: activeHat['color'] == Colors.white ? Colors.black87 : activeHat['color'] as Color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activeHat['hint'] as String,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Active Hat notes field
        TextFormField(
          controller: _controllers[_selectedHatIndex],
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Catatan untuk ${activeHat['name']}',
            hintText: 'Tuliskan analisis kognitif Anda di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 9. DISNEY STRATEGY WORKSPACE (THREE ROOMS)
// ==========================================
class DisneyStrategyWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const DisneyStrategyWorkspace({super.key, required this.onChanged});

  @override
  State<DisneyStrategyWorkspace> createState() => _DisneyStrategyWorkspaceState();
}

class _DisneyStrategyWorkspaceState extends State<DisneyStrategyWorkspace> {
  int _activeRoomIndex = 0; // 0 = Dreamer, 1 = Realist, 2 = Critic

  final List<Map<String, String>> _rooms = const [
    {
      'title': '1. Ruang Dreamer ☁️',
      'hint': 'Tuliskan visi terbesar Anda tanpa batasan logistik atau finansial. Berimajinasilah!',
      'label': 'Visi Dreamer (Impian)',
      'gradientStart': '0xFF4F83CC',
      'gradientEnd': '0xFF96C0CE',
    },
    {
      'title': '2. Ruang Realist 🛠️',
      'hint': 'Bagaimana cara merealisasikan mimpi ini? Tulis rencana taktis dan langkah konkret.',
      'label': 'Langkah Realist (Rencana)',
      'gradientStart': '0xFF5C8D89',
      'gradientEnd': '0xFF8FB9A8',
    },
    {
      'title': '3. Ruang Critic 🔎',
      'hint': 'Temukan celah, risiko, dan kelemahan rencana ini secara kritis untuk memolesnya.',
      'label': 'Analisis Critic (Evaluasi)',
      'gradientStart': '0xFF7E8A97',
      'gradientEnd': '0xFFB2BEC3',
    },
  ];

  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Disney Strategy:');
    buffer.writeln('- DREAMER: ${_controllers[0]!.text.trim()}');
    buffer.writeln('- REALIST: ${_controllers[1]!.text.trim()}');
    buffer.writeln('- CRITIC: ${_controllers[2]!.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = _rooms[_activeRoomIndex];
    final colorStart = Color(int.parse(room['gradientStart']!));
    final colorEnd = Color(int.parse(room['gradientEnd']!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Lembar Kerja Disney Strategy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),

        // Tabs Row
        Row(
          children: List.generate(3, (index) {
            final r = _rooms[index];
            final isActive = index == _activeRoomIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeRoomIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    r['title']!.split(' ')[1], // show short label like Dreamer, Realist, Critic
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Aesthetic Gradient Room Banner
        Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colorStart, colorEnd]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                room['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                room['hint']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.white70, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Active room editor
        TextFormField(
          controller: _controllers[_activeRoomIndex],
          maxLines: 5,
          decoration: InputDecoration(
            labelText: room['label'],
            hintText: 'Tuliskan poin-poin ide Anda di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 10. SCAMPER ACCORDION WORKSPACE
// ==========================================
class ScamperWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const ScamperWorkspace({super.key, required this.onChanged});

  @override
  State<ScamperWorkspace> createState() => _ScamperWorkspaceState();
}

class _ScamperWorkspaceState extends State<ScamperWorkspace> {
  final List<Map<String, String>> _panels = const [
    {'key': 'S', 'name': 'Substitute (Substitusi)', 'hint': 'Komponen, bahan, atau proses apa yang bisa kita ganti?'},
    {'key': 'C', 'name': 'Combine (Kombinasi)', 'hint': 'Bagaimana cara menggabungkan ide ini dengan produk/layanan lain?'},
    {'key': 'A', 'name': 'Adapt (Adaptasi)', 'hint': 'Bagaimana cara mengadaptasi ide sukses dari industri lain ke masalah ini?'},
    {'key': 'M', 'name': 'Modify (Modifikasi)', 'hint': 'Apakah kita bisa mengubah bentuk, ukuran, atau kemasan menjadi lebih besar/kecil?'},
    {'key': 'P', 'name': 'Put to another use', 'hint': 'Bagaimana jika ide ini digunakan untuk segmen pasar/tujuan yang berbeda?'},
    {'key': 'E', 'name': 'Eliminate (Eliminasi)', 'hint': 'Bagian/fitur apa yang paling tidak penting dan bisa kita hilangkan saja?'},
    {'key': 'R', 'name': 'Reverse (Pembalikan)', 'hint': 'Bagaimana jika kita membalik alur prosesnya dari belakang ke depan?'},
  ];

  int _expandedIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _panels.length; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Kerangka Kerja SCAMPER:');
    for (int i = 0; i < _panels.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln('- [${_panels[i]['key']}] ${_panels[i]['name']}: $text');
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Check-List Kreatif SCAMPER',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),

        // Accordion-like cards list
        ...List.generate(_panels.length, (index) {
          final p = _panels[index];
          final isExpanded = index == _expandedIndex;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isExpanded ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.08),
                width: isExpanded ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header tap
                ListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isExpanded ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        p['key']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isExpanded ? theme.colorScheme.onPrimary : theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                  title: Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  trailing: Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? -1 : index;
                    });
                  },
                ),

                // Expanded content
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          p['hint']!,
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _controllers[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Tulis ide SCAMPER Anda di sini...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================
// 11. SWOT MATRIX WORKSPACE (2x2 GRID)
// ==========================================
class SwotMatrixWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const SwotMatrixWorkspace({super.key, required this.onChanged});

  @override
  State<SwotMatrixWorkspace> createState() => _SwotMatrixWorkspaceState();
}

class _SwotMatrixWorkspaceState extends State<SwotMatrixWorkspace> {
  final Map<String, TextEditingController> _controllers = {
    'S': TextEditingController(),
    'W': TextEditingController(),
    'O': TextEditingController(),
    'T': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _controllers.forEach((_, c) => c.addListener(_notifyChanges));
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.removeListener(_notifyChanges));
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Matriks SWOT:');
    buffer.writeln('- STRENGTHS (Kekuatan): ${_controllers['S']!.text.trim()}');
    buffer.writeln('- WEAKNESSES (Kelemahan): ${_controllers['W']!.text.trim()}');
    buffer.writeln('- OPPORTUNITIES (Peluang): ${_controllers['O']!.text.trim()}');
    buffer.writeln('- THREATS (Ancaman): ${_controllers['T']!.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Matriks SWOT (Kuadran 2x2)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // 2x2 Grid quadrants layout
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            _buildSwotBox('STRENGTHS (S)', _controllers['S']!, Colors.green, theme),
            _buildSwotBox('WEAKNESSES (W)', _controllers['W']!, Colors.red, theme),
            _buildSwotBox('OPPORTUNITIES (O)', _controllers['O']!, Colors.blue, theme),
            _buildSwotBox('THREATS (T)', _controllers['T']!, Colors.orange, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildSwotBox(String label, TextEditingController controller, Color accentColor, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                hintText: 'Tuliskan poin...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 12. STARBURSTING WORKSPACE (6-POINT STAR)
// ==========================================
class StarburstingWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const StarburstingWorkspace({super.key, required this.onChanged});

  @override
  State<StarburstingWorkspace> createState() => _StarburstingWorkspaceState();
}

class _StarburstingWorkspaceState extends State<StarburstingWorkspace> {
  final List<Map<String, String>> _points = const [
    {'key': 'WHO', 'question': 'Siapa target pengguna, pesaing, atau aktor kunci utama?'},
    {'key': 'WHAT', 'question': 'Apa masalah inti, solusi alternatif, atau fiturnya?'},
    {'key': 'WHERE', 'question': 'Di mana produk ini dipasarkan atau diimplementasikan?'},
    {'key': 'WHEN', 'question': 'Kapan waktu rilis terbaik, deadline, atau batas peluncuran?'},
    {'key': 'WHY', 'question': 'Mengapa ide ini harus dibuat? Apa nilai keunikannya?'},
    {'key': 'HOW', 'question': 'Bagaimana cara mendistribusikan, membiayai, atau mempromosikannya?'},
  ];

  int _selectedPointIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _points.length; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Starbursting 5W1H Questions:');
    for (int i = 0; i < _points.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln('- [${_points[i]['key']}] ${_points[i]['question']}: $text');
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePoint = _points[_selectedPointIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Starbursting (Analisis 5W + 1H)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),

        // Grid of 6 star points buttons
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1.6,
          children: List.generate(_points.length, (index) {
            final p = _points[index];
            final isSelected = index == _selectedPointIndex;

            return GestureDetector(
              onTap: () => setState(() => _selectedPointIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    p['key']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Point Description Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fokus Pertanyaan ${activePoint['key']}:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                activePoint['question']!,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Active point editor
        TextFormField(
          controller: _controllers[_selectedPointIndex],
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Ajukan Pertanyaan Kritis untuk ${activePoint['key']}',
            hintText: 'Tuliskan draf pertanyaan di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 13. MIND DUMP WORKSPACE (STICKY NOTES)
// ==========================================
class MindDumpWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const MindDumpWorkspace({super.key, required this.onChanged});

  @override
  State<MindDumpWorkspace> createState() => _MindDumpWorkspaceState();
}

class _MindDumpWorkspaceState extends State<MindDumpWorkspace> {
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

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Hasil Kuras Pikiran (Mind Dump Sticky Notes):');
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Kuras Pikiran (Mind Dump Sticky Notes)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            hintText: 'Ketik apa saja yang ada di kepala Anda lalu tekan Enter...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
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
              color: theme.colorScheme.onBackground.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.06)),
            ),
            child: const Column(
              children: [
                Icon(Icons.note_alt_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Belum ada catatan tempel. Ketik sesuatu di atas untuk meluapkan isi kepala Anda!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
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
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${index + 1}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                        GestureDetector(
                          onTap: () => _removeNote(index),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _notes[index],
                          style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

// ==========================================
// 14. AFFINITY MAPPING WORKSPACE
// ==========================================
class AffinityMappingWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const AffinityMappingWorkspace({super.key, required this.onChanged});

  @override
  State<AffinityMappingWorkspace> createState() => _AffinityMappingWorkspaceState();
}

class _AffinityMappingWorkspaceState extends State<AffinityMappingWorkspace> {
  final List<Map<String, dynamic>> _items = [];
  final List<String> _groups = const ['Grup A (Hijau)', 'Grup B (Biru)', 'Grup C (Orange)'];

  final TextEditingController _inputController = TextEditingController();

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add({
          'text': text,
          'group': _groups[0], // default
        });
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

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Pengelompokan Affinity Mapping:');
    for (final group in _groups) {
      buffer.writeln('[$group]:');
      final matched = _items.where((item) => item['group'] == group).toList();
      if (matched.isEmpty) {
        buffer.writeln('  (Kosong)');
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Pengelompokan Affinity Mapping',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            hintText: 'Ketik gagasan/ide Anda lalu tekan Enter...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: _addItem,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _addItem(),
        ),
        const SizedBox(height: 12),

        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.colorScheme.onBackground.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onBackground.withOpacity(0.06)),
            ),
            child: const Column(
              children: [
                Icon(Icons.label_outline_rounded, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Belum ada ide. Tambahkan ide di atas lalu kelompokkan ke dalam grup!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item['text'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      DropdownButton<String>(
                        value: activeGroup,
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onBackground, fontWeight: FontWeight.bold),
                        underline: const SizedBox(),
                        items: _groups.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) _changeGroup(index, val);
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeItem(index),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
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
// 15. FIVE WHYS WORKSPACE (WHY CHAIN)
// ==========================================
class FiveWhysWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const FiveWhysWorkspace({super.key, required this.onChanged});

  @override
  State<FiveWhysWorkspace> createState() => _FiveWhysWorkspaceState();
}

class _FiveWhysWorkspaceState extends State<FiveWhysWorkspace> {
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Rantai 5 Whys (Akar Masalah):');
    for (int i = 0; i < 5; i++) {
      buffer.writeln('Why ${i + 1}: ${_controllers[i].text.trim()}');
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Rantai 5 Whys (Menelusuri Akar Masalah)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),

        ...List.generate(5, (index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vertical node indicator
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1 + (index * 0.1)),
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (index < 4)
                    Container(
                      width: 2,
                      height: 40,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Text Field
              Expanded(
                child: TextFormField(
                  controller: _controllers[index],
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: index == 0 ? 'Mengapa masalah ini terjadi?' : 'Mengapa hal itu bisa terjadi?',
                    hintText: 'Tuliskan analisis sebab Anda...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ==========================================
// 16. FIRST PRINCIPLES WORKSPACE (LADDER)
// ==========================================
class FirstPrinciplesWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const FirstPrinciplesWorkspace({super.key, required this.onChanged});

  @override
  State<FirstPrinciplesWorkspace> createState() => _FirstPrinciplesWorkspaceState();
}

class _FirstPrinciplesWorkspaceState extends State<FirstPrinciplesWorkspace> {
  final List<TextEditingController> _controllers = List.generate(3, (_) => TextEditingController());
  final List<String> _steps = const [
    'Asumsi Lama (Bagaimana orang biasa melakukannya)',
    'Fakta Dasar (Kebenaran fisik/logika murni)',
    'Konstruksi Baru (Solusi orisinil yang dirancang dari nol)'
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis First Principles (Dekonstruksi):');
    buffer.writeln('- ASUMSI LAMA: ${_controllers[0].text.trim()}');
    buffer.writeln('- FAKTA DASAR: ${_controllers[1].text.trim()}');
    buffer.writeln('- KONSTRUKSI BARU: ${_controllers[2].text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Tangga Dekonstruksi First Principles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),

        ...List.generate(3, (index) {
          final isLast = index == 2;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLast ? theme.colorScheme.primary.withOpacity(0.04) : theme.colorScheme.onBackground.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLast ? theme.colorScheme.primary.withOpacity(0.2) : theme.colorScheme.onBackground.withOpacity(0.08),
                width: isLast ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _steps[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLast ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers[index],
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan poin hasil pemikiran Anda...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================
// 17. DOUBLE DIAMOND WORKSPACE
// ==========================================
class DoubleDiamondWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const DoubleDiamondWorkspace({super.key, required this.onChanged});

  @override
  State<DoubleDiamondWorkspace> createState() => _DoubleDiamondWorkspaceState();
}

class _DoubleDiamondWorkspaceState extends State<DoubleDiamondWorkspace> {
  int _activeTab = 0; // 0=Discover, 1=Define, 2=Develop, 3=Deliver
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

  final List<Map<String, String>> _phases = const [
    {
      'title': '1. DISCOVER 🔍',
      'label': 'Divergen: Cari Wawasan',
      'hint': 'Tulis wawasan, riset lapangan, atau tren perilaku pengguna yang Anda temukan.',
    },
    {
      'title': '2. DEFINE 🎯',
      'label': 'Konvergen: Fokus Masalah',
      'hint': 'Rumuskan satu pernyataan masalah utama yang krusial untuk segera diselesaikan.',
    },
    {
      'title': '3. DEVELOP 💡',
      'label': 'Divergen: Eksplorasi Ide',
      'hint': 'Brainstorming berbagai alternatif solusi liar untuk memecahkan masalah utama.',
    },
    {
      'title': '4. DELIVER 🚀',
      'label': 'Konvergen: Eksekusi Solusi',
      'hint': 'Pilih satu solusi terbaik, buat prototipe kecil, dan rencanakan cara mengujinya.',
    },
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Proses Kerangka Kerja Double Diamond:');
    buffer.writeln('- DISCOVER: ${_controllers[0].text.trim()}');
    buffer.writeln('- DEFINE: ${_controllers[1].text.trim()}');
    buffer.writeln('- DEVELOP: ${_controllers[2].text.trim()}');
    buffer.writeln('- DELIVER: ${_controllers[3].text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = _phases[_activeTab];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Jalur Pipa Double Diamond',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),

        // Tabs Row
        Row(
          children: List.generate(4, (index) {
            final isActive = index == _activeTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    _phases[index]['title']!.split(' ')[1],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Active Phase Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${phase['title']} — ${phase['label']}:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                phase['hint']!,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Editor
        TextFormField(
          controller: _controllers[_activeTab],
          maxLines: 4,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: 'Catatan untuk Fase ${_phases[_activeTab]['title']!.split(' ')[1]}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 18. VALIDATION WORKSPACE (SCORECARD)
// ==========================================
class ValidationWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const ValidationWorkspace({super.key, required this.onChanged});

  @override
  State<ValidationWorkspace> createState() => _ValidationWorkspaceState();
}

class _ValidationWorkspaceState extends State<ValidationWorkspace> {
  final TextEditingController _asumsiController = TextEditingController();
  final List<String> _supports = [];
  final List<String> _opposes = [];
  bool _isValidated = true;

  final TextEditingController _supportInput = TextEditingController();
  final TextEditingController _opposeInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _asumsiController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _asumsiController.removeListener(_notifyChanges);
    _asumsiController.dispose();
    _supportInput.dispose();
    _opposeInput.dispose();
    super.dispose();
  }

  void _addSupport() {
    final text = _supportInput.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _supports.add(text);
        _supportInput.clear();
      });
      _notifyChanges();
    }
  }

  void _addOppose() {
    final text = _opposeInput.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _opposes.add(text);
        _opposeInput.clear();
      });
      _notifyChanges();
    }
  }

  void _removeSupport(int index) {
    setState(() {
      _supports.removeAt(index);
    });
    _notifyChanges();
  }

  void _removeOppose(int index) {
    setState(() {
      _opposes.removeAt(index);
    });
    _notifyChanges();
  }

  void _toggleValidation(bool val) {
    setState(() {
      _isValidated = val;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Lembar Validasi Asumsi Ide:');
    buffer.writeln('- ASUMSI UTAMA: ${_asumsiController.text.trim()}');
    buffer.writeln('- STATUS VALIDASI: ${_isValidated ? "VALID (Terbukti) 🟢" : "GUGUR (Terbantahkan) 🔴"}');
    buffer.writeln('- BUKTI PENDUKUNG (Supports):');
    if (_supports.isEmpty) buffer.writeln('  (Tidak ada)');
    for (final s in _supports) {
      buffer.writeln('  + $s');
    }
    buffer.writeln('- BUKTI PEMBANTAH (Opposes):');
    if (_opposes.isEmpty) buffer.writeln('  (Tidak ada)');
    for (final o in _opposes) {
      buffer.writeln('  - $o');
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Lembar Validasi & Verifikasi Asumsi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),

        // Asumsi Utama Input
        TextFormField(
          controller: _asumsiController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: 'Asumsi Utama yang Ingin Divalidasi',
            hintText: 'Misal: Pengguna bersedia membayar langganan bulanan...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),

        // Validation Status Toggle Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isValidated ? Colors.green.withOpacity(0.06) : Colors.red.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isValidated ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hasil Akhir Hipotesis:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _isValidated ? Colors.green : Colors.red),
              ),
              Row(
                children: [
                  Text(
                    _isValidated ? 'VALID (Terbukti) 🟢' : 'GUGUR (Terbantah) 🔴',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isValidated,
                    onChanged: _toggleValidation,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Side-by-side Evidence lists
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supports column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Bukti Pendukung (+)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _supportInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Ketik bukti...',
                      suffixIcon: GestureDetector(
                        onTap: _addSupport,
                        child: const Icon(Icons.add_circle, color: Colors.green, size: 20),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                    onSubmitted: (_) => _addSupport(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_supports.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.green.withOpacity(0.03),
                      child: ListTile(
                        title: Text(_supports[index], style: const TextStyle(fontSize: 10)),
                        trailing: GestureDetector(
                          onTap: () => _removeSupport(index),
                          child: const Icon(Icons.close_rounded, size: 12, color: Colors.redAccent),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Opposes column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Bukti Pembantah (-)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _opposeInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Ketik bukti...',
                      suffixIcon: GestureDetector(
                        onTap: _addOppose,
                        child: const Icon(Icons.add_circle, color: Colors.red, size: 20),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                    onSubmitted: (_) => _addOppose(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_opposes.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.red.withOpacity(0.03),
                      child: ListTile(
                        title: Text(_opposes[index], style: const TextStyle(fontSize: 10)),
                        trailing: GestureDetector(
                          onTap: () => _removeOppose(index),
                          child: const Icon(Icons.close_rounded, size: 12, color: Colors.redAccent),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}


