import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// 1. MIND DUMP WORKSPACE (STICKY NOTES)
// ==========================================
class MindDumpWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const MindDumpWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<MindDumpWorkspace> createState() => _MindDumpWorkspaceState();
}

class _MindDumpWorkspaceState extends ConsumerState<MindDumpWorkspace> {
  final List<String> _notes = [];
  final TextEditingController _inputController = TextEditingController();

  final List<Color> _stickyColors = const [
    Color(0xFFFFF9C4), // Yellow
    Color(0xFFFFCDD2), // Pink
    Color(0xFFC8E6C9), // Green
    Color(0xFFB3E5FC), // Blue
    Color(0xFFD1C4E9), // Purple
  ];

  void _addNote() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _notes.add(text);
        _inputController.clear();
      });
      _notifyChanges();
    }
  }

  void _removeNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _notifyChanges();
  }

  void _editNote(int index) {
    final controller = TextEditingController(text: _notes[index]);
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DaojiText.resolve(
            DaojiTextKey.mindDumpEditTitle,
            vocabularyLevel,
            params: {'index': index + 1},
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: DaojiText.resolve(
              DaojiTextKey.mindDumpEditLabel,
              vocabularyLevel,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                setState(() => _notes[index] = v);
                _notifyChanges();
              }
              Navigator.pop(ctx);
            },
            child: Text(
              DaojiText.resolve(DaojiTextKey.systemSave, vocabularyLevel),
            ),
          ),
        ],
      ),
    );
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final buffer = StringBuffer();
    buffer.writeln(
      DaojiText.resolve(DaojiTextKey.mindDumpStickyHeader, vocabularyLevel),
    );
    for (int i = 0; i < _notes.length; i++) {
      buffer.writeln('- ${_notes[i]}');
    }
    widget.onChanged(buffer.toString());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.mindDumpTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.mindDumpAddLabel,
              vocabularyLevel,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.mindDumpHint,
              vocabularyLevel,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.mindDumpAddLabel,
                vocabularyLevel,
              ),
              onPressed: _addNote,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _addNote(),
        ),
        const SizedBox(height: 12),
        if (_notes.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.note_alt_outlined, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  DaojiText.resolve(
                    DaojiTextKey.mindDumpEmptyMessage,
                    vocabularyLevel,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final color = _stickyColors[index % _stickyColors.length];
              return GestureDetector(
                onTap: () => _editNote(index),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 3,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${index + 1}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeNote(index),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _notes[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ==========================================
// 2. AFFINITY MAPPING WORKSPACE
// ==========================================
class AffinityMappingWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const AffinityMappingWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<AffinityMappingWorkspace> createState() =>
      _AffinityMappingWorkspaceState();
}

class _AffinityMappingWorkspaceState
    extends ConsumerState<AffinityMappingWorkspace> {
  final List<Map<String, dynamic>> _items = [];
  final List<String> _groups = ['Grup A', 'Grup B', 'Grup C'];

  final TextEditingController _inputController = TextEditingController();

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add({'text': text, 'group': _groups[0]});
        _inputController.clear();
      });
      _notifyChanges();
    }
  }

  void _changeGroup(int index, String group) {
    setState(() {
      _items[index]['group'] = group;
    });
    _notifyChanges();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _notifyChanges();
  }

  void _renameGroup(int index) {
    final controller = TextEditingController(text: _groups[index]);
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          DaojiText.resolve(DaojiTextKey.affinityRenameGroup, vocabularyLevel),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: DaojiText.resolve(
              DaojiTextKey.mindDumpEditLabel,
              vocabularyLevel,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) {
                final old = _groups[index];
                setState(() {
                  _groups[index] = v;
                  for (final item in _items) {
                    if (item['group'] == old) item['group'] = v;
                  }
                });
                _notifyChanges();
              }
              Navigator.pop(ctx);
            },
            child: Text(
              DaojiText.resolve(DaojiTextKey.systemSave, vocabularyLevel),
            ),
          ),
        ],
      ),
    );
  }

  void _addGroup() {
    setState(() {
      _groups.add('Grup ${String.fromCharCode(65 + _groups.length)}');
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    final buffer = StringBuffer();
    buffer.writeln(
      DaojiText.resolve(DaojiTextKey.affinityGroupHeader, vocabularyLevel),
    );
    for (final group in _groups) {
      buffer.writeln('[$group]:');
      final matched = _items.where((item) => item['group'] == group).toList();
      if (matched.isEmpty) {
        buffer.writeln(
          '  ${DaojiText.resolve(DaojiTextKey.affinityGroupEmpty, vocabularyLevel)}',
        );
      } else {
        for (final item in matched) {
          buffer.writeln('  - ${item['text']}');
        }
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.affinityTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.affinityAddLabel,
              vocabularyLevel,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.affinityHint,
              vocabularyLevel,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              tooltip: DaojiText.resolve(
                DaojiTextKey.affinityAddLabel,
                vocabularyLevel,
              ),
              onPressed: _addItem,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _addItem(),
        ),
        const SizedBox(height: 12),
        // Group management row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _addGroup,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(
                DaojiText.resolve(
                  DaojiTextKey.affinityAddGroup,
                  vocabularyLevel,
                ),
                style: const TextStyle(fontSize: 11),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.label_outline_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  DaojiText.resolve(
                    DaojiTextKey.affinityEmptyMessage,
                    vocabularyLevel,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final activeGroup = item['group'] as String;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['text'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DropdownButton<String>(
                        value: activeGroup,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        underline: const SizedBox(),
                        items: [
                          ..._groups.map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          ),
                          DropdownMenuItem(
                            value: '__rename__',
                            child: Text(
                              DaojiText.resolve(
                                DaojiTextKey.affinityRenameOption,
                                vocabularyLevel,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == '__rename__') {
                            final gIdx = _groups.indexOf(activeGroup);
                            if (gIdx >= 0) _renameGroup(gIdx);
                          } else if (val != null) {
                            _changeGroup(index, val);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeItem(index),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ==========================================
// 3. FIVE WHYS WORKSPACE (WHY CHAIN)
// ==========================================
class FiveWhysWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const FiveWhysWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<FiveWhysWorkspace> createState() => _FiveWhysWorkspaceState();
}

class _FiveWhysWorkspaceState extends ConsumerState<FiveWhysWorkspace> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Rantai 5 Whys (Akar Masalah):');
    for (int i = 0; i < 5; i++) {
      buffer.writeln('Why ${i + 1}: ${_controllers[i].text.trim()}');
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.fiveWhysTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.1 + (index * 0.1),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (index < 4)
                    Container(
                      width: 2,
                      height: 40,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _controllers[index],
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: index == 0
                        ? DaojiText.resolve(
                            DaojiTextKey.fiveWhysFirstLabel,
                            vocabularyLevel,
                          )
                        : DaojiText.resolve(
                            DaojiTextKey.fiveWhysOtherLabel,
                            vocabularyLevel,
                          ),
                    hintText: DaojiText.resolve(
                      DaojiTextKey.fiveWhysHint,
                      vocabularyLevel,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return DaojiText.resolve(
                        DaojiTextKey.fiveWhysValidatorMessage,
                        vocabularyLevel,
                      );
                    }
                    return null;
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ==========================================
// 4. FIRST PRINCIPLES WORKSPACE (LADDER)
// ==========================================
class FirstPrinciplesWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const FirstPrinciplesWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<FirstPrinciplesWorkspace> createState() =>
      _FirstPrinciplesWorkspaceState();
}

class _FirstPrinciplesWorkspaceState
    extends ConsumerState<FirstPrinciplesWorkspace> {
  final List<TextEditingController> _controllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final List<DaojiTextKey> _steps = const [
    DaojiTextKey.firstPrinciplesStepOldAssumption,
    DaojiTextKey.firstPrinciplesStepFact,
    DaojiTextKey.firstPrinciplesStepConstruction,
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis First Principles (Dekonstruksi):');
    buffer.writeln('- ASUMSI LAMA: ${_controllers[0].text.trim()}');
    buffer.writeln('- FAKTA DASAR: ${_controllers[1].text.trim()}');
    buffer.writeln('- KONSTRUKSI BARU: ${_controllers[2].text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.firstPrinciplesTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          final isLast = index == 2;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLast
                  ? theme.colorScheme.primary.withValues(alpha: 0.04)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLast
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: isLast ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DaojiText.resolve(_steps[index], vocabularyLevel),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLast
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers[index],
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: DaojiText.resolve(
                      DaojiTextKey.firstPrinciplesHint,
                      vocabularyLevel,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return DaojiText.resolve(
                        DaojiTextKey.firstPrinciplesValidatorMessage,
                        vocabularyLevel,
                      );
                    }
                    return null;
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================
// 5. DOUBLE DIAMOND WORKSPACE
// ==========================================

class _DoubleDiamondPhaseDefinition {
  final DaojiTextKey title;
  final DaojiTextKey label;
  final DaojiTextKey hint;
  final String tabLabel;

  const _DoubleDiamondPhaseDefinition({
    required this.title,
    required this.label,
    required this.hint,
    required this.tabLabel,
  });
}

class DoubleDiamondWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const DoubleDiamondWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<DoubleDiamondWorkspace> createState() =>
      _DoubleDiamondWorkspaceState();
}

class _DoubleDiamondWorkspaceState
    extends ConsumerState<DoubleDiamondWorkspace> {
  int _activeTab = 0;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<_DoubleDiamondPhaseDefinition> _phases = const [
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDiscoverTitle,
      label: DaojiTextKey.doubleDiamondPhaseDiscoverLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDiscoverHint,
      tabLabel: 'Discover',
    ),
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDefineTitle,
      label: DaojiTextKey.doubleDiamondPhaseDefineLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDefineHint,
      tabLabel: 'Define',
    ),
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDevelopTitle,
      label: DaojiTextKey.doubleDiamondPhaseDevelopLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDevelopHint,
      tabLabel: 'Develop',
    ),
    _DoubleDiamondPhaseDefinition(
      title: DaojiTextKey.doubleDiamondPhaseDeliverTitle,
      label: DaojiTextKey.doubleDiamondPhaseDeliverLabel,
      hint: DaojiTextKey.doubleDiamondPhaseDeliverHint,
      tabLabel: 'Deliver',
    ),
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Proses Kerangka Kerja Double Diamond:');
    buffer.writeln('- DISCOVER: ${_controllers[0].text.trim()}');
    buffer.writeln('- DEFINE: ${_controllers[1].text.trim()}');
    buffer.writeln('- DEVELOP: ${_controllers[2].text.trim()}');
    buffer.writeln('- DELIVER: ${_controllers[3].text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final phase = _phases[_activeTab];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.doubleDiamondTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(4, (index) {
            final isActive = index == _activeTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    _phases[index].tabLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DaojiText.resolve(phase.title, vocabularyLevel)} — ${DaojiText.resolve(phase.label, vocabularyLevel)}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DaojiText.resolve(phase.hint, vocabularyLevel),
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[_activeTab],
          maxLines: 4,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.doubleDiamondNoteLabel,
              vocabularyLevel,
              params: {
                'phase': phase.tabLabel,
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return DaojiText.resolve(
                DaojiTextKey.doubleDiamondValidatorMessage,
                vocabularyLevel,
              );
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ==========================================
// 6. VALIDATION WORKSPACE (SCORECARD)
// ==========================================
class ValidationWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const ValidationWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<ValidationWorkspace> createState() =>
      _ValidationWorkspaceState();
}

class _ValidationWorkspaceState extends ConsumerState<ValidationWorkspace> {
  final TextEditingController _asumsiController = TextEditingController();
  final List<String> _supports = [];
  final List<String> _opposes = [];
  bool _isValidated = true;

  final TextEditingController _supportInput = TextEditingController();
  final TextEditingController _opposeInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _asumsiController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _asumsiController.removeListener(_notifyChanges);
    _asumsiController.dispose();
    _supportInput.dispose();
    _opposeInput.dispose();
    super.dispose();
  }

  void _addSupport() {
    final text = _supportInput.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _supports.add(text);
        _supportInput.clear();
      });
      _notifyChanges();
    }
  }

  void _addOppose() {
    final text = _opposeInput.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _opposes.add(text);
        _opposeInput.clear();
      });
      _notifyChanges();
    }
  }

  void _removeSupport(int index) {
    setState(() {
      _supports.removeAt(index);
    });
    _notifyChanges();
  }

  void _removeOppose(int index) {
    setState(() {
      _opposes.removeAt(index);
    });
    _notifyChanges();
  }

  void _toggleValidation(bool val) {
    setState(() {
      _isValidated = val;
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final buffer = StringBuffer();
    buffer.writeln('Lembar Validasi Asumsi Ide:');
    buffer.writeln('- ASUMSI UTAMA: ${_asumsiController.text.trim()}');
    buffer.writeln(
      '- STATUS VALIDASI: ${_isValidated ? "VALID (Terbukti) 🟢" : "GUGUR (Terbantahkan) 🔴"}',
    );
    buffer.writeln('- BUKTI PENDUKUNG (Supports):');
    if (_supports.isEmpty) {
      buffer.writeln('  (Tidak ada)');
    }
    for (final s in _supports) {
      buffer.writeln('  + $s');
    }
    buffer.writeln(
      '- ${DaojiText.resolve(DaojiTextKey.validationOpposeTitle, vocabularyLevel)} (Opposes):',
    );
    if (_opposes.isEmpty) {
      buffer.writeln(
        '  ${DaojiText.resolve(DaojiTextKey.validationNoOpposes, vocabularyLevel)}',
      );
    }
    for (final o in _opposes) {
      buffer.writeln('  - $o');
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DaojiText.resolve(DaojiTextKey.validationTitle, vocabularyLevel),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _asumsiController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.validationAssumptionLabel,
              vocabularyLevel,
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.validationAssumptionHint,
              vocabularyLevel,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isValidated
                ? Colors.green.withValues(alpha: 0.06)
                : Colors.red.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isValidated
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DaojiText.resolve(
                  DaojiTextKey.validationResultTitle,
                  vocabularyLevel,
                ),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isValidated ? Colors.green : Colors.red,
                ),
              ),
              Row(
                children: [
                  Text(
                    DaojiText.resolve(
                      _isValidated
                          ? DaojiTextKey.validationValidState
                          : DaojiTextKey.validationInvalidState,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isValidated,
                    onChanged: _toggleValidation,
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DaojiText.resolve(
                      DaojiTextKey.validationSupportTitle,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _supportInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      labelText: DaojiText.resolve(
                        DaojiTextKey.validationSupportInputLabel,
                        vocabularyLevel,
                      ),
                      hintText: DaojiText.resolve(
                        DaojiTextKey.validationSupportInputHint,
                        vocabularyLevel,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: _addSupport,
                        child: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                    ),
                    onSubmitted: (_) => _addSupport(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_supports.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.green.withValues(alpha: 0.03),
                      child: ListTile(
                        title: Text(
                          _supports[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                        trailing: GestureDetector(
                          onTap: () => _removeSupport(index),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DaojiText.resolve(
                      DaojiTextKey.validationOpposeTitle,
                      vocabularyLevel,
                    ),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _opposeInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      labelText: DaojiText.resolve(
                        DaojiTextKey.validationOpposeInputLabel,
                        vocabularyLevel,
                      ),
                      hintText: DaojiText.resolve(
                        DaojiTextKey.validationOpposeInputHint,
                        vocabularyLevel,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: _addOppose,
                        child: const Icon(
                          Icons.add_circle,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                    ),
                    onSubmitted: (_) => _addOppose(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_opposes.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.red.withValues(alpha: 0.03),
                      child: ListTile(
                        title: Text(
                          _opposes[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                        trailing: GestureDetector(
                          onTap: () => _removeOppose(index),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
