import '../../../cultivation/cultivation_constants.dart';
import '../../../cultivation/cultivation_strings.dart';
import 'growth_map_node.dart';

class GrowthMapSemantics {
  static String buildLabel(
    GrowthMapNode node,
    CultivationLanguageLevel languageLevel,
  ) {
    if (node is RootNode) {
      final rootLabel = CultivationStrings.growthMapRoot(languageLevel);
      final valuesStr = node.coreValues.isEmpty
          ? 'belum diisi'
          : node.coreValues.join(', ');
      return '$rootLabel. Nilai Inti: $valuesStr. Ketuk untuk melihat ringkasan nilai.';
    } else if (node is BranchNode) {
      final branchLabel = CultivationStrings.growthMapBranch(languageLevel);
      return '$branchLabel ${node.label}. Status: ${node.statusLabel} (Skor ${node.score.toStringAsFixed(0)} dari 10). Ketuk untuk melihat wawasan.';
    } else if (node is LeafNode) {
      final leafLabel = CultivationStrings.growthMapLeaf(languageLevel);
      final status = node.isDone
          ? 'Sudah diselesaikan'
          : 'Belum aktif hari ini';
      return '$leafLabel: ${node.label}. Status: $status. Ketuk untuk mengubah status.';
    } else if (node is FlowerNode) {
      final flowerLabel = CultivationStrings.growthMapFlower(languageLevel);
      final leafLabel = CultivationStrings.growthMapLeaf(languageLevel);
      return '$flowerLabel $leafLabel: ${node.label}. Streak: ${node.streakDays} hari.';
    } else if (node is FruitNode) {
      final fruitLabel = CultivationStrings.growthMapFruit(languageLevel);
      return '$fruitLabel: ${node.label}. Ketuk untuk melihat jurnal.';
    }
    return node.label;
  }
}
