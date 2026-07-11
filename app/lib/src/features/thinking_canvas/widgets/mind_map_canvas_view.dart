import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/mind_map_model.dart';

class MindMapCanvasView extends StatefulWidget {
  final List<MindMapNode> initialNodes;
  final ValueChanged<List<MindMapNode>> onSaved;

  const MindMapCanvasView({
    super.key,
    required this.initialNodes,
    required this.onSaved,
  });

  @override
  State<MindMapCanvasView> createState() => _MindMapCanvasViewState();
}

class _MindMapCanvasViewState extends State<MindMapCanvasView> {
  final List<MindMapNode> _nodes = [];
  final TransformationController _transformationController =
      TransformationController();

  String? _selectedNodeId;
  String? _editingNodeId;
  final TextEditingController _inlineEditController = TextEditingController();
  final FocusNode _inlineEditFocusNode = FocusNode();

  // Undo stack
  final List<List<MindMapNode>> _undoStack = [];
  static const int _maxUndoSteps = 20;

  // Predefined soft pastel palette colors
  final List<int> _palette = const [
    0xFF7D9B76, // Sage Green (Default)
    0xFFD4728A, // Sakura Pink
    0xFFE05C2F, // Maple Orange
    0xFF4A7360, // Bonsai Dark Green
    0xFF5C789B, // Calm Blue
    0xFF8E719B, // Calm Purple
  ];

  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialNodes.isEmpty) {
      _nodes.add(
        MindMapNode(
          id: 'root_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Topik Utama',
          position: const Offset(400, 300),
          colorValue: 0xFF7D9B76,
        ),
      );
    } else {
      for (var node in widget.initialNodes) {
        _nodes.add(
          MindMapNode(
            id: node.id,
            text: node.text,
            position: node.position,
            parentId: node.parentId,
            colorValue: node.colorValue,
          ),
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recenterCanvas();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _inlineEditController.dispose();
    _inlineEditFocusNode.dispose();
    super.dispose();
  }

  void _saveToUndoStack() {
    _undoStack.add(
      _nodes
          .map((n) => MindMapNode(
                id: n.id,
                text: n.text,
                position: n.position,
                parentId: n.parentId,
                colorValue: n.colorValue,
              ))
          .toList(),
    );
    if (_undoStack.length > _maxUndoSteps) {
      _undoStack.removeAt(0);
    }
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _nodes.clear();
      _nodes.addAll(_undoStack.removeLast());
      _selectedNodeId = null;
      _editingNodeId = null;
    });
  }

  void _recenterCanvas() {
    final size = MediaQuery.of(context).size;
    final double xVal = -400.0 + (size.width / 2);
    final double yVal = -300.0 + (size.height / 2);
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(xVal, yVal, 0.0, 1.0);
    _currentScale = 1.0;
    setState(() {});
  }

  void _addNewRootNode() {
    _saveToUndoStack();
    HapticFeedback.selectionClick();
    setState(() {
      final id = 'node_${DateTime.now().millisecondsSinceEpoch}';
      final rng = Random();
      final dx = 350.0 + rng.nextDouble() * 100.0;
      final dy = 250.0 + rng.nextDouble() * 100.0;

      _nodes.add(
        MindMapNode(
          id: id,
          text: 'Ide Baru',
          position: Offset(dx, dy),
          colorValue: _palette[rng.nextInt(_palette.length)],
        ),
      );
      _selectedNodeId = id;
    });
  }

  void _addChildNode(String parentId) {
    _saveToUndoStack();
    HapticFeedback.selectionClick();
    final parent = _nodes.firstWhere((n) => n.id == parentId);
    setState(() {
      final id = 'node_${DateTime.now().millisecondsSinceEpoch}';

      final rng = Random();
      final double angle = rng.nextDouble() * 2 * pi;
      final double distance = 130.0;
      final dx = parent.position.dx + cos(angle) * distance;
      final dy = parent.position.dy + sin(angle) * distance;

      _nodes.add(
        MindMapNode(
          id: id,
          text: 'Sub-ide',
          position: Offset(dx, dy),
          parentId: parentId,
          colorValue: parent.colorValue,
        ),
      );
      _selectedNodeId = id;
    });
  }

  void _startInlineEdit(String nodeId) {
    final node = _nodes.firstWhere((n) => n.id == nodeId);
    _saveToUndoStack();
    setState(() {
      _editingNodeId = nodeId;
      _inlineEditController.text = node.text;
    });
    _inlineEditFocusNode.requestFocus();
  }

  void _finishInlineEdit() {
    if (_editingNodeId == null) return;
    setState(() {
      final node = _nodes.firstWhere((n) => n.id == _editingNodeId);
      node.text = _inlineEditController.text.trim().isEmpty
          ? 'Gagasan'
          : _inlineEditController.text.trim();
      _editingNodeId = null;
    });
    _inlineEditController.clear();
  }

  void _deleteNode(String nodeId) {
    _saveToUndoStack();
    HapticFeedback.mediumImpact();
    setState(() {
      final idsToRemove = <String>{nodeId};
      bool addedMore = true;

      while (addedMore) {
        addedMore = false;
        final currentChildren = _nodes
            .where(
              (n) =>
                  n.parentId != null &&
                  idsToRemove.contains(n.parentId) &&
                  !idsToRemove.contains(n.id),
            )
            .map((n) => n.id)
            .toList();

        if (currentChildren.isNotEmpty) {
          idsToRemove.addAll(currentChildren);
          addedMore = true;
        }
      }

      _nodes.removeWhere((n) => idsToRemove.contains(n.id));
      if (_selectedNodeId == nodeId) {
        _selectedNodeId = null;
      }
    });
  }

  void _changeNodeColor(String nodeId, int colorValue) {
    _saveToUndoStack();
    setState(() {
      final node = _nodes.firstWhere((n) => n.id == nodeId);
      node.colorValue = colorValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedNode = _selectedNodeId != null
        ? _nodes.firstWhere(
            (n) => n.id == _selectedNodeId,
            orElse: () => _nodes.first,
          )
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Visual Mind Map Editor'),
        actions: [
          // Undo button
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Batalkan',
            onPressed: _undoStack.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong_rounded),
            tooltip: 'Pusatkan Kanvas',
            onPressed: _recenterCanvas,
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onSaved(_nodes);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Infinite Drag & Drop Canvas
          GestureDetector(
            onTap: () {
              // Finish any inline edit
              if (_editingNodeId != null) {
                _finishInlineEdit();
              }
              setState(() {
                _selectedNodeId = null;
              });
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.4,
              maxScale: 2.0,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(500),
              onInteractionUpdate: (details) {
                if (details.scale != 1.0) {
                  setState(() {
                    _currentScale = details.scale;
                  });
                }
              },
              child: SizedBox(
                width: 1600,
                height: 1200,
                child: Stack(
                  children: [
                    // Grid background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridBackgroundPainter(
                          theme.colorScheme.onSurface.withValues(alpha: 0.04),
                        ),
                      ),
                    ),

                    // Curved connection lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MindMapLinesPainter(nodes: _nodes),
                      ),
                    ),

                    // Nodes layer
                    ..._nodes.map((node) {
                      final isSelected = _selectedNodeId == node.id;
                      final isEditing = _editingNodeId == node.id;
                      return Positioned(
                        left: node.position.dx,
                        top: node.position.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            if (isEditing) return;
                            _saveToUndoStack();
                            setState(() {
                              node.position = Offset(
                                node.position.dx + details.delta.dx,
                                node.position.dy + details.delta.dy,
                              );
                            });
                          },
                          onTap: () {
                            setState(() {
                              _selectedNodeId = node.id;
                            });
                          },
                          onDoubleTap: () => _startInlineEdit(node.id),
                          child: _buildNodeWidget(
                            node,
                            isSelected,
                            isEditing,
                            theme,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Zoom indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                '${(_currentScale * 100).round()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),

          // Node count indicator
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_tree_rounded,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_nodes.length} node',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Controls Bar (Add Independent Root Node)
          Positioned(
            left: 16,
            bottom: 80,
            child: FloatingActionButton.extended(
              heroTag: 'add_root_node',
              onPressed: _addNewRootNode,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Topik Baru'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),

          // Bottom Editor Toolbar (Appears when a node is selected)
          if (selectedNode != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      // Sub-node / child button
                      IconButton(
                        icon: const Icon(
                          Icons.account_tree_rounded,
                          color: Colors.blueAccent,
                        ),
                        tooltip: 'Tambah Cabang',
                        onPressed: () => _addChildNode(selectedNode.id),
                      ),
                      const SizedBox(width: 4),

                      // Edit button
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Colors.green,
                        ),
                        tooltip: 'Edit Teks',
                        onPressed: () =>
                            _startInlineEdit(selectedNode.id),
                      ),
                      const SizedBox(width: 4),

                      // Color palette selection
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _palette.map((colorVal) {
                              final isCurrentColor =
                                  selectedNode.colorValue == colorVal;
                              return GestureDetector(
                                onTap: () =>
                                    _changeNodeColor(selectedNode.id, colorVal),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Color(colorVal),
                                      shape: BoxShape.circle,
                                      border: isCurrentColor
                                          ? Border.all(
                                              color: theme
                                                  .colorScheme.onSurface,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Hapus Node',
                        onPressed: () => _deleteNode(selectedNode.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(
    MindMapNode node,
    bool isSelected,
    bool isEditing,
    ThemeData theme,
  ) {
    final nodeColor = Color(node.colorValue);

    if (isEditing) {
      // Inline editing mode
      return Container(
        constraints: const BoxConstraints(maxWidth: 180, minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: nodeColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: nodeColor.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: TextField(
          controller: _inlineEditController,
          focusNode: _inlineEditFocusNode,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onSubmitted: (_) => _finishInlineEdit(),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: nodeColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: nodeColor.withValues(alpha: 0.4),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.white.withValues(alpha: 0.5),
          width: isSelected ? 3 : 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              node.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Background painter for dotted grid effect
class _GridBackgroundPainter extends CustomPainter {
  final Color dotColor;
  _GridBackgroundPainter(this.dotColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..strokeWidth = 1.5;

    const double gap = 20.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) => false;
}

// Bezier curve connector line painter
class _MindMapLinesPainter extends CustomPainter {
  final List<MindMapNode> nodes;

  _MindMapLinesPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var node in nodes) {
      if (node.parentId == null) continue;

      final parent = nodes.firstWhere(
        (n) => n.id == node.parentId,
        orElse: () => node,
      );
      if (parent == node) continue;

      final start = Offset(parent.position.dx + 80, parent.position.dy + 20);
      final end = Offset(node.position.dx + 80, node.position.dy + 20);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + (end.dx - start.dx) / 2,
          start.dy,
          start.dx + (end.dx - start.dx) / 2,
          end.dy,
          end.dx,
          end.dy,
        );

      paint.color = Color(node.colorValue).withValues(alpha: 0.5);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapLinesPainter oldDelegate) => true;
}
