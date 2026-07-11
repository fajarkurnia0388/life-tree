import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/i18n/daoji_text_key.dart';
import '../../../../core/i18n/daoji_text_resolver.dart';
import '../../../../core/i18n/daoji_vocabulary_provider.dart';

// ==========================================
// SHARED: Step Progress Indicator
// ==========================================
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activeColor ?? theme.colorScheme.primary;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color
                    : isCurrent
                        ? color.withValues(alpha: 0.5)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ==========================================
// 1. SIX THINKING HATS WORKSPACE
// ==========================================
class SixThinkingHatsWorkspace extends ConsumerStatefulWidget {
  final ValueChanged<String> onChanged;
  const SixThinkingHatsWorkspace({super.key, required this.onChanged});

  @override
  ConsumerState<SixThinkingHatsWorkspace> createState() =>
      _SixThinkingHatsWorkspaceState();
}

class _SixThinkingHatsWorkspaceState
    extends ConsumerState<SixThinkingHatsWorkspace> {
  final List<Map<String, dynamic>> _hats = [
    {
      'color': Colors.white,
      'borderColor': Colors.black45,
      'textColor': Colors.black87,
      'name': 'Topi Putih',
      'label': 'Fakta & Data',
      'hint':
          'Informasi apa saja yang kita miliki? Data apa yang masih kurang?',
    },
    {
      'color': Colors.red,
      'borderColor': Colors.redAccent,
      'textColor': Colors.white,
      'name': 'Topi Merah',
      'label': 'Firasat & Emosi',
      'hint':
          'Bagaimana intuisi atau perasaan Anda melihat masalah ini tanpa logika?',
    },
    {
      'color': Colors.black,
      'borderColor': Colors.black,
      'textColor': Colors.white,
      'name': 'Topi Hitam',
      'label': 'Risiko & Kelemahan',
      'hint':
          'Mengapa ide ini bisa gagal? Apa saja risiko/hambatan terburuknya?',
    },
    {
      'color': Colors.amber,
      'borderColor': Colors.amber,
      'textColor': Colors.black87,
      'name': 'Topi Kuning',
      'label': 'Manfaat & Harapan',
      'hint':
          'Apa keuntungan dan nilai positif dari solusi ini? Mengapa ini berhasil?',
    },
    {
      'color': Colors.green,
      'borderColor': Colors.green,
      'textColor': Colors.white,
      'name': 'Topi Hijau',
      'label': 'Kreativitas & Opsi',
      'hint':
          'Opsi alternatif apa lagi yang belum kita coba? Pikirkan solusi liar!',
    },
    {
      'color': Colors.blue,
      'borderColor': Colors.blue,
      'textColor': Colors.white,
      'name': 'Topi Biru',
      'label': 'Kontrol Proses',
      'hint':
          'Apa kesimpulan akhir kita? Apa langkah selanjutnya yang harus diambil?',
    },
  ];

  int _selectedHatIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _hats.length; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Six Thinking Hats:');
    for (int i = 0; i < _hats.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln('- ${_hats[i]['name']} (${_hats[i]['label']}): $text');
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeHat = _hats[_selectedHatIndex];
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DaojiText.resolve(DaojiTextKey.sixThinkingHatsTitle, vocabularyLevel),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${_selectedHatIndex + 1}/6',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        StepProgressIndicator(
          currentStep: _selectedHatIndex,
          totalSteps: 6,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(_hats.length, (index) {
            final h = _hats[index];
            final isSelected = index == _selectedHatIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHatIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: h['color'] as Color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (h['borderColor'] as Color).withValues(alpha: 0.5),
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: Text(
                  h['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: h['textColor'] as Color,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: (activeHat['color'] as Color).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (activeHat['borderColor'] as Color).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${activeHat['name']} — ${activeHat['label']}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: activeHat['color'] == Colors.white
                      ? Colors.black87
                      : activeHat['color'] as Color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activeHat['hint'] as String,
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
          controller: _controllers[_selectedHatIndex],
          maxLines: 4,
          decoration: InputDecoration(
            labelText: DaojiText.resolve(
              DaojiTextKey.sixThinkingHatsNoteLabel,
              vocabularyLevel,
              params: {'name': activeHat['name']},
            ),
            hintText: DaojiText.resolve(
              DaojiTextKey.sixThinkingHatsNoteHint,
              vocabularyLevel,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return DaojiText.resolve(
                DaojiTextKey.sixThinkingHatsValidatorMessage,
                vocabularyLevel,
                params: {'name': activeHat['name']},
              );
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Navigation buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_selectedHatIndex > 0)
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedHatIndex--);
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  _hats[_selectedHatIndex - 1]['label'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            if (_selectedHatIndex < _hats.length - 1)
              FilledButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedHatIndex++);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(
                  _hats[_selectedHatIndex + 1]['label'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

// ==========================================
// 2. DISNEY STRATEGY WORKSPACE (THREE ROOMS)
// ==========================================
class DisneyStrategyWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const DisneyStrategyWorkspace({super.key, required this.onChanged});

  @override
  State<DisneyStrategyWorkspace> createState() =>
      _DisneyStrategyWorkspaceState();
}

class _DisneyStrategyWorkspaceState extends State<DisneyStrategyWorkspace> {
  int _activeRoomIndex = 0;

  final List<Map<String, String>> _rooms = const [
    {
      'title': '1. Ruang Dreamer ☁️',
      'tabLabel': 'Dreamer',
      'hint':
          'Tuliskan visi terbesar Anda tanpa batasan logistik atau finansial. Berimajinasilah!',
      'label': 'Visi Dreamer (Impian)',
      'gradientStart': '0xFF4F83CC',
      'gradientEnd': '0xFF96C0CE',
    },
    {
      'title': '2. Ruang Realist 🛠️',
      'tabLabel': 'Realist',
      'hint':
          'Bagaimana cara merealisasikan mimpi ini? Tulis rencana taktis dan langkah konkret.',
      'label': 'Langkah Realist (Rencana)',
      'gradientStart': '0xFF5C8D89',
      'gradientEnd': '0xFF8FB9A8',
    },
    {
      'title': '3. Ruang Critic 🔎',
      'tabLabel': 'Critic',
      'hint':
          'Temukan celah, risiko, dan kelemahan rencana ini secara kritis untuk memolesnya.',
      'label': 'Analisis Critic (Evaluasi)',
      'gradientStart': '0xFF7E8A97',
      'gradientEnd': '0xFFB2BEC3',
    },
  ];

  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Disney Strategy:');
    buffer.writeln('- DREAMER: ${_controllers[0]!.text.trim()}');
    buffer.writeln('- REALIST: ${_controllers[1]!.text.trim()}');
    buffer.writeln('- CRITIC: ${_controllers[2]!.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = _rooms[_activeRoomIndex];
    final colorStart = Color(int.parse(room['gradientStart']!));
    final colorEnd = Color(int.parse(room['gradientEnd']!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Lembar Kerja Disney Strategy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 6),
        StepProgressIndicator(
          currentStep: _activeRoomIndex,
          totalSteps: 3,
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (index) {
            final r = _rooms[index];
            final isActive = index == _activeRoomIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _activeRoomIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    r['tabLabel']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
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
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [colorStart, colorEnd]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                room['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                room['hint']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controllers[_activeRoomIndex],
          maxLines: 5,
          decoration: InputDecoration(
            labelText: room['label'],
            hintText: 'Tuliskan poin-poin ide Anda di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Harap tuliskan ide untuk ${room['label']}';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ==========================================
// 3. SCAMPER ACCORDION WORKSPACE
// ==========================================
class ScamperWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const ScamperWorkspace({super.key, required this.onChanged});

  @override
  State<ScamperWorkspace> createState() => _ScamperWorkspaceState();
}

class _ScamperWorkspaceState extends State<ScamperWorkspace> {
  final List<Map<String, String>> _panels = const [
    {
      'key': 'S',
      'name': 'Substitute (Substitusi)',
      'hint': 'Komponen, bahan, atau proses apa yang bisa kita ganti?',
    },
    {
      'key': 'C',
      'name': 'Combine (Kombinasi)',
      'hint':
          'Bagaimana cara menggabungkan ide ini dengan produk/layanan lain?',
    },
    {
      'key': 'A',
      'name': 'Adapt (Adaptasi)',
      'hint':
          'Bagaimana cara mengadaptasi ide sukses dari industri lain ke masalah ini?',
    },
    {
      'key': 'M',
      'name': 'Modify (Modifikasi)',
      'hint':
          'Apakah kita bisa mengubah bentuk, ukuran, atau kemasan menjadi lebih besar/kecil?',
    },
    {
      'key': 'P',
      'name': 'Put to another use',
      'hint':
          'Bagaimana jika ide ini digunakan untuk segmen pasar/tujuan yang berbeda?',
    },
    {
      'key': 'E',
      'name': 'Eliminate (Eliminasi)',
      'hint':
          'Bagian/fitur apa yang paling tidak penting dan bisa kita hilangkan saja?',
    },
    {
      'key': 'R',
      'name': 'Reverse (Pembalikan)',
      'hint':
          'Bagaimana jika kita membalik alur prosesnya dari belakang ke depan?',
    },
  ];

  int _expandedIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _panels.length; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Kerangka Kerja SCAMPER:');
    for (int i = 0; i < _panels.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln('- [${_panels[i]['key']}] ${_panels[i]['name']}: $text');
      }
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
          '4. Check-List Kreatif SCAMPER',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        ...List.generate(_panels.length, (index) {
          final p = _panels[index];
          final isExpanded = index == _expandedIndex;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isExpanded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                width: isExpanded ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        p['key']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isExpanded
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    p['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? -1 : index;
                    });
                  },
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          p['hint']!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _controllers[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Tulis ide SCAMPER Anda di sini...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Harap tuliskan ide untuk ${p['key']}';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
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
// 4. SWOT MATRIX WORKSPACE (2x2 GRID)
// ==========================================
class SwotMatrixWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const SwotMatrixWorkspace({super.key, required this.onChanged});

  @override
  State<SwotMatrixWorkspace> createState() => _SwotMatrixWorkspaceState();
}

class _SwotMatrixWorkspaceState extends State<SwotMatrixWorkspace> {
  final Map<String, TextEditingController> _controllers = {
    'S': TextEditingController(),
    'W': TextEditingController(),
    'O': TextEditingController(),
    'T': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _controllers.forEach((_, c) => c.addListener(_notifyChanges));
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.removeListener(_notifyChanges));
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Analisis Matriks SWOT:');
    buffer.writeln('- STRENGTHS (Kekuatan): ${_controllers['S']!.text.trim()}');
    buffer.writeln(
      '- WEAKNESSES (Kelemahan): ${_controllers['W']!.text.trim()}',
    );
    buffer.writeln(
      '- OPPORTUNITIES (Peluang): ${_controllers['O']!.text.trim()}',
    );
    buffer.writeln('- THREATS (Ancaman): ${_controllers['T']!.text.trim()}');
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Matriks SWOT (Kuadran 2x2)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            _buildSwotBox(
              'STRENGTHS (S)',
              _controllers['S']!,
              Colors.green,
              theme,
            ),
            _buildSwotBox(
              'WEAKNESSES (W)',
              _controllers['W']!,
              Colors.red,
              theme,
            ),
            _buildSwotBox(
              'OPPORTUNITIES (O)',
              _controllers['O']!,
              Colors.blue,
              theme,
            ),
            _buildSwotBox(
              'THREATS (T)',
              _controllers['T']!,
              Colors.orange,
              theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwotBox(
    String label,
    TextEditingController controller,
    Color accentColor,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(
                hintText: 'Tuliskan poin...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. STARBURSTING WORKSPACE (6-POINT STAR)
// ==========================================
class StarburstingWorkspace extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const StarburstingWorkspace({super.key, required this.onChanged});

  @override
  State<StarburstingWorkspace> createState() => _StarburstingWorkspaceState();
}

class _StarburstingWorkspaceState extends State<StarburstingWorkspace> {
  final List<Map<String, String>> _points = const [
    {
      'key': 'WHO',
      'question': 'Siapa target pengguna, pesaing, atau aktor kunci utama?',
    },
    {
      'key': 'WHAT',
      'question': 'Apa masalah inti, solusi alternatif, atau fiturnya?',
    },
    {
      'key': 'WHERE',
      'question': 'Di mana produk ini dipasarkan atau diimplementasikan?',
    },
    {
      'key': 'WHEN',
      'question': 'Kapan waktu rilis terbaik, deadline, atau batas peluncuran?',
    },
    {
      'key': 'WHY',
      'question': 'Mengapa ide ini harus dibuat? Apa nilai keunikannya?',
    },
    {
      'key': 'HOW',
      'question':
          'Bagaimana cara mendistribusikan, membiayai, atau mempromosikannya?',
    },
  ];

  int _selectedPointIndex = 0;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _points.length; i++) {
      _controllers[i] = TextEditingController();
      _controllers[i]!.addListener(_notifyChanges);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _notifyChanges() {
    final buffer = StringBuffer();
    buffer.writeln('Starbursting 5W1H Questions:');
    for (int i = 0; i < _points.length; i++) {
      final text = _controllers[i]!.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln(
          '- [${_points[i]['key']}] ${_points[i]['question']}: $text',
        );
      }
    }
    widget.onChanged(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePoint = _points[_selectedPointIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '4. Starbursting (Analisis 5W + 1H)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1.6,
          children: List.generate(_points.length, (index) {
            final p = _points[index];
            final isSelected = index == _selectedPointIndex;

            return GestureDetector(
              onTap: () => setState(() => _selectedPointIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    p['key']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
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
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fokus Pertanyaan ${activePoint['key']}:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activePoint['question']!,
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
          controller: _controllers[_selectedPointIndex],
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Ajukan Pertanyaan Kritis untuk ${activePoint['key']}',
            hintText: 'Tuliskan draf pertanyaan di sini...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Harap tuliskan pertanyaan untuk ${activePoint['key']}';
            }
            return null;
          },
        ),
      ],
    );
  }
}
