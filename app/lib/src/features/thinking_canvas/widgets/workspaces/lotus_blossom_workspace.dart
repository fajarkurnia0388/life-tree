import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 2. RADIAL LOTUS BLOSSOM WORKSPACE
// ==========================================
class LotusBlossomWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onStructuredOutput;
  final String? initialStructuredOutput;
  final String? initialValue;

  const LotusBlossomWorkspace({
    super.key,
    required this.onChanged,
    this.onStructuredOutput,
    this.initialStructuredOutput,
    this.initialValue,
  });

  @override
  ConsumerState<LotusBlossomWorkspace> createState() =>
      _LotusBlossomWorkspaceState();
}

class _LotusBlossomWorkspaceState extends ConsumerState<LotusBlossomWorkspace> {
  final List<String> _cells = List.filled(9, '');
  int _activePetalIndex = -1; // -1 = center grid, 0-8 = sub grids
  final Map<int, List<String>> _subGrids = {};

  @override
  void initState() {
    super.initState();
    _cells[4] = DaojiText.resolve(
      DaojiTextKey.lotusCenterPlaceholder,
      ref.read(daojiVocabularyLevelValueProvider),
    );
    for (int i = 0; i < 9; i++) {
      if (i != 4) {
        _subGrids[i] = List.filled(9, '');
      }
    }
    // Restore from structured output if available
    if (widget.initialStructuredOutput != null) {
      try {
        final data = jsonDecode(widget.initialStructuredOutput!) as Map<String, dynamic>;
        final cells = data['cells'] as List<dynamic>?;
        if (cells != null) {
          for (int i = 0; i < cells.length && i < 9; i++) {
            _cells[i] = cells[i] as String? ?? '';
          }
        }
        final subGrids = data['subGrids'] as Map<String, dynamic>?;
        if (subGrids != null) {
          subGrids.forEach((key, value) {
            final idx = int.tryParse(key);
            if (idx != null) {
              _subGrids[idx] = (value as List<dynamic>).map((e) => e.toString()).toList();
            }
          });
        }
      } catch (_) {}
    }
    // Defer initial notify: calling widget.onChanged (which modifies a Riverpod
    // provider) inside initState is forbidden — it mutates state while the
    // widget tree is still being built. addPostFrameCallback fires after the
    // first frame, safely outside the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifyChanges();
    });
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
    widget.onStructuredOutput?.call(jsonEncode({
      'cells': _cells,
      'subGrids': _subGrids.map((k, v) => MapEntry(k.toString(), v)),
    }));
  }

  void _editCell(int index, bool isSubGrid) {
    final currentText = isSubGrid
        ? _subGrids[_activePetalIndex]![index]
        : _cells[index];
    final controller = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isSubGrid
                ? DaojiText.resolve(
                    DaojiTextKey.lotusEditSubTitle,
                    ref.read(daojiVocabularyLevelValueProvider),
                  )
                : (index == 4
                      ? DaojiText.resolve(
                          DaojiTextKey.lotusEditCenterTitle,
                          ref.read(daojiVocabularyLevelValueProvider),
                        )
                      : DaojiText.resolve(
                          DaojiTextKey.lotusEditDirectionTitle,
                          ref.read(daojiVocabularyLevelValueProvider),
                        )),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: DaojiText.resolve(
                DaojiTextKey.lotusLabelText,
                ref.read(daojiVocabularyLevelValueProvider),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                DaojiText.resolve(
                  DaojiTextKey.lotusCancel,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isSubGrid) {
                    _subGrids[_activePetalIndex]![index] = controller.text
                        .trim();
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
              child: Text(
                DaojiText.resolve(
                  DaojiTextKey.lotusSave,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
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
              isViewingSubGrid
                  ? '${DaojiText.resolve(DaojiTextKey.lotusTitle, ref.read(daojiVocabularyLevelValueProvider)).split(':').first} "${_cells[_activePetalIndex]}"'
                  : DaojiText.resolve(
                      DaojiTextKey.lotusTitle,
                      ref.read(daojiVocabularyLevelValueProvider),
                    ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (isViewingSubGrid)
              TextButton.icon(
                onPressed: () => setState(() => _activePetalIndex = -1),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text(
                  'Kembali ke Pusat',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Beautiful Radial Layout Canvas
        Container(
          height: 310,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            ),
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
                        themeColor: theme.colorScheme.primary.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // Nodes render
                  ...nodeOffsets.entries.map((entry) {
                    final index = entry.key;
                    final pos = entry.value;
                    final isCenter = index == 4;
                    final text = isViewingSubGrid
                        ? _subGrids[_activePetalIndex]![index]
                        : _cells[index];

                    return Positioned(
                      left: pos.dx - 36,
                      top: pos.dy - 36,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
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
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: isCenter
                                ? theme.colorScheme.primary
                                : (text.isNotEmpty
                                      ? theme.colorScheme.primaryContainer
                                            .withValues(alpha: 0.85)
                                      : theme.colorScheme.onSurface.withValues(
                                          alpha: 0.04,
                                        )),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isCenter
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface)
                                        .withValues(alpha: 0.12),
                                blurRadius: 6,
                              ),
                            ],
                            border: Border.all(
                              color: isCenter
                                  ? Colors.white
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    ),
                              width: isCenter ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                text.isEmpty
                                    ? (isCenter
                                          ? DaojiText.resolve(
                                              DaojiTextKey
                                                  .lotusCenterPlaceholder,
                                              ref.read(
                                                daojiVocabularyLevelValueProvider,
                                              ),
                                            )
                                          : DaojiText.resolve(
                                              DaojiTextKey
                                                  .lotusAddIdeaPlaceholder,
                                              ref.read(
                                                daojiVocabularyLevelValueProvider,
                                              ),
                                            ))
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
                                            ? theme
                                                  .colorScheme
                                                  .onPrimaryContainer
                                            : theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6)),
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
        Text(
          DaojiText.resolve(
            DaojiTextKey.lotusFootnote,
            ref.read(daojiVocabularyLevelValueProvider),
          ),
          style: const TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
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
