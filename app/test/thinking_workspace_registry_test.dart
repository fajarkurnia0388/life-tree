import 'package:daoji/src/features/thinking_canvas/workspace_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all structured Thinking Canvas methods are registered', () {
    const expected = {
      'LotusBlossom',
      'MorphologicalAnalysis',
      'MindDump',
      'MindDumpCluster',
      'AffinityMapping',
      '5Whys',
      'FirstPrinciples',
      'DoubleDiamond',
      'Validation',
      'Scoring',
      'SixThinkingHats',
      'DisneyStrategy',
      'SCAMPER',
      'SWOT',
      'Starbursting',
      'Brainstorming',
      'ReverseBrainstorming',
      'WorstPossibleIdea',
      'QuestionStorming',
      'RandomWord',
      'RoleStorming',
    };
    expect(ThinkingWorkspaceRegistry.registeredMethods, expected);
  });

  for (final method in ThinkingWorkspaceRegistry.registeredMethods) {
    test('$method resolves to a workspace widget', () {
      final widget = ThinkingWorkspaceRegistry.build(
        method,
        onChanged: (_) {},
        onStructuredOutput: (_) {},
      );
      expect(widget, isNotNull);
    });
  }
}
