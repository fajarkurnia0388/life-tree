import 'package:flutter/material.dart';

// ==========================================
// 1. MIND DUMP WORKSPACE (STICKY NOTES)
// ==========================================
class MindDumpWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const MindDumpWorkspace({super.key, required this.onChanged});

  @override
  State<MindDumpWorkspace> createState() => _MindDumpWorkspaceState();
}

class _MindDumpWorkspaceState extends State<MindDumpWorkspace> {
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

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Hasil Kuras Pikiran (Mind Dump Sticky Notes):');
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Kuras Pikiran (Mind Dump Sticky Notes)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: 'Tambah Item',
            hintText: 'Ketik apa saja yang ada di kepala Anda lalu tekan Enter...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
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
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
            ),
            child: const Column(
              children: [
                Icon(Icons.note_alt_outlined, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Belum ada catatan tempel. Ketik sesuatu di atas untuk meluapkan isi kepala Anda!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
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
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${index + 1}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                        GestureDetector(
                          onTap: () => _removeNote(index),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _notes[index],
                          style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
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
class AffinityMappingWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const AffinityMappingWorkspace({super.key, required this.onChanged});

  @override
  State<AffinityMappingWorkspace> createState() => _AffinityMappingWorkspaceState();
}

class _AffinityMappingWorkspaceState extends State<AffinityMappingWorkspace> {
  final List<Map<String, dynamic>> _items = [];
  final List<String> _groups = const ['Grup A (Hijau)', 'Grup B (Biru)', 'Grup C (Orange)'];

  final TextEditingController _inputController = TextEditingController();

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _items.add({
          'text': text,
          'group': _groups[0],
        });
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

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Pengelompokan Affinity Mapping:');
    for (final group in _groups) {
      buffer.writeln('[$group]:');
      final matched = _items.where((item) => item['group'] == group).toList();
      if (matched.isEmpty) {
        buffer.writeln('  (Kosong)');
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Pengelompokan Affinity Mapping',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            labelText: 'Tambah Gagasan',
            hintText: 'Ketik gagasan/ide Anda lalu tekan Enter...',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: _addItem,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => _addItem(),
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
            ),
            child: const Column(
              children: [
                Icon(Icons.label_outline_rounded, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Belum ada ide. Tambahkan ide di atas lalu kelompokkan ke dalam grup!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item['text'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      DropdownButton<String>(
                        value: activeGroup,
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                        underline: const SizedBox(),
                        items: _groups.map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) _changeGroup(index, val);
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeItem(index),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
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
class FiveWhysWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const FiveWhysWorkspace({super.key, required this.onChanged});

  @override
  State<FiveWhysWorkspace> createState() => _FiveWhysWorkspaceState();
}

class _FiveWhysWorkspaceState extends State<FiveWhysWorkspace> {
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Rantai 5 Whys (Menelusuri Akar Masalah)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.1 + (index * 0.1)),
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.primary, width: 1.5),
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
                    labelText: index == 0 ? 'Mengapa masalah ini terjadi?' : 'Mengapa hal itu bisa terjadi?',
                    hintText: 'Tuliskan analisis sebab Anda...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Harap isi analisis sebab';
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
class FirstPrinciplesWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const FirstPrinciplesWorkspace({super.key, required this.onChanged});

  @override
  State<FirstPrinciplesWorkspace> createState() => _FirstPrinciplesWorkspaceState();
}

class _FirstPrinciplesWorkspaceState extends State<FirstPrinciplesWorkspace> {
  final List<TextEditingController> _controllers = List.generate(3, (_) => TextEditingController());
  final List<String> _steps = const [
    'Asumsi Lama (Bagaimana orang biasa melakukannya)',
    'Fakta Dasar (Kebenaran fisik/logika murni)',
    'Konstruksi Baru (Solusi orisinil yang dirancang dari nol)'
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Tangga Dekonstruksi First Principles',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          final isLast = index == 2;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLast ? theme.colorScheme.primary.withValues(alpha: 0.04) : theme.colorScheme.onSurface.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLast ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: isLast ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _steps[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLast ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers[index],
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan poin hasil pemikiran Anda...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
class DoubleDiamondWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const DoubleDiamondWorkspace({super.key, required this.onChanged});

  @override
  State<DoubleDiamondWorkspace> createState() => _DoubleDiamondWorkspaceState();
}

class _DoubleDiamondWorkspaceState extends State<DoubleDiamondWorkspace> {
  int _activeTab = 0;
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

  final List<Map<String, String>> _phases = const [
    {
      'title': '1. DISCOVER 🔍',
      'label': 'Divergen: Cari Wawasan',
      'hint': 'Tulis wawasan, riset lapangan, atau tren perilaku pengguna yang Anda temukan.',
    },
    {
      'title': '2. DEFINE 🎯',
      'label': 'Konvergen: Fokus Masalah',
      'hint': 'Rumuskan satu pernyataan masalah utama yang krusial untuk segera diselesaikan.',
    },
    {
      'title': '3. DEVELOP 💡',
      'label': 'Divergen: Eksplorasi Ide',
      'hint': 'Brainstorming berbagai alternatif solusi liar untuk memecahkan masalah utama.',
    },
    {
      'title': '4. DELIVER 🚀',
      'label': 'Konvergen: Eksekusi Solusi',
      'hint': 'Pilih satu solusi terbaik, buat prototipe kecil, dan rencanakan cara mengujinya.',
    },
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
    final phase = _phases[_activeTab];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Jalur Pipa Double Diamond',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    _phases[index]['title']!.split(' ')[1],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
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
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${phase['title']} — ${phase['label']}:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                phase['hint']!,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
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
            labelText: 'Catatan untuk Fase ${_phases[_activeTab]['title']!.split(' ')[1]}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Harap isi catatan untuk fase ini';
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
class ValidationWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const ValidationWorkspace({super.key, required this.onChanged});

  @override
  State<ValidationWorkspace> createState() => _ValidationWorkspaceState();
}

class _ValidationWorkspaceState extends State<ValidationWorkspace> {
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
    final buffer = StringBuffer();
    buffer.writeln('Lembar Validasi Asumsi Ide:');
    buffer.writeln('- ASUMSI UTAMA: ${_asumsiController.text.trim()}');
    buffer.writeln('- STATUS VALIDASI: ${_isValidated ? "VALID (Terbukti) 🟢" : "GUGUR (Terbantahkan) 🔴"}');
    buffer.writeln('- BUKTI PENDUKUNG (Supports):');
    if (_supports.isEmpty) buffer.writeln('  (Tidak ada)');
    for (final s in _supports) {
      buffer.writeln('  + $s');
    }
    buffer.writeln('- BUKTI PEMBANTAH (Opposes):');
    if (_opposes.isEmpty) buffer.writeln('  (Tidak ada)');
    for (final o in _opposes) {
      buffer.writeln('  - $o');
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Lembar Validasi & Verifikasi Asumsi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _asumsiController,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            labelText: 'Asumsi Utama yang Ingin Divalidasi',
            hintText: 'Misal: Pengguna bersedia membayar langganan bulanan...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Harap masukkan asumsi yang ingin divalidasi';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isValidated ? Colors.green.withValues(alpha: 0.06) : Colors.red.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isValidated ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hasil Akhir Hipotesis:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _isValidated ? Colors.green : Colors.red),
              ),
              Row(
                children: [
                  Text(
                    _isValidated ? 'VALID (Terbukti) 🟢' : 'GUGUR (Terbantah) 🔴',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                  const Text('Bukti Pendukung (+)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _supportInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      labelText: 'Bukti Pendukung',
                      hintText: 'Ketik bukti...',
                      suffixIcon: GestureDetector(
                        onTap: _addSupport,
                        child: const Icon(Icons.add_circle, color: Colors.green, size: 20),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                    onSubmitted: (_) => _addSupport(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_supports.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.green.withValues(alpha: 0.03),
                      child: ListTile(
                        title: Text(_supports[index], style: const TextStyle(fontSize: 10)),
                        trailing: GestureDetector(
                          onTap: () => _removeSupport(index),
                          child: const Icon(Icons.close_rounded, size: 12, color: Colors.redAccent),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
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
                  const Text('Bukti Pembantah (-)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _opposeInput,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      labelText: 'Bukti Pembantah',
                      hintText: 'Ketik bukti...',
                      suffixIcon: GestureDetector(
                        onTap: _addOppose,
                        child: const Icon(Icons.add_circle, color: Colors.red, size: 20),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                    onSubmitted: (_) => _addOppose(),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_opposes.length, (index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: Colors.red.withValues(alpha: 0.03),
                      child: ListTile(
                        title: Text(_opposes[index], style: const TextStyle(fontSize: 10)),
                        trailing: GestureDetector(
                          onTap: () => _removeOppose(index),
                          child: const Icon(Icons.close_rounded, size: 12, color: Colors.redAccent),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
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
