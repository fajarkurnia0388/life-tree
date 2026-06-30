import 'growth_map_node.dart';

class GrowthMapSemantics {
  static String buildLabel(GrowthMapNode node) {
    if (node is RootNode) {
      final valuesStr = node.coreValues.isEmpty ? 'belum diisi' : node.coreValues.join(', ');
      return 'Akar Diri. Nilai Inti: $valuesStr. Ketuk untuk melihat ringkasan nilai.';
    } else if (node is BranchNode) {
      return 'Dahan ${node.label}. Status: ${node.statusLabel} (Skor ${node.score.toStringAsFixed(0)} dari 10). Ketuk untuk melihat wawasan.';
    } else if (node is LeafNode) {
      final status = node.isDone ? 'Sudah diselesaikan' : 'Belum aktif hari ini';
      return 'Daun Kebiasaan: ${node.label}. Status: $status. Ketuk untuk mengubah status kebiasaan.';
    } else if (node is FlowerNode) {
      return 'Bunga Kebiasaan Stabil: ${node.label}. Streak: ${node.streakDays} hari.';
    } else if (node is FruitNode) {
      return 'Buah Keputusan: ${node.label}. Ketuk untuk melihat jurnal keputusan.';
    }
    return node.label;
  }
}
