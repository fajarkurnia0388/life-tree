import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/features/thinking_canvas/domain/mind_map_model.dart';

void main() {
  group('MindMapNode Tests', () {
    test('toJson and fromJson serialization/deserialization', () {
      final node = MindMapNode(
        id: 'node-123',
        text: 'Root Node Idea',
        position: const Offset(150.0, 250.0),
        parentId: 'parent-abc',
        colorValue: 0xFFFF5722,
      );

      final json = node.toJson();
      expect(json['id'], 'node-123');
      expect(json['text'], 'Root Node Idea');
      expect(json['dx'], 150.0);
      expect(json['dy'], 250.0);
      expect(json['parentId'], 'parent-abc');
      expect(json['colorValue'], 0xFFFF5722);

      final decodedNode = MindMapNode.fromJson(json);
      expect(decodedNode.id, 'node-123');
      expect(decodedNode.text, 'Root Node Idea');
      expect(decodedNode.position.dx, 150.0);
      expect(decodedNode.position.dy, 250.0);
      expect(decodedNode.parentId, 'parent-abc');
      expect(decodedNode.colorValue, 0xFFFF5722);
    });

    test('default color configuration', () {
      final node = MindMapNode(
        id: 'node-default',
        text: 'Default node',
        position: Offset.zero,
      );

      expect(node.colorValue, 0xFF7D9B76);
      expect(node.parentId, isNull);
    });

    test('node list hierarchy check', () {
      final rootNode = MindMapNode(
        id: 'root',
        text: 'Core Vibe',
        position: const Offset(800.0, 600.0),
      );

      final childNode1 = MindMapNode(
        id: 'child-1',
        text: 'Branch 1',
        position: const Offset(950.0, 500.0),
        parentId: 'root',
      );

      final childNode2 = MindMapNode(
        id: 'child-2',
        text: 'Branch 2',
        position: const Offset(950.0, 700.0),
        parentId: 'root',
      );

      final nodes = [rootNode, childNode1, childNode2];

      // Find children of root
      final rootChildren = nodes.where((n) => n.parentId == 'root').toList();
      expect(rootChildren.length, 2);
      expect(rootChildren.any((n) => n.id == 'child-1'), isTrue);
      expect(rootChildren.any((n) => n.id == 'child-2'), isTrue);
    });
  });
}
