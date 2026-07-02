import 'package:flutter/material.dart';
import '../domain/thinking_method.dart';

class ScoringItem {
  final TextEditingController nameController;
  int impact;
  int ease;
  ScoringItem({required this.nameController, this.impact = 3, this.ease = 3});
}

class MethodPickerBottomSheet extends StatefulWidget {
  final String currentMethodKey;
  final bool isPremiumUser;
  final ValueChanged<String> onSelected;

  const MethodPickerBottomSheet({
    super.key,
    required this.currentMethodKey,
    required this.isPremiumUser,
    required this.onSelected,
  });

  @override
  State<MethodPickerBottomSheet> createState() => _MethodPickerBottomSheetState();
}

class _MethodPickerBottomSheetState extends State<MethodPickerBottomSheet> {
  String _searchQuery = '';

  static const List<MapEntry<String, List<String>>> _categoryGroups = [
    MapEntry('Quick Dump', [
      'MindDump',
      'Freewriting',
      'MindDumpCluster',
    ]),
    MapEntry('Kreatif', [
      'Brainstorming',
      'MindMapping',
      'SCAMPER',
      'RandomWord',
      'WorstPossibleIdea',
      'RoleStorming',
      'Starbursting',
      'LotusBlossom',
      'MorphologicalAnalysis',
      'QuestionStorming',
    ]),
    MapEntry('Analitis', [
      '5Whys',
      'SWOT',
      'AffinityMapping',
      'ReverseBrainstorming',
    ]),
    MapEntry('Keputusan', [
      'Scoring',
      'Validation',
      'FirstPrinciples',
      'PMI',
    ]),
    MapEntry('Lainnya', [
      'SixThinkingHats',
      'DisneyStrategy',
      'DoubleDiamond',
    ]),
  ];

  Color _getLevelColor(String level, ThemeData theme) {
    switch (level) {
      case 'Pemula':
        return Colors.green;
      case 'Menengah':
        return Colors.orange;
      case 'Lanjutan':
        return Colors.purple;
      case 'Kerangka Kerja':
        return theme.colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  void _showPremiumAdDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Fitur Premium 👑'),
          content: const Text(
            'Metode berpikir tingkat lanjut dan workspace interaktif ini eksklusif untuk pengguna Premium.\n\n'
            'Aktifkan Mode Developer di menu dashboard utama untuk membuka kunci seluruh fitur premium secara gratis!'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMethodCard(ThinkingMethod m, ThemeData theme) {
    final isSelected = widget.currentMethodKey == m.key;
    final levelColor = _getLevelColor(m.level, theme);

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Metode: ${m.name}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (m.isPremium && !widget.isPremiumUser) {
              _showPremiumAdDialog();
            } else {
              widget.onSelected(m.key);
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                m.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            if (m.isPremium) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.lock_rounded, color: Colors.amber[700], size: 14),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m.level,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: levelColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m.desc,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        m.template == WorkspaceTemplate.freeform
                            ? Icons.edit_note_rounded
                            : m.template == WorkspaceTemplate.multiColumn
                                ? Icons.view_column_rounded
                                : m.template == WorkspaceTemplate.sequential
                                    ? Icons.format_list_numbered_rounded
                                    : Icons.table_chart_rounded,
                        size: 14,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        m.template == WorkspaceTemplate.freeform
                            ? 'Workspace: Teks Bebas'
                            : m.template == WorkspaceTemplate.multiColumn
                                ? 'Workspace: Input Kolom'
                                : m.template == WorkspaceTemplate.sequential
                                    ? 'Workspace: Langkah Berurutan'
                                    : 'Workspace: Tabel Skoring',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label, int count, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4, left: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    final query = _searchQuery.trim().toLowerCase();

    final methodsByKey = {for (final m in ThinkingMethod.allMethods) m.key: m};
    final visibleGroups = <MapEntry<String, List<ThinkingMethod>>>[];
    final seenKeys = <String>{};

    for (final group in _categoryGroups) {
      final methods = <ThinkingMethod>[];
      for (final key in group.value) {
        final m = methodsByKey[key];
        if (m == null) continue;
        seenKeys.add(key);
        final matchesSearch = query.isEmpty ||
            m.name.toLowerCase().contains(query) ||
            m.desc.toLowerCase().contains(query);
        if (matchesSearch) methods.add(m);
      }
      if (methods.isNotEmpty) visibleGroups.add(MapEntry(group.key, methods));
    }

    final unmapped = ThinkingMethod.allMethods.where((m) {
      if (seenKeys.contains(m.key)) return false;
      final matchesSearch = query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.desc.toLowerCase().contains(query);
      return matchesSearch;
    }).toList();
    if (unmapped.isNotEmpty) {
      final existing = visibleGroups.indexWhere((g) => g.key == 'Lainnya');
      if (existing >= 0) {
        visibleGroups[existing] = MapEntry('Lainnya', [
          ...visibleGroups[existing].value,
          ...unmapped,
        ]);
      } else {
        visibleGroups.add(MapEntry('Lainnya', unmapped));
      }
    }

    final hasResults = visibleGroups.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: media.viewInsets.bottom + 16,
      ),
      height: media.size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Metode Berpikir 🧠',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              labelText: 'Cari Metode',
              hintText: 'Cari metode (misal: SWOT, 5 Whys)...',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: !hasResults
                ? const Center(
                    child: Text('Metode tidak ditemukan.', style: TextStyle(fontStyle: FontStyle.italic)),
                  )
                : ListView(
                    children: [
                      for (final group in visibleGroups) ...[
                        _buildSectionHeader(group.key, group.value.length, theme),
                        for (final m in group.value) _buildMethodCard(m, theme),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
