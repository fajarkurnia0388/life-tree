import 'package:flutter/material.dart';

// RESIDUAL: avoid "premium" in user copy — no paid tier is implemented.
class ThinkingCanvasOnboardingDialog extends StatefulWidget {
  final ValueChanged<String> onMethodSelected;
  final bool initialDontShowAgain;
  final ValueChanged<bool> onDontShowAgainChanged;

  const ThinkingCanvasOnboardingDialog({
    super.key,
    required this.onMethodSelected,
    required this.initialDontShowAgain,
    required this.onDontShowAgainChanged,
  });

  @override
  State<ThinkingCanvasOnboardingDialog> createState() =>
      _ThinkingCanvasOnboardingDialogState();
}

class _ThinkingCanvasOnboardingDialogState
    extends State<ThinkingCanvasOnboardingDialog> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  String _tempSelectedMethod = 'MindDump';
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _dontShowAgain = widget.initialDontShowAgain;
  }

  final List<Map<String, String>> _steps = [
    {
      'title': '1. Ambil Kertas Fisik 📝',
      'desc':
          'Prinsip Daoji adalah Paper-First. Jauhkan layar Anda sejenak. Ambillah buku catatan, pulpen, atau kertas coretan kosong.',
    },
    {
      'title': '2. Pilih Metode Berpikir 🧠',
      'desc':
          'Kami mendukung puluhan metode berpikir terpandu dengan panduan coretan kertas dan editor interaktif (seperti Mind Map, Slot Machine, Teratai Radial, dll) untuk memicu ide terbaik Anda.',
    },
    {
      'title': '3. Corat-Coret Tanpa Gangguan ✍️',
      'desc':
          'Ikuti rekomendasi format coretan kertas fisik di dalam aplikasi untuk melatih fokus kognitif, membebaskan imajinasi, dan mengurangi screen fatigue.',
    },
    {
      'title': '4. Ringkas & Lakukan Digitalisasi 💾',
      'desc':
          'Gunakan modul editor interaktif khusus bertema kami untuk mengabadikan intisari coretan Anda, mengacak kombinasi slot parameter, memetakan SWOT, atau memilih persona kognitif.',
    },
  ];

  Widget _buildInteractiveStateButton({
    required String label,
    required String methodKey,
    required ThemeData theme,
  }) {
    final isSelected = _tempSelectedMethod == methodKey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _tempSelectedMethod = methodKey;
          });
          widget.onMethodSelected(methodKey);
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          backgroundColor: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 320,
        height: 420,
        child: Column(
          children: [
            Text(
              'Panduan: Thinking Canvas 💡',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        step['title']!,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      if (index == 1) ...[
                        Text(
                          step['desc']!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Apa yang Anda rasakan saat ini?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 6),
                                const Text(
                                  'DIVERGEN (MEMBANGUN IDE)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildInteractiveStateButton(
                                  label: '🤯 Pikiran Penuh / Cemas (Mind Dump)',
                                  methodKey: 'MindDump',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🗺️ Petakan Hubungan Ide (Mind Map)',
                                  methodKey: 'MindMapping',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '⏱️ Tulis Cepat Tanpa Jeda (Freewriting)',
                                  methodKey: 'Freewriting',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '🎰 Kombinasi Unik Acak (Morphological)',
                                  methodKey: 'MorphologicalAnalysis',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '🌸 Mekarkan Cabang Ide (Lotus Blossom)',
                                  methodKey: 'LotusBlossom',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🚀 Brainstorming Kilat (Classic BS)',
                                  methodKey: 'Brainstorming',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '😈 Pikirkan Ide Terburuk (WPI)',
                                  methodKey: 'WorstPossibleIdea',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🔠 Modifikasi Ide Lama (SCAMPER)',
                                  methodKey: 'SCAMPER',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🔤 Butuh Kata Pemantik (Random Word)',
                                  methodKey: 'RandomWord',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '🎭 Pakai Kacamata Karakter (Role Storming)',
                                  methodKey: 'RoleStorming',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '⭐️ Butuh Pertanyaan Kunci (Starburst)',
                                  methodKey: 'Starbursting',
                                  theme: theme,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'KONVERGEN (MENGEVALUASI IDE)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildInteractiveStateButton(
                                  label: '⚖️ Timbang Plus/Minus (PMI)',
                                  methodKey: 'PMI',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '💡 Banyak Ide Bingung Pilih (Scoring)',
                                  methodKey: 'Scoring',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '🔍 Ingin Uji Asumsi Nyata (Validation)',
                                  methodKey: 'Validation',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '🧗 Buntu Cari Akar Solusi (Reverse BS)',
                                  methodKey: 'ReverseBrainstorming',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🔏 Cari Akar Penyebab (5 Whys)',
                                  methodKey: '5Whys',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '🛠️ Bongkar Asumsi Dasar (First Principles)',
                                  methodKey: 'FirstPrinciples',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '📊 Matriks SWOT Kuadran (SWOT)',
                                  methodKey: 'SWOT',
                                  theme: theme,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'SESI LENGKAP & EVALUASI',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildInteractiveStateButton(
                                  label:
                                      '🎩 Analisis 6 Topi Kognitif (Six Hats)',
                                  methodKey: 'SixThinkingHats',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label: '🏰 Uji Visi & Celah Rencana (Disney)',
                                  methodKey: 'DisneyStrategy',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '💎 Alur Desain Terpadu (Double Diamond)',
                                  methodKey: 'DoubleDiamond',
                                  theme: theme,
                                ),
                                _buildInteractiveStateButton(
                                  label:
                                      '🏷️ Kelompokkan Ide Sejenis (Affinity)',
                                  methodKey: 'AffinityMapping',
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          step['desc']!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _dontShowAgain,
                    onChanged: (val) {
                      setState(() {
                        _dontShowAgain = val ?? false;
                      });
                      widget.onDontShowAgainChanged(_dontShowAgain);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Jangan tampilkan panduan ini lagi',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Sebelumnya'),
                  )
                else
                  const SizedBox(width: 88),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _steps.length - 1) {
                      Navigator.pop(context);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(
                    _currentPage == _steps.length - 1 ? 'Mengerti' : 'Lanjut',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
