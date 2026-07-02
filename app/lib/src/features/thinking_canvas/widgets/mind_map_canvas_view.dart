import 'dart:math';
import 'package:flutter/material.dart';
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

  // Predefined soft pastel palette colors
  final List<int> _palette = const [
    0xFF7D9B76, // Sage Green (Default)
    0xFFD4728A, // Sakura Pink
    0xFFE05C2F, // Maple Orange
    0xFF4A7360, // Bonsai Dark Green
    0xFF5C789B, // Calm Blue
    0xFF8E719B, // Calm Purple
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialNodes.isEmpty) {
      // Add a default root node in the center
      _nodes.add(
        MindMapNode(
          id: 'root_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Topik Utama',
          position: const Offset(400, 300),
          colorValue: 0xFF7D9B76,
        ),
      );
    } else {
      // Deep copy initial nodes
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

    // Recenter view on startup after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recenterCanvas();
    });
  }

  void _recenterCanvas() {
    // Canvas dimensions are 1600x1200. Recenter around center (800, 600)
    final size = MediaQuery.of(context).size;
    final double xVal = -400.0 + (size.width / 2);
    final double yVal = -300.0 + (size.height / 2);
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(xVal, yVal, 0.0, 1.0);
  }

  void _addNewRootNode() {
    setState(() {
      final id = 'node_${DateTime.now().millisecondsSinceEpoch}';
      // Place near center with slight offset
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
    final parent = _nodes.firstWhere((n) => n.id == parentId);
    setState(() {
      final id = 'node_${DateTime.now().millisecondsSinceEpoch}';

      // Position child slightly offset from parent
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
          colorValue: parent.colorValue, // inherits color
        ),
      );
      _selectedNodeId = id;
    });
  }

  void _editNodeText(String nodeId) {
    final node = _nodes.firstWhere((n) => n.id == nodeId);
    final controller = TextEditingController(text: node.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Edit Gagasan'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Gagasan',
              hintText: 'Tuliskan gagasan Anda...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  node.text = controller.text.trim().isEmpty
                      ? 'Gagasan'
                      : controller.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNode(String nodeId) {
    // Delete target node and all its child nodes recursively
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
          IconButton(
            icon: const Icon(Icons.center_focus_strong_rounded),
            tooltip: 'Pusatkan Kanvas',
            onPressed: _recenterCanvas,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
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
              setState(() {
                _selectedNodeId = null; // deselect
              });
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.4,
              maxScale: 2.0,
              constrained: false, // allow canvas to be larger than screen
              boundaryMargin: const EdgeInsets.all(500),
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
                      return Positioned(
                        left: node.position.dx,
                        top: node.position.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
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
                          onDoubleTap: () => _editNodeText(node.id),
                          child: _buildNodeWidget(node, isSelected, theme),
                        ),
                      );
                    }),
                  ],
                ),
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
                        tooltip: 'Tambah Cabang (+)',
                        onPressed: () => _addChildNode(selectedNode.id),
                      ),
                      const SizedBox(width: 8),

                      // Edit button
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: Colors.green,
                        ),
                        tooltip: 'Edit Teks',
                        onPressed: () => _editNodeText(selectedNode.id),
                      ),
                      const SizedBox(width: 8),

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
                                              color:
                                                  theme.colorScheme.onSurface,
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
                      const SizedBox(width: 8),

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

  Widget _buildNodeWidget(MindMapNode node, bool isSelected, ThemeData theme) {
    final nodeColor = Color(node.colorValue);

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
      child: Text(
        node.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
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

      // Find parent node
      final parent = nodes.firstWhere(
        (n) => n.id == node.parentId,
        orElse: () => node,
      );
      if (parent == node) continue;

      // Calculate connection coordinates from node centers
      // Nodes constraint is approx 160 max width, let's estimate centers based on offset
      final start = Offset(parent.position.dx + 80, parent.position.dy + 20);
      final end = Offset(node.position.dx + 80, node.position.dy + 20);

      // Curved Bezier line path drawing
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + (end.dx - start.dx) / 2,
          start.dy, // control point 1
          start.dx + (end.dx - start.dx) / 2,
          end.dy, // control point 2
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
