import 'package:flutter/material.dart';

class MindMapNode {
  final String id;
  String text;
  Offset position;
  String? parentId;
  int colorValue; // ARGB integer value

  MindMapNode({
    required this.id,
    required this.text,
    required this.position,
    this.parentId,
    this.colorValue = 0xFF7D9B76, // default sage green
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'dx': position.dx,
      'dy': position.dy,
      'parentId': parentId,
      'colorValue': colorValue,
    };
  }

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'] as String,
      text: json['text'] as String,
      position: Offset(
        (json['dx'] as num).toDouble(),
        (json['dy'] as num).toDouble(),
      ),
      parentId: json['parentId'] as String?,
      colorValue: json['colorValue'] as int? ?? 0xFF7D9B76,
    );
  }
}
