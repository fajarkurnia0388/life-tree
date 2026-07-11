import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/features/cultivation/cultivation_constants.dart';
import 'package:daoji/src/features/dashboard/widgets/growth_map/growth_map_node.dart';
import 'package:daoji/src/features/dashboard/widgets/growth_map/growth_map_semantics.dart';

void main() {
  group('GrowthMap Accessibility Semantics Tests', () {
    const languageLevel = CultivationLanguageLevel.plain;

    test('RootNode semantic label contains core values', () {
      final node = const RootNode(
        id: 'root',
        label: 'Akar Diri',
        semanticLabel: '',
        coreValues: ['Kesehatan', 'Kebebasan'],
      );

      final label = GrowthMapSemantics.buildLabel(node, languageLevel);
      expect(label, contains('Akar Diri'));
      expect(label, contains('Kesehatan, Kebebasan'));
    });

    test('BranchNode semantic label contains domain status and score', () {
      final node = const BranchNode(
        id: 'Tubuh',
        label: 'Tubuh',
        icon: Icons.directions_run,
        score: 9.0,
        statusLabel: 'Stabil',
        color: Colors.green,
        semanticLabel: '',
      );

      final label = GrowthMapSemantics.buildLabel(node, languageLevel);
      expect(label, contains('Domain Tubuh'));
      expect(label, contains('Stabil'));
      expect(label, contains('9 dari 10'));
    });

    test('LeafNode semantic label contains habit title and status', () {
      final nodeDone = const LeafNode(
        id: 'h1',
        label: 'Minum Air Hangat',
        domainTag: 'Tubuh',
        isDone: true,
        initial: 'MA',
        originalHabit: null,
        semanticLabel: '',
      );

      final labelDone = GrowthMapSemantics.buildLabel(nodeDone, languageLevel);
      expect(labelDone, contains('Kebiasaan: Minum Air Hangat'));
      expect(labelDone, contains('Sudah diselesaikan'));

      final nodePending = const LeafNode(
        id: 'h1',
        label: 'Minum Air Hangat',
        domainTag: 'Tubuh',
        isDone: false,
        initial: 'MA',
        originalHabit: null,
        semanticLabel: '',
      );

      final labelPending = GrowthMapSemantics.buildLabel(
        nodePending,
        languageLevel,
      );
      expect(labelPending, contains('Belum aktif hari ini'));
    });
  });
}
