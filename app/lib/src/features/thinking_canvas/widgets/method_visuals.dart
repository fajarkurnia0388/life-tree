import 'package:flutter/material.dart';

/// Central method accent colors/icons (token-friendly, not raw Material primaries).
class ThinkingMethodVisuals {
  ThinkingMethodVisuals._();

  static Color colorFor(String methodKey, ColorScheme scheme) {
    switch (methodKey) {
      case 'MindDump':
      case 'MindDumpCluster':
        return const Color(0xFF2A9D8F);
      case 'Freewriting':
        return const Color(0xFF6D5ACD);
      case 'MindMapping':
        return const Color(0xFF4C6EF5);
      case 'Brainstorming':
      case 'ReverseBrainstorming':
      case 'WorstPossibleIdea':
        return const Color(0xFFE67E22);
      case 'SCAMPER':
        return const Color(0xFFD6336C);
      case 'SixThinkingHats':
        return const Color(0xFF1C7ED6);
      case 'SWOT':
        return const Color(0xFF2F9E44);
      case '5Whys':
        return const Color(0xFFE67700);
      case 'LotusBlossom':
        return const Color(0xFF9C36B5);
      case 'MorphologicalAnalysis':
        return const Color(0xFF0CA678);
      default:
        return scheme.primary;
    }
  }

  static IconData iconFor(String methodKey) {
    switch (methodKey) {
      case 'MindDump':
      case 'MindDumpCluster':
        return Icons.psychology_rounded;
      case 'Freewriting':
        return Icons.edit_note_rounded;
      case 'MindMapping':
        return Icons.account_tree_rounded;
      case 'Brainstorming':
      case 'ReverseBrainstorming':
      case 'WorstPossibleIdea':
        return Icons.lightbulb_rounded;
      case 'SCAMPER':
        return Icons.transform_rounded;
      case 'SixThinkingHats':
        return Icons.hotel_class_rounded;
      case 'SWOT':
        return Icons.grid_view_rounded;
      case '5Whys':
        return Icons.help_rounded;
      case 'LotusBlossom':
        return Icons.local_florist_rounded;
      case 'MorphologicalAnalysis':
        return Icons.casino_rounded;
      default:
        return Icons.insights_rounded;
    }
  }
}
