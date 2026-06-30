import 'package:flutter_test/flutter_test.dart';
import 'package:life_tree/src/core/domain/app_constants.dart';
import 'package:life_tree/src/core/domain/tree_skin_config.dart';

void main() {
  group('TreeSkinConfig', () {
    test('normalizes unknown skin ids to default skin', () {
      expect(TreeSkinConfig.normalizeSkinId(null), TreeSkin.defaultSkin);
      expect(TreeSkinConfig.normalizeSkinId('Unknown'), TreeSkin.defaultSkin);
      expect(TreeSkinConfig.normalizeSkinId(TreeSkin.sakura), TreeSkin.sakura);
    });

    test('keeps recovery status simple', () {
      expect(TreeSkinConfig.normalizeSkinId('Unknown'), TreeSkin.defaultSkin);
    });
  });
}
