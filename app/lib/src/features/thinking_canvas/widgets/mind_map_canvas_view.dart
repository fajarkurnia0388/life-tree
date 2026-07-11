import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../domain/mind_map_model.dart';

class MindMapCanvasView extends ConsumerStatefulWidget {
  final List<MindMapNode> initialNodes;
  final ValueChanged<List<MindMapNode>> onSaved;

  const MindMapCanvasView({
    super.key,
    required this.initialNodes,
    required this.onSaved,
  });

  @override
  ConsumerState<MindMapCanvasView> createState() => _MindMapCanvasViewState();
}

class _MindMapCanvasViewState extends ConsumerState<MindMapCanvasView> {
  final List<MindMapNode> _nodes = [];
  final TransformationController _transformationController =
      TransformationController();
  String? _selectedNodeId;
  String? _editingNodeId;
  final TextEditingController _inlineEditController = TextEditingController();
  final FocusNode _inlineEditFocusNode = FocusNode();
  final List<List<MindMapNode>> _undoStack = [];
  static const int _maxUndoSteps = 20;
  double _currentScale = 1.0;

  final List<int> _palette = const [
    0xFF7D9B76, 0xFFD4728A, 0xFFE05C2F, 0xFF4A7360, 0xFF5C789B, 0xFF8E719B,
  ];

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onZoomChanged);
    if (widget.initialNodes.isEmpty) {
      final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
      _nodes.add(MindMapNode(
        id: 'root_${DateTime.now().millisecondsSinceEpoch}',
        text: DaojiText.resolve(DaojiTextKey.mindMapDefaultRootText, vocabularyLevel),
        position: const Offset(400, 300),
        colorValue: 0xFF7D9B76,
      ));
    } else {
      for (var n in widget.initialNodes) {
        _nodes.add(MindMapNode(
          id: n.id, text: n.text, position: n.position,
          parentId: n.parentId, colorValue: n.colorValue,
        ));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _recenterCanvas());
  }

  void _onZoomChanged() {
    final scale = _transformationController.value.storage[0];
    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onZoomChanged);
    _transformationController.dispose();
    _inlineEditController.dispose();
    _inlineEditFocusNode.dispose();
    super.dispose();
  }

  void _saveToUndoStack() {
    _undoStack.add(_nodes.map((n) => MindMapNode(
      id: n.id, text: n.text, position: n.position,
      parentId: n.parentId, colorValue: n.colorValue,
    )).toList());
    if (_undoStack.length > _maxUndoSteps) _undoStack.removeAt(0);
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
    final xVal = -400.0 + (size.width / 2);
    final yVal = -300.0 + (size.height / 2);
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(xVal, yVal, 0.0, 1.0);
    _currentScale = 1.0;
    setState(() {});
  }

  void _addNewRootNode() {
    _saveToUndoStack();
    HapticFeedback.selectionClick();
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    setState(() {
      final id = 'node_${DateTime.now().millisecondsSinceEpoch}';
      final rng = Random();
      _nodes.add(MindMapNode(
        id: id, text: DaojiText.resolve(DaojiTextKey.mindMapNewNodeText, vocabularyLevel),
        position: Offset(350 + rng.nextDouble() * 100, 250 + rng.nextDouble() * 100),
        colorValue: _palette[rng.nextInt(_palette.length)],
      ));
      _selectedNodeId = id;
    });
  }

  void _addChildNode(String parentId) {
    _saveToUndoStack();
    HapticFeedback.selectionClick();
    final parent = _nodes.firstWhere((n) => n.id == parentId);
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    setState(() {
      final id = 'node_${DateTime.now().millisecondsSinceEpoch}';
      final rng = Random();
      final angle = rng.nextDouble() * 2 * pi;
      _nodes.add(MindMapNode(
        id: id, text: DaojiText.resolve(DaojiTextKey.mindMapNewChildNodeText, vocabularyLevel),
        position: Offset(
          parent.position.dx + cos(angle) * 130,
          parent.position.dy + sin(angle) * 130,
        ),
        parentId: parentId, colorValue: parent.colorValue,
      ));
      _selectedNodeId = id;
    });
  }

  void _startInlineEdit(String nodeId) {
    _saveToUndoStack();
    setState(() {
      _editingNodeId = nodeId;
      _inlineEditController.text = _nodes.firstWhere((n) => n.id == nodeId).text;
    });
    _inlineEditFocusNode.requestFocus();
  }

  void _finishInlineEdit() {
    if (_editingNodeId == null) return;
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    setState(() {
      final node = _nodes.firstWhere((n) => n.id == _editingNodeId);
      node.text = _inlineEditController.text.trim().isEmpty
          ? DaojiText.resolve(DaojiTextKey.mindMapDefaultNodeText, vocabularyLevel)
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
        final children = _nodes.where((n) =>
            n.parentId != null && idsToRemove.contains(n.parentId) &&
            !idsToRemove.contains(n.id)).map((n) => n.id).toList();
        if (children.isNotEmpty) { idsToRemove.addAll(children); addedMore = true; }
      }
      _nodes.removeWhere((n) => idsToRemove.contains(n.id));
      if (_selectedNodeId == nodeId) _selectedNodeId = null;
    });
  }

  void _changeNodeColor(String nodeId, int colorValue) {
    _saveToUndoStack();
    setState(() => _nodes.firstWhere((n) => n.id == nodeId).colorValue = colorValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final selectedNode = _selectedNodeId != null
        ? _nodes.firstWhere((n) => n.id == _selectedNodeId, orElse: () => _nodes.first)
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(DaojiText.resolve(DaojiTextKey.mindMapEditorTitle, vocabularyLevel)),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: DaojiText.resolve(DaojiTextKey.mindMapUndoTooltip, vocabularyLevel),
            onPressed: _undoStack.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong_rounded),
            tooltip: DaojiText.resolve(DaojiTextKey.mindMapRecenterTooltip, vocabularyLevel),
            onPressed: _recenterCanvas,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () { widget.onSaved(_nodes); Navigator.pop(context); },
              icon: const Icon(Icons.check_rounded),
              label: Text(DaojiText.resolve(DaojiTextKey.mindMapSaveButton, vocabularyLevel)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.4,
          maxScale: 2.0,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(500),
          child: GestureDetector(
            onTap: () {
              if (_editingNodeId != null) _finishInlineEdit();
              setState(() => _selectedNodeId = null);
            },
            onDoubleTap: _recenterCanvas,
            child: SizedBox(
              width: 1600, height: 1200,
              child: Stack(children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _GridPainter(theme.colorScheme.onSurface.withValues(alpha: 0.04)),
                    ),
                  ),
                ),

                Positioned.fill(child: CustomPaint(
                    painter: _LinesPainter(nodes: _nodes))),
                ..._nodes.map((node) {
                  final isSelected = _selectedNodeId == node.id;
                  final isEditing = _editingNodeId == node.id;
                  return Positioned(
                    left: node.position.dx, top: node.position.dy,
                    child: GestureDetector(
                      onPanStart: (_) {
                        if (isEditing) return;
                        _saveToUndoStack();
                      },
                      onPanUpdate: (d) {
                        if (isEditing) return;
                        setState(() => node.position = Offset(
                          node.position.dx + d.delta.dx,
                          node.position.dy + d.delta.dy,
                        ));
                      },

                      onTap: () => setState(() => _selectedNodeId = node.id),
                      onDoubleTap: () => _startInlineEdit(node.id),
                      child: _buildNode(node, isSelected, isEditing, theme),
                    ),
                  );
                }),
              ]),
            ),
          ),
        ),
        // Zoom indicator
        Positioned(top: 8, right: 8, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Text('${(_currentScale * 100).round()}%',
              style: TextStyle(fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        )),
        Positioned(top: 8, left: 8, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.account_tree_rounded, size: 10, color: theme.colorScheme.primary),
            const SizedBox(width: 3),
            Text('${_nodes.length}',
                style: TextStyle(fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ]),
        )),
        // Add node FAB
        Positioned(left: 16, bottom: 80,
          child: FloatingActionButton.extended(
            heroTag: 'add_root',
            onPressed: _addNewRootNode,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(DaojiText.resolve(DaojiTextKey.mindMapNewTopicButton, vocabularyLevel)),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
        // Selected node toolbar
        if (selectedNode != null)
          Positioned(left: 16, right: 16, bottom: 16,
            child: Card(elevation: 6, shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.account_tree_rounded, color: Colors.blueAccent),
                    tooltip: DaojiText.resolve(DaojiTextKey.mindMapAddBranchTooltip, vocabularyLevel),
                    onPressed: () => _addChildNode(selectedNode.id),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.green),
                    tooltip: DaojiText.resolve(DaojiTextKey.mindMapEditTooltip, vocabularyLevel),
                    onPressed: () => _startInlineEdit(selectedNode.id),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Row(children: _palette.map((c) {
                      final isCurrent = selectedNode.colorValue == c;
                      return GestureDetector(
                        onTap: () => _changeNodeColor(selectedNode.id, c),
                        child: Container(
                          width: 40, height: 40, alignment: Alignment.center,
                          child: Container(width: 22, height: 22,
                            decoration: BoxDecoration(color: Color(c), shape: BoxShape.circle,
                              border: isCurrent ? Border.all(
                                  color: theme.colorScheme.onSurface, width: 2) : null),
                          ),
                        ),
                      );
                    }).toList()),
                  )),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: DaojiText.resolve(DaojiTextKey.mindMapDeleteTooltip, vocabularyLevel),
                    onPressed: () => _deleteNode(selectedNode.id),
                  ),
                ]),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildNode(MindMapNode node, bool isSelected, bool isEditing, ThemeData theme) {
    final nodeColor = Color(node.colorValue);
    if (isEditing) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 180, minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: nodeColor, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: nodeColor.withValues(alpha: 0.5),
              blurRadius: 16, spreadRadius: 2, offset: const Offset(0, 3))],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: TextField(
          controller: _inlineEditController, focusNode: _inlineEditFocusNode,
          style: const TextStyle(color: Colors.white, fontSize: 13,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center, maxLines: 2,
          decoration: const InputDecoration(border: InputBorder.none,
              contentPadding: EdgeInsets.zero, isDense: true),
          onSubmitted: (_) => _finishInlineEdit(),
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: nodeColor, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: nodeColor.withValues(alpha: 0.4),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0, offset: const Offset(0, 3))],
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary
              : Colors.white.withValues(alpha: 0.5),
          width: isSelected ? 3 : 1.5,
        ),
      ),
      child: Text(node.text, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13,
              fontWeight: FontWeight.bold),
          maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color dotColor;
  _GridPainter(this.dotColor);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor..strokeWidth = 1.5;
    for (double x = 0; x < size.width; x += 20) {
      for (double y = 0; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _GridPainter old) => false;
}

class _LinesPainter extends CustomPainter {
  final List<MindMapNode> nodes;
  _LinesPainter({required this.nodes});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5;
    for (var node in nodes) {
      if (node.parentId == null) continue;
      final parent = nodes.firstWhere((n) => n.id == node.parentId,
          orElse: () => node);
      if (parent == node) continue;
      final start = Offset(parent.position.dx + 70, parent.position.dy + 18);
      final end = Offset(node.position.dx + 70, node.position.dy + 18);
      final path = Path()..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx + (end.dx - start.dx) / 2, start.dy,
            start.dx + (end.dx - start.dx) / 2, end.dy, end.dx, end.dy);
      paint.color = Color(node.colorValue).withValues(alpha: 0.5);
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _LinesPainter old) {
    if (identical(old.nodes, nodes)) return false;
    if (old.nodes.length != nodes.length) return true;
    for (var i = 0; i < nodes.length; i++) {
      final a = old.nodes[i];
      final b = nodes[i];
      if (a.id != b.id || a.position != b.position || a.parentId != b.parentId || a.colorValue != b.colorValue) {
        return true;
      }
    }
    return false;
  }
}
