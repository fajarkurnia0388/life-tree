import 'package:flutter/widgets.dart';

import 'widgets/specialized_workspace_widgets.dart';

typedef StructuredWorkspaceBuilder =
    Widget Function({
      required ValueChanged<String> onChanged,
      required ValueChanged<String> onStructuredOutput,
      String? initialStructuredOutput,
    });

/// Central registry for structured Thinking Canvas workspaces.
///
/// Adding a structured method only requires registering a builder here; the
/// main view no longer needs a large switch statement.
class ThinkingWorkspaceRegistry {
  ThinkingWorkspaceRegistry._();

  static Widget _buildMindDump({
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onStructuredOutput,
    String? initialStructuredOutput,
  }) => MindDumpWorkspace(
    onChanged: onChanged,
    onStructuredOutput: onStructuredOutput,
    initialStructuredOutput: initialStructuredOutput,
  );

  static Widget _buildValidation({
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onStructuredOutput,
    String? initialStructuredOutput,
  }) => ValidationWorkspace(
    onChanged: onChanged,
    onStructuredOutput: onStructuredOutput,
    initialStructuredOutput: initialStructuredOutput,
  );

  static final Map<String, StructuredWorkspaceBuilder> _builders = {
    'LotusBlossom':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => LotusBlossomWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'MorphologicalAnalysis':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => MorphologicalWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'MindDump': _buildMindDump,
    'MindDumpCluster': _buildMindDump,
    'AffinityMapping':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => AffinityMappingWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    '5Whys':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => FiveWhysWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'FirstPrinciples':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => FirstPrinciplesWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'DoubleDiamond':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => DoubleDiamondWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'Validation': _buildValidation,
    'Scoring': _buildValidation,
    'SixThinkingHats':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => SixThinkingHatsWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'DisneyStrategy':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => DisneyStrategyWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'SCAMPER':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => ScamperWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'SWOT':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => SwotMatrixWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'Starbursting':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => StarburstingWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'Brainstorming':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => RapidBrainstormWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'ReverseBrainstorming':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => ReverseBrainstormWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'WorstPossibleIdea':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => WorstPossibleIdeaWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'QuestionStorming':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => QuestionStormWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'RandomWord':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => RandomWordWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
    'RoleStorming':
        ({
          required onChanged,
          required onStructuredOutput,
          initialStructuredOutput,
        }) => RoleStormingWorkspace(
          onChanged: onChanged,
          onStructuredOutput: onStructuredOutput,
          initialStructuredOutput: initialStructuredOutput,
        ),
  };

  static Widget? build(
    String method, {
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onStructuredOutput,
    String? initialStructuredOutput,
  }) {
    final builder = _builders[method];
    return builder?.call(
      onChanged: onChanged,
      onStructuredOutput: onStructuredOutput,
      initialStructuredOutput: initialStructuredOutput,
    );
  }

  static Set<String> get registeredMethods => Set.unmodifiable(_builders.keys);
}
