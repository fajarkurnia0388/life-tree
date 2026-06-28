import 'dart:math';
import 'package:flutter/material.dart';

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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
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
                        themeColor: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.85)
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.04)),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isCenter ? theme.colorScheme.primary : theme.colorScheme.onSurface)
                                    .withValues(alpha: 0.12),
                                blurRadius: 6,
                              )
                            ],
                            border: Border.all(
                              color: isCenter ? Colors.white : theme.colorScheme.primary.withValues(alpha: 0.3),
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
                                          : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
